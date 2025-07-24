import 'dart:io';
import 'package:path/path.dart' as p;

// Import your actual library classes to use their logic.
// The relative path is crucial here.
import 'package:prism/prism.dart';

// Import the source data maps.
import 'sources/css.dart';
import 'sources/material.dart';
import 'sources/open_color.dart';
import 'sources/catppuccin.dart';
import 'sources/solarized.dart';

void main() {
  print('Generating palettes...');

  // Define all the palettes you want to build.
  _generatePalette(
    className: 'CssPalette',
    data: cssColors,
    outputFileName: 'css.dart',
  );

  _generatePalette(
    className: 'MaterialPalette',
    data: materialColors,
    outputFileName: 'material.dart',
    aliases: materialColorsAliases,
  );

  _generatePalette(
    className: 'OpenColorPalette',
    data: openColors,
    outputFileName: 'open_color.dart',
    aliases: openColorAliases,
  );

  _generatePalette(
    className: 'CatppuccinLattePalette',
    data: catppuccinLatteColors,
    outputFileName: 'catppuccin_latte.dart',
  );

  _generatePalette(
    className: 'CatppuccinFrappePalette',
    data: catppuccinFrappeColors,
    outputFileName: 'catppuccin_frappe.dart',
  );

  _generatePalette(
    className: 'CatppuccinMacchiatoPalette',
    data: catppuccinMacchiatoColors,
    outputFileName: 'catppuccin_macchiato.dart',
  );

  _generatePalette(
    className: 'CatppuccinMochaPalette',
    data: catppuccinMochaColors,
    outputFileName: 'catppuccin_mocha.dart',
  );

  _generatePalette(
    className: 'SolarizedPalette',
    data: solarizedColors,
    outputFileName: 'solarized.dart',
  );

  print('Palettes generated successfully!');
}

/// Generates a single palette file.
void _generatePalette({
  required String className,
  required Map<String, String> data,
  required String outputFileName,
  Map<String, String>? aliases,
}) {
  final buffer = StringBuffer();

  // 1. Write the file header
  buffer.writeln('// GENERATED CODE - DO NOT EDIT BY HAND');
  buffer.writeln('// ignore_for_file: public_member_api_docs');
  buffer.writeln("import 'package:prism/prism.dart';");
  buffer.writeln('');
  buffer.writeln('/// An enhanced enum for the $className palette.');
  buffer.writeln('enum $className {');

  // 2. Iterate through the source data and generate enum values
  for (final entry in data.entries) {
    final name = entry.key;
    final hex = entry.value;

    // Use your library's logic to pre-compute the profile
    final ray =
        RayRgb.fromHex(hex); // Assuming fromHex exists and is const-friendly
    final profile = RayScheme<RayRgb>.fromRay(ray);

    // 3. Write the pre-computed const values directly into the code
    buffer.writeln('  $name(RayScheme(');
    buffer.writeln(
        '    ray: RayRgb.fromIntARGB(0x${ray.toIntARGB().toRadixString(16).toUpperCase()}),');
    buffer.writeln('    luminance: ${profile.luminance},');
    buffer.writeln('    isDark: ${profile.isDark},');
    buffer.writeln(
        '    onRay: RayRgb.fromIntARGB(0x${profile.onRay.toIntARGB().toRadixString(16).toUpperCase()}),');
    buffer.writeln(
        '    surfaceDark: RayRgb.fromIntARGB(0x${profile.surfaceDark.toIntARGB().toRadixString(16).toUpperCase()}),');
    buffer.writeln(
        '    surfaceLight: RayRgb.fromIntARGB(0x${profile.surfaceLight.toIntARGB().toRadixString(16).toUpperCase()}),');
    buffer.writeln('  )),');
  }

  // 4. Write the enum footer
  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The pre-computed profile for this color.');
  buffer.writeln('  final RayScheme scheme;');
  buffer.writeln('');
  buffer.writeln('  const $className(this.scheme);');

  // Add getter methods for aliases if they exist
  if (aliases != null && aliases.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('  // Convenience getters for common color aliases');
    for (final alias in aliases.entries) {
      final aliasName = alias.key;
      final targetName = alias.value;
      buffer.writeln('  /// Getter for $aliasName (returns $targetName)');
      buffer.writeln(
          '  static RayScheme get $aliasName => $className.$targetName.scheme;');
    }
  }

  buffer.writeln('}');

  // 5. Write the file to the lib/palettes directory
  final outputPath = p.join('lib', 'palettes', outputFileName);
  File(outputPath).writeAsStringSync(buffer.toString());

  // generate gallery html file
  final galleryBuffer = StringBuffer();
  galleryBuffer.writeln('<!DOCTYPE html>');
  galleryBuffer.writeln('<html>');
  galleryBuffer.writeln('<head>');
  galleryBuffer.writeln('<title>Prism Palette Gallery - $className</title>');
  galleryBuffer.writeln('<meta charset="utf-8">');
  galleryBuffer.writeln('<style>');
  galleryBuffer.writeln(
      'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 20px; background: #f5f5f5; }');
  galleryBuffer.writeln('h1 { color: #333; margin-bottom: 30px; }');
  galleryBuffer.writeln(
      'h1 a { color: #2196F3; text-decoration: none; transition: all 0.2s ease; }');
  galleryBuffer
      .writeln('h1 a:hover { color: #1976D2; text-decoration: underline; }');
  galleryBuffer.writeln(
      '.palette-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }');
  galleryBuffer.writeln(
      '.color-card { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }');
  galleryBuffer.writeln(
      '.color-header { height: 60px; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px; }');
  galleryBuffer.writeln('.color-info { padding: 15px; }');
  galleryBuffer.writeln(
      '.color-name { font-size: 18px; font-weight: bold; margin-bottom: 10px; color: #333; }');
  galleryBuffer.writeln(
      '.luminance { font-size: 14px; color: #666; margin-bottom: 15px; }');
  galleryBuffer.writeln(
      '.text-demo { margin-bottom: 12px; padding: 8px; border-radius: 4px; font-size: 14px; }');
  galleryBuffer.writeln(
      '.text-demo span { display: inline-block; margin-right: 10px; }');
  galleryBuffer.writeln('.text-weight-300 { font-weight: 300; }');
  galleryBuffer.writeln('.text-weight-400 { font-weight: 400; }');
  galleryBuffer.writeln('.text-weight-500 { font-weight: 500; }');
  galleryBuffer.writeln('.text-weight-600 { font-weight: 600; }');
  galleryBuffer.writeln('.text-weight-700 { font-weight: 700; }');
  galleryBuffer.writeln('.surface-demos { display: flex; gap: 10px; }');
  galleryBuffer.writeln(
      '.surface-demo { flex: 1; padding: 8px; border-radius: 4px; text-align: center; font-size: 12px; }');
  galleryBuffer.writeln(
      '.hex-value { font-family: monospace; font-size: 12px; color: #888; }');
  galleryBuffer.writeln(
      '.package-info { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 30px; }');
  galleryBuffer.writeln('.package-info h2 { margin-top: 0; color: #333; }');
  galleryBuffer.writeln('.package-info p { margin: 10px 0; color: #666; }');
  galleryBuffer
      .writeln('.package-info a { color: #2196F3; text-decoration: none; }');
  galleryBuffer
      .writeln('.package-info a:hover { text-decoration: underline; }');
  galleryBuffer.writeln(
      '.package-links { display: flex; gap: 20px; margin-top: 15px; flex-wrap: wrap; }');
  galleryBuffer.writeln(
      '.package-link { padding: 12px 16px; border-radius: 4px; background: #f0f8ff; border: 1px solid #2196F3; flex: 1; min-width: 200px; }');
  galleryBuffer.writeln(
      '@media (max-width: 480px) { .package-links { flex-direction: column; gap: 10px; } .package-link { min-width: unset; } }');
  galleryBuffer.writeln('</style>');
  galleryBuffer.writeln('</head>');
  galleryBuffer.writeln('<body>');
  galleryBuffer.writeln(
      '<h1><a href="https://github.com/jimmyff/prism/tree/main/packages/prism/tools/palettes/gallery/">Palettes</a> → $className</h1>');

  // Add package information section
  galleryBuffer.writeln('<div class="package-info">');
  galleryBuffer.writeln('<h2>About Prism 🌈</h2>');
  galleryBuffer.writeln(
      '<p>This palette is part of the <strong>Prism</strong> color manipulation library for Dart and Flutter. Prism provides comprehensive color operations, accessibility-focused color schemes, and extensive pre-built palettes.</p>');
  galleryBuffer.writeln('<div class="package-links">');
  galleryBuffer.writeln('<div class="package-link">');
  galleryBuffer.writeln('<strong>📦 Dart Package:</strong><br>');
  galleryBuffer.writeln(
      '<a href="https://pub.dev/packages/prism" target="_blank">pub.dev/packages/prism</a>');
  galleryBuffer.writeln('</div>');
  galleryBuffer.writeln('<div class="package-link">');
  galleryBuffer.writeln('<strong>🎯 Flutter Package:</strong><br>');
  galleryBuffer.writeln(
      '<a href="https://pub.dev/packages/prism_flutter" target="_blank">pub.dev/packages/prism_flutter</a>');
  galleryBuffer.writeln('</div>');
  galleryBuffer.writeln('</div>');
  galleryBuffer.writeln('</div>');

  galleryBuffer.writeln('<div class="palette-container">');

  for (final entry in data.entries) {
    final name = entry.key;
    final hex = entry.value;
    final ray = RayRgb.fromHex(hex);
    final profile = RayScheme.fromRay(ray);

    // Check if this color has an alias
    final alias = aliases?.entries.firstWhere(
      (aliasEntry) => aliasEntry.value == name,
      orElse: () => const MapEntry('', ''),
    );
    final hasAlias = alias?.key.isNotEmpty == true;

    galleryBuffer.writeln('<div class="color-card">');

    // Main color header with onRay text
    galleryBuffer.writeln(
        '<div class="color-header" style="background-color: ${ray.toHex()}; color: ${profile.onRay.toHex()};">');
    if (hasAlias) {
      galleryBuffer.writeln('${alias?.key} / $name');
    } else {
      galleryBuffer.writeln(name);
    }
    galleryBuffer.writeln('</div>');

    galleryBuffer.writeln('<div class="color-info">');
    galleryBuffer.writeln('<div class="color-name">$name</div>');
    galleryBuffer.writeln('<div class="hex-value">${ray.toHex()}</div>');
    galleryBuffer.writeln(
        '<div class="luminance">Luminance: ${profile.luminance.toStringAsFixed(3)} (${profile.isDark ? 'Dark' : 'Light'})</div>');

    // Text weight demonstrations on main color
    galleryBuffer.writeln(
        '<div class="text-demo" style="background-color: ${ray.toHex()}; color: ${profile.onRay.toHex()};">');
    galleryBuffer.writeln('<span class="text-weight-300">Light</span>');
    galleryBuffer.writeln('<span class="text-weight-400">Regular</span>');
    galleryBuffer.writeln('<span class="text-weight-500">Medium</span>');
    galleryBuffer.writeln('<span class="text-weight-600">Semibold</span>');
    galleryBuffer.writeln('<span class="text-weight-700">Bold</span>');
    galleryBuffer.writeln('</div>');

    // Surface demonstrations
    galleryBuffer.writeln('<div class="surface-demos">');
    galleryBuffer.writeln(
        '<div class="surface-demo" style="background-color: ${profile.surfaceDark.toHex()}; color: ${profile.surfaceDark.computeLuminance() > 0.5 ? '#000' : '#fff'};">');
    galleryBuffer.writeln('Surface Dark<br>');
    galleryBuffer.writeln(
        '<span class="hex-value">${profile.surfaceDark.toHex()}</span><br>');
    galleryBuffer.writeln(
        '<span class="hex-value">Lum: ${profile.surfaceDark.computeLuminance().toStringAsFixed(3)}</span>');
    galleryBuffer.writeln('</div>');
    galleryBuffer.writeln(
        '<div class="surface-demo" style="background-color: ${profile.surfaceLight.toHex()}; color: ${profile.surfaceLight.computeLuminance() > 0.5 ? '#000' : '#fff'};">');
    galleryBuffer.writeln('Surface Light<br>');
    galleryBuffer.writeln(
        '<span class="hex-value">${profile.surfaceLight.toHex()}</span><br>');
    galleryBuffer.writeln(
        '<span class="hex-value">Lum: ${profile.surfaceLight.computeLuminance().toStringAsFixed(3)}</span>');
    galleryBuffer.writeln('</div>');
    galleryBuffer.writeln('</div>');

    galleryBuffer.writeln('</div>');
    galleryBuffer.writeln('</div>');
  }

  galleryBuffer.writeln('</div>');
  galleryBuffer.writeln('</body>');
  galleryBuffer.writeln('</html>');

  // Ensure gallery directory exists
  final galleryDir = p.join('tools', 'palettes', 'gallery');
  Directory(galleryDir).createSync(recursive: true);

  final galleryOutputPath = p.join(galleryDir, '$className.html');
  File(galleryOutputPath).writeAsStringSync(galleryBuffer.toString());
}
