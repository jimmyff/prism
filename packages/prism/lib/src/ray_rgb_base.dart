import 'dart:math' as math;

import 'ray_base.dart';
import 'ray_oklch.dart';

/// Hexadecimal color format for parsing and output.
enum HexFormat {
  /// RGBA format where alpha is the last component (web standard).
  rgba,

  /// ARGB format where alpha is the first component (Flutter/Android standard).
  argb
}

/// Abstract base class for RGB color implementations with shared operations.
///
/// Provides common functionality for RGB colors regardless of bit depth.
/// Subclasses implement storage-specific optimizations while sharing algorithms.
abstract base class RayRgbBase<T extends Ray, D> extends Ray {
  const RayRgbBase();

  /// The alpha channel as a normalized 8-bit value (0-255).
  num get alpha;

  /// The red channel as a normalized 8-bit value (0-255).
  num get red;

  /// The green channel as a normalized 8-bit value (0-255).
  num get green;

  /// The blue channel as a normalized 8-bit value (0-255).
  num get blue;

  /// The alpha component as an integer in the subclass's native bit depth.
  D get alphaNative;

  /// The red component as an integer in the subclass's native bit depth.
  D get redNative;

  /// The green component as an integer in the subclass's native bit depth.
  D get greenNative;

  /// The blue component as an integer in the subclass's native bit depth.
  D get blueNative;

  @override
  double get opacity => alpha / 255.0;

  /// The alpha channel as a normalized value (0.0-1.0).
  double get alphaNormalized => alpha / 255.0;

  /// The red channel as a normalized value (0.0-1.0).
  double get redNormalized => red / 255.0;

  /// The green channel as a normalized value (0.0-1.0).
  double get greenNormalized => green / 255.0;

  /// The blue channel as a normalized value (0.0-1.0).
  double get blueNormalized => blue / 255.0;

  /// Computes the relative luminance using WCAG 2.0 specification (0.0-1.0).
  /// Where R, G, B are the linearized color components.
  double computeLuminance() {
    final double R = linearizeColorComponent(red / 0xFF);
    final double G = linearizeColorComponent(green / 0xFF);
    final double B = linearizeColorComponent(blue / 0xFF);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  /// Linearizes a color component for RGB luminance calculation.
  ///
  /// See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
  static double linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  T withAlpha(double alpha);
  T withAlphaNative(D alpha);

  T withRed(double alpha);
  T withRedNative(D alpha);

  T withBlue(double alpha);
  T withBlueNative(D alpha);

  T withGreen(double alpha);
  T withGreenNative(D alpha);

  @override
  T withOpacity(double opacity) => withAlpha((opacity.clamp(0.0, 1.0) * 255));

  @override
  double get luminance => computeLuminance();

  @override
  RayOklch toOklch() => RayOklch.fromOklab(toOklab());

  /// Converts the color to a CSS rgb() string.
  String toRgbStr() => "rgb($red, $green, $blue)";

  /// Converts the color to a CSS rgba() string.
  String toRgbaStr() =>
      "rgba($red, $green, $blue, ${(alpha / 255).toStringAsFixed(2)})";

  /// Shared lerp calculation helper that preserves fractional precision.
  /// Returns interpolated RGBA values as doubles to preserve precision.
  (double, double, double, double) lerpPrecise(Ray other, double t) {
    final otherRgb =
        other.toRgb8(); // Convert to common format for interpolation
    final clampedT = t.clamp(0.0, 1.0);

    // Interpolate using normalized values without rounding
    return (
      red + (otherRgb.red - red) * clampedT,
      green + (otherRgb.green - green) * clampedT,
      blue + (otherRgb.blue - blue) * clampedT,
      alpha + (otherRgb.alpha - alpha) * clampedT,
    );
  }

  /// Shared inverse calculation helper that preserves fractional precision.
  /// Returns inverted RGBA values as doubles to preserve precision.
  (double, double, double, double) get inversePrecise {
    return (
      255.0 - red,
      255.0 - green,
      255.0 - blue,
      alpha.toDouble(),
    );
  }
}
