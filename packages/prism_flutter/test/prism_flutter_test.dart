import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism/prism.dart';
import 'package:prism_flutter/prism_flutter.dart';

void main() {
  group('Ray to Flutter Color Extensions', () {
    test('toColor() converts Ray to Flutter Color correctly', () {
      final ray = Ray.fromARGB(255, 255, 0, 0);
      final color = ray.toColor();

      expect(color.value, ray.toIntARGB());
      expect(color.alpha, 255);
      expect(color.red, 255);
      expect(color.green, 0);
      expect(color.blue, 0);
    });

    test('toColor() preserves transparency', () {
      final ray = Ray.fromARGB(128, 0, 255, 0);
      final color = ray.toColor();

      expect(color.value, ray.toIntARGB());
      expect(color.alpha, 128);
      expect(color.red, 0);
      expect(color.green, 255);
      expect(color.blue, 0);
    });

    test('toColorWithOpacity() creates Color with specified opacity', () {
      final ray = Ray.fromARGB(255, 0, 0, 255);
      final color = ray.toColorWithOpacity(0.5);

      expect(color.alpha, 128); // 0.5 * 255 rounded
      expect(color.red, 0);
      expect(color.green, 0);
      expect(color.blue, 255);
    });

    test('toColorWithOpacity() handles edge cases', () {
      final ray = Ray.fromARGB(100, 255, 128, 64);

      // Full opacity
      final opaque = ray.toColorWithOpacity(1.0);
      expect(opaque.alpha, 255);
      expect(opaque.red, 255);
      expect(opaque.green, 128);
      expect(opaque.blue, 64);

      // Zero opacity
      final transparent = ray.toColorWithOpacity(0.0);
      expect(transparent.alpha, 0);
      expect(transparent.red, 255);
      expect(transparent.green, 128);
      expect(transparent.blue, 64);
    });
  });

  group('Flutter Color to Ray Extensions', () {
    test('toRay() converts Flutter Color to Ray correctly', () {
      const color = Color(0xFFFF0000);
      final ray = color.toRay();

      expect(ray.toIntARGB(), color.value);
      expect(ray.alpha, 255);
      expect(ray.red, 255);
      expect(ray.green, 0);
      expect(ray.blue, 0);
    });

    test('toRay() preserves transparency', () {
      const color = Color(0x8000FF00);
      final ray = color.toRay();

      expect(ray.toIntARGB(), color.value);
      expect(ray.alpha, 128);
      expect(ray.red, 0);
      expect(ray.green, 255);
      expect(ray.blue, 0);
    });

    test('toRay() enables Ray manipulation methods', () {
      const color = Color(0xFFFF0000);
      final ray = color.toRay();

      // Test that we can use Ray methods
      final withOpacity = ray.withOpacity(0.5);
      final inverted = ray.inverse;
      final lerped = ray.lerp(Ray.fromHex('#0000FF'), 0.5);

      expect(withOpacity.alpha, 127);
      expect(inverted.red, 0);
      expect(inverted.green, 255);
      expect(inverted.blue, 255);
      expect(lerped.red, 128);
      expect(lerped.blue, 128);
    });
  });

  group('Round Trip Conversions', () {
    test('Ray -> Color -> Ray preserves values', () {
      final originalRay = Ray.fromARGB(200, 100, 150, 75);
      final color = originalRay.toColor();
      final convertedRay = color.toRay();

      expect(convertedRay.toIntARGB(), originalRay.toIntARGB());
      expect(convertedRay, originalRay);
    });

    test('Color -> Ray -> Color preserves values', () {
      const originalColor = Color(0xC8649650);
      final ray = originalColor.toRay();
      final convertedColor = ray.toColor();

      expect(convertedColor.value, originalColor.value);
      expect(convertedColor, originalColor);
    });

    test('Multiple round trips maintain fidelity', () {
      final originalRay = Ray.fromHex('#7F123456');

      // Ray -> Color -> Ray -> Color -> Ray
      final color1 = originalRay.toColor();
      final ray1 = color1.toRay();
      final color2 = ray1.toColor();
      final finalRay = color2.toRay();

      expect(finalRay.toIntARGB(), originalRay.toIntARGB());
      expect(finalRay, originalRay);
    });
  });

  group('Common Flutter Colors', () {
    test('works with standard Flutter colors', () {
      const testColors = [
        Color(0xFF000000), // Black
        Color(0xFFFFFFFF), // White
        Color(0xFFFF0000), // Red
        Color(0xFF00FF00), // Green
        Color(0xFF0000FF), // Blue
        Color(0xFFFFFF00), // Yellow
        Color(0xFFFF00FF), // Magenta
        Color(0xFF00FFFF), // Cyan
      ];

      for (final color in testColors) {
        final ray = color.toRay();
        final backToColor = ray.toColor();

        expect(backToColor.value, color.value);
        expect(backToColor, color);
      }
    });

    test('works with transparent colors', () {
      const testColors = [
        Color(0x00000000), // Fully transparent
        Color(0x80FF0000), // Semi-transparent red
        Color(0x40000000), // Very transparent black
        Color(0xC0FFFFFF), // Mostly opaque white
      ];

      for (final color in testColors) {
        final ray = color.toRay();
        final backToColor = ray.toColor();

        expect(backToColor.value, color.value);
        expect(backToColor, color);
      }
    });
  });

  group('Integration with Ray Methods', () {
    test('can chain Ray operations after Color conversion', () {
      const redColor = Color(0xFFFF0000);
      const blueColor = Color(0xFF0000FF);

      final result = redColor
          .toRay()
          .withOpacity(0.8)
          .lerp(blueColor.toRay(), 0.3)
          .withAlpha(200)
          .toColor();

      expect(result.alpha, 200);
      // Result should be a blend of red and blue with specific alpha
      expect(result.red, greaterThan(100));
      expect(result.blue, greaterThan(50));
    });

    test('can use Ray analysis methods on Flutter Colors', () {
      const color = Color(0xFF808080); // Gray
      final ray = color.toRay();

      final luminance = ray.computeLuminance();
      final inverted = ray.inverse;

      expect(luminance, greaterThan(0.0));
      expect(luminance, lessThan(1.0));
      expect(inverted.red, 127);
      expect(inverted.green, 127);
      expect(inverted.blue, 127);
    });
  });

  group('Error Handling', () {
    test('toColorWithOpacity clamps opacity values', () {
      final ray = Ray.fromHex('#FF0000');

      // Test values outside 0.0-1.0 range
      final belowZero = ray.toColorWithOpacity(-0.5);
      final aboveOne = ray.toColorWithOpacity(1.5);

      // Should clamp to valid range
      expect(belowZero.alpha, 0);
      expect(aboveOne.alpha, 255);
    });
  });
}
