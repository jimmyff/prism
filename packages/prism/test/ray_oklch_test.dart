import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:prism/prism.dart';

void main() {
  group('RayOklch', () {
    group('constructors', () {
      test('creates color with valid parameters', () {
        final color = RayOklch.fromComponents(0.7, 0.15, 180.0, 1.0);
        expect(color.l, closeTo(0.7, 1e-10));
        expect(color.c, closeTo(0.15, 1e-10));
        expect(color.h, closeTo(180.0, 1e-6));
        expect(color.opacity, closeTo(1.0, 1e-10));
        expect(color.colorSpace, equals(ColorSpace.oklch));
      });

      test('normalizes hue to [0, 360) range', () {
        expect(RayOklch.fromComponentsValidated(0.5, 0.1, 380.0).h,
            closeTo(20.0, 1e-6));
        expect(RayOklch.fromComponentsValidated(0.5, 0.1, -20.0).h,
            closeTo(340.0, 1e-6));
        expect(RayOklch.fromComponentsValidated(0.5, 0.1, 720.0).h,
            closeTo(0.0, 1e-6));
      });

      test('clamps chroma to minimum 0.0', () {
        final color = RayOklch.fromComponentsValidated(0.5, -0.1, 180.0);
        expect(color.c, equals(0.0));
      });

      test('throws on invalid lightness', () {
        expect(() => RayOklch.fromComponentsValidated(-0.1, 0.1, 180.0),
            throwsArgumentError);
        expect(() => RayOklch.fromComponentsValidated(1.1, 0.1, 180.0),
            throwsArgumentError);
      });

      test('throws on invalid opacity', () {
        expect(() => RayOklch.fromComponentsValidated(0.5, 0.1, 180.0, -0.1),
            throwsArgumentError);
        expect(() => RayOklch.fromComponentsValidated(0.5, 0.1, 180.0, 1.1),
            throwsArgumentError);
      });

      test('fromLch constructor works correctly', () {
        final color = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);
        expect(color.l, closeTo(0.7, 1e-10));
        expect(color.c, closeTo(0.15, 1e-10));
        expect(color.h, closeTo(180.0, 1e-6));
        expect(color.opacity, closeTo(0.8, 1e-10));
      });

      test('empty constructor creates transparent black', () {
        const color = RayOklch.empty();
        expect(color.l, equals(0.0));
        expect(color.c, equals(0.0));
        expect(color.h, equals(0.0));
        expect(color.opacity, equals(0.0));
      });

      test('fromOklab constructor converts correctly', () {
        final oklab = RayOklab.fromComponents(0.7, 0.1, -0.1, 0.8);
        final oklch = RayOklch.fromOklab(oklab);

        expect(oklch.l, closeTo(oklab.l, 1e-10));
        expect(oklch.opacity, closeTo(oklab.opacity, 1e-10));

        // Verify conversion math
        final expectedChroma = math.sqrt(oklab.a * oklab.a + oklab.b * oklab.b);
        final expectedHue = math.atan2(oklab.b, oklab.a) * 180.0 / math.pi;
        expect(oklch.c, closeTo(expectedChroma, 1e-10));
        expect(oklch.h,
            closeTo(expectedHue < 0 ? expectedHue + 360 : expectedHue, 1e-6));
      });

      test('fromJson creates color from map', () {
        final json = {'l': 0.7, 'c': 0.15, 'h': 180.0, 'o': 0.8};
        final color = RayOklch.fromJson(json);

        expect(color.l, closeTo(0.7, 1e-10));
        expect(color.c, closeTo(0.15, 1e-10));
        expect(color.h, closeTo(180.0, 1e-6));
        expect(color.opacity, closeTo(0.8, 1e-10));
      });

      test('fromJson defaults opacity to 1.0 when missing', () {
        final json = {'l': 0.7, 'c': 0.15, 'h': 180.0};
        final color = RayOklch.fromJson(json);
        expect(color.opacity, equals(1.0));
      });
    });

    group('with methods', () {
      final color = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);

      test('withOpacity creates new color with different opacity', () {
        final newColor = color.withOpacity(0.5);
        expect(newColor.l, equals(color.l));
        expect(newColor.c, equals(color.c));
        expect(newColor.h, equals(color.h));
        expect(newColor.opacity, equals(0.5));
        expect(identical(newColor, color), isFalse);
      });

      test('withOpacity throws on invalid values', () {
        expect(() => color.withOpacity(-0.1), throwsArgumentError);
        expect(() => color.withOpacity(1.1), throwsArgumentError);
      });

      test('withChroma creates new color with different chroma', () {
        final newColor = color.withChroma(0.25);
        expect(newColor.l, equals(color.l));
        // Chroma is clamped to valid gamut - 0.25 is too high for L=0.7, H=180°
        expect(newColor.c, lessThanOrEqualTo(0.25));
        expect(newColor.c, greaterThan(0.1)); // Should be reasonable value
        expect(newColor.h, equals(color.h));
        expect(newColor.opacity, equals(color.opacity));
      });

      test('withChroma clamps negative values to 0', () {
        final newColor = color.withChroma(-0.1);
        expect(newColor.c, equals(0.0));
      });

      test('withHue creates new color with different hue', () {
        final newColor = color.withHue(90.0);
        expect(newColor.l, equals(color.l));
        expect(newColor.c, equals(color.c));
        expect(newColor.h, equals(90.0));
        expect(newColor.opacity, equals(color.opacity));
      });

      test('withHue normalizes hue values', () {
        expect(color.withHue(400.0).h, closeTo(40.0, 1e-6));
        expect(color.withHue(-30.0).h, closeTo(330.0, 1e-6));
      });

      test('withLightness creates new color with different lightness', () {
        final newColor = color.withLightness(0.5);
        expect(newColor.l, equals(0.5));
        // Chroma may be clamped to valid gamut for new lightness
        expect(newColor.c, lessThanOrEqualTo(color.c));
        expect(newColor.c, greaterThan(0.0)); // Should be reasonable value
        expect(newColor.h, equals(color.h));
        expect(newColor.opacity, equals(color.opacity));
      });

      test('withLightness throws on invalid values', () {
        expect(() => color.withLightness(-0.1), throwsArgumentError);
        expect(() => color.withLightness(1.1), throwsArgumentError);
      });
    });

    group('lerp', () {
      final color1 = RayOklch.fromComponents(0.3, 0.1, 0.0, 0.5);
      final color2 = RayOklch.fromComponents(0.7, 0.2, 120.0, 1.0);

      test('returns first color when t = 0', () {
        final result = color1.lerp(color2, 0.0);
        expect(result.l, closeTo(color1.l, 1e-10));
        expect(result.c, closeTo(color1.c, 1e-10));
        expect(result.h, closeTo(color1.h, 1e-6));
        expect(result.opacity, closeTo(color1.opacity, 1e-10));
      });

      test('returns second color when t = 1', () {
        final result = color1.lerp(color2, 1.0);
        expect(result.l, closeTo(color2.l, 1e-10));
        expect(result.c, closeTo(color2.c, 1e-10));
        expect(result.h, closeTo(color2.h, 1e-6));
        expect(result.opacity, closeTo(color2.opacity, 1e-10));
      });

      test('interpolates correctly at midpoint', () {
        final result = color1.lerp(color2, 0.5);
        expect(result.l, closeTo(0.5, 1e-10));
        expect(result.c, closeTo(0.15, 1e-10));
        expect(result.h,
            closeTo(60.0, 1e-6)); // Shortest path: 0° -> 120° = 60° at midpoint
        expect(result.opacity, closeTo(0.75, 1e-10));
      });

      test('uses shortest hue path around color wheel', () {
        final red = RayOklch.fromComponents(0.5, 0.2, 10.0); // Near 0°
        final blue = RayOklch.fromComponents(0.5, 0.2, 350.0); // Near 360°

        final result = red.lerp(blue, 0.5);
        // Should go from 10° to 350° via 0°, midpoint should be around 0° (actually 360°)
        expect(result.h, closeTo(0.0, 1e-6));
      });

      test('works with different color types', () {
        final rgb = RayRgb8.fromComponents(255, 0, 0);
        final result = color1.lerp(rgb, 0.5);
        expect(result, isA<RayOklch>());
      });

      test('throws on invalid t values', () {
        expect(() => color1.lerp(color2, -0.1), throwsArgumentError);
        expect(() => color1.lerp(color2, 1.1), throwsArgumentError);
      });
    });

    group('inverse', () {
      test('inverts lightness and shifts hue by 180°', () {
        final color = RayOklch.fromComponents(0.3, 0.15, 45.0, 0.8);
        final inverted = color.inverse;

        expect(inverted.l, closeTo(0.7, 1e-10)); // 1.0 - 0.3
        expect(inverted.c, closeTo(0.15, 1e-10)); // Chroma unchanged
        expect(inverted.h, closeTo(225.0, 1e-6)); // 45° + 180°
        expect(inverted.opacity, closeTo(0.8, 1e-10)); // Opacity unchanged
      });

      test('wraps hue correctly when adding 180°', () {
        final color = RayOklch.fromComponents(0.5, 0.15, 270.0);
        final inverted = color.inverse;
        expect(inverted.h, closeTo(90.0, 1e-6)); // (270° + 180°) % 360° = 90°
      });
    });

    group('color space conversions', () {
      final oklch = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);

      test('toOklch returns self', () {
        expect(identical(oklch.toOklch(), oklch), isTrue);
      });

      test('toOklab converts correctly', () {
        final oklab = oklch.toOklab();

        expect(oklab.l, closeTo(oklch.l, 1e-10));
        expect(oklab.opacity, closeTo(oklch.opacity, 1e-10));

        // Verify conversion math
        final hueRadians = oklch.h * math.pi / 180.0;
        final expectedA = oklch.c * math.cos(hueRadians);
        final expectedB = oklch.c * math.sin(hueRadians);
        expect(oklab.a, closeTo(expectedA, 1e-10));
        expect(oklab.b, closeTo(expectedB, 1e-10));
      });

      test('round-trip conversion Oklch -> Oklab -> Oklch preserves values',
          () {
        final roundTrip = RayOklch.fromOklab(oklch.toOklab());

        expect(roundTrip.l, closeTo(oklch.l, 1e-10));
        expect(roundTrip.c, closeTo(oklch.c, 1e-10));
        expect(roundTrip.h, closeTo(oklch.h, 1e-6));
        expect(roundTrip.opacity, closeTo(oklch.opacity, 1e-10));
      });

      test('toRgb8 converts via Oklab', () {
        final rgb = oklch.toRgb8();
        expect(rgb, isA<RayRgb>());
        expect(rgb.opacity, closeTo(oklch.opacity, 1e-10));
      });

      test('toHsl converts via RGB', () {
        final hsl = oklch.toHsl();
        expect(hsl, isA<RayHsl>());
        expect(hsl.opacity, closeTo(oklch.opacity, 1e-10));
      });

      test('round-trip conversion through all color spaces', () {
        final rgb = oklch.toRgb8();
        final hsl = rgb.toHsl();
        final oklab = hsl.toOklab();
        final backToOklch = oklab.toOklch();

        // Allow for some precision loss in conversions
        expect(backToOklch.l, closeTo(oklch.l, 0.02));
        expect(backToOklch.c, closeTo(oklch.c, 0.02));
        expect(backToOklch.h, closeTo(oklch.h, 2.0));
        expect(backToOklch.opacity, closeTo(oklch.opacity, 1e-10));
      });
    });

    group('special cases', () {
      test('handles zero chroma (gray colors)', () {
        final gray =
            RayOklch.fromComponents(0.5, 0.0, 45.0); // Hue irrelevant for gray
        final oklab = gray.toOklab();

        expect(oklab.a, closeTo(0.0, 1e-10));
        expect(oklab.b, closeTo(0.0, 1e-10));

        // Round-trip should preserve lightness and chroma
        final backToOklch = RayOklch.fromOklab(oklab);
        expect(backToOklch.l, closeTo(0.5, 1e-10));
        expect(backToOklch.c, closeTo(0.0, 1e-10));
        // Hue can be anything for zero chroma, so don't test it
      });

      test('handles extreme lightness values', () {
        final black = RayOklch.fromComponents(0.0, 0.1, 45.0);
        final white = RayOklch.fromComponents(1.0, 0.1, 45.0);

        expect(() => black.toRgb8(), returnsNormally);
        expect(() => white.toRgb8(), returnsNormally);
      });

      test('handles high chroma values', () {
        final saturated =
            RayOklch.fromComponents(0.7, 0.4, 45.0); // Very saturated

        expect(() => saturated.toRgb8(), returnsNormally);
        // The RGB conversion should clamp values appropriately
        final rgb = saturated.toRgb8();
        expect(rgb.red, inInclusiveRange(0, 255));
        expect(rgb.green, inInclusiveRange(0, 255));
        expect(rgb.blue, inInclusiveRange(0, 255));
      });
    });

    group('JSON serialization', () {
      test('toJson creates correct map', () {
        final color = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);
        final json = color.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['l'], closeTo(0.7, 1e-10));
        expect(json['c'], closeTo(0.15, 1e-10));
        expect(json['h'], closeTo(180.0, 1e-6));
        expect(json['o'], closeTo(0.8, 1e-10));
      });

      test('round-trip JSON serialization preserves values', () {
        final original = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);
        final roundTrip = RayOklch.fromJson(original.toJson());

        expect(roundTrip.l, closeTo(original.l, 1e-10));
        expect(roundTrip.c, closeTo(original.c, 1e-10));
        expect(roundTrip.h, closeTo(original.h, 1e-6));
        expect(roundTrip.opacity, closeTo(original.opacity, 1e-10));
      });
    });

    group('luminance', () {
      test('uses L component directly for Oklch luminance', () {
        final color = RayOklch.fromComponents(0.7, 0.15, 180.0);
        final luminance = color.luminance;

        expect(luminance, equals(0.7)); // Should be L component directly
        expect(luminance, isA<double>());
        expect(luminance, inInclusiveRange(0.0, 1.0));
      });
    });

    group('equality and hashCode', () {
      test('equal colors have same equality and hashCode', () {
        final color1 = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);
        final color2 = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);

        expect(color1, equals(color2));
        expect(color1.hashCode, equals(color2.hashCode));
      });

      test('different colors are not equal', () {
        final color1 = RayOklch.fromComponents(0.7, 0.15, 180.0, 0.8);
        final color2 = RayOklch.fromComponents(0.6, 0.15, 180.0, 0.8);

        expect(color1, isNot(equals(color2)));
      });

      test('handles floating-point precision in equality', () {
        final color1 = RayOklch.fromComponents(0.7, 0.15, 180.0);
        final color2 = RayOklch.fromComponents(
            0.7 + 1e-12, 0.15, 180.0); // Very small difference

        expect(color1, equals(color2)); // Should be considered equal
      });

      test('small hue differences are considered equal within tolerance', () {
        final color1 = RayOklch.fromComponents(0.7, 0.15, 180.0);
        final color2 = RayOklch.fromComponents(
            0.7, 0.15, 180.0 + 1e-7); // Very small hue difference

        expect(color1,
            equals(color2)); // Should be considered equal within tolerance
      });
    });

    group('toString', () {
      test('formats correctly', () {
        final color = RayOklch.fromComponents(0.7123, 0.1567, 180.1234, 0.8567);
        final str = color.toString();

        expect(str, contains('RayOklch'));
        expect(str, contains('l: 0.712'));
        expect(str, contains('c: 0.157'));
        expect(str, contains('h: 180.1°'));
        expect(str, contains('opacity: 0.857'));
      });
    });

    group('Chroma Gamut Issues', () {
      test('withChroma preserves hue for tangerine color', () {
        // Start with a tangerine color
        final tangerine = RayOklch.fromComponents(0.7941, 0.1914, 64.05);

        // Apply maximum chroma - this should give us the most saturated tangerine
        final saturatedTangerine = tangerine.withChroma(1.0);

        // Convert to RGB to verify the result
        final saturatedRgb = saturatedTangerine.toRgb8();

        // After fix: The RGB conversion should maintain the orange/tangerine character
        // A red color (#FF0000) has hue around 0°, not 64°
        expect(saturatedRgb.toHex(), isNot(equals('#FF0000')),
            reason: 'High chroma tangerine should not become pure red');

        // The final color should still be recognizably tangerine/orange
        // Convert back to verify hue is preserved
        final finalOklch = saturatedRgb.toOklch();
        expect(finalOklch.h, closeTo(64.05, 10.0),
            reason: 'Final RGB color should preserve the tangerine hue');
      });

      test('withChroma handles out-of-gamut values gracefully', () {
        // Test various hues with extreme chroma values
        final testColors = [
          RayOklch.fromComponents(0.5, 0.1, 0), // Red
          RayOklch.fromComponents(0.5, 0.1, 30), // Orange
          RayOklch.fromComponents(0.5, 0.1, 60), // Yellow
          RayOklch.fromComponents(0.5, 0.1, 120), // Green
          RayOklch.fromComponents(0.5, 0.1, 240), // Blue
          RayOklch.fromComponents(0.5, 0.1, 300), // Purple
        ];

        for (final color in testColors) {
          final saturated = color.withChroma(2.0); // Extreme chroma

          // Hue should be preserved
          expect(saturated.h, closeTo(color.h, 1.0),
              reason: 'Hue should be preserved for h=${color.h}');

          // Lightness should be preserved
          expect(saturated.l, closeTo(color.l, 1e-6),
              reason: 'Lightness should be preserved for h=${color.h}');

          // Chroma should be valid (not exceed reasonable bounds)
          expect(saturated.c, lessThanOrEqualTo(0.5),
              reason:
                  'Chroma should be clamped to reasonable bounds for h=${color.h}');
        }
      });

      test('withLightness clamps chroma to valid gamut - reported issue', () {
        // Reported issue: (98.4% 0.492 24.87°) shows as bright red instead of near-white
        final problemColor = RayOklch.fromComponents(
            0.5, 0.492, 24.87); // Start with lower lightness

        // When we increase lightness to 98.4%, chroma should be clamped to valid range
        final highLightnessColor = problemColor.withLightness(0.984);

        // Convert to RGB to check the result
        final rgb = highLightnessColor.toRgb8();

        // At 98.4% lightness, the color should be very light (near-white)
        // All RGB components should be high (> 200), not showing as bright red
        expect(rgb.red, greaterThan(200),
            reason: 'High lightness should produce high red component');
        expect(rgb.green, greaterThan(200),
            reason: 'High lightness should produce high green component');
        expect(rgb.blue, greaterThan(200),
            reason: 'High lightness should produce high blue component');

        // The color should not be pure red (#FF0000)
        expect(rgb.toHex(), isNot(equals('#FF0000')),
            reason: 'High lightness color should not be pure red');

        // Chroma should have been clamped to a much lower value
        expect(highLightnessColor.c, lessThan(0.1),
            reason: 'Chroma should be significantly reduced at high lightness');

        // Hue should be preserved
        expect(highLightnessColor.h, closeTo(24.87, 1.0),
            reason: 'Hue should be preserved when adjusting lightness');
      });
    });
  });
}
