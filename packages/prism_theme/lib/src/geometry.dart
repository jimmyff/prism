import 'lerp.dart';

/// Corner radii and stroke metrics.
///
/// The focus ring is drawn as an offset ring *outside* the widget bounds
/// ([focusOffset] gap, [focusWidth] stroke) so it contrasts with the surface,
/// never the fill — which is why the `focus` role can safely share the action
/// seed. Ring rendering itself lands in the interface layer.
class PrismGeometry {
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  /// A "stadium"/max radius sentinel for pill shapes — large enough to fully
  /// round any realistic control height, so callers need no per-widget height.
  final double radiusFull;

  final double focusWidth;
  final double focusOffset;

  /// The default border / outline stroke width (e.g. for outlined containers).
  final double outlineWidth;

  const PrismGeometry({
    this.radiusSm = 4.0,
    this.radiusMd = 8.0,
    this.radiusLg = 16.0,
    this.radiusFull = 999.0,
    this.focusWidth = 2.0,
    this.focusOffset = 2.0,
    this.outlineWidth = 1.2,
  });

  /// Interpolates every metric toward [other]; [t] is clamped to `[0, 1]`.
  PrismGeometry lerp(PrismGeometry other, double t) => PrismGeometry(
    radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
    radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
    radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
    radiusFull: lerpDouble(radiusFull, other.radiusFull, t),
    focusWidth: lerpDouble(focusWidth, other.focusWidth, t),
    focusOffset: lerpDouble(focusOffset, other.focusOffset, t),
    outlineWidth: lerpDouble(outlineWidth, other.outlineWidth, t),
  );

  PrismGeometry copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusFull,
    double? focusWidth,
    double? focusOffset,
    double? outlineWidth,
  }) => PrismGeometry(
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusFull: radiusFull ?? this.radiusFull,
    focusWidth: focusWidth ?? this.focusWidth,
    focusOffset: focusOffset ?? this.focusOffset,
    outlineWidth: outlineWidth ?? this.outlineWidth,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismGeometry &&
          radiusSm == other.radiusSm &&
          radiusMd == other.radiusMd &&
          radiusLg == other.radiusLg &&
          radiusFull == other.radiusFull &&
          focusWidth == other.focusWidth &&
          focusOffset == other.focusOffset &&
          outlineWidth == other.outlineWidth;

  @override
  int get hashCode => Object.hash(
    radiusSm,
    radiusMd,
    radiusLg,
    radiusFull,
    focusWidth,
    focusOffset,
    outlineWidth,
  );

  @override
  String toString() =>
      'PrismGeometry(radiusSm: $radiusSm, radiusMd: '
      '$radiusMd, radiusLg: $radiusLg, radiusFull: $radiusFull, '
      'focusWidth: $focusWidth, focusOffset: $focusOffset, '
      'outlineWidth: $outlineWidth)';
}
