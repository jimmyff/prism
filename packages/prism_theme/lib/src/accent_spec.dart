import 'package:prism/prism.dart';

import 'accent.dart';
import 'brightness.dart';
import 'color_base.dart';
import 'role_spec.dart';
import 'seed.dart';
import 'seeds.dart';

/// The authored spec for an accent family — one visible line per accent.
///
/// An accent compiles to three colors: [fill] (buttons/badges/selected),
/// [onFill] (content on the fill), and [ink] (the accent used as a foreground).
/// Each slot has a per-brightness lightness with a conventional default; all
/// are overridable. [base] is the seed or inline color; [chroma] multiplies its
/// chroma across the family. (Lightness values are range-checked at compile
/// time — see [PrismRoleSpec].)
class PrismAccentSpec {
  final PrismSeed? _seed;
  final RayOklch? _color;

  /// Lightness of the solid fill, per brightness.
  final LightnessPair fill;

  /// Lightness of content drawn on the fill, per brightness.
  final LightnessPair onFill;

  /// Lightness of the accent used as a foreground, per brightness.
  final LightnessPair ink;

  /// Multiplier applied to the base's chroma (>= 0; may exceed 1).
  final double chroma;

  const PrismAccentSpec._({
    required PrismSeed? seed,
    required RayOklch? color,
    this.fill = (light: 0.50, dark: 0.75),
    this.onFill = (light: 0.99, dark: 0.18),
    this.ink = (light: 0.44, dark: 0.80),
    this.chroma = 1.0,
  }) : _seed = seed,
       _color = color,
       assert(
         (seed == null) != (color == null),
         'PrismAccentSpec derives from exactly one of a seed or an inline color',
       ),
       assert(chroma >= 0.0, 'Chroma multiplier must be >= 0');

  /// An accent derived from a theme [seed].
  const PrismAccentSpec(
    PrismSeed seed, {
    LightnessPair fill = (light: 0.50, dark: 0.75),
    LightnessPair onFill = (light: 0.99, dark: 0.18),
    LightnessPair ink = (light: 0.44, dark: 0.80),
    double chroma = 1.0,
  }) : this._(
         seed: seed,
         color: null,
         fill: fill,
         onFill: onFill,
         ink: ink,
         chroma: chroma,
       );

  /// An accent derived from an inline absolute [color] (acts as an inline seed).
  const PrismAccentSpec.absolute(
    RayOklch color, {
    LightnessPair fill = (light: 0.50, dark: 0.75),
    LightnessPair onFill = (light: 0.99, dark: 0.18),
    LightnessPair ink = (light: 0.44, dark: 0.80),
    double chroma = 1.0,
  }) : this._(
         seed: null,
         color: color,
         fill: fill,
         onFill: onFill,
         ink: ink,
         chroma: chroma,
       );

  /// The base color as a sealed union (exactly one case, by construction).
  PrismColorBase get base =>
      _color != null
          ? PrismColorBase.inline(_color)
          : PrismColorBase.seed(_seed!);

  /// The lightness of [slot] for [brightness].
  double lightnessFor(LightnessPair slot, PrismBrightness brightness) =>
      brightness.isDark ? slot.dark : slot.light;

  /// Resolves the three accent slots against an arbitrary [base] color.
  ///
  /// Returns the compiled [PrismAccent] plus each slot's gamut-clamp delta (the
  /// compile pipeline records these under the fill/onFill/ink roles).
  ({PrismAccent accent, double fillDelta, double onFillDelta, double inkDelta})
  resolve(RayOklch base, PrismBrightness b) {
    final f = _resolveSlot(base, fill, chroma, b);
    final o = _resolveSlot(base, onFill, chroma, b);
    final i = _resolveSlot(base, ink, chroma, b);
    return (
      accent: PrismAccent(fill: f.color, onFill: o.color, ink: i.color),
      fillDelta: f.delta,
      onFillDelta: o.delta,
      inkDelta: i.delta,
    );
  }

  /// [resolve] against this spec's base resolved in [seeds] (compile's sugar).
  ({PrismAccent accent, double fillDelta, double onFillDelta, double inkDelta})
  resolveSeed(PrismSeeds seeds, PrismBrightness b) =>
      resolve(_color ?? seeds[_seed!], b);

  /// Returns a copy with the given fields replaced (pass [base] to switch base).
  PrismAccentSpec copyWith({
    PrismColorBase? base,
    LightnessPair? fill,
    LightnessPair? onFill,
    LightnessPair? ink,
    double? chroma,
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
    return PrismAccentSpec._(
      seed: newSeed,
      color: newColor,
      fill: fill ?? this.fill,
      onFill: onFill ?? this.onFill,
      ink: ink ?? this.ink,
      chroma: chroma ?? this.chroma,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismAccentSpec &&
          _seed == other._seed &&
          _color == other._color &&
          fill == other.fill &&
          onFill == other.onFill &&
          ink == other.ink &&
          chroma == other.chroma;

  @override
  int get hashCode => Object.hash(_seed, _color, fill, onFill, ink, chroma);

  @override
  String toString() =>
      'PrismAccentSpec($base, fill: $fill, onFill: $onFill, '
      'ink: $ink, chroma: $chroma)';
}

/// Compiles one accent slot (opaque): lightness first, then chroma.
({RayOklch color, double delta}) _resolveSlot(
  RayOklch base,
  LightnessPair slot,
  double chromaMult,
  PrismBrightness b,
) {
  final l = b.isDark ? slot.dark : slot.light;
  final requested = base.chroma * chromaMult;
  final c = base.withLightness(l).withChroma(requested);
  return (color: c, delta: requested - c.chroma);
}
