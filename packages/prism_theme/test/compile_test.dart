import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  PrismThemeSource source({
    PrismSeeds? seeds,
    PrismSeeds? darkSeeds,
    PrismRoles roles = const PrismRoles(),
  }) => PrismThemeSource(
    seeds:
        seeds ??
        PrismSeeds(
          primary: ok(0.5, 0.15, 264),
          secondary: ok(0.55, 0.12, 200),
          tertiary: ok(0.6, 0.12, 320),
        ),
    darkSeeds: darkSeeds,
    roles: roles,
  );

  group('compile — lightness', () {
    test('applies exact spec L (L never gamut-adjusted, only chroma)', () {
      final s = source().compile(PrismBrightness.light).scheme;
      expect(s.surface.base.lightness, closeTo(0.97, 1e-9));
      // onFill is pushed to an extreme L where chroma must clamp — L stays exact.
      expect(s.action.onFill.lightness, closeTo(0.99, 1e-9));
    });

    test('dark brightness uses the dark L values', () {
      final s = source().compile(PrismBrightness.dark).scheme;
      expect(s.surface.base.lightness, closeTo(0.21, 1e-9));
    });

    test('out-of-range L is caught at compile (withLightness throws)', () {
      final src = source(
        roles: const PrismRoles(
          focus: PrismRoleSpec(PrismSeed.primary, l: (light: 1.2, dark: 0.5)),
        ),
      );
      expect(() => src.compile(PrismBrightness.light), throwsArgumentError);
    });
  });

  group('compile — chroma order (lightness-first)', () {
    test('real divergence: forward preserves chroma, reversed collapses', () {
      final seed = ok(0.985, 0.20, 264); // out of gamut at its own L
      final forward = seed.withLightness(0.55).withChroma(seed.chroma);
      final reversed = seed.withChroma(seed.chroma).withLightness(0.55);
      expect(forward.chroma, greaterThan(reversed.chroma * 3));
      expect(reversed.chroma, lessThan(0.03));

      // compile uses the forward (lightness-first) order.
      final src = source(
        seeds: PrismSeeds(
          primary: seed,
          secondary: ok(0.5, 0.1, 200),
          tertiary: ok(0.5, 0.1, 320),
        ),
        roles: const PrismRoles(
          focus: PrismRoleSpec(PrismSeed.primary, l: (light: 0.55, dark: 0.55)),
        ),
      );
      final focus = src.compile(PrismBrightness.light).scheme.focus;
      expect(focus.chroma, closeTo(forward.chroma, 1e-9));
    });

    test('in-gamut mid-L seed: order makes no difference', () {
      final seed = ok(0.5, 0.10, 264);
      final forward = seed.withLightness(0.55).withChroma(seed.chroma);
      final reversed = seed.withChroma(seed.chroma).withLightness(0.55);
      expect(forward.chroma, closeTo(reversed.chroma, 1e-9));
    });
  });

  group('compile — alpha & provenance', () {
    test('alpha carried onto ink roles', () {
      final s = source().compile(PrismBrightness.light).scheme;
      expect(s.inkMuted.opacity, closeTo(0.65, 1e-9));
      expect(s.inkFaint.opacity, closeTo(0.40, 1e-9));
      expect(s.ink.opacity, closeTo(1.0, 1e-9));
    });

    test('darkSeeds diverges the dark compile', () {
      final darkSeeds = PrismSeeds(
        primary: ok(0.8, 0.1, 30),
        secondary: ok(0.8, 0.1, 60),
        tertiary: ok(0.8, 0.1, 90),
      );
      final src = source(darkSeeds: darkSeeds);
      expect(
        src.compile(PrismBrightness.dark).seeds.primary,
        darkSeeds.primary,
      );
      expect(
        src.compile(PrismBrightness.light).seeds.primary,
        isNot(darkSeeds.primary),
      );
    });
  });

  group('compile — gamut-clamp delta', () {
    test('reports clamp on extreme-L onFill roles', () {
      final s = source().compile(PrismBrightness.light).scheme;
      expect(s.clampDeltas[PrismRole.actionOnFill], isNotNull);
      expect(s.clampDeltas[PrismRole.actionOnFill], greaterThan(0.0));
    });

    test('is unmodifiable', () {
      final s = source().compile(PrismBrightness.light).scheme;
      expect(() => s.clampDeltas[PrismRole.ink] = 1, throwsUnsupportedError);
    });
  });

  group('compile — gradient fills', () {
    test('a flat fill compiles to a flat Beam', () {
      final s = source().compile(PrismBrightness.light).scheme;
      expect(s.surface.isGradient, isFalse);
      expect(s.surface.base.lightness, closeTo(0.97, 1e-9));
    });

    test('a gradient delta compiles to a 2-stop Beam (base = top)', () {
      final src = source(
        roles: const PrismRoles(
          surfaceRaised: PrismRoleSpec(
            PrismSeed.neutral,
            l: (light: 0.30, dark: 0.30),
            gradient: -0.06,
          ),
        ),
      );
      final raised = src.compile(PrismBrightness.light).scheme.surfaceRaised;
      expect(raised.isGradient, isTrue);
      expect(raised.rays.length, 2);
      expect(raised.base.lightness, closeTo(0.30, 1e-9)); // top
      expect(raised.colorAt(1).lightness, closeTo(0.24, 1e-9)); // bottom
    });

    test('gradientSeed shifts the far stop to another seed (hue shift)', () {
      final src = source(
        roles: const PrismRoles(
          surfaceRaised: PrismRoleSpec(
            PrismSeed.primary,
            l: (light: 0.30, dark: 0.30),
            gradientSeed: PrismSeed.secondary,
          ),
        ),
      );
      final raised = src.compile(PrismBrightness.dark).scheme.surfaceRaised;
      expect(raised.isGradient, isTrue);
      expect(raised.base.hue, closeTo(264, 1)); // primary hue (top)
      expect(raised.colorAt(1).hue, closeTo(200, 1)); // secondary hue (bottom)
    });
  });

  group('compilePair', () {
    test('produces both brightnesses', () {
      final pair = source().compilePair();
      expect(pair.light.brightness, PrismBrightness.light);
      expect(pair.dark.brightness, PrismBrightness.dark);
      expect(pair.resolve(PrismBrightness.dark), pair.dark);
    });
  });

  group('resolve seam & absolute base', () {
    test('absolute role compiles from the exact inline color', () {
      final teal = ok(0.6, 0.12, 180);
      final src = source(
        roles: PrismRoles(
          surface: PrismRoleSpec.absolute(teal, l: (light: 0.5, dark: 0.5)),
        ),
      );
      final surface = src.compile(PrismBrightness.light).scheme.surface.base;
      expect(surface.hue, closeTo(180, 1)); // inline hue, not a theme seed
      expect(surface.lightness, closeTo(0.5, 1e-9)); // spec L applied
    });

    test('absolute accent compiles from the inline color', () {
      final teal = ok(0.6, 0.12, 180);
      final src = source(
        roles: PrismRoles(action: PrismAccentSpec.absolute(teal)),
      );
      final action = src.compile(PrismBrightness.light).scheme.action;
      expect(action.fill.hue, closeTo(180, 1));
    });

    test('resolve applies the spec transforms to an arbitrary base', () {
      const spec = PrismRoleSpec(PrismSeed.primary, l: (light: 0.4, dark: 0.4));
      final base = ok(0.9, 0.1, 30);
      final r = spec.resolve(base, PrismBrightness.light);
      expect(r.color.lightness, closeTo(0.4, 1e-9)); // spec L over base's own
      expect(r.color.hue, closeTo(30, 1)); // base hue preserved
    });

    test('resolveSeed matches the compiled scheme role exactly', () {
      final src = source();
      final scheme = src.compile(PrismBrightness.light).scheme;
      final r = src.roles.focus.resolveSeed(src.seeds, PrismBrightness.light);
      expect(r.color, scheme.focus);
    });

    test('accent resolveSeed reports the three clamp deltas', () {
      final src = source();
      final r = src.roles.action.resolveSeed(src.seeds, PrismBrightness.light);
      // onFill pushed to L 0.99 clamps chroma; the record carries all three.
      expect(r.onFillDelta, greaterThan(0.0));
      expect(r.fillDelta, greaterThanOrEqualTo(0.0));
      expect(r.inkDelta, greaterThanOrEqualTo(0.0));
    });

    test('resolve yields a gradient spec top stop (flat base only)', () {
      const spec = PrismRoleSpec(
        PrismSeed.primary,
        l: (light: 0.3, dark: 0.3),
        gradient: -0.1,
      );
      final r = spec.resolve(ok(0.5, 0.1, 264), PrismBrightness.light);
      expect(r.color.lightness, closeTo(0.3, 1e-9)); // top stop, not shifted
    });
  });
}
