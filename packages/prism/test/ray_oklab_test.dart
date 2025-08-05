import 'package:test/test.dart';
import 'package:prism/prism.dart';

import 'test_constants.dart';

void main() {
  group('RayOklab', () {
    group('Construction', () {
      test('creates Oklab color with valid components', () {
        final color = RayOklab(l: 0.7, a: 0.1, b: -0.1, opacity: 1.0);

        expect(color.l, equals(0.7));
        expect(color.a, equals(0.1));
        expect(color.b, equals(-0.1));
        expect(color.opacity, equals(1.0));
        expect(color.colorSpace, equals(ColorSpace.oklab));
      });

      test('creates Oklab color with default opacity', () {
        final color = RayOklab(l: 0.5, a: 0.0, b: 0.0);

        expect(color.opacity, equals(1.0));
      });

      test('creates Oklab color from LAB components', () {
        final color = RayOklab.fromLab(0.8, 0.2, -0.15, 0.9);

        expect(color.l, equals(0.8));
        expect(color.a, equals(0.2));
        expect(color.b, equals(-0.15));
        expect(color.opacity, equals(0.9));
      });

      test('creates empty Oklab color', () {
        final color = RayOklab.empty();

        expect(color.l, equals(0.0));
        expect(color.a, equals(0.0));
        expect(color.b, equals(0.0));
        expect(color.opacity, equals(0.0));
      });

      test('creates Oklab color from JSON', () {
        final json = {'l': 0.6, 'a': 0.15, 'b': -0.2, 'o': 0.8};
        final color = RayOklab.fromJson(json);

        expect(color.l, equals(0.6));
        expect(color.a, equals(0.15));
        expect(color.b, equals(-0.2));
        expect(color.opacity, equals(0.8));
      });

      test('creates Oklab color from JSON with default opacity', () {
        final json = {'l': 0.5, 'a': 0.0, 'b': 0.0};
        final color = RayOklab.fromJson(json);

        expect(color.opacity, equals(1.0));
      });
    });

    group('Properties', () {
      test('returns correct color model', () {
        final color = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        expect(color.colorSpace, equals(ColorSpace.oklab));
      });

      test('returns correct opacity', () {
        final color = RayOklab(l: 0.5, a: 0.0, b: 0.0, opacity: 0.7);
        expect(color.opacity, equals(0.7));
      });
    });

    group('withOpacity', () {
      test('creates new color with different opacity', () {
        final original = RayOklab(l: 0.7, a: 0.1, b: -0.1, opacity: 1.0);
        final modified = original.withOpacity(0.5);

        expect(modified.l, equals(original.l));
        expect(modified.a, equals(original.a));
        expect(modified.b, equals(original.b));
        expect(modified.opacity, equals(0.5));
        expect(modified, isNot(same(original)));
      });

      test('throws ArgumentError for invalid opacity', () {
        final color = RayOklab(l: 0.5, a: 0.0, b: 0.0);

        expect(() => color.withOpacity(-0.1), throwsArgumentError);
        expect(() => color.withOpacity(1.1), throwsArgumentError);
      });
    });

    group('lerp', () {
      test('interpolates between two Oklab colors', () {
        final color1 = RayOklab(l: 0.3, a: -0.1, b: 0.1, opacity: 0.5);
        final color2 = RayOklab(l: 0.7, a: 0.1, b: -0.1, opacity: 1.0);

        final midpoint = color1.lerp(color2, 0.5);

        expect(midpoint.l, closeTo(0.5, oklabTolerance));
        expect(midpoint.a, closeTo(0.0, oklabTolerance));
        expect(midpoint.b, closeTo(0.0, oklabTolerance));
        expect(midpoint.opacity, closeTo(0.75, oklabTolerance));
      });

      test('returns original color at t=0', () {
        final color1 = RayOklab(l: 0.3, a: -0.1, b: 0.1);
        final color2 = RayOklab(l: 0.7, a: 0.1, b: -0.1);

        final result = color1.lerp(color2, 0.0);

        expect(result.l, equals(color1.l));
        expect(result.a, equals(color1.a));
        expect(result.b, equals(color1.b));
        expect(result.opacity, equals(color1.opacity));
      });

      test('returns other color at t=1', () {
        final color1 = RayOklab(l: 0.3, a: -0.1, b: 0.1);
        final color2 = RayOklab(l: 0.7, a: 0.1, b: -0.1);

        // Should convert color2 to Oklab (already Oklab in this case)
        final result = color1.lerp(color2, 1.0);

        expect(result.l, equals(color2.l));
        expect(result.a, equals(color2.a));
        expect(result.b, equals(color2.b));
        expect(result.opacity, equals(color2.opacity));
      });

      test('interpolates with RGB color by converting to Oklab', () {
        final oklabColor = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        final rgbColor = RayRgb8(red: 255, green: 0, blue: 0);

        final result = oklabColor.lerp(rgbColor, 0.5);

        expect(result, isA<RayOklab>());
        expect(result.opacity, equals(1.0));
      });

      test('throws ArgumentError for invalid t values', () {
        final color1 = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        final color2 = RayOklab(l: 0.7, a: 0.1, b: -0.1);

        expect(() => color1.lerp(color2, -0.1), throwsArgumentError);
        expect(() => color1.lerp(color2, 1.1), throwsArgumentError);
      });
    });

    group('inverse', () {
      test('inverts Oklab color correctly', () {
        final color = RayOklab(l: 0.7, a: 0.1, b: -0.2, opacity: 0.8);
        final inverted = color.inverse;

        expect(inverted.l, closeTo(0.3, oklabTolerance)); // 1.0 - 0.7
        expect(inverted.a, closeTo(-0.1, oklabTolerance)); // -0.1
        expect(inverted.b, closeTo(0.2, oklabTolerance)); // -(-0.2)
        expect(inverted.opacity, equals(0.8)); // Opacity preserved
      });
    });

    group('luminance', () {
      test('uses L component directly for Oklab luminance', () {
        final white = RayOklab(l: 1.0, a: 0.0, b: 0.0);
        final black = RayOklab(l: 0.0, a: 0.0, b: 0.0);

        final whiteLuminance = white.luminance;
        final blackLuminance = black.luminance;

        expect(whiteLuminance, greaterThan(blackLuminance));
        expect(whiteLuminance, lessThanOrEqualTo(1.0));
        expect(blackLuminance, greaterThanOrEqualTo(0.0));
      });
    });

    group('Color Conversions', () {
      test('converts to RGB correctly', () {
        final oklabColor = RayOklab(
            l: 0.627975, a: 0.224863, b: 0.125846); // Approximately red
        final rgbColor = oklabColor.toRgb8();

        expect(rgbColor, isA<RayRgb>());
        expect(rgbColor.red, greaterThan(200)); // Should be predominantly red
        expect(rgbColor.green, lessThan(50));
        expect(rgbColor.blue, lessThan(50));
        expect(rgbColor.opacity, equals(oklabColor.opacity));
      });

      test('converts to HSL correctly', () {
        final oklabColor = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        final hslColor = oklabColor.toHsl();

        expect(hslColor, isA<RayHsl>());
        expect(hslColor.opacity, equals(oklabColor.opacity));
      });

      test('converts to Oklab returns self', () {
        final color = RayOklab(l: 0.5, a: 0.1, b: -0.1);
        final converted = color.toOklab();

        expect(converted, same(color));
      });

      test('round-trip RGB conversion preserves approximate color', () {
        final originalRgb = RayRgb8(red: 128, green: 64, blue: 192, alpha: 200);
        final oklab = originalRgb.toOklab();
        final backToRgb = oklab.toRgb8();

        // Due to precision and color space conversion, expect close values
        expect((backToRgb.red - originalRgb.red).abs(), lessThan(5));
        expect((backToRgb.green - originalRgb.green).abs(), lessThan(5));
        expect((backToRgb.blue - originalRgb.blue).abs(), lessThan(5));
        expect(backToRgb.alpha, equals(originalRgb.alpha));
      });
    });

    group('JSON Serialization', () {
      test('converts to JSON correctly', () {
        final color = RayOklab(l: 0.6, a: 0.15, b: -0.2, opacity: 0.8);
        final json = color.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['l'], equals(0.6));
        expect(json['a'], equals(0.15));
        expect(json['b'], equals(-0.2));
        expect(json['o'], equals(0.8));
      });

      test('round-trip JSON serialization', () {
        final original = RayOklab(l: 0.7, a: 0.1, b: -0.15, opacity: 0.9);
        final json = original.toJson();
        final restored = RayOklab.fromJson(json);

        expect(restored.l, equals(original.l));
        expect(restored.a, equals(original.a));
        expect(restored.b, equals(original.b));
        expect(restored.opacity, equals(original.opacity));
      });
    });

    group('Equality and Hashing', () {
      test('equals returns true for identical values', () {
        final color1 = RayOklab(l: 0.5, a: 0.1, b: -0.1, opacity: 0.8);
        final color2 = RayOklab(l: 0.5, a: 0.1, b: -0.1, opacity: 0.8);

        expect(color1, equals(color2));
        expect(color1.hashCode, equals(color2.hashCode));
      });

      test('equals returns false for different values', () {
        final color1 = RayOklab(l: 0.5, a: 0.1, b: -0.1);
        final color2 = RayOklab(l: 0.6, a: 0.1, b: -0.1);
        final color3 = RayOklab(l: 0.5, a: 0.2, b: -0.1);
        final color4 = RayOklab(l: 0.5, a: 0.1, b: -0.2);
        final color5 = RayOklab(l: 0.5, a: 0.1, b: -0.1, opacity: 0.5);

        expect(color1, isNot(equals(color2)));
        expect(color1, isNot(equals(color3)));
        expect(color1, isNot(equals(color4)));
        expect(color1, isNot(equals(color5)));
      });

      test('handles floating point precision in equality', () {
        final color1 =
            RayOklab(l: 0.1 + 0.2, a: 0.0, b: 0.0); // 0.30000000000000004
        final color2 = RayOklab(l: 0.3, a: 0.0, b: 0.0);

        expect(
            color1, equals(color2)); // Should handle floating point precision
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        final color = RayOklab(l: 0.627, a: 0.225, b: -0.126, opacity: 0.8);
        final str = color.toString();

        expect(str, contains('RayOklab'));
        expect(str, contains('0.627'));
        expect(str, contains('0.225'));
        expect(str, contains('-0.126'));
        expect(str, contains('0.800'));
      });
    });

    group('Edge Cases', () {
      test('handles extreme lightness values', () {
        final veryDark = RayOklab(l: 0.0, a: 0.0, b: 0.0);
        final veryBright = RayOklab(l: 1.0, a: 0.0, b: 0.0);

        expect(veryDark.toRgb8().red, equals(0));
        expect(veryDark.toRgb8().green, equals(0));
        expect(veryDark.toRgb8().blue, equals(0));

        expect(veryBright.toRgb8().red, equals(255));
        expect(veryBright.toRgb8().green, equals(255));
        expect(veryBright.toRgb8().blue, equals(255));
      });

      test('handles large a/b values', () {
        final extremeColor = RayOklab(l: 0.5, a: 0.5, b: -0.5);
        final rgbResult = extremeColor.toRgb8();

        // Should clamp to valid RGB range
        expect(rgbResult.red, inInclusiveRange(0, 255));
        expect(rgbResult.green, inInclusiveRange(0, 255));
        expect(rgbResult.blue, inInclusiveRange(0, 255));
      });
    });
  });
}
