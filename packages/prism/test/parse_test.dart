import 'package:prism/prism.dart';
import 'package:test/test.dart';

void main() {
  group('Ray.parse() Global Parser', () {
    test('parses hex formats and returns RayRgb8', () {
      final color1 = Ray.parse('#FF0000');
      final color2 = Ray.parse('#F00');
      final color3 = Ray.parse('#FF0000FF');

      expect(color1, isA<RayRgb8>());
      expect(color2, isA<RayRgb8>());
      expect(color3, isA<RayRgb8>());

      expect((color1 as RayRgb8).red, 255);
      expect((color2 as RayRgb8).red, 255);
      expect((color3 as RayRgb8).red, 255);
    });

    test('parses rgb() formats and returns RayRgb8', () {
      final color1 = Ray.parse('rgb(255, 0, 0)');
      final color2 = Ray.parse('rgb(255 0 0)');
      final color3 = Ray.parse('rgba(255, 0, 0, 0.5)');
      final color4 = Ray.parse('rgb(255 0 0 / 0.5)');

      expect(color1, isA<RayRgb8>());
      expect(color2, isA<RayRgb8>());
      expect(color3, isA<RayRgb8>());
      expect(color4, isA<RayRgb8>());

      expect((color1 as RayRgb8).red, 255);
      expect((color2 as RayRgb8).red, 255);
      expect((color3 as RayRgb8).red, 255);
      expect((color4 as RayRgb8).red, 255);
    });

    test('parses hsl() formats and returns RayHsl', () {
      final color1 = Ray.parse('hsl(120, 100%, 50%)');
      final color2 = Ray.parse('hsl(120 100% 50%)');
      final color3 = Ray.parse('hsla(120, 100%, 50%, 0.8)');
      final color4 = Ray.parse('hsl(120 100% 50% / 0.8)');

      expect(color1, isA<RayHsl>());
      expect(color2, isA<RayHsl>());
      expect(color3, isA<RayHsl>());
      expect(color4, isA<RayHsl>());

      expect((color1 as RayHsl).hue, 120);
      expect((color2 as RayHsl).hue, 120);
      expect((color3 as RayHsl).hue, 120);
      expect((color4 as RayHsl).hue, 120);
    });

    test('parses oklab() formats and returns RayOklab', () {
      final color1 = Ray.parse('oklab(0.5 0.1 -0.2)');
      final color2 = Ray.parse('oklab(0.5 0.1 -0.2 / 0.8)');

      expect(color1, isA<RayOklab>());
      expect(color2, isA<RayOklab>());

      expect((color1 as RayOklab).lightness, closeTo(0.5, 0.001));
      expect((color2 as RayOklab).lightness, closeTo(0.5, 0.001));
    });

    test('parses oklch() formats and returns RayOklch', () {
      final color1 = Ray.parse('oklch(0.6 0.2 300)');
      final color2 = Ray.parse('oklch(0.6 0.2 300 / 0.9)');

      expect(color1, isA<RayOklch>());
      expect(color2, isA<RayOklch>());

      expect((color1 as RayOklch).lightness, closeTo(0.6, 0.001));
      expect((color2 as RayOklch).lightness, closeTo(0.6, 0.001));
    });

    test('handles case insensitivity for all formats', () {
      expect(Ray.parse('RGB(255, 0, 0)'), isA<RayRgb8>());
      expect(Ray.parse('HSL(120, 100%, 50%)'), isA<RayHsl>());
      expect(Ray.parse('OKLAB(0.5 0.1 -0.2)'), isA<RayOklab>());
      expect(Ray.parse('OKLCH(0.6 0.2 300)'), isA<RayOklch>());
    });

    test('handles whitespace for all formats', () {
      expect(Ray.parse('  #FF0000  '), isA<RayRgb8>());
      expect(Ray.parse('  rgb(255, 0, 0)  '), isA<RayRgb8>());
      expect(Ray.parse('  hsl(120, 100%, 50%)  '), isA<RayHsl>());
      expect(Ray.parse('  oklab(0.5 0.1 -0.2)  '), isA<RayOklab>());
      expect(Ray.parse('  oklch(0.6 0.2 300)  '), isA<RayOklch>());
    });

    test('throws ArgumentError for unknown formats', () {
      expect(() => Ray.parse('invalid'), throwsArgumentError);
      expect(() => Ray.parse(''), throwsArgumentError);
      expect(() => Ray.parse('unknown(1, 2, 3)'), throwsArgumentError);
    });

    test('delegates to appropriate parser for each format', () {
      // Each parser should handle its own validation and errors
      expect(() => Ray.parse('rgb(300, 0, 0)'), returnsNormally); // Clamped
      expect(() => Ray.parse('hsl(400, 100%, 50%)'), returnsNormally); // Normalized
      expect(() => Ray.parse('#GGGGGG'), throwsArgumentError); // Invalid hex
    });
  });
}
