import 'package:prism/prism.dart';
import 'package:test/test.dart';

void main() {
  // Test data constants
  const testColors = {
    'red': {
      'argb': 0xFFFF0000,
      'rgbaInt': 0xFF0000FF,
      'hex6': '#FF0000',
      'hex8Rgba': '#FF0000FF',
      'hex8Argb': '#FFFF0000',
      'rgb': 'rgb(255, 0, 0)',
      'rgba': 'rgba(255, 0, 0, 1.00)',
      'r': 255, 'g': 0, 'b': 0, 'a': 255,
    },
    'green': {
      'argb': 0xFF00FF00,
      'rgbaInt': 0x00FF00FF,
      'hex6': '#00FF00',
      'hex8Rgba': '#00FF00FF',
      'hex8Argb': '#FF00FF00',
      'rgb': 'rgb(0, 255, 0)',
      'rgba': 'rgba(0, 255, 0, 1.00)',
      'r': 0, 'g': 255, 'b': 0, 'a': 255,
    },
    'blue': {
      'argb': 0xFF0000FF,
      'rgbaInt': 0x0000FFFF,
      'hex6': '#0000FF',
      'hex8Rgba': '#0000FFFF',
      'hex8Argb': '#FF0000FF',
      'rgb': 'rgb(0, 0, 255)',
      'rgba': 'rgba(0, 0, 255, 1.00)',
      'r': 0, 'g': 0, 'b': 255, 'a': 255,
    },
    'semiTransparentRed': {
      'argb': 0x7FFF0000,
      'rgbaInt': 0xFF00007F,
      'hex6': '#FF0000',
      'hex8Rgba': '#FF00007F',
      'hex8Argb': '#7FFF0000',
      'rgb': 'rgb(255, 0, 0)',
      'rgba': 'rgba(255, 0, 0, 0.50)',
      'r': 255, 'g': 0, 'b': 0, 'a': 127,
    },
    'complexColor': {
      'argb': 0x78123456,
      'rgbaInt': 0x12345678,
      'hex6': '#123456',
      'hex8Rgba': '#12345678',
      'hex8Argb': '#78123456',
      'rgb': 'rgb(18, 52, 86)',
      'rgba': 'rgba(18, 52, 86, 0.47)',
      'r': 18, 'g': 52, 'b': 86, 'a': 120,
    },
  };

  // Helper method to validate complete ray state
  void validateRay(Ray ray, Map<String, dynamic> expected, {String? description}) {
    final desc = description ?? 'Ray validation';
    expect(ray.red, expected['r'], reason: '$desc: red component');
    expect(ray.green, expected['g'], reason: '$desc: green component');
    expect(ray.blue, expected['b'], reason: '$desc: blue component');
    expect(ray.alpha, expected['a'], reason: '$desc: alpha component');
    expect(ray.toJson(), expected['argb'], reason: '$desc: ARGB value');
    expect(ray.toIntARGB(), expected['argb'], reason: '$desc: ARGB integer');
    expect(ray.toIntRGBA(), expected['rgbaInt'], reason: '$desc: RGBA integer');
    expect(ray.toIntRGB(), expected['argb'] & 0x00FFFFFF, reason: '$desc: RGB integer');
    expect(ray.toHex(), expected['hex6'], reason: '$desc: hex6 output');
    expect(ray.toHex(8), expected['hex8Rgba'], reason: '$desc: hex8 RGBA output');
    expect(ray.toHex(8, HexFormat.argb), expected['hex8Argb'], reason: '$desc: hex8 ARGB output');
    expect(ray.toRGB(), expected['rgb'], reason: '$desc: RGB string');
    expect(ray.toRGBA(), expected['rgba'], reason: '$desc: RGBA string');
  }

  group('Ray Constructors', () {
    test('fromRGBO creates correct color', () {
      final ray = Ray.fromRGBO(255, 0, 0, 1.0);
      validateRay(ray, testColors['red']!, description: 'fromRGBO red');
    });

    test('fromRGBO with transparency', () {
      final ray = Ray.fromRGBO(255, 0, 0, 0.5);
      validateRay(ray, testColors['semiTransparentRed']!, description: 'fromRGBO semi-transparent red');
    });

    test('fromARGB creates correct color', () {
      final ray = Ray.fromARGB(255, 0, 255, 0);
      validateRay(ray, testColors['green']!, description: 'fromARGB green');
    });

    test('fromARGB with transparency', () {
      final ray = Ray.fromARGB(127, 255, 0, 0);
      validateRay(ray, testColors['semiTransparentRed']!, description: 'fromARGB semi-transparent red');
    });

    test('fromJson creates correct color', () {
      final ray = Ray.fromJson(testColors['blue']!['argb'] as int);
      validateRay(ray, testColors['blue']!, description: 'fromJson blue');
    });

    test('direct constructor creates correct color', () {
      final ray = Ray(testColors['complexColor']!['argb'] as int);
      validateRay(ray, testColors['complexColor']!, description: 'direct constructor');
    });
  });

  group('Hex Format Parsing', () {
    group('RGBA Format (default)', () {
      test('6-digit hex parsing', () {
        final ray = Ray.fromHex('#FF0000');
        validateRay(ray, testColors['red']!, description: '6-digit hex red');
      });

      test('8-digit hex parsing', () {
        final ray = Ray.fromHex('#FF00007F');
        validateRay(ray, testColors['semiTransparentRed']!, description: '8-digit RGBA hex');
      });

      test('3-digit hex parsing', () {
        final ray = Ray.fromHex('#F00');
        validateRay(ray, testColors['red']!, description: '3-digit hex red');
      });

      test('hex without # prefix', () {
        final ray = Ray.fromHex('00FF00');
        validateRay(ray, testColors['green']!, description: 'hex without # prefix');
      });
    });

    group('ARGB Format (explicit)', () {
      test('8-digit ARGB hex parsing', () {
        final ray = Ray.fromHex('#FF000080', format: HexFormat.argb);
        final expected = {
          'r': 0, 'g': 0, 'b': 128, 'a': 255,
          'argb': 0xFF000080,
          'rgbaInt': 0x000080FF,
          'hex6': '#000080',
          'hex8Rgba': '#000080FF',
          'hex8Argb': '#FF000080',
          'rgb': 'rgb(0, 0, 128)',
          'rgba': 'rgba(0, 0, 128, 1.00)',
        };
        validateRay(ray, expected, description: '8-digit ARGB hex');
      });

      test('ARGB format with transparency', () {
        final ray = Ray.fromHex('#7FFF0000', format: HexFormat.argb);
        validateRay(ray, testColors['semiTransparentRed']!, description: 'ARGB format semi-transparent');
      });
    });

    group('Hex Format Edge Cases', () {
      test('invalid hex length throws error', () {
        expect(() => Ray.fromHex('#FF00'), throwsA(isA<ArgumentError>()));
        expect(() => Ray.fromHex('#FF0000000'), throwsA(isA<ArgumentError>()));
      });

      test('case insensitive hex parsing', () {
        final upper = Ray.fromHex('#FF0000');
        final lower = Ray.fromHex('#ff0000');
        expect(upper.toIntARGB(), lower.toIntARGB());
      });
    });
  });

  group('Output Format Conversion', () {
    test('toHex with different lengths', () {
      final ray = Ray.fromHex('#12345678');
      expect(ray.toHex(6), '#123456');
      expect(ray.toHex(8), '#12345678');
      expect(ray.toHex(8, HexFormat.argb), '#78123456');
    });

    test('toHex throws error for invalid length', () {
      final ray = Ray.fromHex('#FF0000');
      expect(() => ray.toHex(5), throwsA(isA<ArgumentError>()));
      expect(() => ray.toHex(9), throwsA(isA<ArgumentError>()));
    });

    test('integer format conversions', () {
      final ray = Ray.fromHex('#12345678');
      expect(ray.toIntARGB(), 0x78123456);
      expect(ray.toIntRGBA(), 0x12345678);
      expect(ray.toIntRGB(), 0x123456);
    });

    test('string format conversions', () {
      final ray = Ray.fromARGB(127, 255, 128, 64);
      expect(ray.toRGB(), 'rgb(255, 128, 64)');
      expect(ray.toRGBA(), 'rgba(255, 128, 64, 0.50)');
    });
  });

  group('Color Properties', () {
    test('component values are correct', () {
      final ray = Ray.fromARGB(200, 100, 150, 75);
      expect(ray.alpha, 200);
      expect(ray.red, 100);
      expect(ray.green, 150);
      expect(ray.blue, 75);
      expect(ray.opacity, closeTo(0.78, 0.01));
    });

    test('opacity calculation', () {
      expect(Ray.fromARGB(0, 0, 0, 0).opacity, 0.0);
      expect(Ray.fromARGB(255, 0, 0, 0).opacity, 1.0);
      expect(Ray.fromARGB(127, 0, 0, 0).opacity, closeTo(0.5, 0.01));
    });

    test('color inversion', () {
      final red = Ray.fromARGB(255, 255, 0, 0);
      final inverted = red.inverse;
      expect(inverted.alpha, 255);
      expect(inverted.red, 0);
      expect(inverted.green, 255);
      expect(inverted.blue, 255);
    });
  });

  group('Luminance and Contrast', () {
    test('luminance calculation for primary colors', () {
      final black = Ray.fromARGB(255, 0, 0, 0);
      final white = Ray.fromARGB(255, 255, 255, 255);
      final red = Ray.fromARGB(255, 255, 0, 0);
      
      expect(black.computeLuminance(), 0.0);
      expect(white.computeLuminance(), 1.0);
      expect(red.computeLuminance(), greaterThan(0.0));
      expect(red.computeLuminance(), lessThan(0.5));
    });

    test('max contrast selection', () {
      final gray = Ray.fromARGB(255, 128, 128, 128);
      final black = Ray.fromARGB(255, 0, 0, 0);
      final white = Ray.fromARGB(255, 255, 255, 255);
      
      final selected = gray.maxContrast(black, white);
      expect(selected, equals(white));
    });
  });

  group('Special Cases', () {
    test('empty color', () {
      final empty = Ray.empty();
      expect(empty.toIntARGB(), 0x00000000);
      expect(empty.alpha, 0);
      expect(empty.red, 0);
      expect(empty.green, 0);
      expect(empty.blue, 0);
    });

    test('toString formatting', () {
      final ray = Ray.fromARGB(255, 255, 0, 0);
      expect(ray.toString(), 'Ray(0xFFFF0000)');
    });

    test('equality and hash code', () {
      final ray1 = Ray.fromARGB(255, 255, 0, 0);
      final ray2 = Ray.fromARGB(255, 255, 0, 0);
      final ray3 = Ray.fromARGB(255, 0, 255, 0);
      
      expect(ray1.toIntARGB(), ray2.toIntARGB());
      expect(ray1.toIntARGB(), isNot(ray3.toIntARGB()));
    });
  });

  group('Format Interoperability', () {
    test('RGBA to ARGB conversion consistency', () {
      final rgbaHex = '#FF00007F';
      final argbHex = '#7FFF0000';
      
      final fromRgba = Ray.fromHex(rgbaHex);
      final fromArgb = Ray.fromHex(argbHex, format: HexFormat.argb);
      
      expect(fromRgba.toIntARGB(), fromArgb.toIntARGB());
      expect(fromRgba.red, fromArgb.red);
      expect(fromRgba.green, fromArgb.green);
      expect(fromRgba.blue, fromArgb.blue);
      expect(fromRgba.alpha, fromArgb.alpha);
    });

    test('round trip conversion consistency', () {
      final original = Ray.fromARGB(127, 255, 128, 64);
      
      // Test RGBA round trip
      final rgbaHex = original.toHex(8);
      final fromRgbaHex = Ray.fromHex(rgbaHex);
      expect(fromRgbaHex.toIntARGB(), original.toIntARGB());
      
      // Test ARGB round trip  
      final argbHex = original.toHex(8, HexFormat.argb);
      final fromArgbHex = Ray.fromHex(argbHex, format: HexFormat.argb);
      expect(fromArgbHex.toIntARGB(), original.toIntARGB());
    });
  });

  group('New API Methods', () {
    test('withAlpha creates color with new alpha', () {
      final red = Ray.fromARGB(255, 255, 0, 0);
      final semiRed = red.withAlpha(128);
      
      expect(semiRed.red, 255);
      expect(semiRed.green, 0);
      expect(semiRed.blue, 0);
      expect(semiRed.alpha, 128);
      expect(semiRed.toIntARGB(), 0x80FF0000);
    });

    test('withOpacity creates color with new opacity', () {
      final red = Ray.fromARGB(255, 255, 0, 0);
      final semiRed = red.withOpacity(0.5);
      
      expect(semiRed.red, 255);
      expect(semiRed.green, 0);
      expect(semiRed.blue, 0);
      expect(semiRed.alpha, 127); // 0.5 * 255 rounded
      expect(semiRed.opacity, closeTo(0.5, 0.01));
    });

    test('lerp interpolates between colors', () {
      final red = Ray.fromARGB(255, 255, 0, 0);
      final blue = Ray.fromARGB(255, 0, 0, 255);
      
      // Test endpoints
      final atStart = red.lerp(blue, 0.0);
      expect(atStart, red);
      
      final atEnd = red.lerp(blue, 1.0);
      expect(atEnd, blue);
      
      // Test midpoint
      final midpoint = red.lerp(blue, 0.5);
      expect(midpoint.red, 128);
      expect(midpoint.green, 0);
      expect(midpoint.blue, 128);
      expect(midpoint.alpha, 255);
      
      // Test clamping
      final clamped = red.lerp(blue, 2.0);
      expect(clamped, blue);
    });

    test('equality operator works correctly', () {
      final red1 = Ray.fromARGB(255, 255, 0, 0);
      final red2 = Ray.fromARGB(255, 255, 0, 0);
      final blue = Ray.fromARGB(255, 0, 0, 255);
      
      expect(red1, equals(red2));
      expect(red1, isNot(equals(blue)));
      expect(red1.hashCode, equals(red2.hashCode));
      expect(red1.hashCode, isNot(equals(blue.hashCode)));
    });
  });

  group('Error Handling', () {
    test('fromHex throws for invalid hex characters', () {
      expect(() => Ray.fromHex('#GGGGGG'), throwsArgumentError);
      expect(() => Ray.fromHex('#FF00ZZ'), throwsArgumentError);
      expect(() => Ray.fromHex('invalid'), throwsArgumentError);
    });

    test('fromHex throws for invalid hex length', () {
      expect(() => Ray.fromHex('#FF'), throwsArgumentError);
      expect(() => Ray.fromHex('#FF00'), throwsArgumentError);
      expect(() => Ray.fromHex('#FF0000000'), throwsArgumentError);
    });

    test('toHex throws for invalid length', () {
      final red = Ray.fromARGB(255, 255, 0, 0);
      expect(() => red.toHex(5), throwsArgumentError);
      expect(() => red.toHex(9), throwsArgumentError);
      expect(() => red.toHex(0), throwsArgumentError);
    });
  });

  group('Optimizations Verification', () {
    test('3-digit hex parsing optimization', () {
      final red = Ray.fromHex('#F00');
      expect(red.red, 255);
      expect(red.green, 0);
      expect(red.blue, 0);
      expect(red.alpha, 255);
      
      final gray = Ray.fromHex('#777');
      expect(gray.red, 119);
      expect(gray.green, 119);
      expect(gray.blue, 119);
    });

    test('bit mask constants work correctly', () {
      final color = Ray.fromARGB(0xAA, 0xBB, 0xCC, 0xDD);
      expect(color.alpha, 0xAA);
      expect(color.red, 0xBB);
      expect(color.green, 0xCC);
      expect(color.blue, 0xDD);
    });

    test('improved fromRGBO precision', () {
      final precise = Ray.fromRGBO(255, 0, 0, 0.5);
      expect(precise.alpha, 127); // Should be 127.5 rounded to 127
      expect(precise.opacity, closeTo(0.498, 0.01));
    });
  });
}