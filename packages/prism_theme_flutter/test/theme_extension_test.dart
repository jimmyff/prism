import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

PrismThemeSource _source() => PrismThemeSource(
  seeds: PrismSeeds(
    primary: RayOklch.fromComponents(0.55, 0.16, 264),
    secondary: RayOklch.fromComponents(0.60, 0.13, 200),
    tertiary: RayOklch.fromComponents(0.62, 0.14, 320),
  ),
);

void main() {
  group('PrismThemeExtension', () {
    test('role exhaustiveness: color(role) == ray(role).toColor() for all', () {
      final theme = _source().compile(PrismBrightness.light);
      final ext = PrismThemeExtension(theme);
      for (final role in PrismRole.values) {
        expect(
          ext.color(role),
          theme.scheme.ray(role).toColor(),
          reason: role.name,
        );
      }
    });

    test('named getters delegate to color(role)', () {
      final ext = PrismThemeExtension(_source().compile(PrismBrightness.light));
      expect(ext.actionFill, ext.color(PrismRole.actionFill));
      expect(ext.ink, ext.color(PrismRole.ink));
      expect(ext.surface, ext.color(PrismRole.surface));
      expect(ext.divider, ext.color(PrismRole.divider));
    });

    test('color cache returns an identical instance', () {
      final ext = PrismThemeExtension(_source().compile(PrismBrightness.light));
      expect(
        identical(ext.color(PrismRole.ink), ext.color(PrismRole.ink)),
        isTrue,
      );
    });

    test('lerp guards against a non-PrismThemeExtension (returns this)', () {
      final ext = PrismThemeExtension(_source().compile(PrismBrightness.light));
      expect(ext.lerp(null, 0.5), ext);
    });

    test('lerp(other, 1.2) does not throw (overshoot-safe)', () {
      final a = PrismThemeExtension(_source().compile(PrismBrightness.light));
      final b = PrismThemeExtension(_source().compile(PrismBrightness.dark));
      expect(() => a.lerp(b, 1.2), returnsNormally);
    });

    test('equal themes → equal extension AND equal hashCode', () {
      final a = PrismThemeExtension(_source().compile(PrismBrightness.light));
      final b = PrismThemeExtension(_source().compile(PrismBrightness.light));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('canvas getter yields a LinearGradient', () {
      final ext = PrismThemeExtension(_source().compile(PrismBrightness.dark));
      expect(ext.canvas, isA<LinearGradient>());
    });

    test('exposes token getters and a state-layer builder', () {
      final ext = PrismThemeExtension(_source().compile(PrismBrightness.dark));
      expect(ext.geometry.outlineWidth, 1.2);
      expect(ext.stateLayers.hover, 0.13);
      expect(
        ext.stateLayer(const Color(0xFFFFFFFF)),
        isA<WidgetStateProperty<Color?>>(),
      );
    });

    test('fill gradient getters; an authored gradient has multiple stops', () {
      final flat = PrismThemeExtension(_source().compile(PrismBrightness.dark));
      expect(flat.surfaceGradient, isA<LinearGradient>());
      expect(flat.surfaceRaisedGradient, isA<LinearGradient>());
      expect(flat.chromeGradient, isA<LinearGradient>());
      expect(flat.surfaceGradient.colors.toSet().length, 1); // flat = one color

      final gradSrc = PrismThemeSource(
        seeds: PrismSeeds(
          primary: RayOklch.fromComponents(0.55, 0.16, 264),
          secondary: RayOklch.fromComponents(0.60, 0.13, 200),
          tertiary: RayOklch.fromComponents(0.62, 0.14, 320),
        ),
        roles: const PrismRoles(
          surfaceRaised: PrismRoleSpec(
            PrismSeed.neutral,
            l: (light: 0.30, dark: 0.30),
            gradient: -0.06,
          ),
        ),
      );
      final grad = PrismThemeExtension(gradSrc.compile(PrismBrightness.dark));
      expect(grad.surfaceRaisedGradient.colors.toSet().length, greaterThan(1));
    });
  });

  group('context.prism', () {
    testWidgets('is present via toThemeData', (tester) async {
      final theme = _source().compile(PrismBrightness.light);
      late PrismThemeExtension captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme.toThemeData(),
          home: Builder(
            builder: (context) {
              captured = context.prism;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured.theme, theme);
    });

    testWidgets('throws a FlutterError on a bare MaterialApp', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(() => ctx.prism, throwsA(isA<FlutterError>()));
    });
  });
}
