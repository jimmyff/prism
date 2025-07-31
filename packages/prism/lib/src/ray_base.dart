import 'package:prism/prism.dart';

/// Enumeration of supported color spaces.
enum ColorSpace {
  /// RGB (Red, Green, Blue) color space
  rgb,

  /// HSL (Hue, Saturation, Lightness) color space
  hsl,

  /// Oklab color space - perceptually uniform color space
  oklab,

  /// Oklch color space - cylindrical form of Oklab with lightness, chroma, and hue
  oklch,
}

/// Abstract base class for all Ray color implementations.
///
/// Defines common interface for all color models with opacity (0.0-1.0) standardization.
abstract base class Ray {
  const Ray();

  /// The color space used by this Ray implementation.
  ColorSpace get colorSpace;

  /// The opacity of this color (0.0 = transparent, 1.0 = opaque).
  double get opacity;

  /// Creates a new color with different opacity (0.0-1.0).
  Ray withOpacity(double opacity);

  /// Linearly interpolates between this color and [other].
  ///
  /// Parameter [t] should be 0.0-1.0 (0.0 = this color, 1.0 = other color).
  Ray lerp(Ray other, double t);

  /// Returns the color with inverted color values, preserving opacity.
  Ray get inverse;

  /// Returns the relative luminance of the color (0.0 = darkest, 1.0 = lightest).
  double get luminance;

  /// Returns the color ([a] or [b]) with the highest contrast to this color.
  Ray maxContrast(Ray a, Ray b) {
    final lum = luminance;
    final lumA = a.luminance;
    final lumB = b.luminance;
    final contrastA = (lum - lumA).abs();
    final contrastB = (lum - lumB).abs();
    return contrastA > contrastB ? a : b;
  }

  /// Converts this color to a different color space.
  T toColorSpace<T extends Ray>() {
    if (T == RayRgb) return toRgb() as T;
    if (T == RayHsl) return toHsl() as T;
    if (T == RayOklab) return toOklab() as T;
    if (T == RayOklch) return toOklch() as T;

    return this as T;
  }

  /// Converts this color to RGB representation.
  RayRgb toRgb();

  /// Converts this color to HSL representation.
  RayHsl toHsl();

  /// Converts this color to Oklab representation.
  RayOklab toOklab();

  /// Converts this color to Oklch representation.
  RayOklch toOklch();

  /// Returns the color as a JSON-serializable value.
  dynamic toJson();

  /// Creates a color from a JSON value.
  static Ray fromJson(dynamic json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }
}
