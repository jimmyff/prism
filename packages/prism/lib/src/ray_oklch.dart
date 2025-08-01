import 'dart:math' as math;

import 'package:prism/prism.dart';

/// Oklch color space implementation with intuitive lightness, chroma, and hue controls.
///
/// Cylindrical form of Oklab: L (lightness 0-1), C (chroma/saturation), H (hue 0-360°).
base class RayOklch extends Ray {
  /// The lightness component (0.0 to 1.0).
  final double l;

  /// The chroma component (saturation, 0.0 to approximately 0.4).
  final double c;

  /// The hue component in degrees (0.0 to 360.0).
  final double h;

  /// The opacity component (0.0 to 1.0).
  final double _opacity;

  /// Creates an Oklch color with the specified components.
  const RayOklch({
    required this.l,
    required this.c,
    required this.h,
    double opacity = 1.0,
  }) : _opacity = opacity;

  /// Creates an Oklch color with validation and normalization.
  factory RayOklch.validated({
    required double l,
    required double c,
    required double h,
    double opacity = 1.0,
  }) {
    if (l < 0.0 || l > 1.0) {
      throw ArgumentError.value(
          l, 'lightness', 'Lightness must be between 0.0 and 1.0');
    }
    if (opacity < 0.0 || opacity > 1.0) {
      throw ArgumentError.value(
          opacity, 'opacity', 'Opacity must be between 0.0 and 1.0');
    }

    return RayOklch(
      l: l,
      c: math.max(0.0, c),
      h: _normalizeHue(h),
      opacity: opacity,
    );
  }

  /// Creates a constant Oklch color from individual LCH components.
  const RayOklch.fromLch(this.l, this.c, this.h, [this._opacity = 1.0]);

  /// Creates a transparent black Oklch color.
  const RayOklch.empty()
      : l = 0.0,
        c = 0.0,
        h = 0.0,
        _opacity = 0.0;

  /// Creates an Oklch color from an Oklab color.
  ///
  /// Converts the Oklab a and b components to chroma and hue.
  factory RayOklch.fromOklab(RayOklab oklab) {
    final chroma = math.sqrt(oklab.a * oklab.a + oklab.b * oklab.b);
    final hue = math.atan2(oklab.b, oklab.a) * 180.0 / math.pi;

    return RayOklch(
      l: oklab.l,
      c: chroma,
      h: _normalizeHue(hue),
      opacity: oklab.opacity,
    );
  }

  /// Creates an Oklch color from a JSON value.
  ///
  /// The JSON should be a Map with 'l', 'c', 'h', and 'o' keys.
  factory RayOklch.fromJson(Map<String, dynamic> json) {
    return RayOklch(
      l: (json['l'] as num).toDouble(),
      c: (json['c'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
      opacity: (json['o'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  ColorSpace get colorSpace => ColorSpace.oklch;

  @override
  double get opacity => _opacity;

  @override
  RayOklch withOpacity(double opacity) {
    if (opacity < 0.0 || opacity > 1.0) {
      throw ArgumentError.value(
          opacity, 'opacity', 'Opacity must be between 0.0 and 1.0');
    }
    return RayOklch(l: l, c: c, h: h, opacity: opacity);
  }

  /// Creates a new color with different chroma (clamped to valid gamut range).
  RayOklch withChroma(double chroma) {
    // Clamp to minimum 0.0
    final clampedChroma = math.max(0.0, chroma);

    // Find maximum valid chroma for this lightness and hue
    final maxChroma = RayOklab.getMaxValidChroma(l, h);

    // Clamp to maximum valid chroma
    final finalChroma = math.min(clampedChroma, maxChroma);

    return RayOklch(
      l: l,
      c: finalChroma,
      h: h,
      opacity: opacity,
    );
  }

  /// Creates a new color with different hue (normalized to 0-360°).
  RayOklch withHue(double hue) {
    return RayOklch.validated(
      l: l,
      c: c,
      h: hue,
      opacity: opacity,
    );
  }

  /// Creates a new color with different lightness (0.0-1.0), adjusting chroma to stay in gamut.
  RayOklch withLightness(double lightness) {
    if (lightness < 0.0 || lightness > 1.0) {
      throw ArgumentError.value(
          lightness, 'lightness', 'Lightness must be between 0.0 and 1.0');
    }

    // Find the maximum valid chroma for this lightness and hue combination
    final maxChroma = RayOklab.getMaxValidChroma(lightness, h);

    // Clamp the current chroma to the valid range
    final clampedChroma = math.min(c, maxChroma);

    return RayOklch(
      l: lightness,
      c: clampedChroma,
      h: h,
      opacity: opacity,
    );
  }

  @override
  RayOklch lerp(Ray other, double t) {
    if (t < 0.0 || t > 1.0) {
      throw ArgumentError.value(
          t, 't', 'Interpolation factor must be between 0.0 and 1.0');
    }

    if (t == 0.0) return this;
    if (t == 1.0) return other.toOklch();

    final otherOklch = other.toOklch();

    // Interpolate hue using the shorter path around the color wheel
    final hueDiff = _shortestHueDistance(h, otherOklch.h);
    final interpolatedHue = _normalizeHue(h + hueDiff * t);

    return RayOklch(
      l: l + (otherOklch.l - l) * t,
      c: c + (otherOklch.c - c) * t,
      h: interpolatedHue,
      opacity: opacity + (otherOklch.opacity - opacity) * t,
    );
  }

  @override
  RayOklch get inverse {
    // In Oklch, inversion means inverting lightness and shifting hue by 180°
    return RayOklch(
      l: 1.0 - l,
      c: c, // Chroma stays the same
      h: _normalizeHue(h + 180.0),
      opacity: opacity,
    );
  }

  @override
  double get luminance {
    // In Oklch, the L component already represents perceptual lightness/luminance
    return l;
  }

  @override
  RayRgb8 toRgb() {
    return toOklab().toRgb();
  }

  @override
  RayHsl toHsl() {
    return toRgb().toHsl();
  }

  @override
  RayOklab toOklab() {
    // Convert from polar (Oklch) to rectangular (Oklab) coordinates
    final hueRadians = h * math.pi / 180.0;
    final a = c * math.cos(hueRadians);
    final b = c * math.sin(hueRadians);

    return RayOklab(l: l, a: a, b: b, opacity: opacity);
  }

  @override
  RayOklch toOklch() {
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'l': l,
      'c': c,
      'h': h,
    };
    if (opacity != 1.0) {
      json['o'] = opacity;
    }
    return json;
  }

  /// Normalizes a hue value to the range [0.0, 360.0).
  static double _normalizeHue(double hue) {
    hue = hue % 360.0;
    return hue < 0.0 ? hue + 360.0 : hue;
  }

  /// Calculates the shortest distance between two hue values.
  ///
  /// Returns the signed distance, where positive values mean moving
  /// clockwise and negative values mean moving counterclockwise.
  static double _shortestHueDistance(double from, double to) {
    final diff = to - from;
    if (diff > 180.0) {
      return diff - 360.0;
    } else if (diff < -180.0) {
      return diff + 360.0;
    }
    return diff;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RayOklch &&
        (l - other.l).abs() < 1e-10 &&
        (c - other.c).abs() < 1e-10 &&
        (h - other.h).abs() <
            1e-6 && // Slightly higher tolerance for hue due to normalization
        (opacity - other.opacity).abs() < 1e-10;
  }

  @override
  int get hashCode => Object.hash(
        (l * 1e10).round(),
        (c * 1e10).round(),
        (h * 1e6).round(), // Lower precision for hue due to normalization
        (opacity * 1e10).round(),
      );

  @override
  String toString() {
    return 'RayOklch(l: ${l.toStringAsFixed(3)}, c: ${c.toStringAsFixed(3)}, h: ${h.toStringAsFixed(1)}°, opacity: ${opacity.toStringAsFixed(3)})';
  }
}
