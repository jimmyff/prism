import 'package:prism/prism.dart';

import 'lerp.dart';
import 'seed.dart';

/// The seed colors a [PrismThemeSource] is authored from.
///
/// Brand seeds (`primary`/`secondary`/`tertiary`) are required — the document
/// shows them; there is no harmonic magic unless you opt into [PrismSeeds.
/// harmonic]. `neutral` and the four status seeds default to conventional
/// values. All seeds are stored as [RayOklch]; each seed carries the chroma and
/// hue a role builds on (roles set their own lightness).
class PrismSeeds {
  /// The primary brand color.
  final RayOklch primary;

  /// The secondary brand color.
  final RayOklch secondary;

  /// The tertiary brand color.
  final RayOklch tertiary;

  /// The neutral color surfaces and ink derive from.
  final RayOklch neutral;

  /// The error / danger status color.
  final RayOklch error;

  /// The warning status color.
  final RayOklch warning;

  /// The success status color.
  final RayOklch success;

  /// The informational status color.
  final RayOklch info;

  const PrismSeeds._({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.neutral,
    required this.error,
    required this.warning,
    required this.success,
    required this.info,
  });

  /// Creates seeds from brand colors, with conventional defaults for the rest.
  ///
  /// Any [Ray] is normalized to [RayOklch]. [neutral] defaults to the primary
  /// hue at a barely-there chroma; the status seeds default to conventional
  /// hues (all overridable).
  factory PrismSeeds({
    required Ray primary,
    required Ray secondary,
    required Ray tertiary,
    Ray? neutral,
    Ray? error,
    Ray? warning,
    Ray? success,
    Ray? info,
  }) {
    final p = primary.toOklch();
    return PrismSeeds._(
      primary: p,
      secondary: secondary.toOklch(),
      tertiary: tertiary.toOklch(),
      neutral: neutral?.toOklch() ?? RayOklch.fromComponents(0.5, 0.012, p.hue),
      error: error?.toOklch() ?? _defaultError,
      warning: warning?.toOklch() ?? _defaultWarning,
      success: success?.toOklch() ?? _defaultSuccess,
      info: info?.toOklch() ?? _defaultInfo,
    );
  }

  /// Derives secondary and tertiary seeds from a single [primary].
  ///
  /// Opt-in convenience: `secondary` keeps the primary hue at a third of its
  /// chroma; `tertiary` shifts the hue +60° at two-thirds chroma. Neutral and
  /// status seeds use the conventional defaults.
  factory PrismSeeds.harmonic(Ray primary) {
    final p = primary.toOklch();
    return PrismSeeds(
      primary: p,
      secondary: p.withChroma(p.chroma * (1 / 3)),
      tertiary: p.withHue(p.hue + 60).withChroma(p.chroma * (2 / 3)),
    );
  }

  static const _defaultError = RayOklch.fromComponents(0.55, 0.22, 27);
  static const _defaultWarning = RayOklch.fromComponents(0.75, 0.16, 85);
  static const _defaultSuccess = RayOklch.fromComponents(0.62, 0.15, 150);
  static const _defaultInfo = RayOklch.fromComponents(0.62, 0.13, 250);

  /// The seed color for [seed].
  RayOklch operator [](PrismSeed seed) => switch (seed) {
    PrismSeed.primary => primary,
    PrismSeed.secondary => secondary,
    PrismSeed.tertiary => tertiary,
    PrismSeed.neutral => neutral,
    PrismSeed.error => error,
    PrismSeed.warning => warning,
    PrismSeed.success => success,
    PrismSeed.info => info,
  };

  /// Returns a copy with the given seeds replaced (each normalized to Oklch).
  PrismSeeds copyWith({
    Ray? primary,
    Ray? secondary,
    Ray? tertiary,
    Ray? neutral,
    Ray? error,
    Ray? warning,
    Ray? success,
    Ray? info,
  }) => PrismSeeds._(
    primary: primary?.toOklch() ?? this.primary,
    secondary: secondary?.toOklch() ?? this.secondary,
    tertiary: tertiary?.toOklch() ?? this.tertiary,
    neutral: neutral?.toOklch() ?? this.neutral,
    error: error?.toOklch() ?? this.error,
    warning: warning?.toOklch() ?? this.warning,
    success: success?.toOklch() ?? this.success,
    info: info?.toOklch() ?? this.info,
  );

  /// Interpolates every seed toward [other]; [t] is clamped to `[0, 1]`.
  PrismSeeds lerp(PrismSeeds other, double t) => PrismSeeds._(
    primary: lerpRay(primary, other.primary, t),
    secondary: lerpRay(secondary, other.secondary, t),
    tertiary: lerpRay(tertiary, other.tertiary, t),
    neutral: lerpRay(neutral, other.neutral, t),
    error: lerpRay(error, other.error, t),
    warning: lerpRay(warning, other.warning, t),
    success: lerpRay(success, other.success, t),
    info: lerpRay(info, other.info, t),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismSeeds &&
          primary == other.primary &&
          secondary == other.secondary &&
          tertiary == other.tertiary &&
          neutral == other.neutral &&
          error == other.error &&
          warning == other.warning &&
          success == other.success &&
          info == other.info;

  @override
  int get hashCode => Object.hash(
    primary,
    secondary,
    tertiary,
    neutral,
    error,
    warning,
    success,
    info,
  );

  @override
  String toString() =>
      'PrismSeeds(primary: $primary, secondary: $secondary, '
      'tertiary: $tertiary, neutral: $neutral)';
}
