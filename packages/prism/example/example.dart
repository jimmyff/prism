import 'package:prism/prism.dart';
import 'package:prism/palettes/rgb/css.dart';
import 'package:prism/palettes/rgb/material.dart';

void main() {
  print('🌈 Prism Library Demo\n');

  // === Color Creation ===
  print('🎨 Creating Colors:');
  final rgbRed = RayRgb8.fromHex('#FF0000');
  final rgb16Color = RayRgb16.fromRgb(220.5, 137.2, 180.8, 127);
  final hslGreen = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
  final oklabBlue = RayOklab(l: 0.452, a: -0.032, b: -0.312);
  final oklchPurple = RayOklch(l: 0.6, c: 0.2, h: 300);

  print('RGB8: ${rgbRed.toHex()} (R:${rgbRed.red}, G:${rgbRed.green})');
  print('RGB16: (R:${rgb16Color.red}, G:${rgb16Color.green}, Native R:${rgb16Color.redNative})');
  print('HSL Green: ${hslGreen.toRgb8().toHex()}');
  print('Oklab Blue: ${oklabBlue.toRgb8().toHex()}');
  print('Oklch Purple: ${oklchPurple.toRgb8().toHex()}\n');

  // === Seamless Conversion ===
  print('🔄 Color Model Conversion:');
  final baseColor = RayRgb8.fromHex('#FF6B35'); // Orange
  print('Original RGB: ${baseColor.toHex()}');
  print('→ HSL: ${baseColor.toHsl()}');
  print('→ Oklab: ${baseColor.toOklab()}');
  print('→ Oklch: ${baseColor.toOklch()}');
  print('Round-trip: ${baseColor.toHsl().toRgb8().toHex()}\n');

  // === Color Manipulation ===
  print('🔧 Color Manipulation:');
  final red = RayRgb8.fromHex('#E53E3E');
  final blue = RayRgb8.fromHex('#3182CE');

  print('Original: ${red.toHex()}');
  print('50% Opacity: ${red.withOpacity(0.5).toHex(8)}');
  print('Interpolated (Red→Blue): ${red.lerp(blue, 0.5).toHex()}');
  print('Inverted: ${red.inverse.toHex()}');

  // HSL manipulation
  final hslColor = red.toHsl();
  print(
      'Hue shifted (+60°): ${hslColor.withHue(hslColor.hue + 60).toRgb8().toHex()}');

  // Oklch manipulation (perceptually uniform)
  final oklchColor = red.toOklch();
  print(
      'Darker (perceptual): ${oklchColor.withLightness(0.3).toRgb8().toHex()}\n');

  // === Accessibility Schemes ===
  print('♿ Accessibility Schemes:');
  final colors = [
    RayRgb8.fromHex('#2D3748'), // Dark gray
    RayRgb8.fromHex('#E53E3E'), // Red
    RayRgb8.fromHex('#38A169'), // Green
    RayRgb8.fromHex('#3182CE'), // Blue
  ];

  for (final color in colors) {
    final scheme = RayScheme.fromRay(color);
    final theme = scheme.source.isDark ? 'Dark' : 'Light';
    print('${color.toHex()} → $theme theme');
    print('  Text color: ${scheme.source.onRay.toHex()}');
    print('  Light surface: ${scheme.surfaceLight.toHex()}');
    print('  Dark surface: ${scheme.surfaceDark.toHex()}');
  }
  print('');

  // === Color Palettes ===
  print('🎨 Color Palettes:');

  // CSS Colors
  print('CSS Palette:');
  print('  Navy: ${CssRgb.navy.source.toHex()}');
  print('  Crimson: ${CssRgb.crimson.source.toHex()}');
  print('  Gold: ${CssRgb.gold.source.toHex()}');

  // Material Design
  print('Material Design:');
  print('  Blue 500: ${MaterialRgb.blue.shade500?.toHex() ?? "N/A"}');
  print('  Red 700: ${MaterialRgb.red.shade700?.toHex() ?? "N/A"}');
  print('  Green A200: ${MaterialRgb.green.accent200?.toHex() ?? "N/A"}');
  print('');

  // === Advanced Features ===
  print('🧪 Advanced Features:');

  // Perceptual interpolation comparison
  final startRgb = RayRgb8.fromHex('#FF0000'); // Red
  final endRgb = RayRgb8.fromHex('#00FF00'); // Green
  final rgbMidpoint = startRgb.lerp(endRgb, 0.5);
  final oklabMidpoint = startRgb.toOklab().lerp(endRgb.toOklab(), 0.5).toRgb8();

  print('RGB Interpolation: ${rgbMidpoint.toHex()}');
  print('Oklab Interpolation: ${oklabMidpoint.toHex()}');

  // Color analysis
  print('\nColor Analysis:');
  final testColor = RayRgb8.fromHex('#4A90E2');
  print('Color: ${testColor.toHex()}');
  print('Luminance: ${testColor.computeLuminance().toStringAsFixed(3)}');
  final bestContrast = testColor.maxContrast(
      RayRgb8.fromHex('#000000'), RayRgb8.fromHex('#FFFFFF')) as RayRgb8;
  print('Best contrast: ${bestContrast.toHex()}');

  // HSL color distance
  final color1 = RayHsl(hue: 30, saturation: 0.8, lightness: 0.6);
  final color2 = RayHsl(hue: 150, saturation: 0.6, lightness: 0.4);
  print('Hue distance: ${color1.hueDistance(color2).toStringAsFixed(1)}°');

  print('\n✅ Demo completed successfully!');
}
