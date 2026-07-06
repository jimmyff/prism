import 'package:prism/prism.dart';

/// A portable, interpolatable linear gradient over [Ray] colors.
///
/// A single ray is a flat color; multiple rays form a gradient. Interpolation
/// happens in the rays' own color space — Oklch rays blend perceptually, RGB
/// rays blend in sRGB — so there is no hidden colorspace parameter.
///
/// [stops] are optional positions in `[0, 1]` (one per ray, ascending); when
/// omitted the rays are spaced evenly. [angle] is a presentation hint in
/// degrees (default 180 = top→bottom) and does not affect [colorAt].
///
/// Radial and sweep variants are intentionally left for a future named
/// constructor.
class Beam<T extends Ray> {
  /// The gradient's colors. Length 1 = flat color, length n = gradient.
  final List<T> rays;

  /// Optional stop positions in `[0, 1]`, one per ray. Null = evenly spaced.
  final List<double>? stops;

  /// Presentation hint: gradient angle in degrees (180 = top→bottom).
  final double angle;

  /// Creates a linear beam from [rays] with optional [stops] and [angle].
  const Beam.linear(this.rays, {this.stops, this.angle = 180})
    : assert(rays.length > 0, 'A Beam needs at least one ray'),
      assert(
        stops == null || stops.length == rays.length,
        'stops must have one position per ray',
      );

  /// Creates a flat (single-color) beam.
  factory Beam.flat(T ray) => Beam.linear([ray]);

  /// The first ray — the beam's base color.
  T get base => rays.first;

  /// Whether this beam has more than one ray.
  bool get isGradient => rays.length > 1;

  /// The stop positions, materialized (even spacing when [stops] is null).
  List<double> get _effectiveStops => stops ?? _evenStops(rays.length);

  /// The color at position [t] along the beam.
  ///
  /// [t] is clamped to `[0, 1]`; a flat beam always returns [base]. The
  /// segment-local factor is also clamped, since [RayOklch.lerp] throws for
  /// factors outside `[0, 1]`.
  T colorAt(double t) {
    if (rays.length == 1) return rays.first;

    final clamped = t.clamp(0.0, 1.0);
    final s = _effectiveStops;
    if (clamped <= s.first) return rays.first;
    if (clamped >= s.last) return rays.last;

    for (var i = 0; i < rays.length - 1; i++) {
      final lo = s[i];
      final hi = s[i + 1];
      if (clamped <= hi) {
        final span = hi - lo;
        final localT =
            span <= 0.0 ? 0.0 : ((clamped - lo) / span).clamp(0.0, 1.0);
        return rays[i].lerp(rays[i + 1], localT) as T;
      }
    }
    return rays.last;
  }

  /// Linearly interpolates between this beam and [other].
  ///
  /// [t] is clamped to `[0, 1]`. When both beams share the same shape (equal
  /// ray count and stop positions) the blend is stop-wise; otherwise both are
  /// resampled to the union of their stops and then blended stop-wise.
  Beam<T> lerp(Beam<T> other, double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (clamped == 0.0) return this;
    if (clamped == 1.0) return other;

    if (_sameShapeAs(other)) {
      return Beam.linear(
        [
          for (var i = 0; i < rays.length; i++)
            rays[i].lerp(other.rays[i], clamped) as T,
        ],
        stops: stops,
        angle: _lerpAngle(other.angle, clamped),
      );
    }

    final union = _unionStops(_effectiveStops, other._effectiveStops);
    return Beam.linear(
      [for (final p in union) colorAt(p).lerp(other.colorAt(p), clamped) as T],
      stops: union,
      angle: _lerpAngle(other.angle, clamped),
    );
  }

  double _lerpAngle(double other, double t) => angle + (other - angle) * t;

  bool _sameShapeAs(Beam<T> other) {
    if (rays.length != other.rays.length) return false;
    final a = _effectiveStops;
    final b = other._effectiveStops;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 1e-9) return false;
    }
    return true;
  }

  static List<double> _evenStops(int n) {
    if (n == 1) return const [0.0];
    return [for (var i = 0; i < n; i++) i / (n - 1)];
  }

  static List<double> _unionStops(List<double> a, List<double> b) =>
      (<double>{...a, ...b}.toList()..sort());

  /// JSON representation, tagged by the rays' color space.
  Map<String, dynamic> toJson() => {
    'space': base.colorSpace.name,
    'rays': [for (final r in rays) r.toJson()],
    if (stops != null) 'stops': stops,
    'angle': angle,
  };

  /// Reconstructs a [Beam] from [json]; rays decode per the tagged color space.
  static Beam<Ray> fromJson(Map<String, dynamic> json) {
    final decode = _rayDecoder(json['space'] as String);
    return Beam.linear(
      [for (final r in json['rays'] as List) decode(r)],
      stops:
          (json['stops'] as List?)?.map((e) => (e as num).toDouble()).toList(),
      angle: (json['angle'] as num?)?.toDouble() ?? 180.0,
    );
  }

  static Ray Function(dynamic) _rayDecoder(String space) => switch (space) {
    'oklch' => (j) => RayOklch.fromJson(j as Map<String, dynamic>),
    'rgb8' => (j) => RayRgb8.fromJson(j as int),
    'rgb16' => (j) => RayRgb16.fromJson(j as Map<String, dynamic>),
    'oklab' => (j) => RayOklab.fromJson(j as Map<String, dynamic>),
    'hsl' => (j) => RayHsl.fromJson(j as Map<String, dynamic>),
    _ => throw FormatException('Unknown Beam color space: $space'),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Beam) return false;
    if (rays.length != other.rays.length) return false;
    for (var i = 0; i < rays.length; i++) {
      if (rays[i] != other.rays[i]) return false;
    }
    final a = stops;
    final b = other.stops;
    if (a == null || b == null) {
      if (a != null || b != null) return false;
    } else {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if ((a[i] - b[i]).abs() > 1e-9) return false;
      }
    }
    return (angle - other.angle).abs() < 1e-9;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(rays),
    stops == null
        ? null
        : Object.hashAll([for (final s in stops!) (s * 1e9).round()]),
    (angle * 1e9).round(),
  );

  @override
  String toString() =>
      'Beam(${rays.length} ray(s), stops: ${stops ?? 'even'}, angle: $angle°)';
}
