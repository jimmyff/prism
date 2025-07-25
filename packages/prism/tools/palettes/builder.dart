import 'dart:io';
import 'package:path/path.dart' as p;

// Import your actual library classes to use their logic.
// The relative path is crucial here.
import 'package:prism/prism.dart';

// Import the source data maps.
import 'sources/spectrum.dart';
import 'sources/css.dart';
import 'sources/material.dart';
import 'sources/open_color.dart';
// import 'sources/catppuccin.dart';
// import 'sources/solarized.dart';

// Import generators are removed - only generating enum files now

void main() {
  print('Generating palettes...');

  _generatePaletteFromSchemes(
    className: 'Spectrum',
    data: spectrumColors,
    outputFileName: 'spectrum.dart',
  );

  _generatePaletteFromRays(
    className: 'Css',
    data: cssColors,
    outputFileName: 'css.dart',
  );

  _generatePaletteFromSchemes(
    className: 'Material',
    data: materialColors,
    outputFileName: 'material.dart',
  );

  _generatePaletteFromSchemes(
    className: 'OpenColor',
    data: openColorSchemes,
    outputFileName: 'open_color.dart',
  );

  // _generatePaletteFromRays(
  //   className: 'CatppuccinLatte',
  //   data: catppuccinLatteColors,
  //   outputFileName: 'catppuccin_latte.dart',
  // );

  // _generatePaletteFromRays(
  //   className: 'CatppuccinFrappe',
  //   data: catppuccinFrappeColors,
  //   outputFileName: 'catppuccin_frappe.dart',
  // );

  // _generatePaletteFromRays(
  //   className: 'CatppuccinMacchiato',
  //   data: catppuccinMacchiatoColors,
  //   outputFileName: 'catppuccin_macchiato.dart',
  // );

  // _generatePaletteFromRays(
  //   className: 'CatppuccinMocha',
  //   data: catppuccinMochaColors,
  //   outputFileName: 'catppuccin_mocha.dart',
  // );

  // _generatePaletteFromRays(
  //   className: 'Solarized',
  //   data: solarizedColors,
  //   outputFileName: 'solarized.dart',
  // );

  print('Palettes generated successfully!');
}

void _generatePaletteFromSchemes({
  required String className,
  required Map<String, RayScheme> data,
  required String outputFileName,
  Map<String, String>? aliases,
}) {
  // Create schemes map (data is already RayScheme objects)
  final Map<String, RayScheme> schemes = Map.from(data);

  _generatePaletteCode(
    className: className,
    schemes: schemes,
    outputFileName: outputFileName,
    aliases: aliases,
  );
}

/// Generates a single palette file from Ray colors.
void _generatePaletteFromRays({
  required String className,
  required Map<String, Ray> data,
  required String outputFileName,
  Map<String, String>? aliases,
}) {
  // Create schemes map by converting Ray objects to RayScheme
  final Map<String, RayScheme> schemes = {};
  for (final entry in data.entries) {
    final ray = entry.value is Ray
        ? entry.value
        : RayRgb.fromHex(entry.value.toString());
    schemes[entry.key] = RayScheme.fromRay(ray);
  }

  _generatePaletteCode(
    className: className,
    schemes: schemes,
    outputFileName: outputFileName,
    aliases: aliases,
  );
}

/// Core palette generation logic that works with RayScheme data.
void _generatePaletteCode({
  required String className,
  required Map<String, RayScheme> schemes,
  required String outputFileName,
  Map<String, String>? aliases,
}) {
  final buffer = StringBuffer();

  // Extract base name without 'Palette' suffix for the color space enums
  final baseName = className.endsWith('Palette')
      ? className.substring(0, className.length - 7)
      : className;

  // 1. Write the file header
  buffer.writeln('// GENERATED CODE - DO NOT EDIT BY HAND');
  buffer.writeln('// ignore_for_file: public_member_api_docs');
  buffer.writeln("import 'package:prism/prism.dart';");
  buffer.writeln('');

  // Extract rays from schemes for convenience
  final Map<String, Ray> rays = {};
  for (final entry in schemes.entries) {
    rays[entry.key] = entry.value.base;
  }

  // 2. Generate RGB scheme enum
  buffer.writeln('/// RGB-based RayScheme enum for the ${baseName} palette.');
  buffer.writeln('enum ${baseName}Rgb implements PrismPalette {');

  for (final entry in schemes.entries) {
    final name = entry.key;
    final scheme = entry.value;
    final rgb = scheme.base.toRgb();

    buffer.writeln('  $name(RayScheme<RayRgb>(');
    buffer.writeln(
        '    base: RayRgb.fromIntARGB(0x${rgb.toArgbInt().toRadixString(16).toUpperCase()}),');
    buffer.writeln('    baseLuminance: ${scheme.baseLuminance},');
    buffer.writeln('    baseIsDark: ${scheme.baseIsDark},');
    buffer.writeln(
        '    onBase: RayRgb.fromIntARGB(0x${scheme.onBase.toRgb().toArgbInt().toRadixString(16).toUpperCase()}),');
    buffer.writeln('    shades: {');

    for (final shade in Shade.values) {
      // check if this contains the shade
      if (!scheme.shades.containsKey(shade)) {
        continue;
      }
      final rayLuminance = scheme.shades[shade]!;
      final ray = rayLuminance.ray;
      final luminance = rayLuminance.luminance;
      final shadeRgb = ray.toRgb();
      buffer.writeln(
          '      Shade.${shade.name}: (ray: RayRgb.fromIntARGB(0x${shadeRgb.toArgbInt().toRadixString(16).toUpperCase()}), luminance: $luminance),');
    }
    buffer.writeln('    },');
    buffer.writeln('  )),');
  }

  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The RGB-based RayScheme.');
  buffer.writeln('  final RayScheme<RayRgb> scheme;');
  buffer.writeln('');
  buffer.writeln('  const ${baseName}Rgb(this.scheme);');

  // Add RGB aliases if they exist
  if (aliases != null && aliases.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('  // Convenience getters for common color aliases');
    for (final alias in aliases.entries) {
      final aliasName = alias.key;
      final targetName = alias.value;
      buffer.writeln('  /// Getter for $aliasName (returns $targetName)');
      buffer.writeln(
          '  static RayScheme get $aliasName => ${baseName}Rgb.$targetName.scheme;');
    }
  }

  buffer.writeln('}');
  buffer.writeln('');

  // 3. Generate Oklch scheme enum
  buffer.writeln('/// Oklch-based RayScheme enum for the ${baseName} palette.');
  buffer.writeln('enum ${baseName}Oklch implements PrismPalette {');

  for (final entry in schemes.entries) {
    final name = entry.key;
    final scheme = entry.value;
    final oklch = scheme.base.toOklch();

    buffer.writeln('  $name(RayScheme<RayOklch>(');
    buffer.writeln('    base: RayOklch(');
    buffer.writeln('      l: ${oklch.l},');
    buffer.writeln('      c: ${oklch.c},');
    buffer.writeln('      h: ${oklch.h},');
    buffer.writeln('      opacity: ${oklch.opacity},');
    buffer.writeln('    ),');
    buffer.writeln('    baseLuminance: ${scheme.baseLuminance},');
    buffer.writeln('    baseIsDark: ${scheme.baseIsDark},');
    buffer.writeln('    onBase: RayOklch(');
    buffer.writeln('      l: ${scheme.onBase.toOklch().l},');
    buffer.writeln('      c: ${scheme.onBase.toOklch().c},');
    buffer.writeln('      h: ${scheme.onBase.toOklch().h},');
    buffer.writeln('      opacity: ${scheme.onBase.toOklch().opacity},');
    buffer.writeln('    ),');
    buffer.writeln('    shades: {');

    for (final shade in Shade.values) {
      // check if this contains the shade
      if (!scheme.shades.containsKey(shade)) {
        continue;
      }
      final rayLuminance = scheme.shades[shade]!;
      final ray = rayLuminance.ray;
      final luminance = rayLuminance.luminance;
      final shadeOklch = ray.toOklch();
      buffer.writeln('      Shade.${shade.name}: (');
      buffer.writeln('        ray: RayOklch(');
      buffer.writeln('          l: ${shadeOklch.l},');
      buffer.writeln('          c: ${shadeOklch.c},');
      buffer.writeln('          h: ${shadeOklch.h},');
      buffer.writeln('          opacity: ${shadeOklch.opacity},');
      buffer.writeln('        ),');
      buffer.writeln('        luminance: $luminance,');
      buffer.writeln('      ),');
    }
    buffer.writeln('    },');
    buffer.writeln('  )),');
  }

  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The Oklch-based RayScheme.');
  buffer.writeln('  final RayScheme scheme;');
  buffer.writeln('');
  buffer.writeln('  const ${baseName}Oklch(this.scheme);');

  // Add Oklch aliases if they exist
  if (aliases != null && aliases.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('  // Convenience getters for common color aliases');
    for (final alias in aliases.entries) {
      final aliasName = alias.key;
      final targetName = alias.value;
      buffer.writeln('  /// Getter for $aliasName (returns $targetName)');
      buffer.writeln(
          '  static RayScheme get $aliasName => ${baseName}Oklch.$targetName.scheme;');
    }
  }

  buffer.writeln('}');
  buffer.writeln('');

  // 4. Generate original RayScheme enum for backward compatibility
  buffer.writeln('/// An enhanced enum for the $className palette.');
  buffer.writeln('enum $className {');

  for (final entry in schemes.entries) {
    final name = entry.key;
    final profile = entry.value;
    final ray = rays[name]!;

    // Write the pre-computed const values directly into the code
    buffer.writeln('  $name(RayScheme(');
    buffer.writeln(
        '    base: RayRgb.fromIntARGB(0x${ray.toRgb().toArgbInt().toRadixString(16).toUpperCase()}),');
    buffer.writeln('    baseLuminance: ${profile.baseLuminance},');
    buffer.writeln('    baseIsDark: ${profile.baseIsDark},');
    buffer.writeln(
        '    onBase: RayRgb.fromIntARGB(0x${profile.onBase.toRgb().toArgbInt().toRadixString(16).toUpperCase()}),');

    // Generate all shades as map
    buffer.writeln('    shades: {');

    for (final shade in Shade.values) {
      // check if this contains the shade
      if (!profile.shades.containsKey(shade)) {
        continue;
      }
      final rayLuminance = profile.shades[shade]!;
      final ray = rayLuminance.ray;
      final luminance = rayLuminance.luminance;
      final shadeRgb = ray.toRgb();
      buffer.writeln(
          '      Shade.${shade.name}: (ray: RayRgb.fromIntARGB(0x${shadeRgb.toArgbInt().toRadixString(16).toUpperCase()}), luminance: $luminance),');
    }
    buffer.writeln('    },');
    buffer.writeln('  )),');
  }

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
}
