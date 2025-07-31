import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:prism/prism.dart';

class PaletteImageGenerator {
  static const int imageWidth = 720;
  static const int columns = 4;
  static const int colorHeight = 64;
  static const int borderSpacing = 4;
  static const int headerHeight = 64;

  static void generatePaletteImage({
    required String className,
    required Map<String, RayScheme<RayWithLuminanceBase>> schemes,
    required String outputPath,
    Map<String, String>? aliases,
  }) {
    // Calculate cell dimensions accounting for borders and header
    final availableWidth = imageWidth - (borderSpacing * (columns + 1));
    final cellWidth = availableWidth ~/ columns;
    final rows = (schemes.length / columns).ceil();
    final colorsHeight = rows * colorHeight + ((rows + 1) * borderSpacing);
    final imageHeight = headerHeight + colorsHeight;

    // Create image
    final image = img.Image(width: imageWidth, height: imageHeight);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    // Draw header
    _drawHeader(image, className);

    int colorIndex = 0;
    for (final entry in schemes.entries) {
      final name = entry.key;
      final scheme = entry.value;
      final ray = scheme.source;

      // Calculate position with border spacing and header offset
      final row = colorIndex ~/ columns;
      final col = colorIndex % columns;
      final x = borderSpacing + (col * (cellWidth + borderSpacing));
      final y =
          headerHeight + borderSpacing + (row * (colorHeight + borderSpacing));

      // Check for alias
      final alias = aliases?.entries.firstWhere(
        (aliasEntry) => aliasEntry.value == name,
        orElse: () => const MapEntry('', ''),
      );
      final aliasName = alias?.key.isNotEmpty == true ? alias!.key : null;

      _drawColorCell(
        image,
        x: x,
        y: y,
        width: cellWidth,
        height: colorHeight,
        ray: ray,
        scheme: scheme,
        name: name,
        alias: aliasName,
      );

      colorIndex++;
    }

    // Save image
    final pngBytes = img.encodePng(image, level: 9);
    File(outputPath).writeAsBytesSync(pngBytes);
  }

  static void _drawHeader(img.Image image, String className) {
    // Draw palette name
    img.drawString(
      image,
      className,
      font: img.arial24,
      x: 16,
      y: 16,
      color: img.ColorRgb8(33, 33, 33),
    );

    // Draw project info
    img.drawString(
      image,
      'Prism: A powerful color package for Dart & Flutter',
      font: img.arial14,
      rightJustify: true,
      x: imageWidth - 16,
      y: 44,
      color: img.ColorRgb8(100, 100, 100),
    );

    // Draw project URL
    img.drawString(
      image,
      'https://github.com/jimmyff/prism/',
      font: img.arial14,
      x: 16,
      y: 44,
      color: img.ColorRgb8(33, 150, 243),
    );
  }

  static void _drawColorCell(
    img.Image image, {
    required int x,
    required int y,
    required int width,
    required int height,
    required Ray ray,
    required RayScheme<RayWithLuminanceBase> scheme,
    required String name,
    String? alias,
  }) {
    // Main color section (top 40px)
    final mainHeight = (height * 0.625).round(); // ~40px of 64px

    // Fill main color background
    final rayRgb = ray.toRgb();

    final mainColor = img.ColorRgb8(rayRgb.red, rayRgb.green, rayRgb.blue);
    img.fillRect(
      image,
      x1: x,
      y1: y,
      x2: x + width - 1,
      y2: y + mainHeight - 1,
      color: mainColor,
    );

    // Draw text on main color
    final onRayRgb = scheme.source.onRay.toRgb();
    final onRayColor = img.ColorRgb8(
      onRayRgb.red,
      onRayRgb.green,
      onRayRgb.blue,
    );

    // Draw name (always the correct color name)
    img.drawString(
      image,
      name,
      font: img.arial14,
      x: x + 4,
      y: y + 4,
      color: onRayColor,
    );

    // Draw alias below if it exists
    if (alias != null) {
      img.drawString(
        image,
        alias,
        font: img.arial14,
        x: x + 4,
        y: y + 20,
        color: onRayColor,
      );
    }

    // luminance
    img.drawString(
      image,
      "L${scheme.source.luminance.toStringAsFixed(2)}",
      font: img.arial14,
      x: x + width - 4,
      rightJustify: true,
      y: y + 20,
      color: onRayColor,
    );

    // Only show present tones along the bottom
    final tones = scheme.tones;
    final presentShades = tones.keys.toList();
    final shadeWidth =
        presentShades.isNotEmpty ? width ~/ presentShades.length : width;

    int i = 0;
    for (final shade in presentShades) {
      final rayLuminance = tones[shade]!;
      final shadeRgb = rayLuminance.toRgb();
      final shadeColor = img.ColorRgb8(
        shadeRgb.red,
        shadeRgb.green,
        shadeRgb.blue,
      );

      final shadeX = x + (i * shadeWidth);
      final shadeWidthActual = (i == presentShades.length - 1)
          ? width - (i * shadeWidth)
          : shadeWidth; // Last shade fills remaining space

      img.fillRect(
        image,
        x1: shadeX,
        y1: y + mainHeight,
        x2: shadeX + shadeWidthActual - 1,
        y2: y + height - 1,
        color: shadeColor,
      );

      // Currently not used
      // Choose text color based on shade luminance
      // final luminance = rayLuminance.luminance;
      // final textColor = luminance < 0.4
      //     ? img.ColorRgb8(255, 255, 255) // White on dark shades
      //     : img.ColorRgb8(0, 0, 0); // Black on light shades

      // // Draw simple asterisk to save space
      // img.drawString(
      //   image,
      //   '*',
      //   font: img.arial14,
      //   x: shadeX + (shadeWidthActual ~/ 2) - 4, // Center the asterisk
      //   y: y + mainHeight + 4,
      //   color: textColor,
      // );

      i++;
    }

    // Draw border around cell using shade 4 (darker shade)
    final borderRgb = scheme.shade400!.toRgb();
    img.drawRect(
      image,
      x1: x,
      y1: y,
      x2: x + width - 1,
      y2: y + height - 1,
      color: img.ColorRgb8(
        borderRgb.red,
        borderRgb.green,
        borderRgb.blue,
      ),
    );
  }
}
