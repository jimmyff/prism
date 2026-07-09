import 'package:flutter/material.dart';
import 'package:prism_flutter/prism_flutter.dart';
import 'package:prism_theme/prism_theme.dart';

import 'converters.dart';
import 'theme_extension.dart';

/// Maps a [PrismTheme] onto Flutter's [ThemeData] / [ColorScheme] / [TextTheme].
///
/// This is a best-effort bridge so stock Material widgets are themed. The
/// perceptual-interpolation guarantee holds only through `context.prism`;
/// Flutter animates the mapped [ColorScheme] in sRGB.
extension PrismThemeData on PrismTheme {
  /// A Material [ColorScheme] from the intent roles (judgment mapping).
  ///
  /// Alpha roles are composited over `surface` first (a [ColorScheme] wants
  /// solid colors).
  ColorScheme toColorScheme() {
    final s = scheme;
    final isDark = brightness.isDark;
    Color solid(RayOklch r) => r.toColor();

    // Composite the (possibly translucent) authored surface over the canvas, so
    // stock widgets and washed containers get a solid surface. `context.prism`
    // keeps the translucent surface for intentional frosted panels.
    final solidSurface = s.composite(s.surface.base, s.canvas.base);
    Color onSurfaceOf(RayOklch r) => s.composite(r, solidSurface).toColor();

    // A tonal container: an accent fill washed over the solid surface. Weight is
    // brightness-tuned for coverage; opaque by construction (over solidSurface).
    final w = isDark ? 0.20 : 0.14;
    Color container(PrismRole fill) => solid(s.wash(fill, solidSurface, w));

    final primaryContainer = container(PrismRole.actionFill);
    final secondaryContainer = container(PrismRole.heroFill);
    final tertiaryContainer = container(PrismRole.highlightFill);
    final errorContainer = container(PrismRole.errorFill);
    final onPrimaryContainer = solid(s.action.ink);
    final onSecondaryContainer = solid(s.hero.ink);
    final onTertiaryContainer = solid(s.highlight.ink);
    final onErrorContainer = solid(s.error.ink);

    final cs = ColorScheme(
      brightness: brightness.flutter,
      primary: solid(s.action.fill),
      onPrimary: solid(s.action.onFill),
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: solid(s.hero.fill),
      onSecondary: solid(s.hero.onFill),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: solid(s.highlight.fill),
      onTertiary: solid(s.highlight.onFill),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: solid(s.error.fill),
      onError: solid(s.error.onFill),
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      // Fixed variants alias the containers (M3 fixed slots otherwise fall back
      // to full-strength accents).
      primaryFixed: primaryContainer,
      primaryFixedDim: primaryContainer,
      onPrimaryFixed: onPrimaryContainer,
      onPrimaryFixedVariant: onPrimaryContainer,
      secondaryFixed: secondaryContainer,
      secondaryFixedDim: secondaryContainer,
      onSecondaryFixed: onSecondaryContainer,
      onSecondaryFixedVariant: onSecondaryContainer,
      tertiaryFixed: tertiaryContainer,
      tertiaryFixedDim: tertiaryContainer,
      onTertiaryFixed: onTertiaryContainer,
      onTertiaryFixedVariant: onTertiaryContainer,
      surface: solid(solidSurface),
      onSurface: solid(s.ink),
      onSurfaceVariant: onSurfaceOf(s.inkMuted),
      outline: onSurfaceOf(s.outline),
      outlineVariant: onSurfaceOf(s.divider),
      scrim: onSurfaceOf(s.scrim),
      // Inverse trio, explicit (were correct only by fallback accident).
      inverseSurface: solid(s.ink),
      onInverseSurface: solid(s.surface.base),
      inversePrimary: solid(s.action.fill.withLightness(isDark ? 0.44 : 0.80)),
      surfaceTint: Colors.transparent, // kill stray elevation tinting
      // Surface ramp: dim=canvas, bright=surfaceRaised (else both collapse to
      // surface, flattening M3's ramp).
      surfaceDim: solid(s.canvas.base),
      surfaceBright: solid(s.surfaceRaised.base),
      // Container ramp remapped for the prism↔M3 impedance mismatch (prism
      // raises by lightening; M3 differentiates). Deliberately non-monotonic:
      // stock filled Card/Chip (surfaceContainerHighest) render at chrome.
      surfaceContainerLowest: solid(s.canvas.base),
      surfaceContainerLow: solid(s.surface.base),
      surfaceContainer: solid(s.surfaceRaised.base),
      surfaceContainerHigh: solid(s.surfaceRaised.base),
      surfaceContainerHighest: solid(s.chrome.base),
    );

    assert(() {
      for (final c in [
        cs.surface,
        cs.primaryContainer,
        cs.secondaryContainer,
        cs.tertiaryContainer,
        cs.errorContainer,
      ]) {
        if (c.a < 1.0) {
          throw StateError(
            'prism ColorScheme surface/container is translucent: $c',
          );
        }
      }
      return true;
    }());

    return cs;
  }

  /// A Material [TextTheme]: 7 of the 8 prism slots fanned out to 15 (some
  /// scaled). The `data` slot is intentionally unmapped — it is a second-voice
  /// sibling with no Material slot; read it via `context.prism.typography.data`.
  TextTheme toTextTheme() {
    final t = typography;
    TextStyle f(PrismTextStyle s) => s.flutter;
    TextStyle scaled(PrismTextStyle s, double factor) =>
        s.copyWith(fontSize: s.fontSize * factor).flutter;

    return TextTheme(
      displayLarge: f(t.display),
      displayMedium: scaled(t.display, 0.80),
      displaySmall: scaled(t.display, 0.65),
      headlineLarge: f(t.headline),
      headlineMedium: scaled(t.headline, 0.85),
      headlineSmall: scaled(t.headline, 0.72),
      titleLarge: f(t.title),
      titleMedium: scaled(t.title, 0.85),
      titleSmall: f(t.label),
      bodyLarge: f(t.body),
      bodyMedium: scaled(t.body, 0.90),
      bodySmall: f(t.bodySmall),
      labelLarge: f(t.label),
      labelMedium: scaled(t.label, 0.90),
      labelSmall: f(t.caption),
    );
  }

  /// A complete [ThemeData] with the mapped scheme/text plus the
  /// [PrismThemeExtension] (and any [extensions] you add). No component themes —
  /// that is the interface layer's job.
  ThemeData toThemeData({Iterable<ThemeExtension> extensions = const []}) {
    final s = scheme;
    final cs = toColorScheme();
    // inkFaint over the solid surface — the legacy hint/disabled fallback.
    final faint =
        s
            .composite(s.inkFaint, s.composite(s.surface.base, s.canvas.base))
            .toColor();
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: toTextTheme(),
      scaffoldBackgroundColor: s.canvas.base.toColor(),
      splashFactory: _splashFactory(splash),
      // Legacy Material-2 fallbacks (limited effect under M3; hint/disabled are
      // mostly driven by InputDecorationTheme / onSurfaceVariant).
      dividerColor: cs.outlineVariant,
      cardColor: s.surfaceRaised.base.toColor(),
      hintColor: faint,
      disabledColor: faint,
      extensions: [PrismThemeExtension(this), ...extensions],
    );
  }
}

/// Maps a [PrismSplash] to a Flutter ink `splashFactory`.
InteractiveInkFeatureFactory _splashFactory(PrismSplash splash) =>
    switch (splash) {
      PrismSplash.ripple => InkRipple.splashFactory,
      PrismSplash.sparkle => InkSparkle.splashFactory,
      PrismSplash.splash => InkSplash.splashFactory,
      PrismSplash.none => NoSplash.splashFactory,
    };
