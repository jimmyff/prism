import 'package:test/test.dart';
import 'package:prism/prism.dart';

import 'test_constants.dart';

void main() {
  group('RayOklab', () {
    group('Construction', () {
      test('creates Oklab color with valid components', () {
        final color = RayOklab.fromComponents(0.7, 0.1, -0.1, 1.0);

        expect(color.lightness, equals(0.7));
        expect(color.opponentA, equals(0.1));
        expect(color.opponentB, equals(-0.1));
        expect(color.opacity, equals(1.0));
        expect(color.colorSpace, equals(ColorSpace.oklab));
      });

      test('creates Oklab color with default opacity', () {
        final color = RayOklab.fromComponents(0.5, 0.0, 0.0);

        expect(color.opacity, equals(1.0));
      });

      test('creates Oklab color from LAB components', () {
        final color = RayOklab.fromComponents(0.8, 0.2, -0.15, 0.9);

        expect(color.lightness, equals(0.8));
        expect(color.opponentA, equals(0.2));
        expect(color.opponentB, equals(-0.15));
        expect(color.opacity, equals(0.9));
      });

      test('creates empty Oklab color', () {
        final color = RayOklab.empty();

        expect(color.lightness, equals(0.0));
        expect(color.opponentA, equals(0.0));
        expect(color.opponentB, equals(0.0));
        expect(color.opacity, equals(0.0));
      });

      test('creates Oklab color from JSON', () {
        final json = {'l': 0.6, 'a': 0.15, 'b': -0.2, 'o': 0.8};
        final color = RayOklab.fromJson(json);

        expect(color.lightness, equals(0.6));
        expect(color.opponentA, equals(0.15));
        expect(color.opponentB, equals(-0.2));
        expect(color.opacity, equals(0.8));
      });
    });

    group('Component Access', () {
      test('lightness getter returns l component', () {
        final color = RayOklab.fromComponents(0.7, 0.1, -0.1, 0.8);
        expect(color.lightness, equals(0.7));
      });

      test('opponentA getter returns a component', () {
        final color = RayOklab.fromComponents(0.5, 0.25, -0.2, 0.9);
        expect(color.opponentA, equals(0.25));
      });

      test('opponentB getter returns b component', () {
        final color = RayOklab.fromComponents(0.6, 0.1, -0.15, 1.0);
        expect(color.opponentB, equals(-0.15));
      });
    });

    group('Component Modification', () {
      test('withLightness creates new color with different lightness', () {
        final original = RayOklab.fromComponents(0.5, 0.1, -0.1, 0.8);
        final modified = original.withLightness(0.7);

        expect(modified.lightness, equals(0.7));
        expect(modified.opponentA, equals(original.opponentA));
        expect(modified.opponentB, equals(original.opponentB));
        expect(modified.opacity, equals(original.opacity));
        expect(modified == original, isFalse);
      });

      test('withLightness validates range', () {
        final color = RayOklab.fromComponents(0.5, 0.1, -0.1);
        
        expect(() => color.withLightness(-0.1), throwsArgumentError);
        expect(() => color.withLightness(1.1), throwsArgumentError);
        expect(() => color.withLightness(0.0), returnsNormally);
        expect(() => color.withLightness(1.0), returnsNormally);
      });

      test('withOpponentA creates new color with different a component', () {
        final original = RayOklab.fromComponents(0.5, 0.1, -0.1, 0.8);
        final modified = original.withOpponentA(0.3);

        expect(modified.lightness, equals(original.lightness));
        expect(modified.opponentA, equals(0.3));
        expect(modified.opponentB, equals(original.opponentB));
        expect(modified.opacity, equals(original.opacity));
        expect(modified == original, isFalse);
      });

      test('withOpponentB creates new color with different b component', () {
        final original = RayOklab.fromComponents(0.5, 0.1, -0.1, 0.8);
        final modified = original.withOpponentB(-0.3);

        expect(modified.lightness, equals(original.lightness));
        expect(modified.opponentA, equals(original.opponentA));
        expect(modified.opponentB, equals(-0.3));
        expect(modified.opacity, equals(original.opacity));
        expect(modified == original, isFalse);
      });

      test('creates Oklab color from JSON with default opacity', () {
        final json = {'l': 0.5, 'a': 0.0, 'b': 0.0};
        final color = RayOklab.fromJson(json);

        expect(color.opacity, equals(1.0));
      });
    });

    group('Properties', () {
      test('returns correct color model', () {
        final color = RayOklab.fromComponents(0.5, 0.0, 0.0);
        expect(color.colorSpace, equals(ColorSpace.oklab));
      });

      test('returns correct opacity', () {
        final color = RayOklab.fromComponents(0.5, 0.0, 0.0, 0.7);
        expect(color.opacity, equals(0.7));
      });
    });

    group('withOpacity', () {
      test('creates new color with different opacity', () {
        final original = RayOklab.fromComponents(0.7, 0.1, -0.1, 1.0);
        final modified = original.withOpacity(0.5);

        expect(modified.lightness, equals(original.lightness));
        expect(modified.opponentA, equals(original.opponentA));
        expect(modified.opponentB, equals(original.opponentB));
        expect(modified.opacity, equals(0.5));
        expect(modified, isNot(same(original)));
      });

      test('throws ArgumentError for invalid opacity', () {
        final color = RayOklab.fromComponents(0.5, 0.0, 0.0);

        expect(() => color.withOpacity(-0.1), throwsArgumentError);
        expect(() => color.withOpacity(1.1), throwsArgumentError);
      });
    });

    group('lerp', () {
      test('interpolates between two Oklab colors', () {
        final color1 = RayOklab.fromComponents(0.3, -0.1, 0.1, 0.5);
        final color2 = RayOklab.fromComponents(0.7, 0.1, -0.1, 1.0);

        final midpoint = color1.lerp(color2, 0.5);

        expect(midpoint.lightness, closeTo(0.5, oklabTolerance));
        expect(midpoint.opponentA, closeTo(0.0, oklabTolerance));
        expect(midpoint.opponentB, closeTo(0.0, oklabTolerance));
        expect(midpoint.opacity, closeTo(0.75, oklabTolerance));
      });

      test('returns original color at t=0', () {
        final color1 = RayOklab.fromComponents(0.3, -0.1, 0.1);
        final color2 = RayOklab.fromComponents(0.7, 0.1, -0.1);

        final result = color1.lerp(color2, 0.0);

        expect(result.lightness, equals(color1.lightness));
        expect(result.opponentA, equals(color1.opponentA));
        expect(result.opponentB, equals(color1.opponentB));
        expect(result.opacity, equals(color1.opacity));
      });

      test('returns other color at t=1', () {
        final color1 = RayOklab.fromComponents(0.3, -0.1, 0.1);
        final color2 = RayOklab.fromComponents(0.7, 0.1, -0.1);

        // Should convert color2 to Oklab (already Oklab in this case)
        final result = color1.lerp(color2, 1.0);

        expect(result.lightness, equals(color2.lightness));
        expect(result.opponentA, equals(color2.opponentA));
        expect(result.opponentB, equals(color2.opponentB));
        expect(result.opacity, equals(color2.opacity));
      });

      test('interpolates with RGB color by converting to Oklab', () {
        final oklabColor = RayOklab.fromComponents(0.5, 0.0, 0.0);
        final rgbColor = RayRgb8.fromComponentsNative(255, 0, 0);

        final result = oklabColor.lerp(rgbColor, 0.5);

        expect(result, isA<RayOklab>());
        expect(result.opacity, equals(1.0));
      });

      test('throws ArgumentError for invalid t values', () {
        final color1 = RayOklab.fromComponents(0.5, 0.0, 0.0);
        final color2 = RayOklab.fromComponents(0.7, 0.1, -0.1);

        expect(() => color1.lerp(color2, -0.1), throwsArgumentError);
        expect(() => color1.lerp(color2, 1.1), throwsArgumentError);
      });
    });

    group('inverse', () {
      test('inverts Oklab color correctly', () {
        final color = RayOklab.fromComponents(0.7, 0.1, -0.2, 0.8);
        final inverted = color.inverse;

        expect(inverted.lightness, closeTo(0.3, oklabTolerance)); // 1.0 - 0.7
        expect(inverted.opponentA, closeTo(-0.1, oklabTolerance)); // -0.1
        expect(inverted.opponentB, closeTo(0.2, oklabTolerance)); // -(-0.2)
        expect(inverted.opacity, equals(0.8)); // Opacity preserved
      });
    });

    group('luminance', () {
      test('uses L component directly for Oklab luminance', () {
        final white = RayOklab.fromComponents(1.0, 0.0, 0.0);
        final black = RayOklab.fromComponents(0.0, 0.0, 0.0);

        final whiteLuminance = white.luminance;
        final blackLuminance = black.luminance;

        expect(whiteLuminance, greaterThan(blackLuminance));
        expect(whiteLuminance, lessThanOrEqualTo(1.0));
        expect(blackLuminance, greaterThanOrEqualTo(0.0));
      });
    });

    group('Color Conversions', () {
      test('converts to RGB correctly', () {
        final oklabColor = RayOklab.fromComponents(
            0.627975, 0.224863, 0.125846); // Approximately red
        final rgbColor = oklabColor.toRgb8();

        expect(rgbColor, isA<RayRgb>());
        expect(rgbColor.red, greaterThan(200)); // Should be predominantly red
        expect(rgbColor.green, lessThan(50));
        expect(rgbColor.blue, lessThan(50));
        expect(rgbColor.opacity, equals(oklabColor.opacity));
      });

      test('converts to HSL correctly', () {
        final oklabColor = RayOklab.fromComponents(0.5, 0.0, 0.0);
        final hslColor = oklabColor.toHsl();

        expect(hslColor, isA<RayHsl>());
        expect(hslColor.opacity, equals(oklabColor.opacity));
      });

      test('converts to Oklab returns self', () {
        final color = RayOklab.fromComponents(0.5, 0.1, -0.1);
        final converted = color.toOklab();

        expect(converted, same(color));
      });

      test('round-trip RGB conversion preserves approximate color', () {
        final originalRgb = RayRgb8.fromComponentsNative(128, 64, 192, 200);
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
        final color = RayOklab.fromComponents(0.6, 0.15, -0.2, 0.8);
        final json = color.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['l'], equals(0.6));
        expect(json['a'], equals(0.15));
        expect(json['b'], equals(-0.2));
        expect(json['o'], equals(0.8));
      });

      test('round-trip JSON serialization', () {
        final original = RayOklab.fromComponents(0.7, 0.1, -0.15, 0.9);
        final json = original.toJson();
        final restored = RayOklab.fromJson(json);

        expect(restored.lightness, equals(original.lightness));
        expect(restored.opponentA, equals(original.opponentA));
        expect(restored.opponentB, equals(original.opponentB));
        expect(restored.opacity, equals(original.opacity));
      });
    });

    group('Equality and Hashing', () {
      test('equals returns true for identical values', () {
        final color1 = RayOklab.fromComponents(0.5, 0.1, -0.1, 0.8);
        final color2 = RayOklab.fromComponents(0.5, 0.1, -0.1, 0.8);

        expect(color1, equals(color2));
        expect(color1.hashCode, equals(color2.hashCode));
      });

      test('equals returns false for different values', () {
        final color1 = RayOklab.fromComponents(0.5, 0.1, -0.1);
        final color2 = RayOklab.fromComponents(0.6, 0.1, -0.1);
        final color3 = RayOklab.fromComponents(0.5, 0.2, -0.1);
        final color4 = RayOklab.fromComponents(0.5, 0.1, -0.2);
        final color5 = RayOklab.fromComponents(0.5, 0.1, -0.1, 0.5);

        expect(color1, isNot(equals(color2)));
        expect(color1, isNot(equals(color3)));
        expect(color1, isNot(equals(color4)));
        expect(color1, isNot(equals(color5)));
      });

      test('handles floating point precision in equality', () {
        final color1 =
            RayOklab.fromComponents(0.1 + 0.2, 0.0, 0.0); // 0.30000000000000004
        final color2 = RayOklab.fromComponents(0.3, 0.0, 0.0);

        expect(
            color1, equals(color2)); // Should handle floating point precision
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        final color = RayOklab.fromComponents(0.627, 0.225, -0.126, 0.8);
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
        final veryDark = RayOklab.fromComponents(0.0, 0.0, 0.0);
        final veryBright = RayOklab.fromComponents(1.0, 0.0, 0.0);

        expect(veryDark.toRgb8().red, equals(0));
        expect(veryDark.toRgb8().green, equals(0));
        expect(veryDark.toRgb8().blue, equals(0));

        expect(veryBright.toRgb8().red, equals(255));
        expect(veryBright.toRgb8().green, equals(255));
        expect(veryBright.toRgb8().blue, equals(255));
      });

      test('handles large a/b values', () {
        final extremeColor = RayOklab.fromComponents(0.5, 0.5, -0.5);
        final rgbResult = extremeColor.toRgb8();

        // Should clamp to valid RGB range
        expect(rgbResult.red, inInclusiveRange(0, 255));
        expect(rgbResult.green, inInclusiveRange(0, 255));
        expect(rgbResult.blue, inInclusiveRange(0, 255));
      });
    });
  });
}
