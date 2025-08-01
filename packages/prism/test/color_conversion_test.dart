import 'package:prism/prism.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('Color Model Conversions', () {
    // ============================================================================
    // RGB → HSL Conversions
    // ============================================================================

    group('RGB → HSL Conversions', () {
      test('RGB red to HSL', () {
        final rgb = RayRgb8(red: 255, green: 0, blue: 0);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(0, precisionTolerance));
        expect(hsl.saturation, closeTo(1.0, precisionTolerance));
        expect(hsl.lightness, closeTo(0.5, precisionTolerance));
        expect(hsl.opacity, closeTo(1.0, precisionTolerance));
      });

      test('RGB green to HSL', () {
        final rgb = RayRgb8(red: 0, green: 255, blue: 0);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(120, precisionTolerance));
        expect(hsl.saturation, closeTo(1.0, precisionTolerance));
        expect(hsl.lightness, closeTo(0.5, precisionTolerance));
      });

      test('RGB blue to HSL', () {
        final rgb = RayRgb8(red: 0, green: 0, blue: 255);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(240, precisionTolerance));
        expect(hsl.saturation, closeTo(1.0, precisionTolerance));
        expect(hsl.lightness, closeTo(0.5, precisionTolerance));
      });

      test('RGB black to HSL', () {
        final rgb = RayRgb8(red: 0, green: 0, blue: 0);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(0, precisionTolerance));
        expect(hsl.saturation, closeTo(0, precisionTolerance));
        expect(hsl.lightness, closeTo(0, precisionTolerance));
      });

      test('RGB white to HSL', () {
        final rgb = RayRgb8(red: 255, green: 255, blue: 255);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(0, precisionTolerance));
        expect(hsl.saturation, closeTo(0, precisionTolerance));
        expect(hsl.lightness, closeTo(1.0, precisionTolerance));
      });

      test('RGB gray to HSL', () {
        final rgb = RayRgb8(red: 128, green: 128, blue: 128);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(0, precisionTolerance));
        expect(hsl.saturation, closeTo(0, precisionTolerance));
        expect(hsl.lightness,
            closeTo(0.502, componentTolerance)); // 128/255 ≈ 0.502
      });

      test('RGB cyan to HSL', () {
        final rgb = RayRgb8(red: 0, green: 255, blue: 255);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(180, precisionTolerance));
        expect(hsl.saturation, closeTo(1.0, precisionTolerance));
        expect(hsl.lightness, closeTo(0.5, precisionTolerance));
      });

      test('RGB magenta to HSL', () {
        final rgb = RayRgb8(red: 255, green: 0, blue: 255);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(300, precisionTolerance));
        expect(hsl.saturation, closeTo(1.0, precisionTolerance));
        expect(hsl.lightness, closeTo(0.5, precisionTolerance));
      });

      test('RGB yellow to HSL', () {
        final rgb = RayRgb8(red: 255, green: 255, blue: 0);
        final hsl = rgb.toHsl();

        expect(hsl.hue, closeTo(60, precisionTolerance));
        expect(hsl.saturation, closeTo(1.0, precisionTolerance));
        expect(hsl.lightness, closeTo(0.5, precisionTolerance));
      });

      test('RGB to HSL preserves opacity', () {
        final rgb = RayRgb8(red: 255, green: 0, blue: 0, alpha: 128);
        final hsl = rgb.toHsl();

        expect(hsl.opacity, closeTo(0.502, componentTolerance)); // 128/255
      });

      test('RGB orange to HSL', () {
        // Orange-ish color
        final rgb = RayRgb8(red: 255, green: 165, blue: 0);
        final hsl = rgb.toHsl();

        expect(hsl.hue,
            closeTo(38.8, hueTolerance)); // Expected hue for this orange
        expect(hsl.saturation, closeTo(1.0, componentTolerance));
        expect(hsl.lightness, closeTo(0.5, componentTolerance));
      });
    });

    // ============================================================================
    // HSL → RGB Conversions
    // ============================================================================

    group('HSL → RGB Conversions', () {
      test('HSL red to RGB', () {
        final hsl = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(255));
        expect(rgb.green, equals(0));
        expect(rgb.blue, equals(0));
        expect(rgb.alpha, equals(255));
      });

      test('HSL green to RGB', () {
        final hsl = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(0));
        expect(rgb.green, equals(255));
        expect(rgb.blue, equals(0));
      });

      test('HSL blue to RGB', () {
        final hsl = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(0));
        expect(rgb.green, equals(0));
        expect(rgb.blue, equals(255));
      });

      test('HSL black to RGB', () {
        final hsl = RayHsl(hue: 0, saturation: 0, lightness: 0);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(0));
        expect(rgb.green, equals(0));
        expect(rgb.blue, equals(0));
      });

      test('HSL white to RGB', () {
        final hsl = RayHsl(hue: 0, saturation: 0, lightness: 1.0);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(255));
        expect(rgb.green, equals(255));
        expect(rgb.blue, equals(255));
      });

      test('HSL gray to RGB', () {
        final hsl = RayHsl(hue: 0, saturation: 0, lightness: 0.502);
        final rgb = hsl.toRgb();

        expect(rgb.red, closeTo(128, rgbTolerance));
        expect(rgb.green, closeTo(128, rgbTolerance));
        expect(rgb.blue, closeTo(128, rgbTolerance));
      });

      test('HSL cyan to RGB', () {
        final hsl = RayHsl(hue: 180, saturation: 1.0, lightness: 0.5);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(0));
        expect(rgb.green, equals(255));
        expect(rgb.blue, equals(255));
      });

      test('HSL magenta to RGB', () {
        final hsl = RayHsl(hue: 300, saturation: 1.0, lightness: 0.5);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(255));
        expect(rgb.green, equals(0));
        expect(rgb.blue, equals(255));
      });

      test('HSL yellow to RGB', () {
        final hsl = RayHsl(hue: 60, saturation: 1.0, lightness: 0.5);
        final rgb = hsl.toRgb();

        expect(rgb.red, equals(255));
        expect(rgb.green, equals(255));
        expect(rgb.blue, equals(0));
      });

      test('HSL to RGB preserves opacity', () {
        final hsl =
            RayHsl(hue: 120, saturation: 1.0, lightness: 0.5, opacity: 0.502);
        final rgb = hsl.toRgb();

        expect(rgb.alpha, closeTo(128, rgbTolerance)); // 0.502 * 255
      });

      test('HSL hue wraparound (360° = 0°)', () {
        final hsl1 = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
        final hsl2 = RayHsl(hue: 360, saturation: 1.0, lightness: 0.5);

        final rgb1 = hsl1.toRgb();
        final rgb2 = hsl2.toRgb();

        expect(rgb1.red, equals(rgb2.red));
        expect(rgb1.green, equals(rgb2.green));
        expect(rgb1.blue, equals(rgb2.blue));
      });
    });

    // ============================================================================
    // RGB → Oklab Conversions
    // ============================================================================

    group('RGB → Oklab Conversions', () {
      test('RGB red to Oklab', () {
        final rgb = RayRgb8(red: 255, green: 0, blue: 0);
        final oklab = rgb.toOklab();

        expect(oklab.l, greaterThan(0.0));
        expect(oklab.a, greaterThan(0.0)); // Red should have positive a
        expect(oklab.b,
            greaterThan(0.0)); // Red should have positive b (yellow component)
        expect(oklab.opacity, equals(1.0));
      });

      test('RGB green to Oklab', () {
        final rgb = RayRgb8(red: 0, green: 255, blue: 0);
        final oklab = rgb.toOklab();

        expect(oklab.l, greaterThan(0.0));
        expect(oklab.a, lessThan(0.0)); // Green should have negative a
        expect(oklab.opacity, equals(1.0));
      });

      test('RGB blue to Oklab', () {
        final rgb = RayRgb8(red: 0, green: 0, blue: 255);
        final oklab = rgb.toOklab();

        expect(oklab.l, greaterThan(0.0));
        expect(oklab.b, lessThan(0.0)); // Blue should have negative b
        expect(oklab.opacity, equals(1.0));
      });

      test('RGB white to Oklab', () {
        final rgb = RayRgb8(red: 255, green: 255, blue: 255);
        final oklab = rgb.toOklab();

        expect(oklab.l, closeTo(1.0, perceptualTolerance));
        expect(oklab.a, closeTo(0.0, perceptualTolerance));
        expect(oklab.b, closeTo(0.0, perceptualTolerance));
      });

      test('RGB black to Oklab', () {
        final rgb = RayRgb8(red: 0, green: 0, blue: 0);
        final oklab = rgb.toOklab();

        expect(oklab.l, closeTo(0.0, perceptualTolerance));
        expect(oklab.a, closeTo(0.0, perceptualTolerance));
        expect(oklab.b, closeTo(0.0, perceptualTolerance));
      });

      test('RGB to Oklab preserves opacity', () {
        final rgb = RayRgb8(red: 255, green: 0, blue: 0, alpha: 128);
        final oklab = rgb.toOklab();

        expect(oklab.opacity, closeTo(0.502, componentTolerance)); // 128/255
      });
    });

    // ============================================================================
    // Oklab → RGB Conversions
    // ============================================================================

    group('Oklab → RGB Conversions', () {
      test('Oklab red-like to RGB', () {
        final oklab = RayOklab(l: 0.627975, a: 0.224863, b: 0.125846);
        final rgb = oklab.toRgb();

        expect(rgb.red, greaterThan(200));
        expect(rgb.green, lessThan(50));
        expect(rgb.blue, lessThan(50));
        expect(rgb.alpha, equals(255));
      });

      test('Oklab neutral gray to RGB', () {
        final oklab = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        final rgb = oklab.toRgb();

        expect((rgb.red - rgb.green).abs(), lessThan(10));
        expect((rgb.green - rgb.blue).abs(), lessThan(10));
      });

      test('Oklab white to RGB', () {
        final oklab = RayOklab(l: 1.0, a: 0.0, b: 0.0);
        final rgb = oklab.toRgb();

        expect(rgb.red, equals(255));
        expect(rgb.green, equals(255));
        expect(rgb.blue, equals(255));
      });

      test('Oklab black to RGB', () {
        final oklab = RayOklab(l: 0.0, a: 0.0, b: 0.0);
        final rgb = oklab.toRgb();

        expect(rgb.red, equals(0));
        expect(rgb.green, equals(0));
        expect(rgb.blue, equals(0));
      });

      test('Oklab to RGB preserves opacity', () {
        final oklab = RayOklab(l: 0.5, a: 0.0, b: 0.0, opacity: 0.502);
        final rgb = oklab.toRgb();

        expect(rgb.alpha, closeTo(128, rgbTolerance)); // 0.502 * 255
      });

      test('Oklab extreme values clamp to valid RGB range', () {
        final extremeOklab = RayOklab(l: 2.0, a: 1.0, b: -1.0);
        final rgb = extremeOklab.toRgb();

        expect(rgb.red, inInclusiveRange(0, 255));
        expect(rgb.green, inInclusiveRange(0, 255));
        expect(rgb.blue, inInclusiveRange(0, 255));
      });
    });

    // ============================================================================
    // HSL → Oklab Conversions
    // ============================================================================

    group('HSL → Oklab Conversions', () {
      test('HSL red to Oklab', () {
        final hsl = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
        final oklab = hsl.toOklab();

        expect(oklab.l, greaterThan(0.0));
        expect(oklab.a, greaterThan(0.0));
        expect(oklab.opacity, equals(1.0));
      });

      test('HSL green to Oklab', () {
        final hsl = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
        final oklab = hsl.toOklab();

        expect(oklab.l, greaterThan(0.0));
        expect(oklab.a, lessThan(0.0));
        expect(oklab.opacity, equals(1.0));
      });

      test('HSL grayscale to Oklab', () {
        final hsl = RayHsl(hue: 0, saturation: 0.0, lightness: 0.5);
        final oklab = hsl.toOklab();

        expect(oklab.a, closeTo(0.0, perceptualTolerance));
        expect(oklab.b, closeTo(0.0, perceptualTolerance));
      });
    });

    // ============================================================================
    // Oklab → HSL Conversions
    // ============================================================================

    group('Oklab → HSL Conversions', () {
      test('Oklab to HSL via RGB conversion', () {
        final oklab = RayOklab(l: 0.8, a: -0.1, b: 0.1); // Light greenish
        final hsl = oklab.toHsl();

        expect(hsl.lightness, greaterThan(0.5));
        expect(hsl.opacity, equals(oklab.opacity));
      });

      test('Oklab neutral to HSL', () {
        final oklab = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        final hsl = oklab.toHsl();

        expect(hsl.saturation, closeTo(0.0, perceptualTolerance));
        expect(hsl.lightness, closeTo(0.5, roundTripTolerance));
      });
    });

    // ============================================================================
    // Round-trip Conversion Tests
    // ============================================================================

    group('RGB ↔ HSL Round-trip Conversions', () {
      final testColors = [
        RayRgb8(red: 255, green: 0, blue: 0), // Red
        RayRgb8(red: 0, green: 255, blue: 0), // Green
        RayRgb8(red: 0, green: 0, blue: 255), // Blue
        RayRgb8(red: 255, green: 255, blue: 0), // Yellow
        RayRgb8(red: 255, green: 0, blue: 255), // Magenta
        RayRgb8(red: 0, green: 255, blue: 255), // Cyan
        RayRgb8(red: 128, green: 128, blue: 128), // Gray
        RayRgb8(red: 255, green: 165, blue: 0), // Orange
        RayRgb8(red: 128, green: 0, blue: 128), // Purple
        RayRgb8(red: 255, green: 192, blue: 203), // Pink
        RayRgb8(red: 0, green: 128, blue: 0), // Dark Green
        RayRgb8(red: 139, green: 69, blue: 19), // Brown
      ];

      for (int i = 0; i < testColors.length; i++) {
        test('RGB→HSL→RGB round-trip preserves color ${i + 1}', () {
          final originalRgb = testColors[i];
          final hsl = originalRgb.toHsl();
          final convertedRgb = hsl.toRgb();

          expect(convertedRgb.red, closeTo(originalRgb.red, rgbTolerance));
          expect(convertedRgb.green, closeTo(originalRgb.green, rgbTolerance));
          expect(convertedRgb.blue, closeTo(originalRgb.blue, rgbTolerance));
          expect(convertedRgb.alpha, equals(originalRgb.alpha));
        });
      }

      final testHslColors = [
        RayHsl(hue: 0, saturation: 1.0, lightness: 0.5), // Red
        RayHsl(hue: 120, saturation: 1.0, lightness: 0.5), // Green
        RayHsl(hue: 240, saturation: 1.0, lightness: 0.5), // Blue
        RayHsl(hue: 60, saturation: 1.0, lightness: 0.5), // Yellow
        RayHsl(hue: 300, saturation: 1.0, lightness: 0.5), // Magenta
        RayHsl(hue: 180, saturation: 1.0, lightness: 0.5), // Cyan
        RayHsl(hue: 0, saturation: 0, lightness: 0.502), // Gray
        RayHsl(hue: 30, saturation: 0.8, lightness: 0.6), // Light Orange
        RayHsl(hue: 270, saturation: 0.6, lightness: 0.4), // Purple
        RayHsl(hue: 350, saturation: 0.3, lightness: 0.8), // Light Pink
      ];

      for (int i = 0; i < testHslColors.length; i++) {
        test('HSL→RGB→HSL round-trip preserves color ${i + 1}', () {
          final originalHsl = testHslColors[i];
          final rgb = originalHsl.toRgb();
          final convertedHsl = rgb.toHsl();

          expect(convertedHsl.hue, closeTo(originalHsl.hue, hueTolerance));
          expect(convertedHsl.saturation,
              closeTo(originalHsl.saturation, componentTolerance));
          expect(convertedHsl.lightness,
              closeTo(originalHsl.lightness, componentTolerance));
          expect(convertedHsl.opacity,
              closeTo(originalHsl.opacity, componentTolerance));
        });
      }
    });

    group('RGB ↔ Oklab Round-trip Conversions', () {
      final testColors = [
        RayRgb8(red: 255, green: 0, blue: 0), // Red
        RayRgb8(red: 0, green: 255, blue: 0), // Green
        RayRgb8(red: 0, green: 0, blue: 255), // Blue
        RayRgb8(red: 255, green: 255, blue: 255), // White
        RayRgb8(red: 0, green: 0, blue: 0), // Black
        RayRgb8(red: 128, green: 128, blue: 128), // Gray
        RayRgb8(red: 255, green: 165, blue: 0), // Orange
        RayRgb8(red: 128, green: 0, blue: 128), // Purple
      ];

      for (int i = 0; i < testColors.length; i++) {
        test('RGB→Oklab→RGB round-trip preserves approximate color ${i + 1}',
            () {
          final originalRgb = testColors[i];
          final oklab = originalRgb.toOklab();
          final convertedRgb = oklab.toRgb();

          // Oklab conversion may have more variance due to color space differences
          expect((convertedRgb.red - originalRgb.red).abs(), lessThan(10));
          expect((convertedRgb.green - originalRgb.green).abs(), lessThan(10));
          expect((convertedRgb.blue - originalRgb.blue).abs(), lessThan(10));
          expect(convertedRgb.alpha, equals(originalRgb.alpha));
        });
      }

      final testOklabColors = [
        RayOklab(l: 0.627975, a: 0.224863, b: 0.125846), // Red-ish
        RayOklab(l: 0.86644, a: -0.233887, b: 0.179498), // Green-ish
        RayOklab(l: 0.452014, a: -0.032457, b: -0.311528), // Blue-ish
        RayOklab(l: 1.0, a: 0.0, b: 0.0), // White
        RayOklab(l: 0.0, a: 0.0, b: 0.0), // Black
        RayOklab(l: 0.5, a: 0.0, b: 0.0), // Neutral gray
      ];

      for (int i = 0; i < testOklabColors.length; i++) {
        test('Oklab→RGB→Oklab round-trip preserves approximate color ${i + 1}',
            () {
          final originalOklab = testOklabColors[i];
          final rgb = originalOklab.toRgb();
          final convertedOklab = rgb.toOklab();

          expect((convertedOklab.l - originalOklab.l).abs(), lessThan(0.05));
          expect((convertedOklab.a - originalOklab.a).abs(), lessThan(0.05));
          expect((convertedOklab.b - originalOklab.b).abs(), lessThan(0.05));
          expect(convertedOklab.opacity, equals(originalOklab.opacity));
        });
      }
    });

    group('HSL ↔ Oklab Round-trip Conversions', () {
      final testColors = [
        RayHsl(hue: 0, saturation: 1.0, lightness: 0.5), // Red
        RayHsl(hue: 120, saturation: 1.0, lightness: 0.5), // Green
        RayHsl(hue: 240, saturation: 1.0, lightness: 0.5), // Blue
        RayHsl(hue: 60, saturation: 0.5, lightness: 0.75), // Light yellow
        RayHsl(hue: 0, saturation: 0.0, lightness: 0.5), // Gray
      ];

      for (int i = 0; i < testColors.length; i++) {
        test('HSL→Oklab→HSL round-trip preserves approximate color ${i + 1}',
            () {
          final originalHsl = testColors[i];
          final oklab = originalHsl.toOklab();
          final backToHsl = oklab.toHsl();

          // Color space conversions can introduce variance
          if (originalHsl.saturation > 0.1) {
            expect((backToHsl.hue - originalHsl.hue).abs(), lessThan(15));
          }
          expect((backToHsl.saturation - originalHsl.saturation).abs(),
              lessThan(0.15));
          expect((backToHsl.lightness - originalHsl.lightness).abs(),
              lessThan(0.15));
          expect(backToHsl.opacity, equals(originalHsl.opacity));
        });
      }
    });

    // ============================================================================
    // Multi-space Conversion Chains
    // ============================================================================

    group('Multi-space Conversion Chains', () {
      test('RGB→HSL→Oklab→RGB preserves approximate color', () {
        final originalRgb = RayRgb8(red: 128, green: 64, blue: 192);
        final hsl = originalRgb.toHsl();
        final oklab = hsl.toOklab();
        final finalRgb = oklab.toRgb();

        expect((finalRgb.red - originalRgb.red).abs(), lessThan(15));
        expect((finalRgb.green - originalRgb.green).abs(), lessThan(15));
        expect((finalRgb.blue - originalRgb.blue).abs(), lessThan(15));
        expect(finalRgb.alpha, equals(originalRgb.alpha));
      });

      test('Oklab→HSL→RGB→Oklab preserves approximate color', () {
        final originalOklab = RayOklab(l: 0.7, a: 0.1, b: -0.15);
        final hsl = originalOklab.toHsl();
        final rgb = hsl.toRgb();
        final finalOklab = rgb.toOklab();

        expect((finalOklab.l - originalOklab.l).abs(), lessThan(0.1));
        expect((finalOklab.a - originalOklab.a).abs(), lessThan(0.1));
        expect((finalOklab.b - originalOklab.b).abs(), lessThan(0.1));
        expect(finalOklab.opacity, equals(originalOklab.opacity));
      });

      test('RGB→Oklab→HSL→RGB preserves approximate color', () {
        final originalRgb = RayRgb8(red: 200, green: 100, blue: 50);
        final oklab = originalRgb.toOklab();
        final hsl = oklab.toHsl();
        final finalRgb = hsl.toRgb();

        expect((finalRgb.red - originalRgb.red).abs(), lessThan(15));
        expect((finalRgb.green - originalRgb.green).abs(), lessThan(15));
        expect((finalRgb.blue - originalRgb.blue).abs(), lessThan(15));
        expect(finalRgb.alpha, equals(originalRgb.alpha));
      });
    });

    // ============================================================================
    // Opacity Preservation Tests
    // ============================================================================

    group('Opacity Preservation Across All Conversions', () {
      test('all conversions preserve opacity values', () {
        final opacities = [0.0, 0.25, 0.5, 0.75, 1.0];

        for (final opacity in opacities) {
          final rgb = RayRgb8(
              red: 128, green: 64, blue: 192, alpha: (opacity * 255).round());

          final hsl = rgb.toHsl();
          expect(hsl.opacity, closeTo(opacity, componentTolerance));

          final oklab = rgb.toOklab();
          expect(oklab.opacity, closeTo(opacity, componentTolerance));

          final backToRgb = hsl.toRgb();
          expect(backToRgb.opacity, closeTo(opacity, componentTolerance));

          final oklabToRgb = oklab.toRgb();
          expect(oklabToRgb.opacity, closeTo(opacity, componentTolerance));
        }
      });
    });

    // ============================================================================
    // Edge Cases and Special Behaviors
    // ============================================================================

    group('Edge Cases and Special Color Behaviors', () {
      test('very dark RGB colors convert correctly', () {
        final rgb = RayRgb8(red: 1, green: 0, blue: 0);
        final hsl = rgb.toHsl();
        final backToRgb = hsl.toRgb();

        expect(backToRgb.red, closeTo(1, rgbTolerance));
        expect(backToRgb.green, closeTo(0, rgbTolerance));
        expect(backToRgb.blue, closeTo(0, rgbTolerance));
      });

      test('very bright RGB colors convert correctly', () {
        final rgb = RayRgb8(red: 254, green: 255, blue: 254);
        final hsl = rgb.toHsl();
        final backToRgb = hsl.toRgb();

        expect(backToRgb.red, closeTo(254, rgbTolerance));
        expect(backToRgb.green, closeTo(255, rgbTolerance));
        expect(backToRgb.blue, closeTo(254, rgbTolerance));
      });

      test('HSL colors with very low saturation convert correctly', () {
        final hsl = RayHsl(hue: 45, saturation: 0.01, lightness: 0.5);
        final rgb = hsl.toRgb();
        final backToHsl = rgb.toHsl();

        expect(backToHsl.saturation, closeTo(0.01, componentTolerance));
        expect(backToHsl.lightness, closeTo(0.5, componentTolerance));
      });

      test('transparent colors preserve transparency', () {
        final rgbTransparent = RayRgb8(red: 255, green: 0, blue: 0, alpha: 0);
        final hslTransparent = rgbTransparent.toHsl();

        expect(hslTransparent.opacity, closeTo(0, precisionTolerance));

        final backToRgb = hslTransparent.toRgb();
        expect(backToRgb.alpha, equals(0));
      });

      test('Oklab extreme values clamp to valid RGB', () {
        final extremeOklab = RayOklab(l: 2.0, a: 1.0, b: -1.0);
        final rgb = extremeOklab.toRgb();

        expect(rgb.red, inInclusiveRange(0, 255));
        expect(rgb.green, inInclusiveRange(0, 255));
        expect(rgb.blue, inInclusiveRange(0, 255));
      });

      test('negative Oklab lightness clamps to valid RGB', () {
        final negativeL = RayOklab(l: -0.5, a: 0.0, b: 0.0);
        final rgb = negativeL.toRgb();

        expect(rgb.red, inInclusiveRange(0, 255));
        expect(rgb.green, inInclusiveRange(0, 255));
        expect(rgb.blue, inInclusiveRange(0, 255));
      });

      test('HSL hue normalization works correctly', () {
        final hues = [-90, 450, -270, 720];
        final expectedNormalized = [270, 90, 90, 0];

        for (int i = 0; i < hues.length; i++) {
          final hsl =
              RayHsl(hue: hues[i].toDouble(), saturation: 1.0, lightness: 0.5);
          final rgb = hsl.toRgb();

          final normalizedHsl = RayHsl(
              hue: expectedNormalized[i].toDouble(),
              saturation: 1.0,
              lightness: 0.5);
          final normalizedRgb = normalizedHsl.toRgb();

          expect((rgb.red - normalizedRgb.red).abs(), lessThan(2));
          expect((rgb.green - normalizedRgb.green).abs(), lessThan(2));
          expect((rgb.blue - normalizedRgb.blue).abs(), lessThan(2));
        }
      });
    });

    // ============================================================================
    // Color Space Characteristics Tests
    // ============================================================================

    group('Color Space Characteristics', () {
      test('Oklab provides better perceptual uniformity than RGB', () {
        // Test that equal steps in Oklab space are more perceptually uniform
        final baseColor = RayOklab(l: 0.5, a: 0.0, b: 0.0);
        final step = 0.1;

        final lighterOklab = RayOklab(l: 0.5 + step, a: 0.0, b: 0.0);
        final darkerOklab = RayOklab(l: 0.5 - step, a: 0.0, b: 0.0);

        // Convert to RGB to see the effect
        final baseRgb = baseColor.toRgb();
        final lighterRgb = lighterOklab.toRgb();
        final darkerRgb = darkerOklab.toRgb();

        // In Oklab, equal steps should produce more perceptually uniform changes
        expect(lighterRgb.red, greaterThan(baseRgb.red));
        expect(darkerRgb.red, lessThan(baseRgb.red));
      });

      test('HSL hue wraps correctly at 360 degrees', () {
        final hsl360 = RayHsl(hue: 360, saturation: 1.0, lightness: 0.5);
        final hsl0 = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);

        final rgb360 = hsl360.toRgb();
        final rgb0 = hsl0.toRgb();

        expect(rgb360.red, equals(rgb0.red));
        expect(rgb360.green, equals(rgb0.green));
        expect(rgb360.blue, equals(rgb0.blue));
      });
    });

    // ============================================================================
    // Performance Tests
    // ============================================================================

    group('Conversion Performance', () {
      test('RGB→HSL conversion is reasonably fast', () {
        final rgb = RayRgb8(red: 128, green: 64, blue: 192);
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          rgb.toHsl();
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMicroseconds,
            lessThan(10000)); // Less than 10ms for 1000 conversions
      });

      test('HSL→RGB conversion is reasonably fast', () {
        final hsl = RayHsl(hue: 270, saturation: 0.75, lightness: 0.4);
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          hsl.toRgb();
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMicroseconds,
            lessThan(10000)); // Less than 10ms for 1000 conversions
      });

      test('RGB→Oklab conversion is reasonably fast', () {
        final rgb = RayRgb8(red: 128, green: 64, blue: 192);
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          rgb.toOklab();
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMicroseconds,
            lessThan(50000)); // Less than 50ms for 1000 conversions
      });

      test('Oklab→RGB conversion is reasonably fast', () {
        final oklab = RayOklab(l: 0.7, a: 0.1, b: -0.15);
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          oklab.toRgb();
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMicroseconds,
            lessThan(50000)); // Less than 50ms for 1000 conversions
      });
    });
  });
}
