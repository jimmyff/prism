import 'dart:io';
import 'package:path/path.dart' as p;

// Import your actual library classes to use their logic.
// The relative path is crucial here.
import 'package:prism/prism.dart';

// Import the source data maps.
import 'sources/rainbow.dart';
import 'sources/css.dart';
import 'sources/material.dart';
import 'sources/open_color.dart';

// Import generators are removed - only generating enum files now

void main() {
  print('Generating palettes...');

  _generatePaletteFromSpectrums(
    className: 'Rainbow',
    spectrum: rainbowSpectrums,
    spotColors: rainbowFixedRays,
    outputFileName: 'rainbow.dart',
  );

  _generatePaletteFromRays(
    className: 'Css',
    data: cssColors,
    outputFileName: 'css.dart',
  );

  _generatePaletteFromSpectrums(
    className: 'Material',
    spectrum: materialColors,
    spotColors: materialSpotColors,
    outputFileName: 'material.dart',
  );

  _generatePaletteFromSpectrums(
    className: 'OpenColor',
    spectrum: openColorSchemes,
    outputFileName: 'open_color.dart',
  );

  print('Palettes generated successfully!');
}

void _generatePaletteFromSpectrums({
  required String className,
  required Map<String, Spectrum> spectrum,
  Map<String, RayWithLuminance>? spotColors,
  required String outputFileName,
  Map<String, String>? aliases,
}) {
  // Create schemes map (data is already RayScheme objects)
  final Map<String, Spectrum> spectrums = Map.from(spectrum);

  _generatePaletteCode(
    className: className,
    spectrums: spectrums,
    spotColors: spotColors,
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
  final Map<String, Spectrum> schemes = {};
  for (final entry in data.entries) {
    final ray = entry.value as Ray? ?? RayRgb8.fromHex(entry.value.toString());
    schemes[entry.key] = Spectrum.fromRay(ray);
  }

  _generatePaletteCode(
    className: className,
    spectrums: schemes,
    outputFileName: outputFileName,
    aliases: aliases,
  );
}

/// Core palette generation logic that works with RayScheme data.
void _generatePaletteCode({
  required String className,
  required Map<String, Spectrum> spectrums,
  Map<String, RayWithLuminance>? spotColors,
  required String outputFileName,
  Map<String, String>? aliases,
}) {
  // Generate both RGB and Oklch versions
  _generateRgbPalette(
    className: className,
    spectrums: spectrums,
    spotColors: spotColors,
    outputFileName: outputFileName,
    aliases: aliases,
  );

  _generateOklchPalette(
    className: className,
    spectrums: spectrums,
    spotColors: spotColors,
    outputFileName: outputFileName,
    aliases: aliases,
  );
}

/// Generates RGB palette file.
void _generateRgbPalette({
  required String className,
  required Map<String, Spectrum> spectrums,
  Map<String, RayWithLuminance>? spotColors,
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
  final Map<String, RayWithLuminance> rays = {};
  for (final entry in spectrums.entries) {
    rays[entry.key] = entry.value.source;
  }

  // 2. Generate private FixedRays enum if spotColors exist
  if (spotColors != null && spotColors.isNotEmpty) {
    buffer.writeln('/// Private enum for fixed rays in the $baseName palette.');
    buffer.writeln('enum _${baseName}RgbFixedRays {');

    for (final entry in spotColors.entries) {
      final name = entry.key;
      final ray = entry.value.toRgb8();
      final luminance = entry.value.luminance;
      buffer.writeln(
          '  $name(RayWithLuminance<RayRgb8>(RayRgb8.fromArgbInt(0x${ray.toArgbInt().toRadixString(16).toUpperCase()}), $luminance)),');
    }
    buffer.writeln(';');
    buffer.writeln('');
    buffer.writeln('  const _${baseName}RgbFixedRays(this.ray);');
    buffer.writeln('  final RayWithLuminance<RayRgb8> ray;');
    buffer.writeln('}');
    buffer.writeln('');
  }

  // 3. Generate RGB scheme enum that implements PrismPalette directly
  buffer.writeln('/// RGB-based Spectrum enum for the $baseName palette.');
  buffer.writeln(
      '/// Each enum value implements Spectrum directly for clean API access.');
  buffer.writeln('enum ${baseName}Rgb implements PrismPalette {');

  for (final entry in spectrums.entries) {
    final name = entry.key;
    final scheme = entry.value;
    final rgb = scheme.source.toRgb8();

    buffer.writeln('  $name(');
    buffer.writeln(
        '    RayWithLuminance<RayRgb8>(RayRgb8.fromArgbInt(0x${rgb.toArgbInt().toRadixString(16).toUpperCase()}), ${scheme.source.luminance}), // source');
    buffer.writeln('    {');

    for (final tone in RayTone.values) {
      // check if this contains the tone
      if (!scheme.spectrum.containsKey(tone)) {
        continue;
      }
      final rayLuminance = scheme.spectrum[tone]!;
      final luminance = rayLuminance.luminance;
      final toneRgb = rayLuminance.toRgb8();
      buffer.writeln(
          '      RayTone.${tone.name}: RayWithLuminance<RayRgb8>(RayRgb8.fromArgbInt(0x${toneRgb.toArgbInt().toRadixString(16).toUpperCase()}), $luminance),');
    }
    buffer.writeln('    }, // spectrum');
    buffer.writeln('  ),');
  }

  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The source color with precomputed luminance');
  buffer.writeln('  @override');
  buffer.writeln('  final RayWithLuminance<RayRgb8> source;');
  buffer.writeln('');
  buffer.writeln('  /// The complete tonal palette');
  buffer.writeln('  @override');
  buffer.writeln('  final Map<RayTone, RayWithLuminance<RayRgb8>> spectrum;');
  buffer.writeln('');
  buffer.writeln('  const ${baseName}Rgb(this.source, this.spectrum);');
  buffer.writeln('');

  // Add direct tone access getters
  buffer.writeln('  // Direct tone access getters');
  for (final tone in RayTone.values) {
    buffer.writeln('  @override');
    buffer.writeln(
        '  RayWithLuminance<RayRgb8>? get ${tone.name} => spectrum[RayTone.${tone.name}];');
  }

  // Add convenience methods
  buffer.writeln('  /// Access specific tone by RayTone enum');
  buffer.writeln('  @override');
  buffer.writeln(
      '  RayWithLuminance<RayRgb8>? tone(RayTone tone) => spectrum[tone];');
  buffer.writeln('');

  // Add static fixed rays getters if they exist
  if (spotColors != null && spotColors.isNotEmpty) {
    buffer.writeln('  // Static getters for fixed rays');
    for (final entry in spotColors.entries) {
      final name = entry.key;
      buffer.writeln(
          '  static RayWithLuminance<RayRgb8> get $name => _${baseName}RgbFixedRays.$name.ray;');
    }
    buffer.writeln('');

    buffer.writeln('  /// Map of all fixed rays for iteration');
    buffer.writeln(
        '  static Map<String, RayWithLuminance<RayRgb8>> get fixedRays => {');
    for (final entry in spotColors.entries) {
      buffer.writeln(
          "    '${entry.key}': _${baseName}RgbFixedRays.${entry.key}.ray,");
    }
    buffer.writeln('  };');
    buffer.writeln('');
  }
  buffer.writeln('  /// A lighter surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminance<RayRgb8> get surfaceLight => shade100!;');
  buffer.writeln('');
  buffer.writeln('  /// A darker surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminance<RayRgb8> get surfaceDark => shade700!;');
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
  required Map<String, Spectrum> spectrums,
  Map<String, RayWithLuminance>? spotColors,
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
  final Map<String, RayWithLuminance> rays = {};
  for (final entry in spectrums.entries) {
    rays[entry.key] = entry.value.source;
  }

  // 2. Generate private FixedRays enum if spotColors exist
  if (spotColors != null && spotColors.isNotEmpty) {
    buffer.writeln('/// Private enum for fixed rays in the $baseName palette.');
    buffer.writeln('enum _${baseName}OklchFixedRays {');

    for (final entry in spotColors.entries) {
      final name = entry.key;
      final ray = entry.value.toOklch();
      final luminance = entry.value.luminance;
      buffer.writeln(
          '  $name(RayWithLuminance<RayOklch>(RayOklch.fromComponents(${ray.lightness}, ${ray.chroma}, ${ray.hue}, ${ray.opacity}), $luminance)),');
    }
    buffer.writeln(';');
    buffer.writeln('');
    buffer.writeln('  const _${baseName}OklchFixedRays(this.ray);');
    buffer.writeln('  final RayWithLuminance<RayOklch> ray;');
    buffer.writeln('}');
    buffer.writeln('');
  }

  // 3. Generate Oklch scheme enum that implements PrismPalette directly
  buffer.writeln('/// Oklch-based Spectrum enum for the $baseName palette.');
  buffer.writeln(
      '/// Each enum value implements Spectrum directly for clean API access.');
  buffer.writeln('enum ${baseName}Oklch implements PrismPalette {');

  for (final entry in spectrums.entries) {
    final name = entry.key;
    final scheme = entry.value;
    final oklch = scheme.source.toOklch();

    buffer.writeln('  $name(');
    buffer.writeln(
        '    RayWithLuminance<RayOklch>(RayOklch.fromComponents(${oklch.lightness}, ${oklch.chroma}, ${oklch.hue}, ${oklch.opacity}), ${oklch.luminance}), // source');
    buffer.writeln('    {');

    for (final tone in RayTone.values) {
      // check if this contains the tone
      if (!scheme.spectrum.containsKey(tone)) {
        continue;
      }
      final rayLuminance = scheme.spectrum[tone]!;
      final luminance = rayLuminance.luminance;
      final toneOklch = rayLuminance.toOklch();
      buffer.writeln(
          '      RayTone.${tone.name}: RayWithLuminance<RayOklch>(RayOklch.fromComponents(${toneOklch.lightness}, ${toneOklch.chroma}, ${toneOklch.hue}, ${toneOklch.opacity}), $luminance),');
    }
    buffer.writeln('    }, // spectrum');
    buffer.writeln('  ),');
  }

  buffer.writeln(';');
  buffer.writeln('');
  buffer.writeln('  /// The source color with precomputed luminance');
  buffer.writeln('  @override');
  buffer.writeln('  final RayWithLuminance<RayOklch> source;');
  buffer.writeln('');
  buffer.writeln('  /// The complete tonal palette');
  buffer.writeln('  @override');
  buffer.writeln('  final Map<RayTone, RayWithLuminance<RayOklch>> spectrum;');
  buffer.writeln('');
  buffer.writeln('  const ${baseName}Oklch(this.source, this.spectrum);');
  buffer.writeln('');

  // Add direct tone access getters
  buffer.writeln('  // Direct tone access getters');
  for (final tone in RayTone.values) {
    buffer.writeln('  @override');
    buffer.writeln(
        '  RayWithLuminance<RayOklch>? get ${tone.name} => spectrum[RayTone.${tone.name}];');
  }
  buffer.writeln('');

  // Add convenience methods
  buffer.writeln('  /// Access specific tone by RayTone enum');
  buffer.writeln('  @override');
  buffer.writeln(
      '  RayWithLuminance<RayOklch>? tone(RayTone tone) => spectrum[tone];');
  buffer.writeln('');

  // Add static fixed rays getters if they exist
  if (spotColors != null && spotColors.isNotEmpty) {
    buffer.writeln('  // Static getters for fixed rays');
    for (final entry in spotColors.entries) {
      final name = entry.key;
      buffer.writeln(
          '  static RayWithLuminance<RayOklch> get $name => _${baseName}OklchFixedRays.$name.ray;');
    }
    buffer.writeln('');

    buffer.writeln('  /// Map of all fixed rays for iteration');
    buffer.writeln(
        '  static Map<String, RayWithLuminance<RayOklch>> get fixedRays => {');
    for (final entry in spotColors.entries) {
      buffer.writeln(
          "    '${entry.key}': _${baseName}OklchFixedRays.${entry.key}.ray,");
    }
    buffer.writeln('  };');
    buffer.writeln('');
  }
  buffer.writeln('  /// A lighter surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminance<RayOklch> get surfaceLight => shade100!;');
  buffer.writeln('');
  buffer.writeln('  /// A darker surface variant of the primary color');
  buffer.writeln('  @override');
  buffer.writeln('  RayWithLuminance<RayOklch> get surfaceDark => shade700!;');
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
