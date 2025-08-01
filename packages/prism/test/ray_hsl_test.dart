import 'package:prism/prism.dart';
import 'package:test/test.dart';

import 'test_constants.dart';

void main() {
  group('RayHsl Constructors', () {
    test('creates HSL color with named parameters', () {
      final hsl = RayHsl(hue: 120, saturation: 0.5, lightness: 0.6);

      expect(hsl.hue, closeTo(120, precisionTolerance));
      expect(hsl.saturation, closeTo(0.5, precisionTolerance));
      expect(hsl.lightness, closeTo(0.6, precisionTolerance));
      expect(hsl.opacity, closeTo(1.0, precisionTolerance));
      expect(hsl.colorSpace, equals(ColorSpace.hsl));
    });

    test('creates HSL color with opacity', () {
      final hsl =
          RayHsl(hue: 240, saturation: 1.0, lightness: 0.5, opacity: 0.7);

      expect(hsl.hue, closeTo(240, precisionTolerance));
      expect(hsl.saturation, closeTo(1.0, precisionTolerance));
      expect(hsl.lightness, closeTo(0.5, precisionTolerance));
      expect(hsl.opacity, closeTo(0.7, precisionTolerance));
    });

    test('normalizes hue values', () {
      final hsl1 = RayHsl(hue: 370, saturation: 1.0, lightness: 0.5); // > 360
      final hsl2 = RayHsl(hue: -10, saturation: 1.0, lightness: 0.5); // < 0

      expect(hsl1.hue, closeTo(10, precisionTolerance));
      expect(hsl2.hue, closeTo(350, precisionTolerance));
    });

    test('clamps saturation and lightness values', () {
      final hsl =
          RayHsl(hue: 0, saturation: 1.5, lightness: -0.1, opacity: 1.2);

      expect(hsl.saturation, closeTo(1.0, precisionTolerance));
      expect(hsl.lightness, closeTo(0.0, precisionTolerance));
      expect(hsl.opacity, closeTo(1.0, precisionTolerance));
    });

    test('creates empty HSL color', () {
      final empty = RayHsl.empty();

      expect(empty.hue, closeTo(0, precisionTolerance));
      expect(empty.saturation, closeTo(0, precisionTolerance));
      expect(empty.lightness, closeTo(0, precisionTolerance));
      expect(empty.opacity, closeTo(0, precisionTolerance));
    });

    test('creates HSL from JSON', () {
      final json = {'h': 180.0, 's': 0.8, 'l': 0.4, 'o': 0.9};
      final hsl = RayHsl.fromJson(json);

      expect(hsl.hue, closeTo(180, precisionTolerance));
      expect(hsl.saturation, closeTo(0.8, precisionTolerance));
      expect(hsl.lightness, closeTo(0.4, precisionTolerance));
      expect(hsl.opacity, closeTo(0.9, precisionTolerance));
    });

    test('creates HSL from JSON without opacity', () {
      final json = {'h': 90.0, 's': 0.6, 'l': 0.7};
      final hsl = RayHsl.fromJson(json);

      expect(hsl.opacity, closeTo(1.0, precisionTolerance));
    });
  });

  group('RayHsl Methods', () {
    test('withHue creates new HSL with different hue', () {
      final original =
          RayHsl(hue: 0, saturation: 0.8, lightness: 0.6, opacity: 0.7);
      final modified = original.withHue(120);

      expect(modified.hue, closeTo(120, precisionTolerance));
      expect(modified.saturation, closeTo(0.8, precisionTolerance));
      expect(modified.lightness, closeTo(0.6, precisionTolerance));
      expect(modified.opacity, closeTo(0.7, precisionTolerance));
      expect(
          original.hue, closeTo(0, precisionTolerance)); // Original unchanged
    });

    test('withSaturation creates new HSL with different saturation', () {
      final original = RayHsl(hue: 240, saturation: 0.8, lightness: 0.6);
      final modified = original.withSaturation(0.3);

      expect(modified.hue, closeTo(240, precisionTolerance));
      expect(modified.saturation, closeTo(0.3, precisionTolerance));
      expect(modified.lightness, closeTo(0.6, precisionTolerance));
    });

    test('withLightness creates new HSL with different lightness', () {
      final original = RayHsl(hue: 180, saturation: 0.7, lightness: 0.5);
      final modified = original.withLightness(0.8);

      expect(modified.hue, closeTo(180, precisionTolerance));
      expect(modified.saturation, closeTo(0.7, precisionTolerance));
      expect(modified.lightness, closeTo(0.8, precisionTolerance));
    });

    test('withOpacity creates new HSL with different opacity', () {
      final original = RayHsl(hue: 60, saturation: 0.5, lightness: 0.4);
      final modified = original.withOpacity(0.6);

      expect(modified.opacity, closeTo(0.6, precisionTolerance));
      expect(modified.hue, closeTo(60, precisionTolerance));
      expect(modified.saturation, closeTo(0.5, precisionTolerance));
      expect(modified.lightness, closeTo(0.4, precisionTolerance));
    });

    test('inverse creates complementary HSL color', () {
      final original =
          RayHsl(hue: 60, saturation: 0.8, lightness: 0.3, opacity: 0.7);
      final inverted = original.inverse;

      expect(inverted.hue, closeTo(240, precisionTolerance)); // 60 + 180
      expect(
          inverted.saturation, closeTo(0.2, precisionTolerance)); // 1.0 - 0.8
      expect(inverted.lightness, closeTo(0.7, precisionTolerance)); // 1.0 - 0.3
      expect(inverted.opacity, closeTo(0.7, precisionTolerance)); // Unchanged
    });

    test('inverse handles hue wraparound', () {
      final original = RayHsl(hue: 300, saturation: 0.5, lightness: 0.5);
      final inverted = original.inverse;

      expect(inverted.hue, closeTo(120, precisionTolerance)); // 300 + 180 - 360
    });
  });

  group('RayHsl Interpolation', () {
    test('lerp interpolates between HSL colors', () {
      final red = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
      final blue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
      final midpoint = red.lerp(blue, 0.5);

      // Should find shortest path around color wheel: 0° to 240° via 300°
      expect(midpoint.hue, closeTo(300, hueTolerance)); // Allow some tolerance
      expect(midpoint.saturation, closeTo(1.0, precisionTolerance));
      expect(midpoint.lightness, closeTo(0.5, precisionTolerance));
    });

    test('lerp handles hue wraparound correctly', () {
      final orange = RayHsl(hue: 30, saturation: 1.0, lightness: 0.5);
      final violet = RayHsl(hue: 330, saturation: 1.0, lightness: 0.5);
      final midpoint = orange.lerp(violet, 0.5);

      // Should interpolate via 0°: 30° -> 0° -> 330°
      expect(midpoint.hue, closeTo(0, hueTolerance));
    });

    test('lerp interpolates opacity', () {
      final opaque =
          RayHsl(hue: 120, saturation: 0.5, lightness: 0.5, opacity: 1.0);
      final transparent =
          RayHsl(hue: 120, saturation: 0.5, lightness: 0.5, opacity: 0.0);
      final midpoint = opaque.lerp(transparent, 0.3);

      expect(midpoint.opacity, closeTo(0.7, precisionTolerance));
    });

    test('lerp with RGB color converts and interpolates', () {
      final hsl = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
      final rgb = RayRgb8(red: 255, green: 0, blue: 0);
      final result = hsl.lerp(rgb, 0.5);

      expect(result.colorSpace, equals(ColorSpace.hsl));
      // Should be some intermediate color between green HSL and red RGB
    });
  });

  group('RayHsl Conversions', () {
    test('toHsl returns self', () {
      final hsl = RayHsl(hue: 180, saturation: 0.6, lightness: 0.7);
      final converted = hsl.toHsl();

      expect(identical(hsl, converted), isTrue);
    });

    test('toJson creates correct map', () {
      final hsl =
          RayHsl(hue: 270, saturation: 0.4, lightness: 0.8, opacity: 0.6);
      final json = hsl.toJson();

      expect(json['h'], closeTo(270, precisionTolerance));
      expect(json['s'], closeTo(0.4, precisionTolerance));
      expect(json['l'], closeTo(0.8, precisionTolerance));
      expect(json['o'], closeTo(0.6, precisionTolerance));
    });

    test('toJson omits opacity when 1.0', () {
      final hsl = RayHsl(hue: 90, saturation: 0.3, lightness: 0.5);
      final json = hsl.toJson();

      expect(json.containsKey('o'), isFalse);
    });
  });

  group('RayHsl Equality and Hashing', () {
    test('equals operator works correctly', () {
      final hsl1 =
          RayHsl(hue: 45, saturation: 0.7, lightness: 0.6, opacity: 0.8);
      final hsl2 =
          RayHsl(hue: 45, saturation: 0.7, lightness: 0.6, opacity: 0.8);
      final hsl3 =
          RayHsl(hue: 46, saturation: 0.7, lightness: 0.6, opacity: 0.8);

      expect(hsl1 == hsl2, isTrue);
      expect(hsl1 == hsl3, isFalse);
      expect(hsl1.hashCode, equals(hsl2.hashCode));
      expect(hsl1.hashCode, isNot(equals(hsl3.hashCode)));
    });

    test('handles floating point precision in equality', () {
      final hsl1 = RayHsl(hue: 120.0000000001, saturation: 0.5, lightness: 0.5);
      final hsl2 =
          RayHsl(hue: 120.0000000001, saturation: 0.5000000001, lightness: 0.5);

      expect(hsl1 == hsl2, isTrue); // Within epsilon tolerance
    });
  });

  group('RayHsl String Representation', () {
    test('toString formats correctly without opacity', () {
      final hsl = RayHsl(hue: 123.456, saturation: 0.789, lightness: 0.234);
      final str = hsl.toString();

      expect(str, contains('123.5°'));
      expect(str, contains('78.9%'));
      expect(str, contains('23.4%'));
      expect(str, isNot(contains('100.0%'))); // No opacity shown when 1.0
    });

    test('toString formats correctly with opacity', () {
      final hsl =
          RayHsl(hue: 0, saturation: 1.0, lightness: 0.5, opacity: 0.75);
      final str = hsl.toString();

      expect(str, contains('0.0°'));
      expect(str, contains('100.0%'));
      expect(str, contains('50.0%'));
      expect(str, contains('75.0%')); // Opacity shown when != 1.0
    });
  });

  group('RayHsl Luminance', () {
    test('luminance works for pure colors', () {
      final red = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
      final green = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
      final blue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);

      final redLum = red.luminance;
      final greenLum = green.luminance;
      final blueLum = blue.luminance;

      // Green should have highest luminance, red medium, blue lowest
      expect(greenLum, greaterThan(redLum));
      expect(redLum, greaterThan(blueLum));
    });

    test('luminance for grayscale matches lightness', () {
      final gray25 = RayHsl(hue: 0, saturation: 0.0, lightness: 0.25);
      final gray50 = RayHsl(hue: 0, saturation: 0.0, lightness: 0.50);
      final gray75 = RayHsl(hue: 0, saturation: 0.0, lightness: 0.75);

      final lum25 = gray25.luminance;
      final lum50 = gray50.luminance;
      final lum75 = gray75.luminance;

      expect(lum75, greaterThan(lum50));
      expect(lum50, greaterThan(lum25));

      // For grayscale, luminance should correlate with lightness
      expect(lum25, lessThan(0.5));
      expect(lum75, greaterThan(0.5));
    });
  });

  group('RayHsl maxContrast', () {
    test('maxContrast selects color with highest contrast', () {
      final gray = RayHsl(hue: 0, saturation: 0, lightness: 0.5);
      final black = RayHsl(hue: 0, saturation: 0, lightness: 0);
      final white = RayHsl(hue: 0, saturation: 0, lightness: 1.0);

      final bestContrast = gray.maxContrast(black, white);

      // White should have higher contrast with gray than black
      expect(bestContrast, equals(white));
    });
  });

  group('RayHsl Difference Functions', () {
    test('hueDifference calculates signed hue difference', () {
      final red = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
      final green = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
      final blue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);

      // Red to green: +120° (clockwise)
      expect(red.hueDifference(green), closeTo(120.0, precisionTolerance));

      // Red to blue: -120° (counter-clockwise, shorter path)
      expect(red.hueDifference(blue), closeTo(-120.0, precisionTolerance));

      // Green to blue: +120°
      expect(green.hueDifference(blue), closeTo(120.0, precisionTolerance));

      // Blue to red: +120° (shorter path over 0°)
      expect(blue.hueDifference(red), closeTo(120.0, precisionTolerance));
    });

    test('hueDifference handles hue wraparound correctly', () {
      final almostRed1 = RayHsl(hue: 350, saturation: 1.0, lightness: 0.5);
      final almostRed2 = RayHsl(hue: 10, saturation: 1.0, lightness: 0.5);

      // 350° to 10° should be +20° (shortest path)
      expect(almostRed1.hueDifference(almostRed2),
          closeTo(20.0, precisionTolerance));

      // 10° to 350° should be -20°
      expect(almostRed2.hueDifference(almostRed1),
          closeTo(-20.0, precisionTolerance));
    });

    test('saturationDifference calculates signed saturation difference', () {
      final vivid = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
      final medium = RayHsl(hue: 120, saturation: 0.5, lightness: 0.5);
      final pastel = RayHsl(hue: 120, saturation: 0.2, lightness: 0.5);

      // Vivid to pastel: -0.8 (pastel is less saturated)
      expect(vivid.saturationDifference(pastel),
          closeTo(-0.8, precisionTolerance));

      // Pastel to vivid: +0.8 (vivid is more saturated)
      expect(
          pastel.saturationDifference(vivid), closeTo(0.8, precisionTolerance));

      // Medium to pastel: -0.3
      expect(medium.saturationDifference(pastel),
          closeTo(-0.3, precisionTolerance));
    });

    test('lightnessDifference calculates signed lightness difference', () {
      final dark = RayHsl(hue: 240, saturation: 1.0, lightness: 0.2);
      final medium = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
      final bright = RayHsl(hue: 240, saturation: 1.0, lightness: 0.8);

      // Dark to bright: +0.6 (bright is lighter)
      expect(
          dark.lightnessDifference(bright), closeTo(0.6, precisionTolerance));

      // Bright to dark: -0.6 (dark is darker)
      expect(
          bright.lightnessDifference(dark), closeTo(-0.6, precisionTolerance));

      // Medium to dark: -0.3
      expect(
          medium.lightnessDifference(dark), closeTo(-0.3, precisionTolerance));
    });

    test('difference functions handle identical colors', () {
      final color1 = RayHsl(hue: 180, saturation: 0.7, lightness: 0.4);
      final color2 = RayHsl(hue: 180, saturation: 0.7, lightness: 0.4);

      expect(color1.hueDifference(color2), closeTo(0.0, precisionTolerance));
      expect(color1.saturationDifference(color2),
          closeTo(0.0, precisionTolerance));
      expect(
          color1.lightnessDifference(color2), closeTo(0.0, precisionTolerance));
    });
  });

  group('RayHsl Distance Functions', () {
    test('hueDistance calculates absolute hue distance', () {
      final red = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
      final green = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
      final blue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
      final yellow = RayHsl(hue: 60, saturation: 1.0, lightness: 0.5);

      // All distances should be positive
      expect(red.hueDistance(green), closeTo(120.0, precisionTolerance));
      expect(red.hueDistance(blue),
          closeTo(120.0, precisionTolerance)); // Shorter path
      expect(red.hueDistance(yellow), closeTo(60.0, precisionTolerance));
      expect(green.hueDistance(blue), closeTo(120.0, precisionTolerance));

      // Distance is symmetric
      expect(red.hueDistance(blue), equals(blue.hueDistance(red)));
      expect(green.hueDistance(yellow), equals(yellow.hueDistance(green)));
    });

    test('hueDistance handles wraparound correctly', () {
      final almostRed1 = RayHsl(hue: 350, saturation: 1.0, lightness: 0.5);
      final almostRed2 = RayHsl(hue: 10, saturation: 1.0, lightness: 0.5);

      // Distance should be 20° (shortest path over 0°/360°)
      expect(almostRed1.hueDistance(almostRed2),
          closeTo(20.0, precisionTolerance));
      expect(almostRed2.hueDistance(almostRed1),
          closeTo(20.0, precisionTolerance));
    });

    test('saturationDistance calculates absolute saturation distance', () {
      final vivid = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
      final medium = RayHsl(hue: 120, saturation: 0.5, lightness: 0.5);
      final pastel = RayHsl(hue: 120, saturation: 0.2, lightness: 0.5);

      // All distances should be positive
      expect(
          vivid.saturationDistance(pastel), closeTo(0.8, precisionTolerance));
      expect(
          pastel.saturationDistance(vivid), closeTo(0.8, precisionTolerance));
      expect(
          medium.saturationDistance(pastel), closeTo(0.3, precisionTolerance));

      // Distance is symmetric
      expect(vivid.saturationDistance(medium),
          equals(medium.saturationDistance(vivid)));
    });

    test('lightnessDistance calculates absolute lightness distance', () {
      final dark = RayHsl(hue: 240, saturation: 1.0, lightness: 0.2);
      final medium = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
      final bright = RayHsl(hue: 240, saturation: 1.0, lightness: 0.8);

      // All distances should be positive
      expect(dark.lightnessDistance(bright), closeTo(0.6, precisionTolerance));
      expect(bright.lightnessDistance(dark), closeTo(0.6, precisionTolerance));
      expect(medium.lightnessDistance(dark), closeTo(0.3, precisionTolerance));

      // Distance is symmetric
      expect(dark.lightnessDistance(medium),
          equals(medium.lightnessDistance(dark)));
    });

    test('distance functions handle identical colors', () {
      final color1 = RayHsl(hue: 180, saturation: 0.7, lightness: 0.4);
      final color2 = RayHsl(hue: 180, saturation: 0.7, lightness: 0.4);

      expect(color1.hueDistance(color2), closeTo(0.0, precisionTolerance));
      expect(
          color1.saturationDistance(color2), closeTo(0.0, precisionTolerance));
      expect(
          color1.lightnessDistance(color2), closeTo(0.0, precisionTolerance));
    });

    test('distance functions are absolute values of difference functions', () {
      final color1 = RayHsl(hue: 45, saturation: 0.3, lightness: 0.2);
      final color2 = RayHsl(hue: 225, saturation: 0.8, lightness: 0.7);

      expect(color1.hueDistance(color2),
          equals(color1.hueDifference(color2).abs()));
      expect(color1.saturationDistance(color2),
          equals(color1.saturationDifference(color2).abs()));
      expect(color1.lightnessDistance(color2),
          equals(color1.lightnessDifference(color2).abs()));
    });

    test('maximum possible distances are correct', () {
      final hue0 = RayHsl(hue: 0, saturation: 0, lightness: 0);
      final hue180 = RayHsl(hue: 180, saturation: 1.0, lightness: 1.0);

      // Maximum hue distance is 180°
      expect(hue0.hueDistance(hue180), closeTo(180.0, precisionTolerance));

      // Maximum saturation distance is 1.0
      expect(hue0.saturationDistance(hue180), closeTo(1.0, precisionTolerance));

      // Maximum lightness distance is 1.0
      expect(hue0.lightnessDistance(hue180), closeTo(1.0, precisionTolerance));
    });
  });
}
