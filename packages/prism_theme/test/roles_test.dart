import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  group('PrismRole enum', () {
    test('has exactly 31 flat roles', () {
      expect(PrismRole.values.length, 31);
    });
  });

  group('PrismRoleSpec', () {
    // Lightness ranges are validated at compile time (see compile_test), since
    // Dart cannot assert record fields in a const constructor.
    test('asserts alpha in range', () {
      expect(
        () => PrismRoleSpec(PrismSeed.neutral, alpha: 1.5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows chroma multiplier > 1 (gamut boost)', () {
      expect(
        () => PrismRoleSpec(PrismSeed.primary, chroma: 1.4),
        returnsNormally,
      );
    });

    test('lightnessFor picks by brightness; null keeps seed lightness', () {
      const spec = PrismRoleSpec(PrismSeed.neutral, l: (light: 0.2, dark: 0.9));
      expect(spec.lightnessFor(PrismBrightness.light), 0.2);
      expect(spec.lightnessFor(PrismBrightness.dark), 0.9);
      const raw = PrismRoleSpec(PrismSeed.primary);
      expect(raw.lightnessFor(PrismBrightness.light), isNull);
    });

    test('value equality (records compare structurally)', () {
      expect(
        const PrismRoleSpec(PrismSeed.neutral, l: (light: 0.2, dark: 0.9)),
        const PrismRoleSpec(PrismSeed.neutral, l: (light: 0.2, dark: 0.9)),
      );
    });

    test('inline bases with different colors are unequal', () {
      final a = PrismRoleSpec.absolute(RayOklch.fromComponents(0.5, 0.1, 20));
      final b = PrismRoleSpec.absolute(RayOklch.fromComponents(0.5, 0.1, 200));
      expect(a, isNot(b));
    });

    test('copyWith switches the base (seed → inline)', () {
      const seeded = PrismRoleSpec(PrismSeed.primary);
      final inline = seeded.copyWith(
        base: PrismColorBase.inline(RayOklch.fromComponents(0.5, 0.1, 20)),
      );
      expect(inline.base, isNot(seeded.base));
      expect(seeded.base, PrismColorBase.seed(PrismSeed.primary));
    });
  });

  group('PrismAccentSpec', () {
    test('carries per-slot defaults', () {
      const spec = PrismAccentSpec(PrismSeed.primary);
      expect(spec.fill.light, 0.50);
      expect(spec.onFill.light, 0.99);
      expect(spec.ink.dark, 0.80);
    });

    test('inline bases with different colors are unequal', () {
      final a = PrismAccentSpec.absolute(RayOklch.fromComponents(0.5, 0.1, 20));
      final b = PrismAccentSpec.absolute(
        RayOklch.fromComponents(0.5, 0.1, 200),
      );
      expect(a, isNot(b));
    });
  });

  group('PrismRoles standard table', () {
    test('default table is const-constructible with 17 specs', () {
      const roles = PrismRoles();
      expect(roles.singleSpecs.length, 10);
      expect(roles.accentSpecs.length, 7);
      expect(roles.highlight.base, PrismColorBase.seed(PrismSeed.tertiary));
    });

    test('override-per-line keeps other defaults', () {
      const custom = PrismRoles(
        focus: PrismRoleSpec(PrismSeed.tertiary, l: (light: 0.6, dark: 0.7)),
      );
      expect(custom.focus.base, PrismColorBase.seed(PrismSeed.tertiary));
      expect(custom.surface, const PrismRoles().surface); // unchanged
    });

    test('value equality', () {
      expect(const PrismRoles(), const PrismRoles());
      expect(const PrismRoles().hashCode, const PrismRoles().hashCode);
    });
  });

  group('PrismAccent (compiled)', () {
    test('lerp clamps t and hits endpoints', () {
      const a = PrismAccent(
        fill: RayOklch.fromComponents(0.5, 0.1, 260),
        onFill: RayOklch.fromComponents(0.99, 0.02, 260),
        ink: RayOklch.fromComponents(0.44, 0.1, 260),
      );
      const b = PrismAccent(
        fill: RayOklch.fromComponents(0.8, 0.1, 30),
        onFill: RayOklch.fromComponents(0.2, 0.02, 30),
        ink: RayOklch.fromComponents(0.84, 0.1, 30),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(b, -0.5), a); // clamped
      expect(a.lerp(b, 1.5), b); // clamped
    });
  });
}
