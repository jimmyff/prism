import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:prism/prism.dart';

class PaletteHtmlGenerator {
  static void generateGalleryHtml({
    required String className,
    required Map<String, RayScheme<RayWithLuminanceBase>> schemesRgb,
    required Map<String, RayScheme<RayWithLuminanceBase>> schemesOklch,
    required String cssClassName,
    Map<String, String>? aliases,
    required String outputPath,
  }) {
    final galleryBuffer = StringBuffer();

    // Generate both RGB and Oklch CSS files
    _generateCssFiles(
        className, cssClassName, schemesRgb, schemesOklch, outputPath);

    _writeHtmlHeader(galleryBuffer, className);
    _writePackageInfo(galleryBuffer);
    galleryBuffer.writeln('<div class="palette-container">');

    // Only use Oklch schemes for HTML display
    for (final entry in schemesOklch.entries) {
      final name = entry.key;
      final scheme = entry.value;

      _writeColorCard(galleryBuffer, name, scheme, aliases);
    }

    galleryBuffer.writeln('</div>');
    galleryBuffer.writeln('</body>');
    galleryBuffer.writeln('</html>');

    _writeHtmlFile(galleryBuffer.toString(), className, outputPath);
  }

  static void _generateCssFiles(
    String className,
    String cssClassName,
    Map<String, RayScheme<RayWithLuminanceBase>> schemesRgb,
    Map<String, RayScheme<RayWithLuminanceBase>> schemesOklch,
    String outputPath,
  ) {
    // Generate RGB CSS file
    final rgbCssBuffer = StringBuffer();
    _writeCssHeader(rgbCssBuffer, className, 'RGB');
    _writeCssVariables(rgbCssBuffer, schemesRgb, 'rgb');
    _writeCssUtilities(rgbCssBuffer, schemesRgb);

    // Generate Oklch CSS file
    final oklchCssBuffer = StringBuffer();
    _writeCssHeader(oklchCssBuffer, className, 'Oklch');
    _writeCssVariables(oklchCssBuffer, schemesOklch, 'oklch');
    _writeCssUtilities(oklchCssBuffer, schemesOklch);

    // Write CSS files
    Directory(outputPath).createSync(recursive: true);

    final rgbCssPath = p.join(outputPath, '${className}Rgb.css');
    final oklchCssPath = p.join(outputPath, '${className}Oklch.css');

    File(rgbCssPath).writeAsStringSync(rgbCssBuffer.toString());
    File(oklchCssPath).writeAsStringSync(oklchCssBuffer.toString());
  }

  static void _writeCssHeader(
      StringBuffer buffer, String className, String colorSpace) {
    final now = DateTime.now().toIso8601String();
    buffer.writeln('/*!');
    buffer.writeln(' * $className $colorSpace Palette');
    buffer.writeln(' * Generated by Prism Color Library');
    buffer.writeln(' * https://pub.dev/packages/prism');
    buffer.writeln(' * ');
    buffer.writeln(' * Generated: $now');
    buffer.writeln(' * ');
    buffer.writeln(' * This file is auto-generated. Do not edit manually.');
    buffer.writeln(
        ' * To regenerate: dart run packages/prism/tool/palettes/build_gallery.dart');
    buffer.writeln(' * ');
    buffer.writeln(' * Usage:');
    buffer.writeln(' * - Background: .bg-red-500');
    buffer.writeln(' * - Text: .text-blue-300');
    buffer.writeln(' * - Border: .border-green-700');
    buffer.writeln(' * - Custom: background-color: var(--red-500);');
    buffer.writeln(' * ');
    buffer.writeln(
        ' * Modular sections below - remove unused sections as needed');
    buffer.writeln(' */');
    buffer.writeln('');
  }

  static void _writeCssVariables(
    StringBuffer buffer,
    Map<String, RayScheme<RayWithLuminanceBase>> schemes,
    String colorSpace,
  ) {
    buffer.writeln(
        '/* ==========================================================================');
    buffer.writeln('   CSS Custom Properties (Variables)');
    buffer.writeln(
        '   ========================================================================== */');
    buffer.writeln('');
    buffer.writeln(':root {');

    for (final entry in schemes.entries) {
      final name = entry.key.toLowerCase();
      final scheme = entry.value;

      buffer.writeln('  /* $name */');
      for (final toneEntry in scheme.tones.entries) {
        final toneName = toneEntry.key.name.replaceAll('shade', '');
        final colorValue = colorSpace == 'rgb'
            ? 'rgb(${toneEntry.value.toRgb().red}, ${toneEntry.value.toRgb().green}, ${toneEntry.value.toRgb().blue})'
            : 'oklch(${(toneEntry.value.toOklch().l * 100).toStringAsFixed(1)}% ${toneEntry.value.toOklch().c.toStringAsFixed(3)} ${toneEntry.value.toOklch().h.toStringAsFixed(2)})';

        buffer.writeln('  --$name-$toneName: $colorValue;');
      }
      buffer.writeln('');
    }

    buffer.writeln('}');
    buffer.writeln('');
  }

  static void _writeCssUtilities(
    StringBuffer buffer,
    Map<String, RayScheme<RayWithLuminanceBase>> schemes,
  ) {
    // Background utilities
    buffer.writeln(
        '/* ==========================================================================');
    buffer.writeln('   Background Utilities');
    buffer.writeln(
        '   ========================================================================== */');
    buffer.writeln('');

    for (final entry in schemes.entries) {
      final name = entry.key.toLowerCase();
      final scheme = entry.value;

      for (final toneEntry in scheme.tones.entries) {
        final toneName = toneEntry.key.name.replaceAll('shade', '');
        buffer.writeln(
            '.bg-$name-$toneName { background-color: var(--$name-$toneName); }');
      }
    }
    buffer.writeln('');

    // Text utilities
    buffer.writeln(
        '/* ==========================================================================');
    buffer.writeln('   Text Utilities');
    buffer.writeln(
        '   ========================================================================== */');
    buffer.writeln('');

    for (final entry in schemes.entries) {
      final name = entry.key.toLowerCase();
      final scheme = entry.value;

      for (final toneEntry in scheme.tones.entries) {
        final toneName = toneEntry.key.name.replaceAll('shade', '');
        buffer.writeln(
            '.text-$name-$toneName { color: var(--$name-$toneName); }');
      }
    }
    buffer.writeln('');

    // Border utilities
    buffer.writeln(
        '/* ==========================================================================');
    buffer.writeln('   Border Utilities');
    buffer.writeln(
        '   ========================================================================== */');
    buffer.writeln('');

    for (final entry in schemes.entries) {
      final name = entry.key.toLowerCase();
      final scheme = entry.value;

      for (final toneEntry in scheme.tones.entries) {
        final toneName = toneEntry.key.name.replaceAll('shade', '');
        buffer.writeln(
            '.border-$name-$toneName { border-color: var(--$name-$toneName); }');
      }
    }
    buffer.writeln('');
  }

  static void _writeHtmlHeader(StringBuffer buffer, String className) {
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('<title>Prism Palette Gallery - $className</title>');
    buffer.writeln('<meta charset="utf-8">');
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
        '.palette-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }');
    buffer.writeln(
        '.color-card { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }');
    buffer.writeln(
        '.color-header { height: 60px; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px; }');
    buffer.writeln('.color-info {  }');
    buffer.writeln(
        '.luminance-value { font-weight: 300; opacity: 0.8; padding-left:4px; }');
    buffer.writeln(
        '.shades-column { display: flex; flex-direction: column; border-radius: 4px; overflow: hidden; }');
    buffer.writeln(
        '.shade-item { height: 32px; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 500; position: relative; }');
    buffer.writeln(
        '.shade-name { font-size: 9px; font-weight: 600; margin-right: 4px; }');
    buffer.writeln('.shade-luminance { font-size: 8px; opacity: 0.8; }');
    buffer.writeln('.luminance-value { font-weight: 300; opacity: 0.8; }');
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
        '<h1><a href="https://github.com/jimmyff/prism/tree/main/palette_gallery">Palettes</a> → $className</h1>');
  }

  static void _writePackageInfo(StringBuffer buffer) {
    buffer.writeln('<div class="package-info">');
    buffer.writeln('<h2>About Prism 🌈</h2>');
    buffer.writeln(
        '<p>Comprehensive color library for Dart and Flutter with accessibility-focused schemes and pre-built palettes.</p>');
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
    RayScheme<RayWithLuminanceBase> scheme,
    Map<String, String>? aliases,
  ) {
    // Check if this color has an alias
    final alias = aliases?.entries.firstWhere(
      (aliasEntry) => aliasEntry.value == name,
      orElse: () => const MapEntry('', ''),
    );
    final hasAlias = alias?.key.isNotEmpty == true;

    buffer.writeln('<div class="color-card">');

    // Main color header with onRay text and luminance
    final rayRgb8 = scheme.source.toRgb();
    final luminanceValue = scheme.source.luminance.toStringAsFixed(2);
    buffer.writeln(
        '<div class="color-header" style="background-color: ${rayRgb8.toHexStr()}; color: ${scheme.source.onRay.toHexStr()};">');
    if (hasAlias) {
      buffer.writeln(
          '${alias?.key} / $name<span class="luminance-value">(L:$luminanceValue</span>');
    } else {
      buffer.writeln(
          '$name <span class="luminance-value">(L:$luminanceValue)</span>');
    }
    buffer.writeln('</div>');

    buffer.writeln('<div class="color-info">');

    // Only show Oklch color column
    _writeShadesSection(buffer, scheme, 'oklch', name);

    buffer.writeln('</div>'); // Close color-info
    buffer.writeln('</div>'); // Close color-card
  }

  static void _writeShadesSection(
      StringBuffer buffer,
      RayScheme<RayWithLuminanceBase> scheme,
      String colorSpace,
      String schemeName) {
    buffer.writeln('<div class="shades-column">');

    for (final tone in RayTone.values) {
      if (!scheme.tones.containsKey(tone)) {
        continue;
      }
      final rayLuminance = scheme.tones[tone]!;
      final textColor = rayLuminance.isLight ? '#000' : '#fff';
      final toneName = tone.name.replaceAll('shade', '');
      final lowerSchemeName = schemeName.toLowerCase();

      // Use simplified CSS classes without cssClassName
      final bgClass = 'bg-$lowerSchemeName-$toneName';

      buffer.writeln(
          '<div class="shade-item $bgClass" style="color: $textColor;">');
      buffer.writeln('<span class="shade-name">$toneName</span>');
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
