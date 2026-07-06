import 'lerp.dart';

/// A spacing scale derived from a single [unit].
///
/// Steps: `xs` 1u · `sm` 2u · `md` 4u · `lg` 6u · `xl` 8u (default unit 4.0).
class PrismSpacing {
  /// The base spacing unit in logical pixels.
  final double unit;

  const PrismSpacing({this.unit = 4.0});

  double get xs => unit * 1;
  double get sm => unit * 2;
  double get md => unit * 4;
  double get lg => unit * 6;
  double get xl => unit * 8;

  /// Interpolates toward [other]; [t] is clamped to `[0, 1]`.
  PrismSpacing lerp(PrismSpacing other, double t) =>
      PrismSpacing(unit: lerpDouble(unit, other.unit, t));

  PrismSpacing copyWith({double? unit}) =>
      PrismSpacing(unit: unit ?? this.unit);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PrismSpacing && unit == other.unit;

  @override
  int get hashCode => unit.hashCode;

  @override
  String toString() => 'PrismSpacing(unit: $unit)';
}
