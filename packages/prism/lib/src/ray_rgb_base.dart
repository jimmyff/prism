import 'dart:math' as math;

import 'ray_base.dart';
import 'ray_hsl.dart';
import 'ray_oklab.dart';
import 'ray_oklch.dart';

/// Abstract base class for RGB color implementations with shared operations.
///
/// Provides common functionality for RGB colors regardless of bit depth.
/// Subclasses implement storage-specific optimizations while sharing algorithms.
abstract base class RayRgbBase<T> extends Ray {
  const RayRgbBase();

  /// The alpha/opacity component as an integer in the subclass's bit depth.
  T get alphaInt;

  /// The red component as an integer in the subclass's bit depth.
  T get redInt;

  /// The green component as an integer in the subclass's bit depth.
  T get greenInt;

  /// The blue component as an integer in the subclass's bit depth.
  T get blueInt;

  /// The alpha channel as an 8-bit value (0-255) for compatibility.
  int get alpha => toRgb8().alphaInt;

  /// The red channel as an 8-bit value (0-255) for compatibility.
  int get red => toRgb8().redInt;

  /// The green channel as an 8-bit value (0-255) for compatibility.
  int get green => toRgb8().greenInt;

  /// The blue channel as an 8-bit value (0-255) for compatibility.
  int get blue => toRgb8().blueInt;

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

  @override
  double get luminance => computeLuminance();

  // toRgb() method is implemented by concrete subclasses to match Ray interface

  @override
  RayHsl toHsl() =>
      RayHsl.fromRgb8(toRgb8() as dynamic); // Cast needed due to type system

  @override
  RayOklab toOklab() => RayOklab.fromRgb(red, green, blue, opacity);

  @override
  RayOklch toOklch() => RayOklch.fromOklab(toOklab());

  /// Converts the color to a CSS rgb() string.
  String toRgbStr() => "rgb($red, $green, $blue)";

  /// Converts the color to a CSS rgba() string.
  String toRgbaStr() =>
      "rgba($red, $green, $blue, ${(alpha / 255).toStringAsFixed(2)})";

  /// Converts the color to a hexadecimal string.
  /// Subclasses should override with specific bit-depth implementations.
  String toHexStr([int? length]) =>
      throw UnimplementedError('toHexStr must be implemented by subclasses');

  /// Shared lerp implementation helper for subclasses.
  /// Subclasses should call this and handle their own type construction.
  (int, int, int, int) lerpComponents(Ray other, double t) {
    final otherRgb = other.toRgb();
    final clampedT = t.clamp(0.0, 1.0);

    // Use 8-bit representation for interpolation to maintain precision
    final thisRgb8 = toRgb8();
    final otherRgb8 = otherRgb.toRgb8();

    return (
      (thisRgb8.red + (otherRgb8.red - thisRgb8.red) * clampedT).round(),
      (thisRgb8.green + (otherRgb8.green - thisRgb8.green) * clampedT).round(),
      (thisRgb8.blue + (otherRgb8.blue - thisRgb8.blue) * clampedT).round(),
      (thisRgb8.alpha + (otherRgb8.alpha - thisRgb8.alpha) * clampedT).round(),
    );
  }

  /// Shared inverse implementation helper for subclasses.
  /// Subclasses should call this and handle their own type construction.
  (int, int, int, int) get inverseComponents {
    final thisRgb8 = toRgb8();
    return (
      0xff - thisRgb8.red,
      0xff - thisRgb8.green,
      0xff - thisRgb8.blue,
      thisRgb8.alpha,
    );
  }
}
