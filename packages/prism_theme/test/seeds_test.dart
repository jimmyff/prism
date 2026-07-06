import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  PrismSeeds brand({RayOklch? primary}) => PrismSeeds(
    primary: primary ?? RayOklch.fromComponents(0.5, 0.15, 264),
    secondary: RayOklch.fromComponents(0.6, 0.1, 200),
    tertiary: RayOklch.fromComponents(0.7, 0.1, 300),
  );

  group('PrismSeeds', () {
    test('normalizes any Ray to Oklch and indexes by PrismSeed', () {
      final seeds = PrismSeeds(
        primary: Ray.parse('#3366CC'),
        secondary: RayOklch.fromComponents(0.6, 0.1, 200),
        tertiary: RayOklch.fromComponents(0.7, 0.1, 300),
      );
      expect(seeds.primary, isA<RayOklch>());
      expect(seeds[PrismSeed.primary], seeds.primary);
      expect(seeds[PrismSeed.info], isA<RayOklch>()); // default present
    });

    test('neutral defaults to primary hue at barely-there chroma', () {
      final seeds = brand();
      expect(seeds.neutral.hue, closeTo(264, 1e-6));
      expect(seeds.neutral.chroma, lessThan(0.02));
    });

    test('status defaults applied and overridable', () {
      final base = brand();
      expect(base.error.hue, closeTo(27, 1e-6));
      final custom = base.copyWith(
        error: RayOklch.fromComponents(0.5, 0.2, 20),
      );
      expect(custom.error.hue, closeTo(20, 1e-6));
    });

    test('harmonic derives secondary and tertiary', () {
      final seeds = PrismSeeds.harmonic(
        RayOklch.fromComponents(0.5, 0.15, 264),
      );
      expect(seeds.secondary.hue, closeTo(264, 1e-6));
      expect(seeds.secondary.chroma, closeTo(0.15 / 3, 1e-6));
      expect(seeds.tertiary.hue, closeTo(324, 1e-6));
      expect(seeds.tertiary.chroma, closeTo(0.15 * 2 / 3, 1e-6));
    });

    test('lerp clamps t and hits endpoints', () {
      final a = brand();
      final b = brand(primary: RayOklch.fromComponents(0.6, 0.12, 30));
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(() => a.lerp(b, -0.5), returnsNormally);
      expect(() => a.lerp(b, 1.5), returnsNormally);
      expect(a.lerp(b, -0.5), a); // clamped to 0
      expect(a.lerp(b, 1.5), b); // clamped to 1
    });

    test('value equality', () {
      expect(brand(), brand());
      expect(brand().hashCode, brand().hashCode);
    });
  });
}
