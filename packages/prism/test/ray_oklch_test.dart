import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:prism/prism.dart';

void main() {
  group('RayOklch', () {
    group('constructors', () {
      test('creates color with valid parameters', () {
        final color = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 1.0);
        expect(color.l, closeTo(0.7, 1e-10));
        expect(color.c, closeTo(0.15, 1e-10));
        expect(color.h, closeTo(180.0, 1e-6));
        expect(color.opacity, closeTo(1.0, 1e-10));
        expect(color.colorModel, equals(ColorModel.oklch));
      });

      test('normalizes hue to [0, 360) range', () {
        expect(RayOklch(l: 0.5, c: 0.1, h: 380.0).h, closeTo(20.0, 1e-6));
        expect(RayOklch(l: 0.5, c: 0.1, h: -20.0).h, closeTo(340.0, 1e-6));
        expect(RayOklch(l: 0.5, c: 0.1, h: 720.0).h, closeTo(0.0, 1e-6));
      });

      test('clamps chroma to minimum 0.0', () {
        final color = RayOklch(l: 0.5, c: -0.1, h: 180.0);
        expect(color.c, equals(0.0));
      });

      test('throws on invalid lightness', () {
        expect(() => RayOklch(l: -0.1, c: 0.1, h: 180.0), throwsArgumentError);
        expect(() => RayOklch(l: 1.1, c: 0.1, h: 180.0), throwsArgumentError);
      });

      test('throws on invalid opacity', () {
        expect(() => RayOklch(l: 0.5, c: 0.1, h: 180.0, opacity: -0.1), throwsArgumentError);
        expect(() => RayOklch(l: 0.5, c: 0.1, h: 180.0, opacity: 1.1), throwsArgumentError);
      });

      test('fromLch constructor works correctly', () {
        final color = RayOklch.fromLch(0.7, 0.15, 180.0, 0.8);
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
        final oklab = RayOklab(l: 0.7, a: 0.1, b: -0.1, opacity: 0.8);
        final oklch = RayOklch.fromOklab(oklab);
        
        expect(oklch.l, closeTo(oklab.l, 1e-10));
        expect(oklch.opacity, closeTo(oklab.opacity, 1e-10));
        
        // Verify conversion math
        final expectedChroma = math.sqrt(oklab.a * oklab.a + oklab.b * oklab.b);
        final expectedHue = math.atan2(oklab.b, oklab.a) * 180.0 / math.pi;
        expect(oklch.c, closeTo(expectedChroma, 1e-10));
        expect(oklch.h, closeTo(expectedHue < 0 ? expectedHue + 360 : expectedHue, 1e-6));
      });

      test('fromJson creates color from map', () {
        final json = {'l': 0.7, 'c': 0.15, 'h': 180.0, 'opacity': 0.8};
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
      final color = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);

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
        expect(newColor.c, equals(0.25));
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
        expect(newColor.c, equals(color.c));
        expect(newColor.h, equals(color.h));
        expect(newColor.opacity, equals(color.opacity));
      });

      test('withLightness throws on invalid values', () {
        expect(() => color.withLightness(-0.1), throwsArgumentError);
        expect(() => color.withLightness(1.1), throwsArgumentError);
      });
    });

    group('lerp', () {
      final color1 = RayOklch(l: 0.3, c: 0.1, h: 0.0, opacity: 0.5);
      final color2 = RayOklch(l: 0.7, c: 0.2, h: 120.0, opacity: 1.0);

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
        expect(result.h, closeTo(60.0, 1e-6)); // Shortest path: 0° -> 120° = 60° at midpoint
        expect(result.opacity, closeTo(0.75, 1e-10));
      });

      test('uses shortest hue path around color wheel', () {
        final red = RayOklch(l: 0.5, c: 0.2, h: 10.0);  // Near 0°
        final blue = RayOklch(l: 0.5, c: 0.2, h: 350.0); // Near 360°
        
        final result = red.lerp(blue, 0.5);
        // Should go from 10° to 350° via 0°, midpoint should be around 0° (actually 360°)
        expect(result.h, closeTo(0.0, 1e-6));
      });

      test('works with different color types', () {
        final rgb = RayRgb.fromARGB(255, 255, 0, 0);
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
        final color = RayOklch(l: 0.3, c: 0.15, h: 45.0, opacity: 0.8);
        final inverted = color.inverse;
        
        expect(inverted.l, closeTo(0.7, 1e-10)); // 1.0 - 0.3
        expect(inverted.c, closeTo(0.15, 1e-10)); // Chroma unchanged
        expect(inverted.h, closeTo(225.0, 1e-6)); // 45° + 180°
        expect(inverted.opacity, closeTo(0.8, 1e-10)); // Opacity unchanged
      });

      test('wraps hue correctly when adding 180°', () {
        final color = RayOklch(l: 0.5, c: 0.15, h: 270.0);
        final inverted = color.inverse;
        expect(inverted.h, closeTo(90.0, 1e-6)); // (270° + 180°) % 360° = 90°
      });
    });

    group('color space conversions', () {
      final oklch = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);

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

      test('round-trip conversion Oklch -> Oklab -> Oklch preserves values', () {
        final roundTrip = RayOklch.fromOklab(oklch.toOklab());
        
        expect(roundTrip.l, closeTo(oklch.l, 1e-10));
        expect(roundTrip.c, closeTo(oklch.c, 1e-10));
        expect(roundTrip.h, closeTo(oklch.h, 1e-6));
        expect(roundTrip.opacity, closeTo(oklch.opacity, 1e-10));
      });

      test('toRgb converts via Oklab', () {
        final rgb = oklch.toRgb();
        expect(rgb, isA<RayRgb>());
        expect(rgb.opacity, closeTo(oklch.opacity, 1e-10));
      });

      test('toHsl converts via RGB', () {
        final hsl = oklch.toHsl();
        expect(hsl, isA<RayHsl>());
        expect(hsl.opacity, closeTo(oklch.opacity, 1e-10));
      });

      test('round-trip conversion through all color spaces', () {
        final rgb = oklch.toRgb();
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
        final gray = RayOklch(l: 0.5, c: 0.0, h: 45.0); // Hue irrelevant for gray
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
        final black = RayOklch(l: 0.0, c: 0.1, h: 45.0);
        final white = RayOklch(l: 1.0, c: 0.1, h: 45.0);
        
        expect(() => black.toRgb(), returnsNormally);
        expect(() => white.toRgb(), returnsNormally);
      });

      test('handles high chroma values', () {
        final saturated = RayOklch(l: 0.7, c: 0.4, h: 45.0);  // Very saturated
        
        expect(() => saturated.toRgb(), returnsNormally);
        // The RGB conversion should clamp values appropriately
        final rgb = saturated.toRgb();
        expect(rgb.red, inInclusiveRange(0, 255));
        expect(rgb.green, inInclusiveRange(0, 255));
        expect(rgb.blue, inInclusiveRange(0, 255));
      });
    });

    group('JSON serialization', () {
      test('toJson creates correct map', () {
        final color = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);
        final json = color.toJson();
        
        expect(json, isA<Map<String, dynamic>>());
        expect(json['l'], closeTo(0.7, 1e-10));
        expect(json['c'], closeTo(0.15, 1e-10));
        expect(json['h'], closeTo(180.0, 1e-6));
        expect(json['opacity'], closeTo(0.8, 1e-10));
      });

      test('round-trip JSON serialization preserves values', () {
        final original = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);
        final roundTrip = RayOklch.fromJson(original.toJson());
        
        expect(roundTrip.l, closeTo(original.l, 1e-10));
        expect(roundTrip.c, closeTo(original.c, 1e-10));
        expect(roundTrip.h, closeTo(original.h, 1e-6));
        expect(roundTrip.opacity, closeTo(original.opacity, 1e-10));
      });
    });

    group('computeLuminance', () {
      test('computes luminance via RGB conversion', () {
        final color = RayOklch(l: 0.7, c: 0.15, h: 180.0);
        final luminance = color.computeLuminance();
        
        expect(luminance, isA<double>());
        expect(luminance, inInclusiveRange(0.0, 1.0));
        
        // Should match RGB luminance
        final rgbLuminance = color.toRgb().computeLuminance();
        expect(luminance, closeTo(rgbLuminance, 1e-10));
      });
    });

    group('equality and hashCode', () {
      test('equal colors have same equality and hashCode', () {
        final color1 = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);
        final color2 = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);
        
        expect(color1, equals(color2));
        expect(color1.hashCode, equals(color2.hashCode));
      });

      test('different colors are not equal', () {
        final color1 = RayOklch(l: 0.7, c: 0.15, h: 180.0, opacity: 0.8);
        final color2 = RayOklch(l: 0.6, c: 0.15, h: 180.0, opacity: 0.8);
        
        expect(color1, isNot(equals(color2)));
      });

      test('handles floating-point precision in equality', () {
        final color1 = RayOklch(l: 0.7, c: 0.15, h: 180.0);
        final color2 = RayOklch(l: 0.7 + 1e-12, c: 0.15, h: 180.0); // Very small difference
        
        expect(color1, equals(color2)); // Should be considered equal
      });

      test('small hue differences are considered equal within tolerance', () {
        final color1 = RayOklch(l: 0.7, c: 0.15, h: 180.0);
        final color2 = RayOklch(l: 0.7, c: 0.15, h: 180.0 + 1e-7); // Very small hue difference
        
        expect(color1, equals(color2)); // Should be considered equal within tolerance
      });
    });

    group('toString', () {
      test('formats correctly', () {
        final color = RayOklch(l: 0.7123, c: 0.1567, h: 180.1234, opacity: 0.8567);
        final str = color.toString();
        
        expect(str, contains('RayOklch'));
        expect(str, contains('l: 0.712'));
        expect(str, contains('c: 0.157'));
        expect(str, contains('h: 180.1°'));
        expect(str, contains('opacity: 0.857'));
      });
    });
  });
}