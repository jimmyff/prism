import 'package:prism/prism.dart';
import 'package:prism/palettes/css.dart';
import 'package:prism/palettes/material.dart';
import 'package:prism/palettes/catppuccin_mocha.dart';
import 'package:prism/palettes/solarized.dart';
import 'package:prism/palettes/open_color.dart';

void main() {
  print('🌈 Prism Examples\n');

  // === RayRgb Creation ===
  print('✨ Creating RayRgbs:');
  final red = RayRgb.fromHex('#FF0000');
  final blue = RayRgb.fromARGB(255, 0, 0, 255);
  final green = RayRgb(red: 0, green: 255, blue: 0);
  final transparent = RayRgb.fromHex('#FF000080'); // 50% transparent red

  print('Red: ${red.toHexStr()}');
  print('Blue: ${blue.toHexStr()}');
  print('Green: ${green.toHexStr()}');
  print('Transparent Red: ${transparent.toHexStr(8)}');
  print('');

  // === Format Conversion ===
  print('🔄 Format Conversions:');
  print('Hex: ${red.toHexStr()}');
  print('CSS RGB: ${red.toRgbStr()}');
  print('CSS RGBA: ${transparent.toRgbaStr()}');
  print('ARGB Integer: 0x${red.toArgbInt().toRadixString(16).toUpperCase()}');
  print('JSON: ${red.toJson()}');
  print('');

  // === RayRgb Manipulation ===
  print('🔧 RayRgb Manipulation:');
  final semiRed = red.withOpacity(0.5);
  final darkRed = red.withAlpha(128);
  final cyan = red.inverse;

  print('50% Opacity Red: ${semiRed.toRgbaStr()}');
  print('Dark Red: ${darkRed.toHexStr(8)}');
  print('Red Inverse (Cyan): ${cyan.toHexStr()}');
  print('');

  // === RayRgb Interpolation ===
  print('🌈 RayRgb Interpolation:');
  final purple = red.lerp(blue, 0.5);
  final orange = red.lerp(RayRgb.fromHex('#FFFF00'), 0.5);

  print('Red → Blue (50%): ${purple.toHexStr()}');
  print('Red → Yellow (50%): ${orange.toHexStr()}');
  print('');

  // === Advanced Features ===
  print('🔬 Advanced Features:');
  final colors = [
    RayRgb.fromHex('#FF0000'), // Red
    RayRgb.fromHex('#00FF00'), // Green
    RayRgb.fromHex('#0000FF'), // Blue
    RayRgb.fromHex('#FFFF00'), // Yellow
    RayRgb.fromHex('#FF00FF'), // Magenta
  ];

  print('RayRgb Analysis:');
  for (final ray in colors) {
    final luminance = ray.computeLuminance();
    final brightness = luminance > 0.5 ? 'Light' : 'Dark';
    print(
        '${ray.toHexStr()}: $brightness (luminance: ${luminance.toStringAsFixed(3)})');
  }
  print('');

  // === Hex Format Support ===
  print('🌐 Hex Format Support:');
  final webRay = RayRgb.fromHex('#FF000080'); // RGBA format
  final flutterRay =
      RayRgb.fromHex('#80FF0000', format: HexFormat.argb); // ARGB format

  print('Web format (#FF000080): ${webRay.toRgbaStr()}');
  print('Flutter format (#80FF0000): ${flutterRay.toRgbaStr()}');
  print('Same RayRgb? ${webRay == flutterRay}');
  print('');

  // === Accessibility ===
  print('♿ Accessibility Features:');
  final gray = RayRgb.fromHex('#808080');
  final black = RayRgb.fromHex('#000000');
  final white = RayRgb.fromHex('#FFFFFF');

  final bestContrast = gray.maxContrast(black, white) as RayRgb;
  print('Best contrast for gray: ${bestContrast.toHexStr()}');
  print('');

  // === Performance Demo ===
  print('⚡ Performance Demo:');
  final stopwatch = Stopwatch()..start();

  // Create gradient of 100 RayRgbs
  final spectrum = <RayRgb>[];
  for (int i = 0; i < 100; i++) {
    spectrum.add(red.lerp(blue, i / 99.0));
  }

  stopwatch.stop();
  print('Created 100-RayRgb spectrum in ${stopwatch.elapsedMicroseconds}μs');
  print(
      'First: ${spectrum.first.toHexStr()} → Last: ${spectrum.last.toHexStr()}');
  print('');

  // === RayScheme Examples ===
  print('🎭 RayScheme - Accessibility-Focused Color Schemes:');
  final primaryColors = [
    RayRgb.fromHex('#2196F3'), // Blue
    RayRgb.fromHex('#F44336'), // Red
    RayRgb.fromHex('#4CAF50'), // Green
    RayRgb.fromHex('#FF9800'), // Orange
    RayRgb.fromHex('#9C27B0'), // Purple
  ];

  for (final color in primaryColors) {
    final scheme = RayScheme.fromRay(color);
    final theme = scheme.isDark ? 'Dark' : 'Light';
    print('${color.toHexStr()} → $theme theme:');
    print('  ├─ Text color: ${scheme.onRay.toRgb().toHexStr()}');
    print('  ├─ Light surface: ${scheme.surfaceLight.toRgb().toHexStr()}');
    print('  ├─ Dark surface: ${scheme.surfaceDark.toRgb().toHexStr()}');
    print('  └─ Luminance: ${scheme.luminance.toStringAsFixed(3)}');
  }
  print('');

  // === Color Palettes ===
  print('🎨 Color Palettes:');

  // CSS Colors
  print('CSS Colors:');
  final cssColors = [
    CssPalette.red,
    CssPalette.blue,
    CssPalette.green,
    CssPalette.gold
  ];
  for (final color in cssColors) {
    print(
        '  ${color.name}: ${color.scheme.ray.toRgb().toHexStr()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // Material Design
  print('Material Design:');
  final materialColors = [
    MaterialPalette.red500,
    MaterialPalette.blue500,
    MaterialPalette.green500,
    MaterialPalette.amber500
  ];
  for (final color in materialColors) {
    print(
        '  ${color.name}: ${color.scheme.ray.toRgb().toHexStr()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // Catppuccin Mocha
  print('Catppuccin Mocha Theme:');
  final mochaColors = [
    CatppuccinMochaPalette.red,
    CatppuccinMochaPalette.blue,
    CatppuccinMochaPalette.green,
    CatppuccinMochaPalette.yellow
  ];
  for (final color in mochaColors) {
    print(
        '  ${color.name}: ${color.scheme.ray.toRgb().toHexStr()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // Solarized
  print('Solarized:');
  final solarizedColors = [
    SolarizedPalette.red,
    SolarizedPalette.blue,
    SolarizedPalette.green,
    SolarizedPalette.orange
  ];
  for (final color in solarizedColors) {
    print(
        '  ${color.name}: ${color.scheme.ray.toRgb().toHexStr()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // Open Color
  print('Open Color:');
  final openColors = [
    OpenColorPalette.red5,
    OpenColorPalette.blue5,
    OpenColorPalette.green5,
    OpenColorPalette.yellow5
  ];
  for (final color in openColors) {
    print(
        '  ${color.name}: ${color.scheme.ray.toRgb().toHexStr()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // === Palette Theme Generation ===
  print('🌙 Theme Generation Example:');
  final themeColor = CssPalette.blue.scheme;

  print('Creating a blue theme:');
  print('  Primary: ${themeColor.ray.toRgb().toHexStr()}');
  print('  On Primary: ${themeColor.onRay.toRgb().toHexStr()}');
  print('  Surface (Light): ${themeColor.surfaceLight.toRgb().toHexStr()}');
  print('  Surface (Dark): ${themeColor.surfaceDark.toRgb().toHexStr()}');
  print('  Theme type: ${themeColor.isDark ? 'Dark' : 'Light'}');
  print('  Luminance: ${themeColor.luminance.toStringAsFixed(3)}');
  print('');

  // === Advanced Palette Operations ===
  print('⚙️ Advanced Palette Operations:');

  // Create gradient using palette colors
  final gradientStart = MaterialPalette.purple500.scheme.ray;
  final gradientEnd = MaterialPalette.pink500.scheme.ray;
  print('Material Purple → Pink gradient:');
  for (int i = 0; i <= 4; i++) {
    final step = gradientStart.lerp(gradientEnd, i / 4.0);
    final stepScheme = RayScheme.fromRay(step);
    print(
        '  Step $i: ${step.toRgb().toHexStr()} (contrast: ${stepScheme.onRay.toRgb().toHexStr()})');
  }
  print('');

  // Palette accessibility analysis
  print('♿ Palette Accessibility Analysis:');
  final testColors = [
    ('CSS Red', CssPalette.red.scheme),
    ('Material Blue', MaterialPalette.blue500.scheme),
    ('Catppuccin Green', CatppuccinMochaPalette.green.scheme),
    ('Solarized Orange', SolarizedPalette.orange.scheme),
  ];

  for (final (name, scheme) in testColors) {
    final contrast = scheme.ray.maxContrast(
      RayRgb.fromHex('#000000'), // Black
      RayRgb.fromHex('#FFFFFF'), // White
    );
    print('  $name:');
    print(
        '    └─ Best contrast: ${contrast.toRgb().toHexStr()} (${contrast == RayRgb.fromHex('#000000') ? 'Black' : 'White'})');
  }
  print('');

  // === HSL Color Examples ===
  print('🌈 HSL Color Examples:');

  // Basic HSL creation
  final hslRed = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
  final hslGreen = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
  final hslBlue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
  final hslPastel =
      RayHsl(hue: 60, saturation: 0.3, lightness: 0.8, opacity: 0.7);

  print('HSL Colors:');
  print('  Red: $hslRed → ${hslRed.toRgb().toHexStr()}');
  print('  Green: $hslGreen → ${hslGreen.toRgb().toHexStr()}');
  print('  Blue: $hslBlue → ${hslBlue.toRgb().toHexStr()}');
  print('  Pastel Yellow: $hslPastel → ${hslPastel.toRgb().toHexStr(8)}');
  print('');

  // HSL manipulation
  print('🎨 HSL Manipulation:');
  final baseHsl = RayHsl(hue: 200, saturation: 0.8, lightness: 0.6);
  print('Base Color: $baseHsl → ${baseHsl.toRgb().toHexStr()}');
  print(
      '  Hue Shifted (+60°): ${baseHsl.withHue(baseHsl.hue + 60)} → ${baseHsl.withHue(baseHsl.hue + 60).toRgb().toHexStr()}');
  print(
      '  More Saturated: ${baseHsl.withSaturation(1.0)} → ${baseHsl.withSaturation(1.0).toRgb().toHexStr()}');
  print(
      '  Darker: ${baseHsl.withLightness(0.3)} → ${baseHsl.withLightness(0.3).toRgb().toHexStr()}');
  print(
      '  Semi-transparent: ${baseHsl.withOpacity(0.5)} → ${baseHsl.withOpacity(0.5).toRgb().toHexStr(8)}');
  print('');

  // RGB ↔ HSL Conversion
  print('🔄 RGB ↔ HSL Conversion:');
  final rgbOrange = RayRgb(red: 255, green: 165, blue: 0);
  final hslOrange = rgbOrange.toHsl();
  final backToRgb = hslOrange.toRgb();

  print('RGB Orange: ${rgbOrange.toHexStr()} → HSL: $hslOrange');
  print(
      'Back to RGB: ${backToRgb.toHexStr()} (Perfect round-trip: ${rgbOrange == backToRgb})');
  print('');

  // HSL Distance and Difference Functions
  print('📐 HSL Distance and Difference Functions:');
  final color1 = RayHsl(hue: 30, saturation: 0.8, lightness: 0.6);
  final color2 = RayHsl(hue: 150, saturation: 0.5, lightness: 0.4);

  print('Color 1: $color1');
  print('Color 2: $color2');
  print('Differences (signed):');
  print('  Hue: ${color1.hueDifference(color2).toStringAsFixed(1)}°');
  print(
      '  Saturation: ${color1.saturationDifference(color2).toStringAsFixed(2)}');
  print(
      '  Lightness: ${color1.lightnessDifference(color2).toStringAsFixed(2)}');
  print('Distances (absolute):');
  print('  Hue: ${color1.hueDistance(color2).toStringAsFixed(1)}°');
  print(
      '  Saturation: ${color1.saturationDistance(color2).toStringAsFixed(2)}');
  print('  Lightness: ${color1.lightnessDistance(color2).toStringAsFixed(2)}');
  print('');

  // HSL Color Wheel Demonstration
  print('🎯 HSL Color Wheel (12 colors):');
  for (int i = 0; i < 12; i++) {
    final hue = i * 30.0;
    final wheelColor = RayHsl(hue: hue, saturation: 0.8, lightness: 0.6);
    final rgbHex = wheelColor.toRgb().toHexStr();
    print('  ${hue.toStringAsFixed(0).padLeft(3)}°: $wheelColor → $rgbHex');
  }
  print('');

  // HSL Lightness Scale
  print('💡 HSL Lightness Scale (Blue Hue):');
  for (int i = 0; i <= 10; i++) {
    final lightness = i / 10.0;
    final scaleColor = RayHsl(hue: 240, saturation: 1.0, lightness: lightness);
    final rgbHex = scaleColor.toRgb().toHexStr();
    print('  L=${lightness.toStringAsFixed(1)}: $scaleColor → $rgbHex');
  }
  print('');

  // HSL Interpolation
  print('🌈 HSL Interpolation (Hue-aware):');
  final startHsl = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5); // Red
  final endHsl = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5); // Blue

  print('HSL Interpolation (Red → Blue):');
  for (int i = 0; i <= 4; i++) {
    final t = i / 4.0;
    final interpolated = startHsl.lerp(endHsl, t);
    final rgbHex = interpolated.toRgb().toHexStr();
    print('  Step $i (t=${t.toStringAsFixed(2)}): $interpolated → $rgbHex');
  }
  print('');

  // HSL Accessibility Analysis
  print('♿ HSL Accessibility Analysis:');
  final testHslColors = [
    ('Bright Red', RayHsl(hue: 0, saturation: 1.0, lightness: 0.5)),
    ('Dark Green', RayHsl(hue: 120, saturation: 0.8, lightness: 0.3)),
    ('Light Blue', RayHsl(hue: 200, saturation: 0.6, lightness: 0.7)),
    ('Purple', RayHsl(hue: 280, saturation: 0.9, lightness: 0.4)),
  ];

  for (final (name, hslColor) in testHslColors) {
    final luminance = hslColor.computeLuminance();
    final scheme = RayScheme.fromRay(hslColor);
    final contrastColor = scheme.onRay.toRgb();

    print('  $name: $hslColor');
    print(
        '    └─ Luminance: ${luminance.toStringAsFixed(3)}, Text: ${contrastColor.toHexStr()} (${scheme.isDark ? 'Dark' : 'Light'} theme)');
  }
  print('');

  // === Oklab Color Examples ===
  print('🧪 Oklab Color Examples (Perceptually Uniform):');

  // Basic Oklab creation
  final oklabRed = RayOklab(l: 0.628, a: 0.225, b: 0.126);
  final oklabGreen = RayOklab(l: 0.866, a: -0.234, b: 0.179);
  final oklabBlue = RayOklab(l: 0.452, a: -0.032, b: -0.312);
  final oklabNeutral = RayOklab(l: 0.5, a: 0.0, b: 0.0, opacity: 0.8);

  print('Oklab Colors:');
  print('  Red: $oklabRed → ${oklabRed.toRgb().toHexStr()}');
  print('  Green: $oklabGreen → ${oklabGreen.toRgb().toHexStr()}');
  print('  Blue: $oklabBlue → ${oklabBlue.toRgb().toHexStr()}');
  print('  Neutral Gray: $oklabNeutral → ${oklabNeutral.toRgb().toHexStr(8)}');
  print('');

  // RGB → Oklab conversion
  print('🔄 RGB → Oklab Conversion:');
  final rgbPurple = RayRgb(red: 128, green: 0, blue: 128);
  final oklabPurple = rgbPurple.toOklab();
  final backToRgbFromOklab = oklabPurple.toRgb();

  print('RGB Purple: ${rgbPurple.toHexStr()} → Oklab: $oklabPurple');
  print(
      'Back to RGB: ${backToRgbFromOklab.toHexStr()} (Close match: ${(rgbPurple.red - backToRgbFromOklab.red).abs() < 5})');
  print('');

  // Oklab Perceptual Interpolation
  print('🌈 Oklab Perceptual Interpolation:');
  final oklabStart = RayOklab(l: 0.3, a: 0.2, b: -0.1); // Dark reddish
  final oklabEnd = RayOklab(l: 0.8, a: -0.1, b: 0.15); // Light greenish

  print('Oklab Interpolation (Perceptually Uniform):');
  for (int i = 0; i <= 4; i++) {
    final t = i / 4.0;
    final interpolated = oklabStart.lerp(oklabEnd, t);
    final rgbHex = interpolated.toRgb().toHexStr();
    print('  Step $i (t=${t.toStringAsFixed(2)}): $interpolated → $rgbHex');
  }
  print('');

  // Compare RGB vs Oklab interpolation
  print('🔬 RGB vs Oklab Interpolation Comparison:');
  final startRgb = RayRgb(red: 255, green: 0, blue: 0); // Red
  final endRgb = RayRgb(red: 0, green: 255, blue: 0); // Green
  final startOklab = startRgb.toOklab();
  final endOklab = endRgb.toOklab();

  print('Red → Green interpolation:');
  for (int i = 0; i <= 2; i++) {
    final t = i / 2.0;
    final rgbLerp = startRgb.lerp(endRgb, t);
    final oklabLerp = startOklab.lerp(endOklab, t).toRgb();

    print(
        '  t=${t.toStringAsFixed(1)} - RGB: ${rgbLerp.toHexStr()}, Oklab: ${oklabLerp.toHexStr()}');
  }
  print('');

  // Oklab Lightness Scale
  print('💡 Oklab Lightness Scale (Neutral):');
  for (int i = 0; i <= 5; i++) {
    final lightness = i / 5.0;
    final scaleColor = RayOklab(l: lightness, a: 0.0, b: 0.0);
    final rgbHex = scaleColor.toRgb().toHexStr();
    print('  L=${lightness.toStringAsFixed(1)}: $scaleColor → $rgbHex');
  }
  print('');

  // Oklab Color Harmony
  print('🎨 Oklab Color Harmony:');
  final baseOklab = RayOklab(l: 0.6, a: 0.1, b: -0.05);
  print('Base Color: $baseOklab → ${baseOklab.toRgb().toHexStr()}');

  // Generate harmonious colors by varying a and b components
  final complementary =
      RayOklab(l: baseOklab.l, a: -baseOklab.a, b: -baseOklab.b);
  final analogous1 =
      RayOklab(l: baseOklab.l, a: baseOklab.a * 0.5, b: baseOklab.b + 0.1);
  final analogous2 =
      RayOklab(l: baseOklab.l, a: baseOklab.a + 0.05, b: baseOklab.b * 0.5);

  print(
      '  Complementary: $complementary → ${complementary.toRgb().toHexStr()}');
  print('  Analogous 1: $analogous1 → ${analogous1.toRgb().toHexStr()}');
  print('  Analogous 2: $analogous2 → ${analogous2.toRgb().toHexStr()}');
  print('');

  // Multi-space conversion demonstration
  print('🔄 Multi-Space Conversion Chain:');
  final originalRgb = RayRgb(red: 180, green: 60, blue: 200);
  final viaHsl = originalRgb.toHsl().toOklab().toRgb();
  final viaOklab = originalRgb.toOklab().toHsl().toRgb();

  print('Original RGB: ${originalRgb.toHexStr()}');
  print('RGB → HSL → Oklab → RGB: ${viaHsl.toHexStr()}');
  print('RGB → Oklab → HSL → RGB: ${viaOklab.toHexStr()}');
  print(
      'Conversion accuracy: ${(originalRgb.red - viaHsl.red).abs() < 10 ? 'Good' : 'Fair'}');
  print('');

  // Oklab Accessibility Analysis
  print('♿ Oklab Accessibility Analysis:');
  final testOklabColors = [
    ('Bright Red', RayOklab(l: 0.628, a: 0.225, b: 0.126)),
    ('Dark Green', RayOklab(l: 0.4, a: -0.15, b: 0.1)),
    ('Light Blue', RayOklab(l: 0.7, a: -0.02, b: -0.2)),
    ('Neutral Gray', RayOklab(l: 0.5, a: 0.0, b: 0.0)),
  ];

  for (final (name, oklabColor) in testOklabColors) {
    final luminance = oklabColor.computeLuminance();
    final scheme = RayScheme.fromRay(oklabColor);
    final contrastColor = scheme.onRay.toRgb();

    print(
        '  $name: L=${oklabColor.l.toStringAsFixed(3)} → ${oklabColor.toRgb().toHexStr()}');
    print(
        '    └─ Luminance: ${luminance.toStringAsFixed(3)}, Text: ${contrastColor.toHexStr()} (${scheme.isDark ? 'Dark' : 'Light'} theme)');
  }
  print('');

  print('✅ All examples completed successfully!');
}
