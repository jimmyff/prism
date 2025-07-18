import 'package:prism/prism.dart';

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

  print('✅ All examples completed successfully!');
}