import 'package:prism/prism.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  // Test data constants for comprehensive validation
  const testColors8 = {
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


  // Helper method to validate complete RayRgb8 state
  void validateRgb8(RayRgb8 ray, Map<String, dynamic> expected, {String? description}) {
    final desc = description ?? 'RayRgb8 validation';
    expect(ray.redInt, expected['r'], reason: '$desc: red component');
    expect(ray.greenInt, expected['g'], reason: '$desc: green component');
    expect(ray.blueInt, expected['b'], reason: '$desc: blue component');
    expect(ray.alphaInt, expected['a'], reason: '$desc: alpha component');
    expect(ray.toJson(), expected['argb'], reason: '$desc: ARGB value');
    expect(ray.toArgbInt(), expected['argb'], reason: '$desc: ARGB integer');
    expect(ray.toRgbaInt(), expected['rgbaInt'], reason: '$desc: RGBA integer');
    expect(ray.toRgbInt(), expected['argb'] & 0x00FFFFFF, reason: '$desc: RGB integer');
    expect(ray.toHexStr(), expected['hex6'], reason: '$desc: hex6 output');
    expect(ray.toHexStr(8), expected['hex8Rgba'], reason: '$desc: hex8 RGBA output');
    expect(ray.toHexStr(8, HexFormat.argb), expected['hex8Argb'], reason: '$desc: hex8 ARGB output');
    expect(ray.toRgbStr(), expected['rgb'], reason: '$desc: RGB string');
    expect(ray.toRgbaStr(), expected['rgba'], reason: '$desc: RGBA string');
  }


  group('RayRgb8 Core Functionality', () {
    group('Constructors', () {
      test('named parameter constructor creates correct color', () {
        final ray = RayRgb8(red: 255, green: 0, blue: 0);
        validateRgb8(ray, testColors8['red']!, description: 'named parameter red');
      });

      test('named parameter constructor with alpha', () {
        final ray = RayRgb8(red: 255, green: 0, blue: 0, alpha: 127);
        validateRgb8(ray, testColors8['semiTransparentRed']!, description: 'named parameter semi-transparent red');
      });

      test('creates color with default alpha', () {
        final color = RayRgb8(red: 255, green: 0, blue: 0);
        expect(color.alphaInt, equals(255));
        expect(color.redInt, equals(255));
        expect(color.greenInt, equals(0));
        expect(color.blueInt, equals(0));
      });

      test('fromARGB creates correct color', () {
        final ray = RayRgb8.fromARGB(255, 0, 255, 0);
        validateRgb8(ray, testColors8['green']!, description: 'fromARGB green');
      });

      test('fromARGB with transparency', () {
        final ray = RayRgb8.fromARGB(127, 255, 0, 0);
        validateRgb8(ray, testColors8['semiTransparentRed']!, description: 'fromARGB semi-transparent red');
      });

      test('creates color from ARGB integer', () {
        final color = RayRgb8.fromInt(0xFFFF0000); // Red with full alpha
        expect(color.alphaInt, equals(255));
        expect(color.redInt, equals(255));
        expect(color.greenInt, equals(0));
        expect(color.blueInt, equals(0));
      });

      test('fromJson creates correct color', () {
        final ray = RayRgb8.fromJson(testColors8['blue']!['argb'] as int);
        validateRgb8(ray, testColors8['blue']!, description: 'fromJson blue');
      });

      test('fromInt constructor creates correct color', () {
        final ray = RayRgb8.fromInt(testColors8['complexColor']!['argb'] as int);
        validateRgb8(ray, testColors8['complexColor']!, description: 'fromInt constructor');
      });

      test('empty color', () {
        final empty = RayRgb8.empty();
        expect(empty.toArgbInt(), 0x00000000);
        expect(empty.alphaInt, 0);
        expect(empty.redInt, 0);
        expect(empty.greenInt, 0);
        expect(empty.blueInt, 0);
      });
    });

    group('Component Access', () {
      test('component values are correct', () {
        final ray = RayRgb8.fromARGB(200, 100, 150, 75);
        expect(ray.alphaInt, 200);
        expect(ray.redInt, 100);
        expect(ray.greenInt, 150);
        expect(ray.blueInt, 75);
        expect(ray.opacity, closeTo(0.78, componentTolerance));
      });

      test('alpha channel edge cases', () {
        final transparent = RayRgb8(red: 255, green: 255, blue: 255, alpha: 0);
        expect(transparent.alphaInt, equals(0));
        
        final opaque = RayRgb8(red: 255, green: 255, blue: 255, alpha: 255);
        expect(opaque.alphaInt, equals(255));
      });

      test('opacity calculation', () {
        expect(RayRgb8.fromARGB(0, 0, 0, 0).opacity, 0.0);
        expect(RayRgb8.fromARGB(255, 0, 0, 0).opacity, 1.0);
        expect(RayRgb8.fromARGB(127, 0, 0, 0).opacity, closeTo(0.5, componentTolerance));
      });
    });

    group('Methods', () {
      test('withAlpha creates color with new alpha', () {
        final red = RayRgb8.fromARGB(255, 255, 0, 0);
        final semiRed = red.withAlpha(128);

        expect(semiRed.redInt, 255);
        expect(semiRed.greenInt, 0);
        expect(semiRed.blueInt, 0);
        expect(semiRed.alphaInt, 128);
        expect(semiRed.toArgbInt(), 0x80FF0000);
      });

      test('withOpacity creates color with new opacity', () {
        final red = RayRgb8.fromARGB(255, 255, 0, 0);
        final semiRed = red.withOpacity(0.5);

        expect(semiRed.redInt, 255);
        expect(semiRed.greenInt, 0);
        expect(semiRed.blueInt, 0);
        expect(semiRed.alphaInt, 128); // 0.5 * 255 rounded
        expect(semiRed.opacity, closeTo(0.5, componentTolerance));
      });

      test('withOpacity precision', () {
        final base = RayRgb8(red: 255, green: 0, blue: 0);
        final precise = base.withOpacity(0.5);
        expect(precise.alphaInt, 128); // Should be 127.5 rounded to 128
        expect(precise.opacity, closeTo(0.502, componentTolerance));
      });

      test('color inversion', () {
        final red = RayRgb8.fromARGB(255, 255, 0, 0);
        final inverted = red.inverse;
        expect(inverted.alphaInt, 255);
        expect(inverted.redInt, 0);
        expect(inverted.greenInt, 255);
        expect(inverted.blueInt, 255);
      });

      test('lerp interpolates between colors', () {
        final red = RayRgb8.fromARGB(255, 255, 0, 0);
        final blue = RayRgb8.fromARGB(255, 0, 0, 255);

        // Test endpoints
        final atStart = red.lerp(blue, 0.0);
        expect(atStart, red);

        final atEnd = red.lerp(blue, 1.0);
        expect(atEnd, blue);

        // Test midpoint
        final midpoint = red.lerp(blue, 0.5);
        expect(midpoint.redInt, 128);
        expect(midpoint.greenInt, 0);
        expect(midpoint.blueInt, 128);
        expect(midpoint.alphaInt, 255);

        // Test clamping
        final clamped = red.lerp(blue, 2.0);
        expect(clamped, blue);
      });

      test('equality operator works correctly', () {
        final red1 = RayRgb8.fromARGB(255, 255, 0, 0);
        final red2 = RayRgb8.fromARGB(255, 255, 0, 0);
        final blue = RayRgb8.fromARGB(255, 0, 0, 255);

        expect(red1, equals(red2));
        expect(red1, isNot(equals(blue)));
        expect(red1.hashCode, equals(red2.hashCode));
        expect(red1.hashCode, isNot(equals(blue.hashCode)));
      });
    });

    group('Properties', () {
      test('luminance calculation for primary colors', () {
        final black = RayRgb8.fromARGB(255, 0, 0, 0);
        final white = RayRgb8.fromARGB(255, 255, 255, 255);
        final red = RayRgb8.fromARGB(255, 255, 0, 0);

        expect(black.luminance, 0.0);
        expect(white.luminance, 1.0);
        expect(red.luminance, greaterThan(0.0));
        expect(red.luminance, lessThan(0.5));
      });

      test('max contrast selection', () {
        final gray = RayRgb8.fromARGB(255, 128, 128, 128);
        final black = RayRgb8.fromARGB(255, 0, 0, 0);
        final white = RayRgb8.fromARGB(255, 255, 255, 255);

        final selected = gray.maxContrast(black, white);
        expect(selected, equals(white));
      });

      test('toString formatting', () {
        final ray = RayRgb8.fromARGB(255, 255, 0, 0);
        expect(ray.toString(), 'RayRgb8(0xFFFF0000)');
      });
    });
  });

  group('RayRgb8 Format Conversions', () {
    group('Hex Parsing - RGBA Format (default)', () {
      test('6-digit hex parsing', () {
        final ray = RayRgb8.fromHex('#FF0000');
        validateRgb8(ray, testColors8['red']!, description: '6-digit hex red');
      });

      test('8-digit hex parsing', () {
        final ray = RayRgb8.fromHex('#FF00007F');
        validateRgb8(ray, testColors8['semiTransparentRed']!, description: '8-digit RGBA hex');
      });

      test('3-digit hex parsing', () {
        final ray = RayRgb8.fromHex('#F00');
        validateRgb8(ray, testColors8['red']!, description: '3-digit hex red');
      });

      test('3-digit hex parsing optimization', () {
        final red = RayRgb8.fromHex('#F00');
        expect(red.redInt, 255);
        expect(red.greenInt, 0);
        expect(red.blueInt, 0);
        expect(red.alphaInt, 255);

        final gray = RayRgb8.fromHex('#777');
        expect(gray.redInt, 119);
        expect(gray.greenInt, 119);
        expect(gray.blueInt, 119);
      });

      test('hex without # prefix', () {
        final ray = RayRgb8.fromHex('00FF00');
        validateRgb8(ray, testColors8['green']!, description: 'hex without # prefix');
      });

      test('case insensitive hex parsing', () {
        final upper = RayRgb8.fromHex('#FF0000');
        final lower = RayRgb8.fromHex('#ff0000');
        expect(upper.toArgbInt(), lower.toArgbInt());
      });
    });

    group('Hex Parsing - ARGB Format (explicit)', () {
      test('8-digit ARGB hex parsing', () {
        final ray = RayRgb8.fromHex('#FF000080', format: HexFormat.argb);
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
        validateRgb8(ray, expected, description: '8-digit ARGB hex');
      });

      test('ARGB format with transparency', () {
        final ray = RayRgb8.fromHex('#7FFF0000', format: HexFormat.argb);
        validateRgb8(ray, testColors8['semiTransparentRed']!, description: 'ARGB format semi-transparent');
      });
    });

    group('Integer Conversions', () {
      test('integer format conversions', () {
        final ray = RayRgb8.fromHex('#12345678');
        expect(ray.toArgbInt(), 0x78123456);
        expect(ray.toRgbaInt(), 0x12345678);
        expect(ray.toRgbInt(), 0x123456);
      });

      test('toHex with different lengths', () {
        final ray = RayRgb8.fromHex('#12345678');
        expect(ray.toHexStr(6), '#123456');
        expect(ray.toHexStr(8), '#12345678');
        expect(ray.toHexStr(8, HexFormat.argb), '#78123456');
      });

      test('bit mask constants work correctly', () {
        final color = RayRgb8.fromARGB(0xAA, 0xBB, 0xCC, 0xDD);
        expect(color.alphaInt, 0xAA);
        expect(color.redInt, 0xBB);
        expect(color.greenInt, 0xCC);
        expect(color.blueInt, 0xDD);
      });
    });

    group('String Conversions', () {
      test('string format conversions', () {
        final ray = RayRgb8.fromARGB(127, 255, 128, 64);
        expect(ray.toRgbStr(), 'rgb(255, 128, 64)');
        expect(ray.toRgbaStr(), 'rgba(255, 128, 64, 0.50)');
      });
    });

    group('Round-trip Consistency', () {
      test('RGBA to ARGB conversion consistency', () {
        final rgbaHex = '#FF00007F';
        final argbHex = '#7FFF0000';

        final fromRgba = RayRgb8.fromHex(rgbaHex);
        final fromArgb = RayRgb8.fromHex(argbHex, format: HexFormat.argb);

        expect(fromRgba.toArgbInt(), fromArgb.toArgbInt());
        expect(fromRgba.redInt, fromArgb.redInt);
        expect(fromRgba.greenInt, fromArgb.greenInt);
        expect(fromRgba.blueInt, fromArgb.blueInt);
        expect(fromRgba.alphaInt, fromArgb.alphaInt);
      });

      test('round trip conversion consistency', () {
        final original = RayRgb8.fromARGB(127, 255, 128, 64);

        // Test RGBA round trip
        final rgbaHex = original.toHexStr(8);
        final fromRgbaHex = RayRgb8.fromHex(rgbaHex);
        expect(fromRgbaHex.toArgbInt(), original.toArgbInt());

        // Test ARGB round trip
        final argbHex = original.toHexStr(8, HexFormat.argb);
        final fromArgbHex = RayRgb8.fromHex(argbHex, format: HexFormat.argb);
        expect(fromArgbHex.toArgbInt(), original.toArgbInt());
      });
    });
  });

  group('RayRgb16 Core Functionality', () {
    group('Constructors', () {
      test('creates color with basic constructor', () {
        final color = RayRgb16(red: 65535, green: 32768, blue: 16384, alpha: 50000);
        
        expect(color.redInt, equals(65535));
        expect(color.greenInt, equals(32768));
        expect(color.blueInt, equals(16384));
        expect(color.alphaInt, equals(50000), reason: 'Alpha channel should return 50000, not -1');
      });

      test('creates color with default alpha', () {
        final color = RayRgb16(red: 65535, green: 0, blue: 0);
        
        expect(color.alphaInt, equals(65535), reason: 'Default alpha should be 65535 (full opacity)');
        expect(color.redInt, equals(65535));
        expect(color.greenInt, equals(0));
        expect(color.blueInt, equals(0));
      });

      test('creates color from ARGB integer', () {
        // Test with a known 64-bit value: full alpha red
        final value = (65535 << 48) | (65535 << 32); // Alpha: 65535, Red: 65535
        final color = RayRgb16.fromInt(value);
        
        expect(color.alphaInt, equals(65535), reason: 'Alpha extraction from 64-bit integer failed');
        expect(color.redInt, equals(65535));
        expect(color.greenInt, equals(0));
        expect(color.blueInt, equals(0));
      });

      test('creates color from ARGB components', () {
        final color = RayRgb16.fromARGB(32768, 65535, 40000, 20000);
        
        expect(color.alphaInt, equals(32768), reason: 'Alpha from ARGB constructor failed');
        expect(color.redInt, equals(65535));
        expect(color.greenInt, equals(40000));
        expect(color.blueInt, equals(20000));
      });

      test('creates empty color', () {
        final empty = RayRgb16.empty();
        expect(empty.alphaInt, 0);
        expect(empty.redInt, 0);
        expect(empty.greenInt, 0);
        expect(empty.blueInt, 0);
      });

      test('creates color from JSON', () {
        final color = RayRgb16.fromJson(0x3039000000000000);
        expect(color.alphaInt, equals(12345));
        expect(color.redInt, equals(0));
        expect(color.greenInt, equals(0));
        expect(color.blueInt, equals(0));
      });
    });

    group('Component Access', () {
      test('alpha channel edge cases', () {
        final transparent = RayRgb16(red: 65535, green: 65535, blue: 65535, alpha: 0);
        expect(transparent.alphaInt, equals(0), reason: 'Transparent alpha should be 0');
        
        final opaque = RayRgb16(red: 65535, green: 65535, blue: 65535, alpha: 65535);
        expect(opaque.alphaInt, equals(65535), reason: 'Opaque alpha should be 65535');
      });

      test('all component values work correctly', () {
        final color = RayRgb16(red: 12345, green: 23456, blue: 34567, alpha: 45678);
        expect(color.redInt, equals(12345));
        expect(color.greenInt, equals(23456));
        expect(color.blueInt, equals(34567));
        expect(color.alphaInt, equals(45678));
      });
    });

    group('Methods', () {
      test('withAlpha creates color with new alpha', () {
        final original = RayRgb16(red: 65535, green: 32768, blue: 16384, alpha: 65535);
        final modified = original.withAlpha(12345);
        
        expect(modified.redInt, equals(65535));
        expect(modified.greenInt, equals(32768));
        expect(modified.blueInt, equals(16384));
        expect(modified.alphaInt, equals(12345));
      });

      test('withOpacity creates color with new opacity', () {
        final original = RayRgb16(red: 65535, green: 32768, blue: 16384, alpha: 65535);
        final modified = original.withOpacity(0.5);
        
        expect(modified.redInt, equals(65535));
        expect(modified.greenInt, equals(32768));
        expect(modified.blueInt, equals(16384));
        expect(modified.alphaInt, equals(32768)); // 0.5 * 65535 rounded
      });

      test('lerp interpolation works correctly', () {
        final red = RayRgb16(red: 65535, green: 0, blue: 0, alpha: 65535);
        final blue = RayRgb16(red: 0, green: 0, blue: 65535, alpha: 65535);
        
        final midpoint = red.lerp(blue, 0.5);
        // Note: lerp converts to 8-bit, interpolates, then converts back to 16-bit
        expect(midpoint.redInt, equals(128 * 257)); // Half red in 16-bit
        expect(midpoint.greenInt, equals(0));
        expect(midpoint.blueInt, equals(128 * 257)); // Half blue in 16-bit
        expect(midpoint.alphaInt, equals(255 * 257)); // Full alpha in 16-bit
      });

      test('inverse works correctly', () {
        final red = RayRgb16(red: 65535, green: 0, blue: 0, alpha: 65535);
        final inverted = red.inverse;
        // Note: inverse converts to 8-bit, inverts, then converts back to 16-bit
        expect(inverted.redInt, equals(0));
        expect(inverted.greenInt, equals(255 * 257));
        expect(inverted.blueInt, equals(255 * 257));
        expect(inverted.alphaInt, equals(255 * 257));
      });

      test('equality and hash code', () {
        final color1 = RayRgb16(red: 65535, green: 0, blue: 0, alpha: 65535);
        final color2 = RayRgb16(red: 65535, green: 0, blue: 0, alpha: 65535);
        final color3 = RayRgb16(red: 0, green: 65535, blue: 0, alpha: 65535);

        expect(color1, equals(color2));
        expect(color1, isNot(equals(color3)));
        expect(color1.hashCode, equals(color2.hashCode));
        expect(color1.hashCode, isNot(equals(color3.hashCode)));
      });

      test('toString formatting', () {
        final color = RayRgb16(red: 65535, green: 0, blue: 0, alpha: 65535);
        expect(color.toString(), contains('RayRgb16'));
        expect(color.toString(), contains('0x'));
      });
    });
  });

  group('RayRgb16 Format Conversions', () {
    group('64-bit Integer Conversions', () {
      test('toArgbInt returns correct 64-bit value', () {
        final color = RayRgb16(red: 0x1234, green: 0x5678, blue: 0x9ABC, alpha: 0xDEF0);
        final argbInt = color.toArgbInt();
        
        // Verify the bit layout: AAAA RRRR GGGG BBBB (each component 16 bits)
        expect((argbInt >> 48) & 0xFFFF, equals(0xDEF0)); // Alpha
        expect((argbInt >> 32) & 0xFFFF, equals(0x1234)); // Red
        expect((argbInt >> 16) & 0xFFFF, equals(0x5678)); // Green
        expect(argbInt & 0xFFFF, equals(0x9ABC)); // Blue
      });

      test('toRgbInt excludes alpha channel', () {
        final color = RayRgb16(red: 0x1234, green: 0x5678, blue: 0x9ABC, alpha: 0xDEF0);
        final rgbInt = color.toRgbInt();
        
        // Should be RGB only: 0000 RRRR GGGG BBBB
        expect(rgbInt, equals(0x0000123456789ABC));
      });

      test('toRgbaInt reorders components', () {
        final color = RayRgb16(red: 0x1234, green: 0x5678, blue: 0x9ABC, alpha: 0xDEF0);
        final rgbaInt = color.toRgbaInt();
        
        // Should be RGBA: RRRR GGGG BBBB AAAA
        expect(rgbaInt, equals(0x123456789ABCDEF0));
      });

      test('toJson returns internal value', () {
        final color = RayRgb16(red: 12345, green: 23456, blue: 34567, alpha: 45678);
        final json = color.toJson();
        expect(json, equals(color.toArgbInt()));
      });
    });

    group('Hex String Conversions', () {
      test('toHexStr with 12 characters (RGB only)', () {
        final color = RayRgb16(red: 0x1234, green: 0x5678, blue: 0x9ABC, alpha: 0xDEF0);
        final hex12 = color.toHexStr(12);
        expect(hex12, equals('#123456789ABC'));
      });

      test('toHexStr with 16 characters (RGBA)', () {
        final color = RayRgb16(red: 0x1234, green: 0x5678, blue: 0x9ABC, alpha: 0xDEF0);
        final hex16 = color.toHexStr(16);
        expect(hex16, equals('#123456789ABCDEF0'));
      });

      test('toHexStr with invalid length throws error', () {
        final color = RayRgb16(red: 0, green: 0, blue: 0, alpha: 0);
        expect(() => color.toHexStr(8), throwsArgumentError);
        expect(() => color.toHexStr(10), throwsArgumentError);
      });
    });
  });

  group('Bit Depth Conversions', () {
    group('RayRgb8 → RayRgb16', () {
      test('converts 8-bit to 16-bit correctly', () {
        final rgb8 = RayRgb8(red: 255, green: 128, blue: 64, alpha: 200);
        final rgb16 = RayRgb16.fromRgb8(rgb8);
        
        // 8-bit to 16-bit conversion: multiply by 257 (255 * 257 = 65535)
        expect(rgb16.redInt, equals(255 * 257));
        expect(rgb16.greenInt, equals(128 * 257));
        expect(rgb16.blueInt, equals(64 * 257));
        expect(rgb16.alphaInt, equals(200 * 257), reason: 'Alpha conversion from 8-bit to 16-bit failed');
      });

      test('RGB8 white converts to RGB16 maximum white', () {
        final white8 = RayRgb8(red: 255, green: 255, blue: 255, alpha: 255);
        final white16 = RayRgb16.fromRgb8(white8);
        
        expect(white16.redInt, equals(65535), reason: 'Red should be maximum 16-bit value');
        expect(white16.greenInt, equals(65535), reason: 'Green should be maximum 16-bit value'); 
        expect(white16.blueInt, equals(65535), reason: 'Blue should be maximum 16-bit value');
        expect(white16.alphaInt, equals(65535), reason: 'Alpha should be maximum 16-bit value');
      });

      test('converts edge cases correctly', () {
        final transparent8 = RayRgb8(red: 255, green: 255, blue: 255, alpha: 0);
        final transparent16 = RayRgb16.fromRgb8(transparent8);
        expect(transparent16.alphaInt, equals(0));
        
        final opaque8 = RayRgb8(red: 255, green: 255, blue: 255, alpha: 255);
        final opaque16 = RayRgb16.fromRgb8(opaque8);
        expect(opaque16.alphaInt, equals(65535));
      });
    });

    group('RayRgb16 → RayRgb8', () {
      test('converts 16-bit to 8-bit correctly', () {
        final rgb16 = RayRgb16(red: 65535, green: 32768, blue: 16384, alpha: 50000);
        final rgb8 = rgb16.toRgb8();
        
        // 16-bit to 8-bit conversion: divide by 257 or shift right by 8
        expect(rgb8.redInt, equals(255)); // 65535 >> 8 = 255
        expect(rgb8.greenInt, equals(128)); // 32768 >> 8 = 128  
        expect(rgb8.blueInt, equals(64)); // 16384 >> 8 = 64
        expect(rgb8.alphaInt, equals(195)); // 50000 >> 8 = 195
      });

      test('RGB16 maximum white converts to RGB8 white', () {
        final white16 = RayRgb16(red: 65535, green: 65535, blue: 65535, alpha: 65535);
        final white8 = white16.toRgb8();
        
        expect(white8.redInt, equals(255), reason: 'Red should be maximum 8-bit value');
        expect(white8.greenInt, equals(255), reason: 'Green should be maximum 8-bit value'); 
        expect(white8.blueInt, equals(255), reason: 'Blue should be maximum 8-bit value');
        expect(white8.alphaInt, equals(255), reason: 'Alpha should be maximum 8-bit value');
      });
    });

    group('Round-trip Precision Testing', () {
      test('round-trip conversion maintains precision', () {
        // Test that demonstrates precision maintained in round-trip conversion
        final original8 = RayRgb8(red: 100, green: 150, blue: 200, alpha: 128);
        final converted16 = RayRgb16.fromRgb8(original8);
        final backTo8 = converted16.toRgb8();
        
        // Should be identical after round-trip
        expect(backTo8.redInt, equals(original8.redInt));
        expect(backTo8.greenInt, equals(original8.greenInt));
        expect(backTo8.blueInt, equals(original8.blueInt));
        expect(backTo8.alphaInt, equals(original8.alphaInt));
      });

      test('self conversion returns same instance', () {
        final original16 = RayRgb16(red: 12345, green: 23456, blue: 34567, alpha: 45678);
        final converted16 = original16.toRgb16();
        
        expect(identical(original16, converted16), isTrue, reason: 'toRgb16 should return self');
      });
    });

    group('Edge Case Conversions', () {
      test('boundary values convert correctly', () {
        // Test boundary values that might cause issues
        final testValues8 = [0, 1, 127, 128, 254, 255];
        
        for (final value in testValues8) {
          final rgb8 = RayRgb8(red: value, green: value, blue: value, alpha: value);
          final rgb16 = RayRgb16.fromRgb8(rgb8);
          final backToRgb8 = rgb16.toRgb8();
          
          expect(backToRgb8.redInt, equals(value), reason: 'Round-trip failed for value $value');
          expect(backToRgb8.greenInt, equals(value), reason: 'Round-trip failed for value $value');
          expect(backToRgb8.blueInt, equals(value), reason: 'Round-trip failed for value $value');
          expect(backToRgb8.alphaInt, equals(value), reason: 'Round-trip failed for value $value');
        }
      });
    });
  });

  group('Regression Tests', () {
    group('Alpha Channel Sign Extension Fix', () {
      test('alpha values >= 32768 work correctly', () {
        final testValues = [32768, 40000, 50000, 60000, 65535];
        
        for (final alpha in testValues) {
          final color = RayRgb16(red: 0, green: 0, blue: 0, alpha: alpha);
          expect(color.alphaInt, equals(alpha), reason: 'Alpha=$alpha should not be negative');
          expect(color.alphaInt, greaterThanOrEqualTo(0), reason: 'Alpha should never be negative');
        }
      });

      test('specific problematic alpha values', () {
        // Values that previously caused sign extension issues
        final problematicValues = [32768, 50000, 65535];
        
        for (final alpha in problematicValues) {
          final color = RayRgb16(red: 65535, green: 32768, blue: 16384, alpha: alpha);
          expect(color.alphaInt, equals(alpha), reason: 'Problematic alpha value $alpha failed');
          expect(color.alphaInt, isPositive, reason: 'Alpha should be positive');
        }
      });

      test('all 16-bit alpha values work correctly', () {
        // Test a comprehensive range of alpha values
        final testValues = [0, 1, 127, 128, 255, 256, 32767, 32768, 65534, 65535];
        
        for (final alpha in testValues) {
          final color = RayRgb16(red: 0, green: 0, blue: 0, alpha: alpha);
          expect(color.alphaInt, equals(alpha), reason: 'RayRgb16 alpha=$alpha failed');
          expect(color.alphaInt, greaterThanOrEqualTo(0), reason: 'Alpha should not be negative');
          expect(color.alphaInt, lessThanOrEqualTo(65535), reason: 'Alpha should not exceed 16-bit max');
        }
      });

      test('bit operations manual verification', () {
        // Test the bit operations step by step for a known problematic value
        const alpha = 50000; // Previously returned -15536
        final color = RayRgb16(red: 0, green: 0, blue: 0, alpha: alpha);
        
        final argbInt = color.toArgbInt();
        
        // Manual bit extraction using the same constants as in the class
        const alphaMask = 0xFFFF000000000000;
        const alphaShift = 48;
        
        final maskedValue = alphaMask & argbInt;
        final shiftedValue = maskedValue >> alphaShift;
        final finalValue = shiftedValue & 0xFFFF; // The fix: mask to 16 bits
        
        expect(finalValue, equals(alpha), reason: 'Manual bit extraction with fix should work');
        expect(finalValue, equals(alpha), reason: 'Final masked value should equal alpha');
        expect(color.alphaInt, equals(alpha), reason: 'Getter should return correct alpha');
      });
    });

    group('Critical Value Verification', () {
      test('maximum values work correctly', () {
        // Test with all maximum values
        final maxColor = RayRgb16(red: 65535, green: 65535, blue: 65535, alpha: 65535);
        
        expect(maxColor.redInt, equals(65535));
        expect(maxColor.greenInt, equals(65535));
        expect(maxColor.blueInt, equals(65535));
        expect(maxColor.alphaInt, equals(65535));
      });

      test('minimum values work correctly', () {
        // Test with all minimum values
        final minColor = RayRgb16(red: 0, green: 0, blue: 0, alpha: 0);
        
        expect(minColor.redInt, equals(0));
        expect(minColor.greenInt, equals(0));
        expect(minColor.blueInt, equals(0));
        expect(minColor.alphaInt, equals(0));
      });

      test('sign extension boundary values', () {
        // Test specific values around the 15-bit boundary where sign extension occurs
        final boundaryValues = [32767, 32768, 32769];
        
        for (final value in boundaryValues) {
          final color = RayRgb16(red: value, green: value, blue: value, alpha: value);
          
          expect(color.redInt, equals(value), reason: 'Red component failed for boundary value $value');
          expect(color.greenInt, equals(value), reason: 'Green component failed for boundary value $value');
          expect(color.blueInt, equals(value), reason: 'Blue component failed for boundary value $value');
          expect(color.alphaInt, equals(value), reason: 'Alpha component failed for boundary value $value');
        }
      });
    });
  });

  group('Error Handling', () {
    test('fromHex throws for invalid hex characters', () {
      expect(() => RayRgb8.fromHex('#GGGGGG'), throwsArgumentError);
      expect(() => RayRgb8.fromHex('#FF00ZZ'), throwsArgumentError);
      expect(() => RayRgb8.fromHex('invalid'), throwsArgumentError);
    });

    test('fromHex throws for invalid hex length', () {
      expect(() => RayRgb8.fromHex('#FF'), throwsArgumentError);
      expect(() => RayRgb8.fromHex('#FF00'), throwsArgumentError);
      expect(() => RayRgb8.fromHex('#FF0000000'), throwsArgumentError);
    });

    test('toHex throws for invalid length', () {
      final red = RayRgb8.fromARGB(255, 255, 0, 0);
      expect(() => red.toHexStr(5), throwsArgumentError);
      expect(() => red.toHexStr(9), throwsArgumentError);
      expect(() => red.toHexStr(0), throwsArgumentError);
    });

    test('RayRgb16 toHexStr throws for invalid lengths', () {
      final color = RayRgb16(red: 0, green: 0, blue: 0, alpha: 0);
      expect(() => color.toHexStr(8), throwsArgumentError);
      expect(() => color.toHexStr(10), throwsArgumentError);
      expect(() => color.toHexStr(20), throwsArgumentError);
    });
  });
}