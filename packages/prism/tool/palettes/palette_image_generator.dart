import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:prism/prism.dart';

img.ColorUint16 colorFromRay(RayRgb16 ray) => img.ColorUint16.rgba(
      ray.redNative,
      ray.greenNative,
      ray.blueNative,
      ray.alphaNative,
    );

final title = RayRgb8.fromComponentsNative(33, 33, 33).toRgb16();
final text = RayRgb8.fromComponentsNative(100, 100, 100).toRgb16();
final link = RayRgb8.fromComponentsNative(33, 150, 243).toRgb16();
final bg = RayRgb8.fromComponentsNative(255, 255, 255).toRgb16();

final border = RayRgb8.fromComponentsNative(220, 220, 220).toRgb16();

class PaletteImageGenerator {
  static const int imageWidth = 720;
  static const int columns = 4;
  static const int colorHeight = 64;
  static const int borderSpacing = 4;
  static const int headerHeight = 64;

  static void generatePaletteImage({
    required String className,
    required Map<String, Spectrum<RayWithLuminance>> schemes,
    required String outputPath,
    Map<String, String>? aliases,
    Map<String, RayWithLuminance>? fixedRaysOklch,
    Map<String, RayWithLuminance>? fixedRaysRgb,
  }) {
    // Calculate total number of colors including fixed rays
    final totalColors = schemes.length + (fixedRaysOklch?.length ?? 0);

    // Calculate cell dimensions accounting for borders and header
    final availableWidth = imageWidth - (borderSpacing * (columns + 1));
    final cellWidth = availableWidth ~/ columns;
    final rows = (totalColors / columns).ceil();
    final colorsHeight = rows * colorHeight + ((rows + 1) * borderSpacing);
    final imageHeight = headerHeight + colorsHeight;

    // Create image
    final image = img.Image(
        width: imageWidth,
        height: imageHeight,
        numChannels: 4,
        format: img.Format.uint16,
        // backgroundColor: colorFromRay(bg),
        paletteFormat: img.Format.uint16);

    // Draw header
    _drawHeader(image, className);

    int colorIndex = 0;

    // Draw spectrum color schemes
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

    // Draw fixed rays as regular color cells
    if (fixedRaysOklch != null && fixedRaysOklch.isNotEmpty) {
      for (final entry in fixedRaysOklch.entries) {
        final name = entry.key;
        final ray = entry.value;

        // Calculate position with border spacing and header offset
        final row = colorIndex ~/ columns;
        final col = colorIndex % columns;
        final x = borderSpacing + (col * (cellWidth + borderSpacing));
        final y = headerHeight +
            borderSpacing +
            (row * (colorHeight + borderSpacing));

        _drawFixedRayCell(
          image,
          x: x,
          y: y,
          width: cellWidth,
          height: colorHeight,
          ray: ray,
          name: name,
        );

        colorIndex++;
      }
    }

    // Save image
    final pngBytes = img.encodePng(image, level: 9);
    File(outputPath).writeAsBytesSync(pngBytes);
  }

  static void _drawHeader(img.Image image, String className) {
    // header background color
    img.fillRect(
      image,
      x1: 4,
      y1: 4,
      x2: imageWidth - 4,
      y2: headerHeight - 2,
      color: colorFromRay(bg),
    );
    img.drawRect(
      image,
      x1: 4,
      y1: 4,
      x2: imageWidth - 4,
      y2: headerHeight - 2,
      color: colorFromRay(border),
      thickness: 1.5,
    );

    // Draw palette name
    img.drawString(
      image,
      className,
      font: img.arial24,
      x: 12,
      y: 12,
      color: colorFromRay(title),
    );

    // Draw project info
    img.drawString(
      image,
      'Prism: A powerful color package for Dart & Flutter',
      font: img.arial14,
      rightJustify: true,
      x: imageWidth - 12,
      y: 42,
      color: colorFromRay(text),
    );

    // Draw project URL
    img.drawString(
      image,
      'https://github.com/jimmyff/prism/',
      font: img.arial14,
      x: 12,
      y: 42,
      color: colorFromRay(link),
    );
  }

  static void _drawColorCell(
    img.Image image, {
    required int x,
    required int y,
    required int width,
    required int height,
    required Ray ray,
    required Spectrum<RayWithLuminance> scheme,
    required String name,
    String? alias,
  }) {
    // Main color section (top 40px)
    final mainHeight = (height * 0.625).round(); // ~40px of 64px

    final rayRgb16 = ray.toRgb16();
    final mainColor = colorFromRay(rayRgb16);

    img.fillRect(
      image,
      x1: x,
      y1: y,
      x2: x + width - 1,
      y2: y + mainHeight - 1,
      color: mainColor,
    );

    // Draw text on main color
    final onRayRgb = scheme.source.onRay.toRgb16();
    final onRayColor = colorFromRay(onRayRgb);

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
    final tones = scheme.spectrum;
    final presentShades = tones.keys.toList();
    final shadeWidth =
        presentShades.isNotEmpty ? width ~/ presentShades.length : width;

    int i = 0;
    for (final shade in presentShades) {
      final rayLuminance = tones[shade]!;
      final shadeRgb8 = rayLuminance.toRgb16();
      final shadeColor = img.ColorUint16.rgba(shadeRgb8.redNative,
          shadeRgb8.greenNative, shadeRgb8.blueNative, shadeRgb8.alphaNative);

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

      i++;
    }

    // Draw border around cell using shade 4 (darker shade)
    final borderColor = scheme.tone(RayTone.shade400)!.toRgb16();
    img.drawRect(image,
        x1: x,
        y1: y,
        x2: x + width - 1,
        y2: y + height - 1,
        color: colorFromRay(borderColor),
        thickness: 1.5);
  }

  static void _drawFixedRayCell(
    img.Image image, {
    required int x,
    required int y,
    required int width,
    required int height,
    required RayWithLuminance ray,
    required String name,
  }) {
    // Main color section (top 40px) - same as spectrum colors
    final mainHeight = (height * 0.625).round(); // ~40px of 64px

    final rayRgb16 = ray.toRgb16();
    final mainColor = colorFromRay(rayRgb16);

    img.fillRect(
      image,
      x1: x,
      y1: y,
      x2: x + width - 1,
      y2: y + mainHeight - 1,
      color: mainColor,
    );

    // Draw text on main color
    final onRayColor = ray.isLight
        ? colorFromRay(RayRgb8.fromComponentsNative(0, 0, 0).toRgb16())
        : colorFromRay(RayRgb8.fromComponentsNative(255, 255, 255).toRgb16());

    final cellBorderColor =
        colorFromRay(ray.toOklch().withLightness(0.6).toRgb16());

    // Draw name
    img.drawString(
      image,
      name,
      font: img.arial14,
      x: x + 4,
      y: y + 4,
      color: onRayColor,
    );

    // Draw luminance
    img.drawString(
      image,
      "L${ray.luminance.toStringAsFixed(2)}",
      font: img.arial14,
      x: x + width - 4,
      rightJustify: true,
      y: y + 20,
      color: onRayColor,
    );

    // Bottom section - just show the same color (no spectrum tones)
    img.fillRect(
      image,
      x1: x,
      y1: y + mainHeight,
      x2: x + width - 1,
      y2: y + height - 1,
      color: mainColor,
    );

    // Draw border around cell
    img.drawRect(
      image,
      x1: x,
      y1: y,
      x2: x + width - 1,
      y2: y + height - 1,
      color: cellBorderColor,
      thickness: 1.5,
    );
  }
}
