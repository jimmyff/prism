import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  PrismThemeSource src({
    double hue = 264,
    double chroma = 0.15,
    String? font,
    ({Beam<RayOklch> light, Beam<RayOklch> dark})? canvas,
  }) => PrismThemeSource(
    seeds: PrismSeeds(
      primary: ok(0.5, chroma, hue),
      secondary: ok(0.55, chroma * 0.8, (hue + 40) % 360),
      tertiary: ok(0.6, chroma * 0.6, (hue + 80) % 360),
    ),
    typography:
        font == null ? null : PrismTypography.fromScale(fontFamily: font),
    canvas: canvas,
  );

  group('lerp — endpoint clamp on every public lerp', () {
    final a = src().compile(PrismBrightness.light);
    final b = src(hue: 30).compile(PrismBrightness.light);

    void checkEndpoints<T>(T Function(T, double) lerp, T x, T y) {
      expect(lerp(x, 0.0), x);
      expect(lerp(x, 1.0), y);
      expect(() => lerp(x, -0.5), returnsNormally);
      expect(() => lerp(x, 1.5), returnsNormally);
      expect(lerp(x, -0.5), x); // clamped to 0
      expect(lerp(x, 1.5), y); // clamped to 1
    }

    test('PrismTheme', () => checkEndpoints((x, t) => x.lerp(b, t), a, b));
    test(
      'PrismScheme',
      () => checkEndpoints((x, t) => x.lerp(b.scheme, t), a.scheme, b.scheme),
    );
    test(
      'PrismSeeds',
      () => checkEndpoints((x, t) => x.lerp(b.seeds, t), a.seeds, b.seeds),
    );
    test('PrismAccent', () {
      checkEndpoints(
        (x, t) => x.lerp(b.scheme.action, t),
        a.scheme.action,
        b.scheme.action,
      );
    });
    test('PrismTypography', () {
      checkEndpoints(
        (x, t) => x.lerp(b.typography, t),
        a.typography,
        b.typography,
      );
    });
    test('PrismTextStyle', () {
      checkEndpoints(
        (x, t) => x.lerp(b.typography.body, t),
        a.typography.body,
        b.typography.body,
      );
    });
    test(
      'PrismSpacing',
      () =>
          checkEndpoints((x, t) => x.lerp(b.spacing, t), a.spacing, b.spacing),
    );
    test('PrismGeometry', () {
      checkEndpoints((x, t) => x.lerp(b.geometry, t), a.geometry, b.geometry);
    });
  });

  group('lerp — brightness snap', () {
    test('snaps at t=0.5 (0.49 → this, 0.50 → other)', () {
      final light = src().compile(PrismBrightness.light);
      final dark = src().compile(PrismBrightness.dark);
      expect(light.lerp(dark, 0.49).brightness, PrismBrightness.light);
      expect(light.lerp(dark, 0.50).brightness, PrismBrightness.dark);
    });
  });

  group('lerp — cross-source atDarkness', () {
    test('differing seeds/canvas-shape/font: no throw + endpoint identity', () {
      final lightSrc = src(
        hue: 264,
        font: 'Alpha',
        canvas: (
          light: Beam.flat(ok(0.985, 0.004, 264)),
          dark: Beam.flat(ok(0.16, 0.02, 264)),
        ),
      );
      final darkSrc = src(
        hue: 30,
        chroma: 0.2,
        font: 'Beta',
        canvas: (
          light: Beam.flat(ok(0.98, 0.01, 30)),
          // Different shape (3 stops) to exercise union-of-stops resampling.
          dark: Beam.linear([
            ok(0.16, 0.06, 300),
            ok(0.19, 0.07, 280),
            ok(0.22, 0.08, 265),
          ]),
        ),
      );
      final pair = PrismThemePair(
        light: lightSrc.compile(PrismBrightness.light),
        dark: darkSrc.compile(PrismBrightness.dark),
      );
      expect(() => pair.atDarkness(0.5), returnsNormally);
      expect(pair.atDarkness(0), pair.light);
      expect(pair.atDarkness(1), pair.dark);
      expect(() => pair.atDarkness(-0.5), returnsNormally);
      expect(() => pair.atDarkness(1.5), returnsNormally);
    });

    test('a parked midpoint is illegible — ink vs surface contrast ~1:1', () {
      // Verifies the documented caveat empirically: a linear light↔dark
      // crossfade collapses ink/surface contrast near t=0.5 (a motion frame,
      // never a resting theme). Standard table, single source.
      final pair = src().compilePair();
      final mid = pair.atDarkness(0.5).scheme;
      expect(mid.ink.contrastRatio(mid.surface.base), lessThan(1.5));
      // The endpoints, by contrast, clear the body-text bar comfortably.
      final light = pair.light.scheme;
      expect(light.ink.contrastRatio(light.surface.base), greaterThan(4.5));
    });
  });

  group('lerp — gamut safety', () {
    test('saturated cross-hue morph midpoints render without throwing', () {
      final a = src(hue: 30, chroma: 0.22).compile(PrismBrightness.light);
      final b = src(hue: 210, chroma: 0.22).compile(PrismBrightness.light);
      for (final t in [0.25, 0.5, 0.75]) {
        final m = a.lerp(b, t);
        expect(() => m.scheme.action.fill.toRgb8(), returnsNormally);
        expect(() => m.scheme.canvas.colorAt(0.5).toRgb8(), returnsNormally);
      }
    });

    test('scheme color lerp takes the shortest hue path', () {
      final a = PrismAccent(
        fill: ok(0.5, 0.1, 350),
        onFill: ok(0.99, 0.02, 350),
        ink: ok(0.44, 0.1, 350),
      );
      final b = PrismAccent(
        fill: ok(0.5, 0.1, 10),
        onFill: ok(0.99, 0.02, 10),
        ink: ok(0.44, 0.1, 10),
      );
      final mid = a.lerp(b, 0.5).fill;
      expect(mid.hue, anyOf(closeTo(0.0, 1e-6), closeTo(360.0, 1e-6)));
    });
  });
}
