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
        : RayRgb8.fromHex(entry.value.toString());
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
  // Generate both RGB and Oklch versions
  _generateRgbPalette(
    className: className,
    schemes: schemes,
    outputFileName: outputFileName,
    aliases: aliases,
  );

  _generateOklchPalette(
    className: className,
    schemes: schemes,
    outputFileName: outputFileName,
    aliases: aliases,
  );
}

/// Generates RGB palette file.
void _generateRgbPalette({
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
  final Map<String, RayWithLuminanceBase> rays = {};
  for (final entry in schemes.entries) {
    rays[entry.key] = entry.value.source;
  }

  // 2. Generate RGB scheme enum that implements RayScheme directly
  buffer.writeln('/// RGB-based RayScheme enum for the ${baseName} palette.');
  buffer.writeln(
      '/// Each enum value implements RayScheme directly for clean API access.');
  buffer.writeln('enum ${baseName}Rgb implements PrismPalette {');

  for (final entry in schemes.entries) {
    final name = entry.key;
    final scheme = entry.value;
    final rgb = scheme.source.toRgb();

    buffer.writeln('  $name(');
    buffer.writeln(
        '    RayWithLuminanceRgb8.fromRay(RayRgb8.fromIntARGB(0x${rgb.toArgbInt().toRadixString(16).toUpperCase()}), ${scheme.source.luminance}), // source');
    buffer.writeln('    const {');

    for (final tone in RayTone.values) {
      // check if this contains the tone
      if (!scheme.tones.containsKey(tone)) {
        continue;
      }
      final rayLuminance = scheme.tones[tone]!;
      final luminance = rayLuminance.luminance;
      final toneRgb = rayLuminance.toRgb();
      buffer.writeln(
          '      RayTone.${tone.name}: RayWithLuminanceRgb8.fromRay(RayRgb8.fromIntARGB(0x${toneRgb.toArgbInt().toRadixString(16).toUpperCase()}), $luminance),');
    }
    buffer.writeln('    }, // tones');
    buffer.writeln('  ),');
  }

  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The source color with precomputed luminance');
  buffer.writeln('  final RayWithLuminanceRgb8 source;');
  buffer.writeln('');
  buffer.writeln('  /// The complete tonal palette');
  buffer.writeln('  final Map<RayTone, RayWithLuminanceRgb8> tones;');
  buffer.writeln('');
  buffer.writeln('  const ${baseName}Rgb(this.source, this.tones);');
  buffer.writeln('');

  // Add direct tone access getters
  buffer.writeln('  // Direct tone access getters');
  for (final tone in RayTone.values) {
    buffer.writeln('  @override');
    buffer.writeln(
        '  RayWithLuminanceRgb8? get ${tone.name} => tones[RayTone.${tone.name}];');
  }
  buffer.writeln('');

  // Add convenience methods
  buffer.writeln('  /// Access specific tone by RayTone enum');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminanceRgb8? tone(RayTone tone) => tones[tone];');
  buffer.writeln('');
  buffer.writeln('  /// A lighter surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminanceRgb8 get surfaceLight => shade100!;');
  buffer.writeln('');
  buffer.writeln('  /// A darker surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminanceRgb8 get surfaceDark => shade700!;');
  buffer.writeln('');

  // Add RGB aliases if they exist
  if (aliases != null && aliases.isNotEmpty) {
    buffer.writeln('  // Convenience getters for common color aliases');
    for (final alias in aliases.entries) {
      final aliasName = alias.key;
      final targetName = alias.value;
      buffer.writeln('  /// Getter for $aliasName (returns $targetName)');
      buffer.writeln(
          '  static ${baseName}Rgb get $aliasName => ${baseName}Rgb.$targetName;');
    }
    buffer.writeln('');
  }

  buffer.writeln('}');
  buffer.writeln('');

  // 4. Write the RGB file to the lib/palettes/rgb directory
  final scriptDir = Directory(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.parent.parent; // Go up 2 levels
  final outputPath =
      p.join(projectRoot.path, 'lib', 'palettes', 'rgb', outputFileName);

  // Ensure the rgb directory exists
  final rgbDir = Directory(p.join(projectRoot.path, 'lib', 'palettes', 'rgb'));
  if (!rgbDir.existsSync()) {
    rgbDir.createSync(recursive: true);
  }

  File(outputPath).writeAsStringSync(buffer.toString());
}

/// Generates Oklch palette file.
void _generateOklchPalette({
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
  final Map<String, RayWithLuminanceBase> rays = {};
  for (final entry in schemes.entries) {
    rays[entry.key] = entry.value.source;
  }

  // 2. Generate Oklch scheme enum that implements RayScheme directly
  buffer.writeln('/// Oklch-based RayScheme enum for the ${baseName} palette.');
  buffer.writeln(
      '/// Each enum value implements RayScheme directly for clean API access.');
  buffer.writeln('enum ${baseName}Oklch implements PrismPalette {');

  for (final entry in schemes.entries) {
    final name = entry.key;
    final scheme = entry.value;
    final oklch = scheme.source.toOklch();

    buffer.writeln('  $name(');
    buffer.writeln('    RayWithLuminanceOklch.fromComponents(');
    buffer.writeln('      ${oklch.l},');
    buffer.writeln('      ${oklch.c},');
    buffer.writeln('      ${oklch.h},');
    buffer.writeln('      ${oklch.opacity},');
    buffer.writeln('      ${oklch.luminance}), // source');
    buffer.writeln('    const {');

    for (final tone in RayTone.values) {
      // check if this contains the tone
      if (!scheme.tones.containsKey(tone)) {
        continue;
      }
      final rayLuminance = scheme.tones[tone]!;
      final luminance = rayLuminance.luminance;
      final toneOklch = rayLuminance.toOklch();
      buffer.writeln(
          '      RayTone.${tone.name}: RayWithLuminanceOklch.fromComponents(');
      buffer.writeln('        ${toneOklch.l},');
      buffer.writeln('        ${toneOklch.c},');
      buffer.writeln('        ${toneOklch.h},');
      buffer.writeln('        ${toneOklch.opacity},');
      buffer.writeln('        $luminance),');
    }
    buffer.writeln('    }, // tones');
    buffer.writeln('  ),');
  }

  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The source color with precomputed luminance');
  buffer.writeln('  final RayWithLuminanceOklch source;');
  buffer.writeln('');
  buffer.writeln('  /// The complete tonal palette');
  buffer.writeln('  final Map<RayTone, RayWithLuminanceOklch> tones;');
  buffer.writeln('');
  buffer.writeln('  const ${baseName}Oklch(this.source, this.tones);');
  buffer.writeln('');

  // Add direct tone access getters
  buffer.writeln('  // Direct tone access getters');
  for (final tone in RayTone.values) {
    buffer.writeln('  @override');
    buffer.writeln(
        '  RayWithLuminanceOklch? get ${tone.name} => tones[RayTone.${tone.name}];');
  }
  buffer.writeln('');

  // Add convenience methods
  buffer.writeln('  /// Access specific tone by RayTone enum');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminanceOklch? tone(RayTone tone) => tones[tone];');
  buffer.writeln('');
  buffer.writeln('  /// A lighter surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminanceOklch get surfaceLight => shade100!;');
  buffer.writeln('');
  buffer.writeln('  /// A darker surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminanceOklch get surfaceDark => shade700!;');
  buffer.writeln('');

  // Add Oklch aliases if they exist
  if (aliases != null && aliases.isNotEmpty) {
    buffer.writeln('  // Convenience getters for common color aliases');
    for (final alias in aliases.entries) {
      final aliasName = alias.key;
      final targetName = alias.value;
      buffer.writeln('  /// Getter for $aliasName (returns $targetName)');
      buffer.writeln(
          '  static ${baseName}Oklch get $aliasName => ${baseName}Oklch.$targetName;');
    }
    buffer.writeln('');
  }

  buffer.writeln('}');
  buffer.writeln('');

  // 3. Write the Oklch file to the lib/palettes/oklch directory
  final scriptDir = Directory(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.parent.parent; // Go up 2 levels
  final outputPath =
      p.join(projectRoot.path, 'lib', 'palettes', 'oklch', outputFileName);

  // Ensure the oklch directory exists
  final oklchDir =
      Directory(p.join(projectRoot.path, 'lib', 'palettes', 'oklch'));
  if (!oklchDir.existsSync()) {
    oklchDir.createSync(recursive: true);
  }

  File(outputPath).writeAsStringSync(buffer.toString());
}
