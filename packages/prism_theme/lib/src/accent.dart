import 'package:prism/prism.dart';

import 'lerp.dart';

/// A compiled accent: three related colors for one accent family.
///
/// [fill] paints buttons/badges/selected chips; [onFill] is content drawn on
/// [fill]; [ink] is the accent used *as* a foreground (links, outlined buttons,
/// icons on surfaces).
class PrismAccent {
  /// The solid fill color.
  final RayOklch fill;

  /// The content color drawn on [fill].
  final RayOklch onFill;

  /// The accent as a foreground color.
  final RayOklch ink;

  const PrismAccent({
    required this.fill,
    required this.onFill,
    required this.ink,
  });

  /// Interpolates each slot toward [other]; [t] is clamped to `[0, 1]`.
  PrismAccent lerp(PrismAccent other, double t) => PrismAccent(
    fill: lerpRay(fill, other.fill, t),
    onFill: lerpRay(onFill, other.onFill, t),
    ink: lerpRay(ink, other.ink, t),
  );

  /// Returns a copy with the given slots replaced.
  PrismAccent copyWith({RayOklch? fill, RayOklch? onFill, RayOklch? ink}) =>
      PrismAccent(
        fill: fill ?? this.fill,
        onFill: onFill ?? this.onFill,
        ink: ink ?? this.ink,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismAccent &&
          fill == other.fill &&
          onFill == other.onFill &&
          ink == other.ink;

  @override
  int get hashCode => Object.hash(fill, onFill, ink);

  @override
  String toString() => 'PrismAccent(fill: $fill, onFill: $onFill, ink: $ink)';
}
