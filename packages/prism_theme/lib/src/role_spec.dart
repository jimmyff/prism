import 'package:prism/prism.dart';

import 'brightness.dart';
import 'color_base.dart';
import 'seed.dart';
import 'seeds.dart';
import 'sentinel.dart';

/// A lightness value per brightness mode (the "graduated brightness" pair).
typedef LightnessPair = ({double light, double dark});

/// The authored spec for a single-color role — one visible line per role.
///
/// [base] is the color it derives from — a seed (`PrismRoleSpec(seed, ...)`) or
/// an inline absolute color (`PrismRoleSpec.absolute(color, ...)`). [l] is its
/// lightness per brightness (null keeps the base's own lightness); [chroma]
/// multiplies the base's chroma (may exceed 1 to push past it, gamut
/// permitting); [alpha] is the role's opacity; [gradient] is an optional
/// lightness delta rendered only by fill roles (`surface`/`surfaceRaised`/
/// `chrome`).
///
/// `chroma`/`alpha` are range-checked here; lightness values are checked when
/// the theme compiles (`RayOklch.withLightness` throws) — Dart cannot assert
/// record fields inside a `const` constructor.
///
/// The seed/inline base is stored as two disjoint private fields set by the two
/// constructors — "exactly one" is guaranteed by construction (a `const`
/// constructor cannot wrap a parameter into a [PrismColorBase]); [base] presents
/// it as the single sealed union.
class PrismRoleSpec {
  final PrismSeed? _seed;
  final RayOklch? _color;

  /// The lightness per brightness, or null to keep the base's lightness.
  final LightnessPair? l;

  /// Multiplier applied to the base's chroma (>= 0; may exceed 1).
  final double chroma;

  /// The role's opacity (0–1).
  final double alpha;

  /// Optional lightness delta making the role a 2-stop gradient (top→bottom).
  ///
  /// Rendered only by the fill roles (`surface`/`surfaceRaised`/`chrome`), which
  /// compile to `Beam`s; a documented no-op on every other role. Null = flat.
  final double? gradient;

  /// Optional seed the gradient's far (bottom) stop derives from — a hue shift.
  ///
  /// A fill gradients when either [gradient] or [gradientSeed] is set; combine
  /// them for a hue + lightness shift (e.g. deep-purple → blue). Seed-only: an
  /// `.absolute` base still shifts toward a theme seed here.
  final PrismSeed? gradientSeed;

  const PrismRoleSpec._({
    required PrismSeed? seed,
    required RayOklch? color,
    this.l,
    this.chroma = 1.0,
    this.alpha = 1.0,
    this.gradient,
    this.gradientSeed,
  }) : _seed = seed,
       _color = color,
       assert(
         (seed == null) != (color == null),
         'PrismRoleSpec derives from exactly one of a seed or an inline color',
       ),
       assert(chroma >= 0.0, 'Chroma multiplier must be >= 0'),
       assert(alpha >= 0.0 && alpha <= 1.0, 'Alpha must be within [0, 1]'),
       assert(
         gradient == null || (gradient >= -1.0 && gradient <= 1.0),
         'gradient delta must be within [-1, 1]',
       );

  /// A role derived from a theme [seed].
  const PrismRoleSpec(
    PrismSeed seed, {
    LightnessPair? l,
    double chroma = 1.0,
    double alpha = 1.0,
    double? gradient,
    PrismSeed? gradientSeed,
  }) : this._(
         seed: seed,
         color: null,
         l: l,
         chroma: chroma,
         alpha: alpha,
         gradient: gradient,
         gradientSeed: gradientSeed,
       );

  /// A role derived from an inline absolute [color].
  ///
  /// The color acts as an inline seed: [l]/[chroma]/[alpha] still apply (an
  /// `.absolute` with no [l] keeps the color's own lightness). It round-trips
  /// through Oklch and re-clamps chroma to gamut — not verbatim output.
  const PrismRoleSpec.absolute(
    RayOklch color, {
    LightnessPair? l,
    double chroma = 1.0,
    double alpha = 1.0,
    double? gradient,
    PrismSeed? gradientSeed,
  }) : this._(
         seed: null,
         color: color,
         l: l,
         chroma: chroma,
         alpha: alpha,
         gradient: gradient,
         gradientSeed: gradientSeed,
       );

  /// The base color as a sealed union (exactly one case, by construction).
  PrismColorBase get base =>
      _color != null
          ? PrismColorBase.inline(_color)
          : PrismColorBase.seed(_seed!);

  /// The lightness for [brightness], or null to keep the base's lightness.
  double? lightnessFor(PrismBrightness brightness) =>
      l == null ? null : (brightness.isDark ? l!.dark : l!.light);

  /// Applies this spec's lightness/chroma/alpha to an arbitrary [base] color.
  ///
  /// The public resolve seam (lightness-first, then chroma, then alpha). Yields
  /// the **flat** color plus the chroma lost to gamut clamping ([clampDelta]);
  /// gradients are compile-only, so a gradient spec resolves to its top stop.
  /// Distinct from `PrismThemePair.resolve`, which selects light vs dark.
  ({RayOklch color, double clampDelta}) resolve(
    RayOklch base,
    PrismBrightness b,
  ) {
    final li = lightnessFor(b);
    final requested = base.chroma * chroma;
    var c = (li == null ? base : base.withLightness(li)).withChroma(requested);
    final clampDelta = requested - c.chroma;
    if (alpha != 1.0) c = c.withOpacity(alpha);
    return (color: c, clampDelta: clampDelta);
  }

  /// [resolve] against this spec's base resolved in [seeds] (compile's sugar).
  ({RayOklch color, double clampDelta}) resolveSeed(
    PrismSeeds seeds,
    PrismBrightness b,
  ) => resolve(_color ?? seeds[_seed!], b);

  /// Returns a copy with the given fields replaced.
  ///
  /// [l], [gradient] and [gradientSeed] are clearable: pass `null` to reset, or
  /// omit to keep. Pass [base] to switch the whole base (seed ⇄ inline).
  PrismRoleSpec copyWith({
    PrismColorBase? base,
    Object? l = unset,
    double? chroma,
    double? alpha,
    Object? gradient = unset,
    Object? gradientSeed = unset,
  }) {
    var newSeed = _seed;
    var newColor = _color;
    if (base != null) {
      switch (base) {
        case PrismSeedBase(:final seed):
          newSeed = seed;
          newColor = null;
        case PrismInlineBase(:final color):
          newSeed = null;
          newColor = color;
      }
    }
    return PrismRoleSpec._(
      seed: newSeed,
      color: newColor,
      l: identical(l, unset) ? this.l : l as LightnessPair?,
      chroma: chroma ?? this.chroma,
      alpha: alpha ?? this.alpha,
      gradient:
          identical(gradient, unset) ? this.gradient : gradient as double?,
      gradientSeed:
          identical(gradientSeed, unset)
              ? this.gradientSeed
              : gradientSeed as PrismSeed?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismRoleSpec &&
          _seed == other._seed &&
          _color == other._color &&
          l == other.l &&
          chroma == other.chroma &&
          alpha == other.alpha &&
          gradient == other.gradient &&
          gradientSeed == other.gradientSeed;

  @override
  int get hashCode =>
      Object.hash(_seed, _color, l, chroma, alpha, gradient, gradientSeed);

  @override
  String toString() =>
      'PrismRoleSpec($base, l: $l, chroma: $chroma, alpha: $alpha, '
      'gradient: $gradient, gradientSeed: $gradientSeed)';
}
