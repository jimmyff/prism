import 'dart:math' as math;
import 'ray_base.dart';
import 'ray_rgb.dart';
import 'ray_oklab.dart';
import 'ray_oklch.dart';

/// HSL color implementation with intuitive hue, saturation, and lightness controls.
/// 
/// Stored as high-precision doubles for optimal color accuracy.
base class RayHsl extends Ray {
  /// The hue component in degrees (0.0-360.0)
  final double _hue;

  /// The saturation component (0.0-1.0)
  final double _saturation;

  /// The lightness component (0.0-1.0)
  final double _lightness;

  /// The opacity component (0.0-1.0)
  final double _opacity;

  @override
  ColorSpace get colorSpace => ColorSpace.hsl;

  /// Creates a [RayHsl] from HSL components.
  /// 
  /// Hue is normalized to 0-360°, other components are clamped to 0.0-1.0.
  RayHsl({
    required double hue,
    required double saturation,
    required double lightness,
    double opacity = 1.0,
  })  : _hue = _normalizeHue(hue),
        _saturation = saturation.clamp(0.0, 1.0),
        _lightness = lightness.clamp(0.0, 1.0),
        _opacity = opacity.clamp(0.0, 1.0),
        super();

  /// Creates a [RayHsl] from an RGB color by converting RGB to HSL.
  factory RayHsl.fromRgb(RayRgb rgb) {
    return _rgbToHsl(
        rgb.red / 255.0, rgb.green / 255.0, rgb.blue / 255.0, rgb.opacity);
  }

  /// Creates a [RayHsl] for JSON deserialization.
  factory RayHsl.fromJson(Map<String, dynamic> json) {
    return RayHsl(
      hue: (json['h'] as num).toDouble(),
      saturation: (json['s'] as num).toDouble(),
      lightness: (json['l'] as num).toDouble(),
      opacity: json.containsKey('o') ? (json['o'] as num).toDouble() : 1.0,
    );
  }

  /// Creates a transparent black HSL color.
  RayHsl.empty() : this(hue: 0, saturation: 0, lightness: 0, opacity: 0);

  /// The hue component in degrees (0.0-360.0).
  double get hue => _hue;

  /// The saturation component (0.0-1.0).
  double get saturation => _saturation;

  /// The lightness component (0.0-1.0).
  double get lightness => _lightness;

  @override
  double get opacity => _opacity;

  /// Creates a new [RayHsl] with different hue (normalized to 0.0-360.0).
  RayHsl withHue(double hue) => RayHsl(
        hue: hue, // Will be normalized in constructor
        saturation: saturation,
        lightness: lightness,
        opacity: opacity,
      );

  /// Creates a new [RayHsl] with the same HL values but different saturation.
  ///
  /// The [saturation] value will be clamped to the 0.0-1.0 range.
  ///
  /// Example:
  /// ```dart
  /// final vivid = RayHsl(hue: 120, saturation: 1.0, lightness: 0.5);
  /// final pastel = vivid.withSaturation(0.3); // Same hue/lightness, less saturated
  /// ```
  RayHsl withSaturation(double saturation) => RayHsl(
        hue: hue,
        saturation: saturation,
        lightness: lightness,
        opacity: opacity,
      );

  /// Creates a new [RayHsl] with the same HS values but different lightness.
  ///
  /// The [lightness] value will be clamped to the 0.0-1.0 range.
  ///
  /// Example:
  /// ```dart
  /// final normal = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
  /// final dark = normal.withLightness(0.2); // Same hue/saturation, darker
  /// ```
  RayHsl withLightness(double lightness) => RayHsl(
        hue: hue,
        saturation: saturation,
        lightness: lightness,
        opacity: opacity,
      );

  @override
  RayHsl withOpacity(double opacity) => RayHsl(
        hue: hue,
        saturation: saturation,
        lightness: lightness,
        opacity: opacity,
      );

  @override
  RayHsl lerp(Ray other, double t) {
    // Convert other to HSL if needed
    final otherHsl =
        other.colorSpace == ColorSpace.hsl ? other as RayHsl : other.toHsl();

    final clampedT = t.clamp(0.0, 1.0);

    // Handle hue interpolation considering circular nature (0° = 360°)
    final hueDiff = _shortestHueDistance(hue, otherHsl.hue);
    final newHue = _normalizeHue(hue + hueDiff * clampedT);

    return RayHsl(
      hue: newHue,
      saturation: saturation + (otherHsl.saturation - saturation) * clampedT,
      lightness: lightness + (otherHsl.lightness - lightness) * clampedT,
      opacity: opacity + (otherHsl.opacity - opacity) * clampedT,
    );
  }

  @override
  RayHsl get inverse => RayHsl(
        hue: _normalizeHue(hue + 180), // Shift hue by 180 degrees
        saturation: 1.0 - saturation, // Invert saturation
        lightness: 1.0 - lightness, // Invert lightness
        opacity: opacity, // Keep opacity
      );

  /// Returns the relative luminance of this HSL color.
  /// 
  /// Note: Requires RGB conversion. Consider using RayScheme for pre-calculated values.
  @override
  double get luminance {
    // Convert to RGB first, then compute luminance in RGB space
    final rgb = toRgb();
    return rgb.luminance;
  }

  @override
  RayRgb toRgb() {
    final rgbValues = _hslToRgb(hue, saturation, lightness);
    return RayRgb(
      red: (rgbValues.r * 255).round(),
      green: (rgbValues.g * 255).round(),
      blue: (rgbValues.b * 255).round(),
      alpha: (opacity * 255).round(),
    );
  }

  @override
  RayHsl toHsl() => this; // Already HSL, return self

  @override
  RayOklab toOklab() => toRgb().toOklab();

  @override
  RayOklch toOklch() => toRgb().toOklch();

  @override
  Map<String, dynamic> toJson() => {
        'h': hue,
        's': saturation,
        'l': lightness,
        if (opacity != 1.0) 'o': opacity,
      };

  @override
  String toString() =>
      'RayHsl(${hue.toStringAsFixed(1)}°, ${(saturation * 100).toStringAsFixed(1)}%, ${(lightness * 100).toStringAsFixed(1)}%${opacity != 1.0 ? ', ${(opacity * 100).toStringAsFixed(1)}%' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayHsl &&
          runtimeType == other.runtimeType &&
          (hue - other.hue).abs() < 1e-9 &&
          (saturation - other.saturation).abs() < 1e-9 &&
          (lightness - other.lightness).abs() < 1e-9 &&
          (opacity - other.opacity).abs() < 1e-9;

  @override
  int get hashCode => Object.hash(
        (hue * 1000).round(),
        (saturation * 1000).round(),
        (lightness * 1000).round(),
        (opacity * 1000).round(),
      );

  // === HSL Difference and Distance Functions ===

  /// Calculates the signed hue difference (-180° to 180°) considering color wheel circularity.
  double hueDifference(RayHsl other) {
    return _shortestHueDistance(hue, other.hue);
  }

  /// Calculates the signed saturation difference (other - this).
  double saturationDifference(RayHsl other) {
    return other.saturation - saturation;
  }

  /// Calculates the signed lightness difference (other - this).
  double lightnessDifference(RayHsl other) {
    return other.lightness - lightness;
  }

  /// Calculates the absolute hue distance (0-180°) using shortest path on color wheel.
  double hueDistance(RayHsl other) {
    return hueDifference(other).abs();
  }

  /// Calculates the absolute saturation distance.
  double saturationDistance(RayHsl other) {
    return saturationDifference(other).abs();
  }

  /// Calculates the absolute lightness distance.
  double lightnessDistance(RayHsl other) {
    return lightnessDifference(other).abs();
  }

  /// Normalizes hue to 0.0-360.0 range
  static double _normalizeHue(double hue) {
    return hue % 360;
  }

  /// Calculates the shortest distance between two hues on the color wheel
  static double _shortestHueDistance(double from, double to) {
    final diff = to - from;
    if (diff.abs() <= 180) {
      return diff;
    } else if (diff > 180) {
      return diff - 360;
    } else {
      return diff + 360;
    }
  }

  /// High-precision RGB to HSL conversion
  static RayHsl _rgbToHsl(double r, double g, double b, double opacity) {
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final delta = max - min;

    // Calculate lightness
    final lightness = (max + min) / 2;

    double hue = 0;
    double saturation = 0;

    if (delta != 0) {
      // Calculate saturation
      saturation =
          lightness > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      // Calculate hue
      if (max == r) {
        hue = ((g - b) / delta) + (g < b ? 6 : 0);
      } else if (max == g) {
        hue = (b - r) / delta + 2;
      } else {
        hue = (r - g) / delta + 4;
      }
      hue *= 60;
    }

    return RayHsl(
      hue: hue,
      saturation: saturation,
      lightness: lightness,
      opacity: opacity,
    );
  }

  /// High-precision HSL to RGB conversion
  static ({double r, double g, double b}) _hslToRgb(
      double hue, double saturation, double lightness) {
    if (saturation == 0) {
      // Achromatic (gray)
      return (r: lightness, g: lightness, b: lightness);
    }

    final hueNormalized = hue / 360;
    final c = (1 - (2 * lightness - 1).abs()) * saturation;
    final x = c * (1 - ((hueNormalized * 6) % 2 - 1).abs());
    final m = lightness - c / 2;

    double r1, g1, b1;

    final h = (hueNormalized * 6).floor();
    switch (h) {
      case 0:
        r1 = c;
        g1 = x;
        b1 = 0;
        break;
      case 1:
        r1 = x;
        g1 = c;
        b1 = 0;
        break;
      case 2:
        r1 = 0;
        g1 = c;
        b1 = x;
        break;
      case 3:
        r1 = 0;
        g1 = x;
        b1 = c;
        break;
      case 4:
        r1 = x;
        g1 = 0;
        b1 = c;
        break;
      default: // case 5
        r1 = c;
        g1 = 0;
        b1 = x;
        break;
    }

    return (
      r: (r1 + m).clamp(0.0, 1.0),
      g: (g1 + m).clamp(0.0, 1.0),
      b: (b1 + m).clamp(0.0, 1.0),
    );
  }
}
