import 'package:prism/prism.dart';
import 'package:prism/palettes/spectrum.dart';
import 'package:prism/palettes/css.dart';
import 'package:prism/palettes/material.dart';
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
    final luminance = ray.luminance;
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
    final theme = scheme.source.isDark ? 'Dark' : 'Light';
    print('${color.toHexStr()} → $theme theme:');
    print('  ├─ Text color: ${scheme.source.onRay.toRgb().toHexStr()}');
    print('  ├─ Light surface: ${scheme.surfaceLight.toRgb().toHexStr()}');
    print('  ├─ Dark surface: ${scheme.surfaceDark.toRgb().toHexStr()}');
    print('  └─ Luminance: ${scheme.source.luminance.toStringAsFixed(3)}');
  }
  print('');

  // === Color Palettes ===
  print('🎨 Color Palettes:');

  // Spectrum (Prism's own palette)
  print('Spectrum (Prism\'s own palette):');
  final spectrumColors = [
    SpectrumRgb.red,
    SpectrumRgb.blue,
    SpectrumRgb.green,
    SpectrumRgb.purple
  ];
  for (final color in spectrumColors) {
    print(
        '  ${color.name}: ${color.scheme.source.ray.toRgb().toHexStr()} (${color.scheme.source.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // CSS Colors
  print('CSS Colors:');
  final cssColors = [CssRgb.red, CssRgb.blue, CssRgb.green, CssRgb.gold];
  for (final color in cssColors) {
    print(
        '  ${color.name}: ${color.scheme.source.ray.toRgb().toHexStr()} (${color.scheme.source.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // Material Design
  print('Material Design:');
  final materialColors = [
    MaterialRgb.red,
    MaterialRgb.blue,
    MaterialRgb.green,
    MaterialRgb.amber
  ];
  for (final color in materialColors) {
    print(
        '  ${color.name}: ${color.scheme.source.ray.toRgb().toHexStr()} (${color.scheme.source.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // Open Color
  print('Open Color:');
  final openColors = [
    OpenColorRgb.red,
    OpenColorRgb.blue,
    OpenColorRgb.green,
    OpenColorRgb.yellow
  ];
  for (final color in openColors) {
    print(
        '  ${color.name}: ${color.scheme.source.ray.toRgb().toHexStr()} (${color.scheme.source.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // === Palette Theme Generation ===
  print('🌙 Theme Generation Example:');
  final themeColor = SpectrumRgb.blue.scheme;

  print('Creating a blue theme using Spectrum palette:');
  print('  Primary: ${themeColor.source.ray.toRgb().toHexStr()}');
  print('  On Primary: ${themeColor.source.onRay.toRgb().toHexStr()}');
  print('  Surface (Light): ${themeColor.surfaceLight.toRgb().toHexStr()}');
  print('  Surface (Dark): ${themeColor.surfaceDark.toRgb().toHexStr()}');
  print('  Theme type: ${themeColor.source.isDark ? 'Dark' : 'Light'}');
  print('  Luminance: ${themeColor.source.luminance.toStringAsFixed(3)}');
  print('');

  // === Advanced Palette Operations ===
  print('⚙️ Advanced Palette Operations:');

  // Create gradient using palette colors
  final gradientStart = SpectrumRgb.purple.scheme.source.ray;
  final gradientEnd = SpectrumRgb.pink.scheme.source.ray;
  print('Spectrum Purple → Pink gradient:');
  for (int i = 0; i <= 4; i++) {
    final step = gradientStart.lerp(gradientEnd, i / 4.0);
    final stepScheme = RayScheme.fromRay(step);
    print(
        '  Step $i: ${step.toRgb().toHexStr()} (contrast: ${stepScheme.source.onRay.toRgb().toHexStr()})');
  }
  print('');

  // Palette accessibility analysis
  print('♿ Palette Accessibility Analysis:');
  final testColors = [
    ('Spectrum Red', SpectrumRgb.red.scheme),
    ('CSS Red', CssRgb.red.scheme),
    ('Material Blue', MaterialRgb.blue.scheme),
  ];

  for (final (name, scheme) in testColors) {
    final contrast = scheme.source.ray.maxContrast(
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
    final luminance = hslColor.luminance;
    final scheme = RayScheme.fromRay(hslColor);
    final contrastColor = scheme.source.onRay.toRgb();

    print('  $name: $hslColor');
    print(
        '    └─ Luminance: ${luminance.toStringAsFixed(3)}, Text: ${contrastColor.toHexStr()} (${scheme.source.isDark ? 'Dark' : 'Light'} theme)');
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
    final luminance = oklabColor.luminance;
    final scheme = RayScheme.fromRay(oklabColor);
    final contrastColor = scheme.source.onRay.toRgb();

    print(
        '  $name: L=${oklabColor.l.toStringAsFixed(3)} → ${oklabColor.toRgb().toHexStr()}');
    print(
        '    └─ Luminance: ${luminance.toStringAsFixed(3)}, Text: ${contrastColor.toHexStr()} (${scheme.source.isDark ? 'Dark' : 'Light'} theme)');
  }
  print('');

  // === Oklch Color Examples ===
  print('🎨 Oklch Color Examples (Cylindrical Oklab with Intuitive Controls):');

  // Basic Oklch creation
  final brightOklch =
      RayOklch(l: 0.8, c: 0.2, h: 60.0, opacity: 1.0); // Bright yellow-green
  final mutedOklch =
      RayOklch(l: 0.5, c: 0.1, h: 240.0, opacity: 1.0); // Muted blue
  final vibrantOklch =
      RayOklch(l: 0.6, c: 0.25, h: 0.0, opacity: 1.0); // Vibrant red

  print(
      'Bright Yellow-Green: ${brightOklch.toString()} → ${brightOklch.toRgb().toHexStr()}');
  print(
      'Muted Blue: ${mutedOklch.toString()} → ${mutedOklch.toRgb().toHexStr()}');
  print(
      'Vibrant Red: ${vibrantOklch.toString()} → ${vibrantOklch.toRgb().toHexStr()}');
  print('');

  // RGB → Oklch conversion
  print('🔄 RGB → Oklch Conversion:');
  final rgbTeal = RayRgb.fromHex('#008080');
  final oklchTeal = rgbTeal.toOklch();
  final rgbOrangeColor = RayRgb.fromHex('#FFA500');
  final oklchOrange = rgbOrangeColor.toOklch();

  print('RGB Teal: ${rgbTeal.toHexStr()} → Oklch: $oklchTeal');
  print('RGB Orange: ${rgbOrangeColor.toHexStr()} → Oklch: $oklchOrange');
  print('');

  // Oklch Hue-based Interpolation with Shortest Path
  print('🌈 Oklch Hue-aware Interpolation (Shortest Path):');
  final redOklch = RayOklch(l: 0.6, c: 0.2, h: 10.0); // Near red
  final blueOklch =
      RayOklch(l: 0.6, c: 0.2, h: 350.0); // Near red on other side

  print('Color A: ${redOklch.toString()} → ${redOklch.toRgb().toHexStr()}');
  print('Color B: ${blueOklch.toString()} → ${blueOklch.toRgb().toHexStr()}');
  print('Interpolation path goes through 0° (red):');

  for (double t = 0.0; t <= 1.0; t += 0.25) {
    final lerped = redOklch.lerp(blueOklch, t);
    print(
        '  t=${t.toStringAsFixed(2)} - H=${lerped.h.toStringAsFixed(1)}° → ${lerped.toRgb().toHexStr()}');
  }
  print('');

  // Oklch Chroma Manipulation (Saturation Control)
  print('🎨 Oklch Chroma Manipulation (Saturation Control):');
  final baseOklch = RayOklch(l: 0.7, c: 0.15, h: 120.0); // Green base

  print(
      'Base Color: ${baseOklch.toString()} → ${baseOklch.toRgb().toHexStr()}');
  print('Chroma variations:');

  for (double chroma = 0.0; chroma <= 0.25; chroma += 0.05) {
    final chromaVariant = baseOklch.withChroma(chroma);
    print(
        '  C=${chroma.toStringAsFixed(2)} → ${chromaVariant.toRgb().toHexStr()}');
  }
  print('');

  // Oklch Lightness Scale
  print('💡 Oklch Lightness Scale (Consistent Hue/Chroma):');

  print('Purple lightness scale (H=270°, C=0.15):');
  for (double lightness = 0.1; lightness <= 0.9; lightness += 0.1) {
    final lightnessVariant = RayOklch(l: lightness, c: 0.15, h: 270.0);
    print(
        '  L=${lightness.toStringAsFixed(1)} → ${lightnessVariant.toRgb().toHexStr()}');
  }
  print('');

  // Oklch Color Harmonies
  print('🎵 Oklch Color Harmonies (Hue Relationships):');
  final primaryOklch = RayOklch(l: 0.65, c: 0.18, h: 45.0); // Orange

  // Create harmonious colors by rotating hue
  final complementaryOklch =
      primaryOklch.withHue(primaryOklch.h + 180); // Opposite
  final triadicOklch1 = primaryOklch.withHue(primaryOklch.h + 120); // +120°
  final triadicOklch2 = primaryOklch.withHue(primaryOklch.h + 240); // +240°
  final analogousOklch1 = primaryOklch.withHue(primaryOklch.h + 30); // +30°
  final analogousOklch2 = primaryOklch.withHue(primaryOklch.h - 30); // -30°

  print(
      'Primary: ${primaryOklch.toString()} → ${primaryOklch.toRgb().toHexStr()}');
  print('Complementary (+180°): ${complementaryOklch.toRgb().toHexStr()}');
  print('Triadic 1 (+120°): ${triadicOklch1.toRgb().toHexStr()}');
  print('Triadic 2 (+240°): ${triadicOklch2.toRgb().toHexStr()}');
  print('Analogous 1 (+30°): ${analogousOklch1.toRgb().toHexStr()}');
  print('Analogous 2 (-30°): ${analogousOklch2.toRgb().toHexStr()}');
  print('');

  // Round-trip conversion comparison
  print('🔄 Round-trip Conversion Comparison:');
  final originalRgbBlue = RayRgb.fromHex('#4A90E2'); // Blue
  final viaOklchRound = originalRgbBlue.toOklch().toRgb();
  final viaOklabRound = originalRgbBlue.toOklab().toRgb();
  final viaHslRound = originalRgbBlue.toHsl().toRgb();

  print('Original RGB: ${originalRgbBlue.toHexStr()}');
  print('RGB → Oklch → RGB: ${viaOklchRound.toHexStr()}');
  print('RGB → Oklab → RGB: ${viaOklabRound.toHexStr()}');
  print('RGB → HSL → RGB: ${viaHslRound.toHexStr()}');
  print('');

  // Oklch vs HSL Saturation Comparison
  print('⚖️  Oklch vs HSL Saturation Comparison:');
  final testRgb = RayRgb.fromHex('#FF6B6B'); // Coral
  final testHsl = testRgb.toHsl();
  final testOklch = testRgb.toOklch();

  print('Original: ${testRgb.toHexStr()}');
  print(
      'HSL representation: H=${testHsl.hue.toStringAsFixed(1)}°, S=${testHsl.saturation.toStringAsFixed(3)}, L=${testHsl.lightness.toStringAsFixed(3)}');
  print(
      'Oklch representation: H=${testOklch.h.toStringAsFixed(1)}°, C=${testOklch.c.toStringAsFixed(3)}, L=${testOklch.l.toStringAsFixed(3)}');
  print('');

  // Desaturating comparison
  print('Desaturation comparison (50% reduction):');
  final hslDesaturated =
      testHsl.withSaturation(testHsl.saturation * 0.5).toRgb();
  final oklchDesaturated = testOklch.withChroma(testOklch.c * 0.5).toRgb();

  print('HSL 50% saturation: ${hslDesaturated.toHexStr()}');
  print('Oklch 50% chroma: ${oklchDesaturated.toHexStr()}');
  print('');

  print('✅ All examples completed successfully!');
}
