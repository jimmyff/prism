import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:prism/prism.dart';

class PaletteHtmlGenerator {
  static void generateGalleryHtml({
    required String className,
    required Map<String, RayScheme> schemesRgb,
    required Map<String, RayScheme> schemesOklch,
    required String cssClassName,
    Map<String, String>? aliases,
    required String outputPath,
  }) {
    final galleryBuffer = StringBuffer();

    // Generate CSS files first
    _generateCssFiles(
        className, cssClassName, schemesRgb, schemesOklch, outputPath);

    _writeHtmlHeader(galleryBuffer, className, cssClassName);
    _writePackageInfo(galleryBuffer);
    galleryBuffer.writeln('<div class="palette-container">');

    for (final entry in schemesRgb.entries) {
      final name = entry.key;
      final schemeRgb = entry.value;
      final schemeOklch = schemesOklch[name]!;

      _writeColorCard(
          galleryBuffer, name, schemeRgb, schemeOklch, cssClassName, aliases);
    }

    galleryBuffer.writeln('</div>');
    galleryBuffer.writeln('</body>');
    galleryBuffer.writeln('</html>');

    _writeHtmlFile(galleryBuffer.toString(), className, outputPath);
  }

  static void _generateCssFiles(
    String className,
    String cssClassName,
    Map<String, RayScheme> schemesRgb,
    Map<String, RayScheme> schemesOklch,
    String outputPath,
  ) {
    // Generate RGB CSS file
    final rgbCssBuffer = StringBuffer();
    rgbCssBuffer.writeln('/* Generated CSS for ${className}Rgb palette */');
    rgbCssBuffer.writeln('');

    for (final entry in schemesRgb.entries) {
      final name = entry.key.toLowerCase();
      final scheme = entry.value;

      for (final shadeEntry in scheme.shades.entries) {
        final shadeName = shadeEntry.key.name.replaceAll('shade', '');
        final ray = shadeEntry.value.ray.toRgb();
        final colorValue = 'rgb(${ray.red}, ${ray.green}, ${ray.blue})';

        // Generate bg-, text-, and border- classes
        rgbCssBuffer.writeln(
            '.bg-$cssClassName-$name-$shadeName { background-color: $colorValue; }');
        rgbCssBuffer.writeln(
            '.text-$cssClassName-$name-$shadeName { color: $colorValue; }');
        rgbCssBuffer.writeln(
            '.border-$cssClassName-$name-$shadeName { border-color: $colorValue; }');
        rgbCssBuffer.writeln('');
      }
    }

    // Generate Oklch CSS file
    final oklchCssBuffer = StringBuffer();
    oklchCssBuffer.writeln('/* Generated CSS for ${className}Oklch palette */');
    oklchCssBuffer.writeln('');

    for (final entry in schemesOklch.entries) {
      final name = entry.key.toLowerCase();
      final scheme = entry.value;

      for (final shadeEntry in scheme.shades.entries) {
        final shadeName = shadeEntry.key.name.replaceAll('shade', '');
        final ray = shadeEntry.value.ray.toOklch();
        final colorValue =
            'oklch(${(ray.l * 100).toStringAsFixed(1)}% ${ray.c.toStringAsFixed(3)} ${ray.h.toStringAsFixed(2)})';

        // Generate bg-, text-, and border- classes
        oklchCssBuffer.writeln(
            '.bg-$cssClassName-$name-$shadeName { background-color: $colorValue; }');
        oklchCssBuffer.writeln(
            '.text-$cssClassName-$name-$shadeName { color: $colorValue; }');
        oklchCssBuffer.writeln(
            '.border-$cssClassName-$name-$shadeName { border-color: $colorValue; }');
        oklchCssBuffer.writeln('');
      }
    }

    // Write CSS files

    Directory(outputPath).createSync(recursive: true);

    final rgbCssPath = p.join(outputPath, '${className}Rgb.css');
    final oklchCssPath = p.join(outputPath, '${className}Oklch.css');

    File(rgbCssPath).writeAsStringSync(rgbCssBuffer.toString());
    File(oklchCssPath).writeAsStringSync(oklchCssBuffer.toString());
  }

  static void _writeHtmlHeader(
      StringBuffer buffer, String className, String cssClassName) {
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('<title>Prism Palette Gallery - $className</title>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<link rel="stylesheet" href="${className}Rgb.css">');
    buffer.writeln('<link rel="stylesheet" href="${className}Oklch.css">');
    buffer.writeln('<style>');
    buffer.writeln(
        'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 20px; background: #f5f5f5; }');
    buffer.writeln('h1 { color: #333; margin-bottom: 30px; }');
    buffer.writeln(
        'h1 a { color: #2196F3; text-decoration: none; transition: all 0.2s ease; }');
    buffer
        .writeln('h1 a:hover { color: #1976D2; text-decoration: underline; }');
    buffer.writeln(
        '.palette-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 20px; }');
    buffer.writeln(
        '.color-card { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }');
    buffer.writeln(
        '.color-header { height: 60px; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px; }');
    buffer.writeln('.color-info { padding: 15px; }');
    buffer.writeln(
        '.color-name { font-size: 18px; font-weight: bold; margin-bottom: 10px; color: #333; }');
    buffer.writeln(
        '.luminance { font-size: 14px; color: #666; margin-bottom: 15px; }');
    buffer.writeln(
        '.color-spaces { display: flex; border-radius: 4px; overflow: hidden; }');
    buffer.writeln('.color-space-section { flex: 1; }');
    buffer.writeln(
        '.color-space-section h3 { margin: 0; padding: 8px; background: #f8f9fa; color: #333; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; text-align: center; border-bottom: 1px solid #dee2e6; }');
    buffer.writeln('.shades-column { display: flex; flex-direction: column; }');
    buffer.writeln(
        '.shade-item { height: 32px; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 500; position: relative; }');
    buffer.writeln(
        '.shade-name { font-size: 9px; font-weight: 600; margin-right: 4px; }');
    buffer.writeln('.shade-luminance { font-size: 8px; opacity: 0.8; }');
    buffer.writeln(
        '.hex-value { font-family: monospace; font-size: 12px; color: #888; }');
    buffer.writeln(
        '.package-info { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 30px; }');
    buffer.writeln('.package-info h2 { margin-top: 0; color: #333; }');
    buffer.writeln('.package-info p { margin: 10px 0; color: #666; }');
    buffer
        .writeln('.package-info a { color: #2196F3; text-decoration: none; }');
    buffer.writeln('.package-info a:hover { text-decoration: underline; }');
    buffer.writeln(
        '.package-links { display: flex; gap: 20px; margin-top: 15px; flex-wrap: wrap; }');
    buffer.writeln(
        '.package-link { padding: 12px 16px; border-radius: 4px; background: #f0f8ff; border: 1px solid #2196F3; flex: 1; min-width: 200px; }');
    buffer.writeln(
        '@media (max-width: 480px) { .package-links { flex-direction: column; gap: 10px; } .package-link { min-width: unset; } }');
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln(
        '<h1><a href="https://github.com/jimmyff/prism/tree/main/packages/prism/tools/palettes/gallery/">Palettes</a> → $className</h1>');
  }

  static void _writePackageInfo(StringBuffer buffer) {
    buffer.writeln('<div class="package-info">');
    buffer.writeln('<h2>About Prism 🌈</h2>');
    buffer.writeln(
        '<p>This palette is part of the <strong>Prism</strong> color manipulation library for Dart and Flutter. Prism provides comprehensive color operations, accessibility-focused color schemes, and extensive pre-built palettes.</p>');
    buffer.writeln('<div class="package-links">');
    buffer.writeln('<div class="package-link">');
    buffer.writeln('<strong>📦 Dart Package:</strong><br>');
    buffer.writeln(
        '<a href="https://pub.dev/packages/prism" target="_blank">pub.dev/packages/prism</a>');
    buffer.writeln('</div>');
    buffer.writeln('<div class="package-link">');
    buffer.writeln('<strong>🎯 Flutter Package:</strong><br>');
    buffer.writeln(
        '<a href="https://pub.dev/packages/prism_flutter" target="_blank">pub.dev/packages/prism_flutter</a>');
    buffer.writeln('</div>');
    buffer.writeln('</div>');
    buffer.writeln('</div>');
  }

  static void _writeColorCard(
    StringBuffer buffer,
    String name,
    RayScheme schemeRgb,
    RayScheme schemeOklch,
    String cssClassName,
    Map<String, String>? aliases,
  ) {
    // Check if this color has an alias
    final alias = aliases?.entries.firstWhere(
      (aliasEntry) => aliasEntry.value == name,
      orElse: () => const MapEntry('', ''),
    );
    final hasAlias = alias?.key.isNotEmpty == true;

    buffer.writeln('<div class="color-card">');

    // Main color header with onRay text
    final rayRgb = schemeRgb.source.ray.toRgb();
    buffer.writeln(
        '<div class="color-header" style="background-color: ${rayRgb.toHexStr()}; color: ${schemeRgb.source.onRay.toRgb().toHexStr()};">');
    if (hasAlias) {
      buffer.writeln('${alias?.key} / $name');
    } else {
      buffer.writeln(name);
    }
    buffer.writeln('</div>');

    buffer.writeln('<div class="color-info">');
    buffer.writeln('<div class="color-name">$name</div>');
    buffer.writeln(
        '<div class="luminance">Luminance: ${schemeRgb.source.luminance.toStringAsFixed(3)} (${schemeRgb.source.isDark ? 'Dark' : 'Light'})</div>');

    // Color space sections side by side
    buffer.writeln('<div class="color-spaces">');

    // RGB section
    buffer.writeln('<div class="color-space-section">');
    buffer.writeln('<h3>RGB</h3>');
    _writeShadesSection(buffer, schemeRgb, 'rgb', cssClassName, name);
    buffer.writeln('</div>');

    // Oklch section
    buffer.writeln('<div class="color-space-section">');
    buffer.writeln('<h3>Oklch</h3>');
    _writeShadesSection(buffer, schemeOklch, 'oklch', cssClassName, name);
    buffer.writeln('</div>');

    buffer.writeln('</div>'); // Close color-spaces
    buffer.writeln('</div>'); // Close color-info
    buffer.writeln('</div>'); // Close color-card
  }

  static void _writeShadesSection(StringBuffer buffer, RayScheme scheme,
      String colorSpace, String cssClassName, String schemeName) {
    buffer.writeln('<div class="shades-column">');

    for (final shade in Shade.values) {
      if (!scheme.shades.containsKey(shade)) {
        continue;
      }
      final rayLuminance = scheme.shades[shade]!;
      final ray = rayLuminance.ray;
      final luminance = rayLuminance.luminance;
      final textColor = luminance > 0.6 ? '#000' : '#fff';
      final shadeName = shade.name.replaceAll('shade', '');
      final lowerSchemeName = schemeName.toLowerCase();

      // Use CSS classes instead of inline styles
      final bgClass = 'bg-$cssClassName-$lowerSchemeName-$shadeName';

      buffer.writeln(
          '<div class="shade-item $bgClass" style="color: $textColor;">');
      buffer.writeln('<span class="shade-name">$shadeName</span>');
      buffer.writeln(
          '<span class="shade-luminance">L: ${luminance.toStringAsFixed(2)}</span>');
      buffer.writeln('</div>');
    }

    buffer.writeln('</div>');
  }

  static void _writeHtmlFile(
      String content, String className, String outputPath) {
    // Ensure gallery directory exists
    Directory(outputPath).createSync(recursive: true);

    final galleryOutputPath = p.join(outputPath, '$className.html');
    File(galleryOutputPath).writeAsStringSync(content);
  }
}
