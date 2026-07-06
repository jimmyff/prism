import 'package:prism/prism.dart';

import 'seed.dart';
import 'seeds.dart';

/// The base color a role/accent spec derives from — a seed reference or an
/// inline absolute color.
///
/// A sealed union, so "exactly one of {seed, inline}" is a *type* guarantee —
/// no nullable pair, no sentinel, no runtime assert. A spec holds a single
/// non-null [PrismColorBase]. Construct with [PrismColorBase.seed] /
/// [PrismColorBase.inline] (or the [PrismSeedBase] / [PrismInlineBase] subtypes
/// directly, e.g. to `switch`); resolve to a concrete color with [baseColor].
sealed class PrismColorBase {
  const PrismColorBase();

  /// Derives from a theme [PrismSeed] (resolved against a [PrismSeeds] set).
  const factory PrismColorBase.seed(PrismSeed seed) = PrismSeedBase;

  /// An inline absolute color, already normalized to [RayOklch].
  ///
  /// Acts as an "inline seed": the spec's lightness/chroma/alpha still apply, so
  /// it round-trips through Oklch and re-clamps chroma to gamut — not verbatim.
  const factory PrismColorBase.inline(RayOklch color) = PrismInlineBase;

  /// The base color: a seed lookup in [seeds], or the inline color verbatim.
  RayOklch baseColor(PrismSeeds seeds);
}

/// A [PrismColorBase] that references a theme seed.
final class PrismSeedBase extends PrismColorBase {
  final PrismSeed seed;
  const PrismSeedBase(this.seed);

  @override
  RayOklch baseColor(PrismSeeds seeds) => seeds[seed];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PrismSeedBase && seed == other.seed);

  @override
  int get hashCode => Object.hash(PrismSeedBase, seed);

  @override
  String toString() => 'PrismColorBase.seed($seed)';
}

/// A [PrismColorBase] that carries an inline absolute color.
final class PrismInlineBase extends PrismColorBase {
  final RayOklch color;
  const PrismInlineBase(this.color);

  @override
  RayOklch baseColor(PrismSeeds seeds) => color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrismInlineBase && color == other.color);

  @override
  int get hashCode => Object.hash(PrismInlineBase, color);

  @override
  String toString() => 'PrismColorBase.inline($color)';
}
