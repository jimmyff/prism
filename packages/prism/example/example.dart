import 'package:prism/prism.dart';
import 'package:prism/palettes/css.dart';
import 'package:prism/palettes/material.dart';

void main() {
  print('🌈 Prism Library Demo\n');

  // === Color Creation ===
  print('🎨 Creating Colors:');
  final rgbRed = RayRgb.fromHex('#FF0000');
  final hslGreen = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
  final oklabBlue = RayOklab(l: 0.452, a: -0.032, b: -0.312);
  final oklchPurple = RayOklch(l: 0.6, c: 0.2, h: 300);

  print('RGB Red: ${rgbRed.toHexStr()}');
  print('HSL Green: ${hslGreen.toRgb().toHexStr()}');
  print('Oklab Blue: ${oklabBlue.toRgb().toHexStr()}');
  print('Oklch Purple: ${oklchPurple.toRgb().toHexStr()}\n');

  // === Seamless Conversion ===
  print('🔄 Color Model Conversion:');
  final baseColor = RayRgb.fromHex('#FF6B35'); // Orange
  print('Original RGB: ${baseColor.toHexStr()}');
  print('→ HSL: ${baseColor.toHsl()}');
  print('→ Oklab: ${baseColor.toOklab()}');
  print('→ Oklch: ${baseColor.toOklch()}');
  print('Round-trip: ${baseColor.toHsl().toRgb().toHexStr()}\n');

  // === Color Manipulation ===
  print('🔧 Color Manipulation:');
  final red = RayRgb.fromHex('#E53E3E');
  final blue = RayRgb.fromHex('#3182CE');
  
  print('Original: ${red.toHexStr()}');
  print('50% Opacity: ${red.withOpacity(0.5).toHexStr(8)}');
  print('Interpolated (Red→Blue): ${red.lerp(blue, 0.5).toHexStr()}');
  print('Inverted: ${red.inverse.toHexStr()}');
  
  // HSL manipulation
  final hslColor = red.toHsl();
  print('Hue shifted (+60°): ${hslColor.withHue(hslColor.hue + 60).toRgb().toHexStr()}');
  
  // Oklch manipulation (perceptually uniform)
  final oklchColor = red.toOklch();
  print('Darker (perceptual): ${oklchColor.withLightness(0.3).toRgb().toHexStr()}\n');

  // === Accessibility Schemes ===
  print('♿ Accessibility Schemes:');
  final colors = [
    RayRgb.fromHex('#2D3748'), // Dark gray
    RayRgb.fromHex('#E53E3E'), // Red
    RayRgb.fromHex('#38A169'), // Green
    RayRgb.fromHex('#3182CE'), // Blue
  ];

  for (final color in colors) {
    final scheme = RayScheme.fromRay(color);
    final theme = scheme.source.isDark ? 'Dark' : 'Light';
    print('${color.toHexStr()} → $theme theme');
    print('  Text color: ${scheme.source.onRay.toHexStr()}');
    print('  Light surface: ${scheme.surfaceLight.toHexStr()}');
    print('  Dark surface: ${scheme.surfaceDark.toHexStr()}');
  }
  print('');

  // === Color Palettes ===
  print('🎨 Color Palettes:');
  
  // CSS Colors
  print('CSS Palette:');
  print('  Navy: ${CssRgb.navy.source.toHexStr()}');
  print('  Crimson: ${CssRgb.crimson.source.toHexStr()}');
  print('  Gold: ${CssRgb.gold.source.toHexStr()}');
  
  // Material Design
  print('Material Design:');
  print('  Blue 500: ${MaterialRgb.blue.shade500?.toHexStr() ?? "N/A"}');
  print('  Red 700: ${MaterialRgb.red.shade700?.toHexStr() ?? "N/A"}');
  print('  Green A200: ${MaterialRgb.green.accent200?.toHexStr() ?? "N/A"}');
  print('');

  // === Advanced Features ===
  print('🧪 Advanced Features:');
  
  // Perceptual interpolation comparison
  final startRgb = RayRgb.fromHex('#FF0000'); // Red
  final endRgb = RayRgb.fromHex('#00FF00');   // Green
  final rgbMidpoint = startRgb.lerp(endRgb, 0.5);
  final oklabMidpoint = startRgb.toOklab().lerp(endRgb.toOklab(), 0.5).toRgb();
  
  print('RGB Interpolation: ${rgbMidpoint.toHexStr()}');
  print('Oklab Interpolation: ${oklabMidpoint.toHexStr()}');
  
  // Color analysis
  print('\nColor Analysis:');
  final testColor = RayRgb.fromHex('#4A90E2');
  print('Color: ${testColor.toHexStr()}');
  print('Luminance: ${testColor.computeLuminance().toStringAsFixed(3)}');
  final bestContrast = testColor.maxContrast(RayRgb.fromHex('#000000'), RayRgb.fromHex('#FFFFFF')) as RayRgb;
  print('Best contrast: ${bestContrast.toHexStr()}');
  
  // HSL color distance
  final color1 = RayHsl(hue: 30, saturation: 0.8, lightness: 0.6);
  final color2 = RayHsl(hue: 150, saturation: 0.6, lightness: 0.4);
  print('Hue distance: ${color1.hueDistance(color2).toStringAsFixed(1)}°');
  
  print('\n✅ Demo completed successfully!');
}