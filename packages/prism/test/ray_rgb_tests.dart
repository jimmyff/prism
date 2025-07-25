import 'package:prism/prism.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

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
      'r': 255,
      'g': 0,
      'b': 0,
      'a': 255,
    },
    'green': {
      'argb': 0xFF00FF00,
      'rgbaInt': 0x00FF00FF,
      'hex6': '#00FF00',
      'hex8Rgba': '#00FF00FF',
      'hex8Argb': '#FF00FF00',
      'rgb': 'rgb(0, 255, 0)',
      'rgba': 'rgba(0, 255, 0, 1.00)',
      'r': 0,
      'g': 255,
      'b': 0,
      'a': 255,
    },
    'blue': {
      'argb': 0xFF0000FF,
      'rgbaInt': 0x0000FFFF,
      'hex6': '#0000FF',
      'hex8Rgba': '#0000FFFF',
      'hex8Argb': '#FF0000FF',
      'rgb': 'rgb(0, 0, 255)',
      'rgba': 'rgba(0, 0, 255, 1.00)',
      'r': 0,
      'g': 0,
      'b': 255,
      'a': 255,
    },
    'semiTransparentRed': {
      'argb': 0x7FFF0000,
      'rgbaInt': 0xFF00007F,
      'hex6': '#FF0000',
      'hex8Rgba': '#FF00007F',
      'hex8Argb': '#7FFF0000',
      'rgb': 'rgb(255, 0, 0)',
      'rgba': 'rgba(255, 0, 0, 0.50)',
      'r': 255,
      'g': 0,
      'b': 0,
      'a': 127,
    },
    'complexColor': {
      'argb': 0x78123456,
      'rgbaInt': 0x12345678,
      'hex6': '#123456',
      'hex8Rgba': '#12345678',
      'hex8Argb': '#78123456',
      'rgb': 'rgb(18, 52, 86)',
      'rgba': 'rgba(18, 52, 86, 0.47)',
      'r': 18,
      'g': 52,
      'b': 86,
      'a': 120,
    },
  };

  // Helper method to validate complete ray state
  void validateRay(RayRgb ray, Map<String, dynamic> expected,
      {String? description}) {
    final desc = description ?? 'Ray validation';
    expect(ray.red, expected['r'], reason: '$desc: red component');
    expect(ray.green, expected['g'], reason: '$desc: green component');
    expect(ray.blue, expected['b'], reason: '$desc: blue component');
    expect(ray.alpha, expected['a'], reason: '$desc: alpha component');
    expect(ray.toJson(), expected['argb'], reason: '$desc: ARGB value');
    expect(ray.toArgbInt(), expected['argb'], reason: '$desc: ARGB integer');
    expect(ray.toRgbaInt(), expected['rgbaInt'], reason: '$desc: RGBA integer');
    expect(ray.toRgbInt(), expected['argb'] & 0x00FFFFFF,
        reason: '$desc: RGB integer');
    expect(ray.toHexStr(), expected['hex6'], reason: '$desc: hex6 output');
    expect(ray.toHexStr(8), expected['hex8Rgba'],
        reason: '$desc: hex8 RGBA output');
    expect(ray.toHexStr(8, HexFormat.argb), expected['hex8Argb'],
        reason: '$desc: hex8 ARGB output');
    expect(ray.toRgbStr(), expected['rgb'], reason: '$desc: RGB string');
    expect(ray.toRgbaStr(), expected['rgba'], reason: '$desc: RGBA string');
  }

  group('Ray Constructors', () {
    test('named parameter constructor creates correct color', () {
      final ray = RayRgb(red: 255, green: 0, blue: 0);
      validateRay(ray, testColors['red']!, description: 'named parameter red');
    });

    test('named parameter constructor with alpha', () {
      final ray = RayRgb(red: 255, green: 0, blue: 0, alpha: 127);
      validateRay(ray, testColors['semiTransparentRed']!,
          description: 'named parameter semi-transparent red');
    });

    test('fromARGB creates correct color', () {
      final ray = RayRgb.fromARGB(255, 0, 255, 0);
      validateRay(ray, testColors['green']!, description: 'fromARGB green');
    });

    test('fromARGB with transparency', () {
      final ray = RayRgb.fromARGB(127, 255, 0, 0);
      validateRay(ray, testColors['semiTransparentRed']!,
          description: 'fromARGB semi-transparent red');
    });

    test('fromJson creates correct color', () {
      final ray = RayRgb.fromJson(testColors['blue']!['argb'] as int);
      validateRay(ray, testColors['blue']!, description: 'fromJson blue');
    });

    test('fromInt constructor creates correct color', () {
      final ray = RayRgb.fromInt(testColors['complexColor']!['argb'] as int);
      validateRay(ray, testColors['complexColor']!,
          description: 'fromInt constructor');
    });
  });

  group('Hex Format Parsing', () {
    group('RGBA Format (default)', () {
      test('6-digit hex parsing', () {
        final ray = RayRgb.fromHex('#FF0000');
        validateRay(ray, testColors['red']!, description: '6-digit hex red');
      });

      test('8-digit hex parsing', () {
        final ray = RayRgb.fromHex('#FF00007F');
        validateRay(ray, testColors['semiTransparentRed']!,
            description: '8-digit RGBA hex');
      });

      test('3-digit hex parsing', () {
        final ray = RayRgb.fromHex('#F00');
        validateRay(ray, testColors['red']!, description: '3-digit hex red');
      });

      test('hex without # prefix', () {
        final ray = RayRgb.fromHex('00FF00');
        validateRay(ray, testColors['green']!,
            description: 'hex without # prefix');
      });
    });

    group('ARGB Format (explicit)', () {
      test('8-digit ARGB hex parsing', () {
        final ray = RayRgb.fromHex('#FF000080', format: HexFormat.argb);
        final expected = {
          'r': 0,
          'g': 0,
          'b': 128,
          'a': 255,
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
        final ray = RayRgb.fromHex('#7FFF0000', format: HexFormat.argb);
        validateRay(ray, testColors['semiTransparentRed']!,
            description: 'ARGB format semi-transparent');
      });
    });

    group('Hex Format Edge Cases', () {
      test('invalid hex length throws error', () {
        expect(() => RayRgb.fromHex('#FF00'), throwsA(isA<ArgumentError>()));
        expect(
            () => RayRgb.fromHex('#FF0000000'), throwsA(isA<ArgumentError>()));
      });

      test('case insensitive hex parsing', () {
        final upper = RayRgb.fromHex('#FF0000');
        final lower = RayRgb.fromHex('#ff0000');
        expect(upper.toArgbInt(), lower.toArgbInt());
      });
    });
  });

  group('Output Format Conversion', () {
    test('toHex with different lengths', () {
      final ray = RayRgb.fromHex('#12345678');
      expect(ray.toHexStr(6), '#123456');
      expect(ray.toHexStr(8), '#12345678');
      expect(ray.toHexStr(8, HexFormat.argb), '#78123456');
    });

    test('toHex throws error for invalid length', () {
      final ray = RayRgb.fromHex('#FF0000');
      expect(() => ray.toHexStr(5), throwsA(isA<ArgumentError>()));
      expect(() => ray.toHexStr(9), throwsA(isA<ArgumentError>()));
    });

    test('integer format conversions', () {
      final ray = RayRgb.fromHex('#12345678');
      expect(ray.toArgbInt(), 0x78123456);
      expect(ray.toRgbaInt(), 0x12345678);
      expect(ray.toRgbInt(), 0x123456);
    });

    test('string format conversions', () {
      final ray = RayRgb.fromARGB(127, 255, 128, 64);
      expect(ray.toRgbStr(), 'rgb(255, 128, 64)');
      expect(ray.toRgbaStr(), 'rgba(255, 128, 64, 0.50)');
    });
  });

  group('Color Properties', () {
    test('component values are correct', () {
      final ray = RayRgb.fromARGB(200, 100, 150, 75);
      expect(ray.alpha, 200);
      expect(ray.red, 100);
      expect(ray.green, 150);
      expect(ray.blue, 75);
      expect(ray.opacity, closeTo(0.78, componentTolerance));
    });

    test('opacity calculation', () {
      expect(RayRgb.fromARGB(0, 0, 0, 0).opacity, 0.0);
      expect(RayRgb.fromARGB(255, 0, 0, 0).opacity, 1.0);
      expect(RayRgb.fromARGB(127, 0, 0, 0).opacity,
          closeTo(0.5, componentTolerance));
    });

    test('color inversion', () {
      final red = RayRgb.fromARGB(255, 255, 0, 0);
      final inverted = red.inverse;
      expect(inverted.alpha, 255);
      expect(inverted.red, 0);
      expect(inverted.green, 255);
      expect(inverted.blue, 255);
    });
  });

  group('Luminance and Contrast', () {
    test('luminance calculation for primary colors', () {
      final black = RayRgb.fromARGB(255, 0, 0, 0);
      final white = RayRgb.fromARGB(255, 255, 255, 255);
      final red = RayRgb.fromARGB(255, 255, 0, 0);

      expect(black.luminance, 0.0);
      expect(white.luminance, 1.0);
      expect(red.luminance, greaterThan(0.0));
      expect(red.luminance, lessThan(0.5));
    });

    test('max contrast selection', () {
      final gray = RayRgb.fromARGB(255, 128, 128, 128);
      final black = RayRgb.fromARGB(255, 0, 0, 0);
      final white = RayRgb.fromARGB(255, 255, 255, 255);

      final selected = gray.maxContrast(black, white);
      expect(selected, equals(white));
    });
  });

  group('Special Cases', () {
    test('empty color', () {
      final empty = RayRgb.empty();
      expect(empty.toArgbInt(), 0x00000000);
      expect(empty.alpha, 0);
      expect(empty.red, 0);
      expect(empty.green, 0);
      expect(empty.blue, 0);
    });

    test('toString formatting', () {
      final ray = RayRgb.fromARGB(255, 255, 0, 0);
      expect(ray.toString(), 'RayRgb(0xFFFF0000)');
    });

    test('equality and hash code', () {
      final ray1 = RayRgb.fromARGB(255, 255, 0, 0);
      final ray2 = RayRgb.fromARGB(255, 255, 0, 0);
      final ray3 = RayRgb.fromARGB(255, 0, 255, 0);

      expect(ray1.toArgbInt(), ray2.toArgbInt());
      expect(ray1.toArgbInt(), isNot(ray3.toArgbInt()));
    });
  });

  group('Format Interoperability', () {
    test('RGBA to ARGB conversion consistency', () {
      final rgbaHex = '#FF00007F';
      final argbHex = '#7FFF0000';

      final fromRgba = RayRgb.fromHex(rgbaHex);
      final fromArgb = RayRgb.fromHex(argbHex, format: HexFormat.argb);

      expect(fromRgba.toArgbInt(), fromArgb.toArgbInt());
      expect(fromRgba.red, fromArgb.red);
      expect(fromRgba.green, fromArgb.green);
      expect(fromRgba.blue, fromArgb.blue);
      expect(fromRgba.alpha, fromArgb.alpha);
    });

    test('round trip conversion consistency', () {
      final original = RayRgb.fromARGB(127, 255, 128, 64);

      // Test RGBA round trip
      final rgbaHex = original.toHexStr(8);
      final fromRgbaHex = RayRgb.fromHex(rgbaHex);
      expect(fromRgbaHex.toArgbInt(), original.toArgbInt());

      // Test ARGB round trip
      final argbHex = original.toHexStr(8, HexFormat.argb);
      final fromArgbHex = RayRgb.fromHex(argbHex, format: HexFormat.argb);
      expect(fromArgbHex.toArgbInt(), original.toArgbInt());
    });
  });

  group('New API Methods', () {
    test('withAlpha creates color with new alpha', () {
      final red = RayRgb.fromARGB(255, 255, 0, 0);
      final semiRed = red.withAlpha(128);

      expect(semiRed.red, 255);
      expect(semiRed.green, 0);
      expect(semiRed.blue, 0);
      expect(semiRed.alpha, 128);
      expect(semiRed.toArgbInt(), 0x80FF0000);
    });

    test('withOpacity creates color with new opacity', () {
      final red = RayRgb.fromARGB(255, 255, 0, 0);
      final semiRed = red.withOpacity(0.5);

      expect(semiRed.red, 255);
      expect(semiRed.green, 0);
      expect(semiRed.blue, 0);
      expect(semiRed.alpha, 128); // 0.5 * 255 rounded
      expect(semiRed.opacity, closeTo(0.5, componentTolerance));
    });

    test('lerp interpolates between colors', () {
      final red = RayRgb.fromARGB(255, 255, 0, 0);
      final blue = RayRgb.fromARGB(255, 0, 0, 255);

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
      final red1 = RayRgb.fromARGB(255, 255, 0, 0);
      final red2 = RayRgb.fromARGB(255, 255, 0, 0);
      final blue = RayRgb.fromARGB(255, 0, 0, 255);

      expect(red1, equals(red2));
      expect(red1, isNot(equals(blue)));
      expect(red1.hashCode, equals(red2.hashCode));
      expect(red1.hashCode, isNot(equals(blue.hashCode)));
    });
  });

  group('Error Handling', () {
    test('fromHex throws for invalid hex characters', () {
      expect(() => RayRgb.fromHex('#GGGGGG'), throwsArgumentError);
      expect(() => RayRgb.fromHex('#FF00ZZ'), throwsArgumentError);
      expect(() => RayRgb.fromHex('invalid'), throwsArgumentError);
    });

    test('fromHex throws for invalid hex length', () {
      expect(() => RayRgb.fromHex('#FF'), throwsArgumentError);
      expect(() => RayRgb.fromHex('#FF00'), throwsArgumentError);
      expect(() => RayRgb.fromHex('#FF0000000'), throwsArgumentError);
    });

    test('toHex throws for invalid length', () {
      final red = RayRgb.fromARGB(255, 255, 0, 0);
      expect(() => red.toHexStr(5), throwsArgumentError);
      expect(() => red.toHexStr(9), throwsArgumentError);
      expect(() => red.toHexStr(0), throwsArgumentError);
    });
  });

  group('Optimizations Verification', () {
    test('3-digit hex parsing optimization', () {
      final red = RayRgb.fromHex('#F00');
      expect(red.red, 255);
      expect(red.green, 0);
      expect(red.blue, 0);
      expect(red.alpha, 255);

      final gray = RayRgb.fromHex('#777');
      expect(gray.red, 119);
      expect(gray.green, 119);
      expect(gray.blue, 119);
    });

    test('bit mask constants work correctly', () {
      final color = RayRgb.fromARGB(0xAA, 0xBB, 0xCC, 0xDD);
      expect(color.alpha, 0xAA);
      expect(color.red, 0xBB);
      expect(color.green, 0xCC);
      expect(color.blue, 0xDD);
    });

    test('withOpacity precision', () {
      final base = RayRgb(red: 255, green: 0, blue: 0);
      final precise = base.withOpacity(0.5);
      expect(precise.alpha, 128); // Should be 127.5 rounded to 128
      expect(precise.opacity, closeTo(0.502, componentTolerance));
    });
  });
}
