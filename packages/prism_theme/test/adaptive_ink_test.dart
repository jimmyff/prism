import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

/// PrismInkMode.adaptive — the compile-time ink-lightness solve.
///
/// The scenario is a dynamic theme rotating an accent seed's hue: the authored
/// ink lightness was calibrated against one hue, and at another hue the same
/// OKLCH L has a different WCAG luminance, failing body contrast. Adaptive
/// mode solves the ink to the nearest passing lightness; fixed mode ships the
/// failure.
void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  // A plum-calibrated brand whose secondary has been swung to emerald green —
  // the hue rotation that sinks a light ink authored at the 4.5:1 boundary.
  PrismSeeds greenSwung() => PrismSeeds(
    primary: ok(0.55, 0.11, 220),
    secondary: ok(0.63, 0.09, 155), // emerald at the plum's L/C
    tertiary: ok(0.55, 0.17, 288),
    neutral: ok(0.5, 0.02, 295),
  );

  // Lavender gradient canvas + translucent, gradient surfaces (the layered
  // backdrops the audit composites) — the environment the ink must clear.
  ({Beam<RayOklch> light, Beam<RayOklch> dark}) canvas() => (
    light: Beam.linear([ok(0.91, 0.05, 290), ok(0.87, 0.04, 285)]),
    dark: Beam.linear([ok(0.20, 0.09, 300), ok(0.16, 0.10, 285)]),
  );

  PrismRoles roles({required PrismInkMode inkMode}) => PrismRoles(
    surface: const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.97, dark: 0.21),
      alpha: 0.3,
      gradient: -0.03,
    ),
    surfaceRaised: const PrismRoleSpec(
      PrismSeed.neutral,
      chroma: 6,
      l: (light: 0.994, dark: 0.26),
      alpha: 0.95,
      gradient: -0.10,
    ),
    chrome: const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.95, dark: 0.18),
      alpha: 0.50,
      gradient: -0.05,
    ),
    hero: PrismAccentSpec(
      PrismSeed.secondary,
      ink: const (light: 0.48, dark: 0.90),
      inkMode: inkMode,
    ),
  );

  PrismThemeSource source({required PrismInkMode inkMode}) => PrismThemeSource(
    seeds: greenSwung(),
    canvas: canvas(),
    roles: roles(inkMode: inkMode),
  );

  List<PrismAuditResult> heroInkFailures(PrismTheme theme) =>
      theme
          .audit()
          .where(
            (r) =>
                !r.passes &&
                !r.advisory &&
                r.foreground == PrismRole.heroInk,
          )
          .toList();

  group('PrismInkMode.adaptive', () {
    test('a hue-swung ink fails fixed and passes adaptive', () {
      final fixed = source(
        inkMode: PrismInkMode.fixed,
      ).compile(PrismBrightness.light);
      expect(heroInkFailures(fixed), isNotEmpty, reason: 'fixture must bite');

      final pair = source(inkMode: PrismInkMode.adaptive).compilePair();
      expect(heroInkFailures(pair.light), isEmpty);
      expect(heroInkFailures(pair.dark), isEmpty);
    });

    test('light member only darkens, dark member only brightens', () {
      final fixedPair = source(inkMode: PrismInkMode.fixed).compilePair();
      final pair = source(inkMode: PrismInkMode.adaptive).compilePair();

      // Light authored 0.48 fails at green → solved strictly darker.
      expect(
        pair.light.scheme.hero.ink.lightness,
        lessThan(fixedPair.light.scheme.hero.ink.lightness),
      );
      // Dark authored 0.90 already passes → bit-identical to fixed.
      expect(pair.dark.scheme.hero.ink, fixedPair.dark.scheme.hero.ink);
    });

    test('identity when the authored ink passes (whole scheme matches fixed)',
        () {
      // The original plum secondary — the hue the 0.48 ink was calibrated for.
      final plum = greenSwung().copyWith(secondary: ok(0.63, 0.09, 337));
      final fixed = source(inkMode: PrismInkMode.fixed).copyWith(seeds: plum);
      final adaptive = source(
        inkMode: PrismInkMode.adaptive,
      ).copyWith(seeds: plum);

      for (final b in [PrismBrightness.light, PrismBrightness.dark]) {
        final f = fixed.compile(b).scheme;
        final a = adaptive.compile(b).scheme;
        expect(a.hero.ink, f.hero.ink);
        expect(a.hero.fill, f.hero.fill);
        expect(a.hero.onFill, f.hero.onFill);
        expect(a.clampDeltas, f.clampDeltas);
      }
    });

    test('a failing dark ink brightens to pass', () {
      // Lifted dark canvas + a too-dim authored dark ink: the solve must move
      // the other direction (brighten).
      final src = PrismThemeSource(
        seeds: greenSwung(),
        canvas: (
          light: canvas().light,
          dark: Beam.flat(ok(0.30, 0.06, 290)),
        ),
        roles: PrismRoles(
          hero: const PrismAccentSpec(
            PrismSeed.secondary,
            ink: (light: 0.30, dark: 0.62),
            inkMode: PrismInkMode.adaptive,
          ),
        ),
      );
      final dark = src.compile(PrismBrightness.dark);
      expect(dark.scheme.hero.ink.lightness, greaterThan(0.62));
      expect(heroInkFailures(dark), isEmpty);
    });

    test('unsolvable backdrops keep the authored lightness (audit owns it)',
        () {
      // A full-span canvas gradient: every lightness sits near-crossover with
      // some sample, so no L can clear body contrast. The solve must not
      // thrash — it returns the authored value and the audit reports the
      // failure.
      final fullSpan = Beam.linear([ok(0.02, 0, 0), ok(0.98, 0, 0)]);
      final src = PrismThemeSource(
        seeds: greenSwung(),
        canvas: (light: fullSpan, dark: fullSpan),
        roles: roles(inkMode: PrismInkMode.adaptive),
      );
      final light = src.compile(PrismBrightness.light);
      expect(light.scheme.hero.ink.lightness, closeTo(0.48, 1e-9));
      expect(heroInkFailures(light), isNotEmpty);
    });

    test('the solved ink measures at or above the policy body threshold', () {
      final pair = source(inkMode: PrismInkMode.adaptive).compilePair();
      final heroChecks = pair.light
          .audit()
          .where((r) => r.foreground == PrismRole.heroInk);
      for (final r in heroChecks) {
        expect(r.ratio, greaterThanOrEqualTo(4.5), reason: r.toString());
      }
    });
  });
}
