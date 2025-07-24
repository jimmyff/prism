import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism/prism.dart';
import 'package:prism_flutter/prism_flutter.dart';

import 'test_constants.dart';

void main() {
  group('RayRgb to Flutter Color Extensions', () {
    test('toColor() converts RayRgb to Flutter Color correctly', () {
      const ray = RayRgb.fromARGB(255, 255, 0, 0);
      final color = ray.toColor();

      expect(color.toARGB32(), ray.toIntARGB());
      expect((color.a * 255.0).round() & 0xff, 255);
      expect((color.r * 255.0).round() & 0xff, 255);
      expect((color.g * 255.0).round() & 0xff, 0);
      expect((color.b * 255.0).round() & 0xff, 0);
    });

    test('toColor() preserves transparency', () {
      const ray = RayRgb.fromARGB(128, 0, 255, 0);
      final color = ray.toColor();

      expect(color.toARGB32(), ray.toIntARGB());
      expect((color.a * 255.0).round() & 0xff, 128);
      expect((color.r * 255.0).round() & 0xff, 0);
      expect((color.g * 255.0).round() & 0xff, 255);
      expect((color.b * 255.0).round() & 0xff, 0);
    });

    test('toColorWithOpacity() creates Color with specified opacity', () {
      const ray = RayRgb.fromARGB(255, 0, 0, 255);
      final color = ray.toColorWithOpacity(0.5);

      expect((color.a * 255.0).round() & 0xff, 128); // 0.5 * 255 rounded
      expect((color.r * 255.0).round() & 0xff, 0);
      expect((color.g * 255.0).round() & 0xff, 0);
      expect((color.b * 255.0).round() & 0xff, 255);
    });

    test('toColorWithOpacity() handles edge cases', () {
      const ray = RayRgb.fromARGB(100, 255, 128, 64);

      // Full opacity
      final opaque = ray.toColorWithOpacity(1.0);
      expect((opaque.a * 255.0).round() & 0xff, 255);
      expect((opaque.r * 255.0).round() & 0xff, 255);
      expect((opaque.g * 255.0).round() & 0xff, 128);
      expect((opaque.b * 255.0).round() & 0xff, 64);

      // Zero opacity
      final transparent = ray.toColorWithOpacity(0.0);
      expect((transparent.a * 255.0).round() & 0xff, 0);
      expect((transparent.r * 255.0).round() & 0xff, 255);
      expect((transparent.g * 255.0).round() & 0xff, 128);
      expect((transparent.b * 255.0).round() & 0xff, 64);
    });
  });

  group('Flutter Color to RayRgb Extensions', () {
    test('toRay() converts Flutter Color to RayRgb correctly', () {
      const color = Color(0xFFFF0000);
      final ray = color.toRay();

      expect(ray.toIntARGB(), color.toARGB32());
      expect(ray.alpha, 255);
      expect(ray.red, 255);
      expect(ray.green, 0);
      expect(ray.blue, 0);
    });

    test('toRay() preserves transparency', () {
      const color = Color(0x8000FF00);
      final ray = color.toRay();

      expect(ray.toIntARGB(), color.toARGB32());
      expect(ray.alpha, closeTo(128, flutterColorTolerance));
      expect(ray.red, 0);
      expect(ray.green, 255);
      expect(ray.blue, 0);
    });

    test('toRay() enables RayRgb manipulation methods', () {
      const color = Color(0xFFFF0000);
      final ray = color.toRay();

      // Test that we can use RayRgb methods
      final withOpacity = ray.withOpacity(0.5);
      final inverted = ray.inverse;
      final lerped = ray.lerp(RayRgb.fromHex('#0000FF'), 0.5);

      expect(withOpacity.alpha, closeTo(127, flutterColorTolerance));
      expect(inverted.red, 0);
      expect(inverted.green, 255);
      expect(inverted.blue, 255);
      expect(lerped.red, closeTo(128, flutterColorTolerance));
      expect(lerped.blue, closeTo(128, flutterColorTolerance));
    });
  });

  group('Round Trip Conversions', () {
    test('RayRgb -> Color -> RayRgb preserves values', () {
      const originalRay = RayRgb.fromARGB(200, 100, 150, 75);
      final color = originalRay.toColor();
      final convertedRay = color.toRay();

      expect(convertedRay.toIntARGB(), originalRay.toIntARGB());
      expect(convertedRay, originalRay);
    });

    test('Color -> RayRgb -> Color preserves values', () {
      const originalColor = Color(0xC8649650);
      final ray = originalColor.toRay();
      final convertedColor = ray.toColor();

      expect(convertedColor.toARGB32(), originalColor.toARGB32());
      expect(convertedColor, originalColor);
    });

    test('Multiple round trips maintain fidelity', () {
      final originalRay = RayRgb.fromHex('#7F123456');

      // RayRgb -> Color -> RayRgb -> Color -> RayRgb
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

        expect(backToColor.toARGB32(), color.toARGB32());
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

        expect(backToColor.toARGB32(), color.toARGB32());
        expect(backToColor, color);
      }
    });
  });

  group('Integration with Ray Methods', () {
    test('can chain RayRgb operations after Color conversion', () {
      const redColor = Color(0xFFFF0000);
      const blueColor = Color(0xFF0000FF);

      final result = redColor
          .toRay()
          .withOpacity(0.8)
          .lerp(blueColor.toRay(), 0.3)
          .withAlpha(200)
          .toColor();

      expect((result.a * 255.0).round() & 0xff, 200);
      // Result should be a blend of red and blue with specific alpha
      expect((result.r * 255.0).round() & 0xff, greaterThan(100));
      expect((result.b * 255.0).round() & 0xff, greaterThan(50));
    });

    test('can use RayRgb analysis methods on Flutter Colors', () {
      const color = Color(0xFF808080); // Gray
      final ray = color.toRay();

      final luminance = ray.computeLuminance();
      final inverted = ray.inverse;

      expect(luminance, greaterThan(0.0));
      expect(luminance, lessThan(1.0));
      expect(inverted.red, closeTo(127, flutterColorTolerance));
      expect(inverted.green, closeTo(127, flutterColorTolerance));
      expect(inverted.blue, closeTo(127, flutterColorTolerance));
    });
  });

  group('Error Handling', () {
    test('toColorWithOpacity clamps opacity values', () {
      final ray = RayRgb.fromHex('#FF0000');

      // Test values outside 0.0-1.0 range
      final belowZero = ray.toColorWithOpacity(-0.5);
      final aboveOne = ray.toColorWithOpacity(1.5);

      // Should clamp to valid range
      expect((belowZero.a * 255.0).round() & 0xff, 0);
      expect((aboveOne.a * 255.0).round() & 0xff, 255);
    });
  });
}
