import 'dart:math' as math;

import 'package:prism/prism.dart';

/// Oklch color space implementation with intuitive lightness, chroma, and hue controls.
///
/// Cylindrical form of Oklab: L (lightness 0-1), C (chroma/saturation), H (hue 0-360°).
base class RayOklch extends Ray {
  /// The lightness component (0.0 to 1.0).
  final double _l;

  /// The chroma component (saturation, 0.0 to approximately 0.4).
  final double _c;

  /// The hue component in degrees (0.0 to 360.0).
  final double _h;

  /// The opacity component (0.0 to 1.0).
  final double _opacity;

  /// Creates an Oklch color with the specified components.
  const RayOklch._({
    required double l,
    required double c,
    required double h,
    double opacity = 1.0,
  }) : _l = l,
       _c = c,
       _h = h,
       _opacity = opacity;

  /// Creates a constant Oklch color from individual LCHO components.
  ///
  /// [l] is lightness (0-1), [c] is chroma (0+), [h] is hue (0-360°), [opacity] is 0-1.
  const RayOklch.fromComponents(this._l, this._c, this._h, [this._opacity = 1.0]);

  /// Creates a gamut clipped [RayOklch] from individual LCHO component values.
  ///
  /// [l] is lightness (0-1), [c] is chroma (0+), [h] is hue (0-360°), [opacity] is 0-1.
  factory RayOklch.fromComponentsValidated(double l, double c, double h,
      [double opacity = 1.0]) {
    if (l < 0.0 || l > 1.0) {
      throw ArgumentError.value(
          l, 'lightness', 'Lightness must be between 0.0 and 1.0');
    }
    if (opacity < 0.0 || opacity > 1.0) {
      throw ArgumentError.value(
          opacity, 'opacity', 'Opacity must be between 0.0 and 1.0');
    }

    return RayOklch._(
      l: l,
      c: math.max(0.0, c),
      h: _normalizeHue(h),
      opacity: opacity,
    );
  }

  /// Creates a [RayOklch] from a list of component values.
  ///
  /// Accepts [l, c, h] or [l, c, h, opacity].
  /// L is 0-1, C is 0+, H is 0-360°, opacity is 0-1.
  factory RayOklch.fromList(List<num> values) {
    if (values.length < 3 || values.length > 4) {
      throw ArgumentError(
          'Oklch color list must have 3 or 4 components (LCHO)');
    }
    return RayOklch.fromComponents(
      values[0].toDouble(),
      values[1].toDouble(),
      values[2].toDouble(),
      values.length > 3 ? values[3].toDouble() : 1.0,
    );
  }

  /// Creates a gamut clipped [RayOklch] from a list of component values.
  ///
  /// Accepts [l, c, h] or [l, c, h, opacity].
  /// L is 0-1, C is 0+, H is 0-360°, opacity is 0-1.
  factory RayOklch.fromListValidated(List<num> values) {
    if (values.length < 3 || values.length > 4) {
      throw ArgumentError(
          'Oklch color list must have 3 or 4 components (LCHO)');
    }
    return RayOklch.fromComponentsValidated(
      values[0].toDouble(),
      values[1].toDouble(),
      values[2].toDouble(),
      values.length > 3 ? values[3].toDouble() : 1.0,
    );
  }

  /// Creates a transparent black Oklch color.
  const RayOklch.empty()
      : _l = 0.0,
        _c = 0.0,
        _h = 0.0,
        _opacity = 0.0;

  /// Creates an Oklch color from an Oklab color.
  ///
  /// Converts the Oklab a and b components to chroma and hue.
  factory RayOklch.fromOklab(RayOklab oklab) {
    final chroma = math.sqrt(oklab.opponentA * oklab.opponentA + oklab.opponentB * oklab.opponentB);
    final hue = math.atan2(oklab.opponentB, oklab.opponentA) * 180.0 / math.pi;

    return RayOklch._(
      l: oklab.lightness,
      c: chroma,
      h: _normalizeHue(hue),
      opacity: oklab.opacity,
    );
  }

  /// Creates an Oklch color from a JSON value.
  ///
  /// The JSON should be a Map with 'l', 'c', 'h', and 'o' keys.
  factory RayOklch.fromJson(Map<String, dynamic> json) {
    return RayOklch._(
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

  /// The lightness component (0.0 to 1.0).
  double get lightness => _l;

  /// The chroma component (saturation, 0.0 to approximately 0.4).
  double get chroma => _c;

  /// The hue component in degrees (0.0 to 360.0).
  double get hue => _h;

  @override
  RayOklch withOpacity(double opacity) {
    if (opacity < 0.0 || opacity > 1.0) {
      throw ArgumentError.value(
          opacity, 'opacity', 'Opacity must be between 0.0 and 1.0');
    }
    return RayOklch._(l: lightness, c: chroma, h: hue, opacity: opacity);
  }

  /// Creates a new color with different chroma (clamped to valid gamut range).
  RayOklch withChroma(double chroma) {
    // Clamp to minimum 0.0
    final clampedChroma = math.max(0.0, chroma);

    // Find maximum valid chroma for this lightness and hue
    final maxChroma = RayOklab.getMaxValidChroma(lightness, hue);

    // Clamp to maximum valid chroma
    final finalChroma = math.min(clampedChroma, maxChroma);

    return RayOklch._(
      l: lightness,
      c: finalChroma,
      h: hue,
      opacity: opacity,
    );
  }

  /// Creates a new color with different hue (normalized to 0-360°).
  RayOklch withHue(double hue) {
    return RayOklch.fromComponentsValidated(lightness, chroma, hue, opacity);
  }

  /// Creates a new color with different lightness (0.0-1.0), adjusting chroma to stay in gamut.
  RayOklch withLightness(double lightness) {
    if (lightness < 0.0 || lightness > 1.0) {
      throw ArgumentError.value(
          lightness, 'lightness', 'Lightness must be between 0.0 and 1.0');
    }

    // Find the maximum valid chroma for this lightness and hue combination
    final maxChroma = RayOklab.getMaxValidChroma(lightness, hue);

    // Clamp the current chroma to the valid range
    final clampedChroma = math.min(chroma, maxChroma);

    return RayOklch._(
      l: lightness,
      c: clampedChroma,
      h: hue,
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
    final hueDiff = _shortestHueDistance(hue, otherOklch.hue);
    final interpolatedHue = _normalizeHue(hue + hueDiff * t);

    return RayOklch._(
      l: lightness + (otherOklch.lightness - lightness) * t,
      c: chroma + (otherOklch.chroma - chroma) * t,
      h: interpolatedHue,
      opacity: opacity + (otherOklch.opacity - opacity) * t,
    );
  }

  @override
  RayOklch get inverse {
    // In Oklch, inversion means inverting lightness and shifting hue by 180°
    return RayOklch._(
      l: 1.0 - lightness,
      c: chroma, // Chroma stays the same
      h: _normalizeHue(hue + 180.0),
      opacity: opacity,
    );
  }

  @override
  double get luminance {
    // In Oklch, the L component already represents perceptual lightness/luminance
    return lightness;
  }

  @override
  RayRgb16 toRgb16() {
    return toOklab().toRgb16();
  }

  @override
  RayHsl toHsl() {
    return toRgb16().toHsl();
  }

  @override
  RayOklab toOklab() {
    // Convert from polar (Oklch) to rectangular (Oklab) coordinates
    final hueRadians = hue * math.pi / 180.0;
    final a = chroma * math.cos(hueRadians);
    final b = chroma * math.sin(hueRadians);

    return RayOklab.fromComponents(lightness, a, b, opacity);
  }

  @override
  RayOklch toOklch() {
    return this;
  }

  @override
  List<num> toList() => [lightness, chroma, hue, opacity];

  @override
  Map<String, dynamic> toJson() => {
        'l': lightness,
        'c': chroma,
        'h': hue,
        if (opacity != 1.0) 'o': opacity,
      };

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
        (lightness - other.lightness).abs() < 1e-10 &&
        (chroma - other.chroma).abs() < 1e-10 &&
        (hue - other.hue).abs() <
            1e-6 && // Slightly higher tolerance for hue due to normalization
        (opacity - other.opacity).abs() < 1e-10;
  }

  @override
  int get hashCode => Object.hash(
        (lightness * 1e10).round(),
        (chroma * 1e10).round(),
        (hue * 1e6).round(), // Lower precision for hue due to normalization
        (opacity * 1e10).round(),
      );

  @override
  String toString() {
    return 'RayOklch(lightness: ${lightness.toStringAsFixed(3)}, chroma: ${chroma.toStringAsFixed(3)}, hue: ${hue.toStringAsFixed(1)}°, opacity: ${opacity.toStringAsFixed(3)})';
  }
}
