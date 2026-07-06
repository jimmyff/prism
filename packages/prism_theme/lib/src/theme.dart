import 'brightness.dart';
import 'contrast.dart';
import 'geometry.dart';
import 'lerp.dart';
import 'scheme.dart';
import 'seeds.dart';
import 'spacing.dart';
import 'splash.dart';
import 'state_layers.dart';
import 'typography.dart';

/// A compiled theme for one brightness: the scheme plus the token sets.
///
/// Produced by `PrismThemeSource.compile`. [seeds] is carried for provenance
/// (which seeds this was derived from) and is deliberately kept off the Flutter
/// convenience surface. There is no compiled-theme JSON — persist a
/// `PrismThemeSelection` and recompile instead.
class PrismTheme {
  final PrismBrightness brightness;
  final PrismScheme scheme;
  final PrismTypography typography;
  final PrismSpacing spacing;
  final PrismGeometry geometry;

  /// Interaction state-layer opacities (hover / focus / press).
  final PrismStateLayers stateLayers;

  /// The interaction splash style.
  final PrismSplash splash;

  /// The seeds this theme was compiled from (provenance / derivation).
  final PrismSeeds seeds;

  const PrismTheme({
    required this.brightness,
    required this.scheme,
    required this.typography,
    required this.spacing,
    required this.geometry,
    required this.stateLayers,
    required this.splash,
    required this.seeds,
  });

  /// Interpolates toward [other]; [t] is clamped to `[0, 1]`.
  ///
  /// Colors, tokens and seeds blend continuously. [brightness] is discrete and
  /// snaps at t < 0.5 (this) vs t >= 0.5 (other) — a deliberate discontinuity
  /// the cosmic clock should account for (e.g. status-bar icon brightness).
  ///
  /// A transition/effect hook (see `PrismThemePair.atDarkness`): a linear
  /// light↔dark crossfade passes ~1:1 ink/surface contrast near t=0.5, so an
  /// interior blend is a motion frame, never a resting theme.
  PrismTheme lerp(PrismTheme other, double t) {
    final tt = clampT(t);
    return PrismTheme(
      brightness: tt < 0.5 ? brightness : other.brightness,
      scheme: scheme.lerp(other.scheme, tt),
      typography: typography.lerp(other.typography, tt),
      spacing: spacing.lerp(other.spacing, tt),
      geometry: geometry.lerp(other.geometry, tt),
      stateLayers: stateLayers.lerp(other.stateLayers, tt),
      splash: tt < 0.5 ? splash : other.splash,
      seeds: seeds.lerp(other.seeds, tt),
    );
  }

  /// Every contrast pair for this theme's scheme, checked against [policy].
  ///
  /// Filter `.where((r) => !r.passes)` for failures. Never mutates the theme.
  List<PrismAuditResult> audit({
    PrismContrastPolicy policy = const PrismContrastPolicy(),
  }) => auditScheme(scheme, policy);

  /// Debug-only accessibility guard (stripped from release builds).
  void assertAccessible({
    PrismContrastPolicy policy = const PrismContrastPolicy(),
  }) => assertSchemeAccessible(scheme, policy);

  PrismTheme copyWith({
    PrismBrightness? brightness,
    PrismScheme? scheme,
    PrismTypography? typography,
    PrismSpacing? spacing,
    PrismGeometry? geometry,
    PrismStateLayers? stateLayers,
    PrismSplash? splash,
    PrismSeeds? seeds,
  }) => PrismTheme(
    brightness: brightness ?? this.brightness,
    scheme: scheme ?? this.scheme,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    geometry: geometry ?? this.geometry,
    stateLayers: stateLayers ?? this.stateLayers,
    splash: splash ?? this.splash,
    seeds: seeds ?? this.seeds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismTheme &&
          brightness == other.brightness &&
          scheme == other.scheme &&
          typography == other.typography &&
          spacing == other.spacing &&
          geometry == other.geometry &&
          stateLayers == other.stateLayers &&
          splash == other.splash &&
          seeds == other.seeds;

  @override
  int get hashCode => Object.hash(
    brightness,
    scheme,
    typography,
    spacing,
    geometry,
    stateLayers,
    splash,
    seeds,
  );

  @override
  String toString() => 'PrismTheme($brightness, scheme: $scheme)';
}
