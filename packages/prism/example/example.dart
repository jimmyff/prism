import 'package:prism/prism.dart';
import 'package:prism/palettes/css.dart';
import 'package:prism/palettes/material.dart';
import 'package:prism/palettes/catppuccin_mocha.dart';
import 'package:prism/palettes/solarized.dart';
import 'package:prism/palettes/open_color.dart';

void main() {
  print('🌈 Prism Examples\n');

  // === Ray Creation ===
  print('✨ Creating Rays:');
  final red = Ray.fromHex('#FF0000');
  final blue = Ray.fromARGB(255, 0, 0, 255);
  final green = Ray.fromRGBO(0, 255, 0, 1.0);
  final transparent = Ray.fromHex('#FF000080'); // 50% transparent red
  
  print('Red: ${red.toHex()}');
  print('Blue: ${blue.toHex()}');
  print('Green: ${green.toHex()}');
  print('Transparent Red: ${transparent.toHex(8)}');
  print('');

  // === Format Conversion ===
  print('🔄 Format Conversions:');
  print('Hex: ${red.toHex()}');
  print('CSS RGB: ${red.toRGB()}');
  print('CSS RGBA: ${transparent.toRGBA()}');
  print('ARGB Integer: 0x${red.toIntARGB().toRadixString(16).toUpperCase()}');
  print('JSON: ${red.toJson()}');
  print('');

  // === Ray Manipulation ===
  print('🔧 Ray Manipulation:');
  final semiRed = red.withOpacity(0.5);
  final darkRed = red.withAlpha(128);
  final cyan = red.inverse;
  
  print('50% Opacity Red: ${semiRed.toRGBA()}');
  print('Dark Red: ${darkRed.toHex(8)}');
  print('Red Inverse (Cyan): ${cyan.toHex()}');
  print('');

  // === Ray Interpolation ===
  print('🌈 Ray Interpolation:');
  final purple = red.lerp(blue, 0.5);
  final orange = red.lerp(Ray.fromHex('#FFFF00'), 0.5);
  
  print('Red → Blue (50%): ${purple.toHex()}');
  print('Red → Yellow (50%): ${orange.toHex()}');
  print('');

  // === Advanced Features ===
  print('🔬 Advanced Features:');
  final colors = [
    Ray.fromHex('#FF0000'), // Red
    Ray.fromHex('#00FF00'), // Green
    Ray.fromHex('#0000FF'), // Blue
    Ray.fromHex('#FFFF00'), // Yellow
    Ray.fromHex('#FF00FF'), // Magenta
  ];
  
  print('Ray Analysis:');
  for (final ray in colors) {
    final luminance = ray.computeLuminance();
    final brightness = luminance > 0.5 ? 'Light' : 'Dark';
    print('${ray.toHex()}: $brightness (luminance: ${luminance.toStringAsFixed(3)})');
  }
  print('');

  // === Hex Format Support ===
  print('🌐 Hex Format Support:');
  final webRay = Ray.fromHex('#FF000080'); // RGBA format
  final flutterRay = Ray.fromHex('#80FF0000', format: HexFormat.argb); // ARGB format
  
  print('Web format (#FF000080): ${webRay.toRGBA()}');
  print('Flutter format (#80FF0000): ${flutterRay.toRGBA()}');
  print('Same ray? ${webRay == flutterRay}');
  print('');

  // === Accessibility ===
  print('♿ Accessibility Features:');
  final gray = Ray.fromHex('#808080');
  final black = Ray.fromHex('#000000');
  final white = Ray.fromHex('#FFFFFF');
  
  final bestContrast = gray.maxContrast(black, white);
  print('Best contrast for gray: ${bestContrast.toHex()}');
  print('');

  // === Performance Demo ===
  print('⚡ Performance Demo:');
  final stopwatch = Stopwatch()..start();
  
  // Create gradient of 100 rays
  final spectrum = <Ray>[];
  for (int i = 0; i < 100; i++) {
    spectrum.add(red.lerp(blue, i / 99.0));
  }
  
  stopwatch.stop();
  print('Created 100-ray spectrum in ${stopwatch.elapsedMicroseconds}μs');
  print('First: ${spectrum.first.toHex()} → Last: ${spectrum.last.toHex()}');
  print('');

  // === RayScheme Examples ===
  print('🎭 RayScheme - Accessibility-Focused Color Schemes:');
  final primaryColors = [
    Ray.fromHex('#2196F3'), // Blue
    Ray.fromHex('#F44336'), // Red
    Ray.fromHex('#4CAF50'), // Green
    Ray.fromHex('#FF9800'), // Orange
    Ray.fromHex('#9C27B0'), // Purple
  ];
  
  for (final color in primaryColors) {
    final scheme = RayScheme.fromRay(color);
    final theme = scheme.isDark ? 'Dark' : 'Light';
    print('${color.toHex()} → $theme theme:');
    print('  ├─ Text color: ${scheme.onRay.toHex()}');
    print('  ├─ Light surface: ${scheme.surfaceLight.toHex()}');
    print('  ├─ Dark surface: ${scheme.surfaceDark.toHex()}');
    print('  └─ Luminance: ${scheme.luminance.toStringAsFixed(3)}');
  }
  print('');

  // === Color Palettes ===
  print('🎨 Color Palettes:');
  
  // CSS Colors
  print('CSS Colors:');
  final cssColors = [CssPalette.red, CssPalette.blue, CssPalette.green, CssPalette.gold];
  for (final color in cssColors) {
    print('  ${color.name}: ${color.scheme.ray.toHex()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
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
    print('  ${color.name}: ${color.scheme.ray.toHex()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
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
    print('  ${color.name}: ${color.scheme.ray.toHex()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
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
    print('  ${color.name}: ${color.scheme.ray.toHex()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
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
    print('  ${color.name}: ${color.scheme.ray.toHex()} (${color.scheme.isDark ? 'Dark' : 'Light'})');
  }
  print('');

  // === Palette Theme Generation ===
  print('🌙 Theme Generation Example:');
  final themeColor = CssPalette.blue.scheme;
  
  print('Creating a blue theme:');
  print('  Primary: ${themeColor.ray.toHex()}');
  print('  On Primary: ${themeColor.onRay.toHex()}');
  print('  Surface (Light): ${themeColor.surfaceLight.toHex()}');
  print('  Surface (Dark): ${themeColor.surfaceDark.toHex()}');
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
    print('  Step $i: ${step.toHex()} (contrast: ${stepScheme.onRay.toHex()})');
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
      Ray.fromHex('#000000'), // Black
      Ray.fromHex('#FFFFFF'), // White
    );
    print('  $name:');
    print('    └─ Best contrast: ${contrast.toHex()} (${contrast == Ray.fromHex('#000000') ? 'Black' : 'White'})');
  }
  print('');

  print('✅ All examples completed successfully!');
}