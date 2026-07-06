import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  PrismSeeds seeds() => PrismSeeds(
    primary: ok(0.5, 0.15, 264),
    secondary: ok(0.55, 0.12, 200),
    tertiary: ok(0.6, 0.12, 320),
  );

  ({Beam<RayOklch> light, Beam<RayOklch> dark}) authoredCanvas() => (
    light: Beam.linear([ok(0.9, 0.05, 264), ok(0.7, 0.05, 264)]),
    dark: Beam.linear([ok(0.2, 0.05, 264), ok(0.1, 0.05, 264)]),
  );

  group('PrismThemeSource.copyWith clearing', () {
    test('canvas: null reverts to the default flat neutral canvas', () {
      final authored = PrismThemeSource(
        seeds: seeds(),
        canvas: authoredCanvas(),
      );
      expect(
        authored.compile(PrismBrightness.light).scheme.canvas.isGradient,
        isTrue,
      );

      final cleared = authored.copyWith(canvas: null);
      final canvas = cleared.compile(PrismBrightness.light).scheme.canvas;
      expect(canvas.isGradient, isFalse);
      expect(canvas.base.lightness, closeTo(0.985, 1e-9)); // default neutral L
    });

    test('omitting canvas keeps the authored canvas', () {
      final authored = PrismThemeSource(
        seeds: seeds(),
        canvas: authoredCanvas(),
      );
      final other = authored.copyWith(splash: PrismSplash.sparkle);
      expect(other.canvas, authored.canvas);
      expect(other.splash, PrismSplash.sparkle);
    });

    test('darkSeeds: null un-diverges dark mode', () {
      final authored = PrismThemeSource(
        seeds: seeds(),
        darkSeeds: PrismSeeds(
          primary: ok(0.8, 0.1, 30),
          secondary: ok(0.8, 0.1, 60),
          tertiary: ok(0.8, 0.1, 90),
        ),
      );
      expect(authored.darkSeeds, isNotNull);
      expect(authored.copyWith(darkSeeds: null).darkSeeds, isNull);
    });

    test('typography: null resets to standard', () {
      final authored = PrismThemeSource(
        seeds: seeds(),
        typography: PrismTypography.fromScale(base: 20),
      );
      expect(authored.typography, isNotNull);
      expect(authored.copyWith(typography: null).typography, isNull);
    });
  });

  group('PrismRoles.copyWith', () {
    test('one-line override keeps the rest', () {
      const custom = PrismRoles();
      const focus = PrismRoleSpec(
        PrismSeed.tertiary,
        l: (light: 0.6, dark: 0.7),
      );
      final swapped = custom.copyWith(focus: focus);
      expect(swapped.focus, focus);
      expect(swapped.surface, custom.surface); // unchanged
      expect(swapped.action, custom.action); // unchanged
    });
  });

  group('PrismScheme.copyWith', () {
    test('one-role surgery clears clampDeltas', () {
      final scheme =
          PrismThemeSource(
            seeds: seeds(),
          ).compile(PrismBrightness.light).scheme;
      expect(scheme.clampDeltas, isNotEmpty); // standard table clamps onFill

      final edited = scheme.copyWith(ink: ok(0.3, 0.0, 0));
      expect(edited.ink, ok(0.3, 0.0, 0));
      expect(edited.clampDeltas, isEmpty); // un-audited derived scheme
      expect(edited.surface, scheme.surface); // everything else preserved
    });
  });
}
