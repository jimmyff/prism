import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

/// WCAG contrast ratio between two opaque Flutter colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

PrismThemeSource _source() => PrismThemeSource(
  seeds: PrismSeeds(
    primary: RayOklch.fromComponents(0.55, 0.16, 264),
    secondary: RayOklch.fromComponents(0.60, 0.13, 200),
    tertiary: RayOklch.fromComponents(0.62, 0.14, 320),
  ),
  canvas: (
    light: Beam.flat(RayOklch.fromComponents(0.985, 0.004, 264)),
    dark: Beam.linear([
      RayOklch.fromComponents(0.16, 0.06, 300),
      RayOklch.fromComponents(0.22, 0.08, 262),
    ]),
  ),
);

void main() {
  group('toColorScheme', () {
    test('maps required roles and composites alpha over surface', () {
      final theme = _source().compile(PrismBrightness.light);
      final cs = theme.toColorScheme();
      final s = theme.scheme;
      expect(cs.brightness, Brightness.light);
      expect(cs.primary, s.action.fill.toColor());
      expect(cs.onPrimary, s.action.onFill.toColor());
      expect(cs.secondary, s.hero.fill.toColor());
      expect(cs.error, s.error.fill.toColor());
      final solidSurface = s.composite(s.surface.base, s.canvas.base);
      expect(cs.surface, solidSurface.toColor());
      expect(cs.onSurface, s.ink.toColor());
      expect(
        cs.onSurfaceVariant,
        s.composite(s.inkMuted, solidSurface).toColor(),
      );
      expect(cs.outline, s.composite(s.outline, solidSurface).toColor());
      expect(cs.surfaceContainerLowest, s.canvas.base.toColor());
      expect(cs.surfaceContainerHighest, s.chrome.base.toColor());
    });
  });

  group('toColorScheme — completed mapping', () {
    test('containers are the accent washed over the solid surface', () {
      final theme = _source().compile(PrismBrightness.light);
      final cs = theme.toColorScheme();
      final s = theme.scheme;
      final solidSurface = s.composite(s.surface.base, s.canvas.base);
      expect(
        cs.primaryContainer,
        s.wash(PrismRole.actionFill, solidSurface, 0.14).toColor(),
      );
      expect(cs.onPrimaryContainer, s.action.ink.toColor());
      expect(
        cs.secondaryContainer,
        s.wash(PrismRole.heroFill, solidSurface, 0.14).toColor(),
      );
      expect(
        cs.tertiaryContainer,
        s.wash(PrismRole.highlightFill, solidSurface, 0.14).toColor(),
      );
      expect(
        cs.errorContainer,
        s.wash(PrismRole.errorFill, solidSurface, 0.14).toColor(),
      );
    });

    test('dark containers use the heavier wash weight', () {
      final theme = _source().compile(PrismBrightness.dark);
      final cs = theme.toColorScheme();
      final s = theme.scheme;
      final solidSurface = s.composite(s.surface.base, s.canvas.base);
      expect(
        cs.primaryContainer,
        s.wash(PrismRole.actionFill, solidSurface, 0.20).toColor(),
      );
    });

    test('fixed variants alias the containers', () {
      final cs = _source().compile(PrismBrightness.light).toColorScheme();
      expect(cs.primaryFixed, cs.primaryContainer);
      expect(cs.primaryFixedDim, cs.primaryContainer);
      expect(cs.onPrimaryFixed, cs.onPrimaryContainer);
      expect(cs.onPrimaryFixedVariant, cs.onPrimaryContainer);
      expect(cs.secondaryFixed, cs.secondaryContainer);
      expect(cs.tertiaryFixed, cs.tertiaryContainer);
    });

    test('inverse trio is explicit', () {
      final theme = _source().compile(PrismBrightness.light);
      final cs = theme.toColorScheme();
      final s = theme.scheme;
      expect(cs.inverseSurface, s.ink.toColor());
      expect(cs.onInverseSurface, s.surface.base.toColor());
      expect(cs.inversePrimary, s.action.fill.withLightness(0.80).toColor());
    });

    test(
      'surface ramp: dim=canvas, bright=surfaceRaised, tint transparent',
      () {
        final theme = _source().compile(PrismBrightness.light);
        final cs = theme.toColorScheme();
        final s = theme.scheme;
        expect(cs.surfaceDim, s.canvas.base.toColor());
        expect(cs.surfaceBright, s.surfaceRaised.base.toColor());
        expect(cs.surfaceTint, Colors.transparent);
        expect(cs.surfaceContainer, s.surfaceRaised.base.toColor());
      },
    );

    test('a translucent authored surface is solidified', () {
      final theme = _source()
          .copyWith(
            roles: const PrismRoles(
              surface: PrismRoleSpec(
                PrismSeed.neutral,
                l: (light: 0.97, dark: 0.21),
                alpha: 0.5,
              ),
            ),
          )
          .compile(PrismBrightness.light);
      final cs = theme.toColorScheme();
      final s = theme.scheme;
      expect(s.surface.base.opacity, lessThan(1.0)); // authored translucent
      expect(cs.surface.a, 1.0); // but the ColorScheme surface is opaque
      expect(cs.surface, s.composite(s.surface.base, s.canvas.base).toColor());
    });

    test('every container and the surface are opaque', () {
      for (final b in PrismBrightness.values) {
        final cs = _source().compile(b).toColorScheme();
        for (final c in [
          cs.surface,
          cs.primaryContainer,
          cs.secondaryContainer,
          cs.tertiaryContainer,
          cs.errorContainer,
        ]) {
          expect(c.a, 1.0);
        }
      }
    });

    test('onContainer contrasts its container (Option A — verified here)', () {
      // Container contrast lives in the Flutter layer; auditScheme stays M3-free.
      for (final b in PrismBrightness.values) {
        final cs = _source().compile(b).toColorScheme();
        final pairs = [
          (cs.onPrimaryContainer, cs.primaryContainer),
          (cs.onSecondaryContainer, cs.secondaryContainer),
          (cs.onTertiaryContainer, cs.tertiaryContainer),
          (cs.onErrorContainer, cs.errorContainer),
        ];
        for (final (fg, bg) in pairs) {
          expect(_contrast(fg, bg), greaterThan(3.0), reason: '$b: $fg on $bg');
        }
      }
    });
  });

  group('toTextTheme', () {
    test('fans the 7 slots out to all 15 styles', () {
      final theme = _source().compile(PrismBrightness.light);
      final tt = theme.toTextTheme();
      expect(tt.bodyLarge!.fontSize, theme.typography.body.fontSize);
      expect(tt.displayLarge!.fontSize, theme.typography.display.fontSize);
      expect(tt.bodySmall!.fontSize, theme.typography.bodySmall.fontSize);
      expect(tt.titleSmall!.fontSize, theme.typography.label.fontSize);
      final styles = [
        tt.displayLarge,
        tt.displayMedium,
        tt.displaySmall,
        tt.headlineLarge,
        tt.headlineMedium,
        tt.headlineSmall,
        tt.titleLarge,
        tt.titleMedium,
        tt.titleSmall,
        tt.bodyLarge,
        tt.bodyMedium,
        tt.bodySmall,
        tt.labelLarge,
        tt.labelMedium,
        tt.labelSmall,
      ];
      expect(styles.every((s) => s != null), isTrue);
    });
  });

  group('toThemeData', () {
    test('attaches the extension and the canvas scaffold background', () {
      final theme = _source().compile(PrismBrightness.dark);
      final td = theme.toThemeData();
      expect(td.extension<PrismThemeExtension>()?.theme, theme);
      expect(td.scaffoldBackgroundColor, theme.scheme.canvas.base.toColor());
    });

    test('forwards extra extensions', () {
      final theme = _source().compile(PrismBrightness.light);
      final td = theme.toThemeData(extensions: const [_Marker()]);
      expect(td.extension<_Marker>(), isNotNull);
      expect(td.extension<PrismThemeExtension>(), isNotNull);
    });

    test('equal themes → equal ThemeData AND equal hashCode', () {
      final a = _source().compile(PrismBrightness.light).toThemeData();
      final b = _source().compile(PrismBrightness.light).toThemeData();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('maps splash to a splashFactory', () {
      final td =
          _source()
              .copyWith(splash: PrismSplash.sparkle)
              .compile(PrismBrightness.light)
              .toThemeData();
      expect(td.splashFactory, InkSparkle.splashFactory);
    });

    test('sets legacy divider/card fallbacks', () {
      final theme = _source().compile(PrismBrightness.light);
      final td = theme.toThemeData();
      expect(td.cardColor, theme.scheme.surfaceRaised.base.toColor());
      expect(td.dividerColor, td.colorScheme.outlineVariant);
    });

    testWidgets('AnimatedTheme interpolates light→dark without throwing', (
      tester,
    ) async {
      final light = _source().compile(PrismBrightness.light).toThemeData();
      final dark = _source().compile(PrismBrightness.dark).toThemeData();
      await tester.pumpWidget(
        MaterialApp(theme: light, home: const SizedBox()),
      );
      await tester.pumpWidget(MaterialApp(theme: dark, home: const SizedBox()));
      await tester.pump(const Duration(milliseconds: 100)); // mid-animation
      expect(tester.takeException(), isNull);
    });
  });
}

class _Marker extends ThemeExtension<_Marker> {
  const _Marker();
  @override
  _Marker copyWith() => this;
  @override
  _Marker lerp(_, _) => this;
}
