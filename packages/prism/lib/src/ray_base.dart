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
/// Defines the common interface that all color representations must implement,
/// standardizing on opacity (0.0-1.0) as the universal transparency format.
///
/// This allows different color models (RGB, HSL, etc.) to work together
/// seamlessly while maintaining their optimal internal storage formats.
abstract base class Ray {
  const Ray();

  /// The color space used by this Ray implementation.
  ///
  /// Useful for runtime type checking without using runtimeType.
  ColorSpace get colorSpace;

  /// The opacity of this color as a double.
  ///
  /// A value of 0.0 means this color is fully transparent.
  /// A value of 1.0 means this color is fully opaque.
  double get opacity;

  /// Creates a new color with the same color values but different opacity.
  ///
  /// The [opacity] value should be in the range [0.0, 1.0].
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// final semiRed = red.withOpacity(0.5);
  /// ```
  Ray withOpacity(double opacity);

  /// Linearly interpolates between this color and [other].
  ///
  /// The [t] parameter should be in the range [0.0, 1.0], where:
  /// - t = 0.0 returns this color
  /// - t = 1.0 returns [other]
  /// - t = 0.5 returns the midpoint between the colors
  ///
  /// Both colors will be converted to the same color space for interpolation.
  Ray lerp(Ray other, double t);

  /// Returns the color with inverted color values, preserving opacity.
  ///
  /// The inversion behavior depends on the color space:
  /// - RGB: Each component is inverted using 255 - component
  /// - HSL: Hue is shifted by 180°, saturation and lightness are inverted
  Ray get inverse;

  /// Returns the relative luminance of the color.
  ///
  /// Represents a brightness value between 0 (darkest) and 1 (lightest).
  /// This calculation is color-space specific:
  /// - RGB/HSL: Uses WCAG 2.0 specification in RGB space
  /// - Oklab/Oklch: Uses the lightness component directly
  double get luminance;

  /// Returns the color with the highest contrast relative to this color.
  ///
  /// Compares the luminance contrast between this color and the two provided
  /// colors, returning the one with higher contrast.
  ///
  /// Parameters:
  /// - [a]: First color to compare
  /// - [b]: Second color to compare
  ///
  /// Returns the color ([a] or [b]) with the highest contrast to this color.
  Ray maxContrast(Ray a, Ray b) {
    final lum = luminance;
    final lumA = a.luminance;
    final lumB = b.luminance;
    final contrastA = (lum - lumA).abs();
    final contrastB = (lum - lumB).abs();
    return contrastA > contrastB ? a : b;
  }

  /// Converts this color to a different color space, specified by the generic
  /// type [T].
  ///
  /// Example:
  /// ```dart
  /// final hslColor = rgbColor.toColorSpace<RayHsl>();
  /// ```
  T toColorSpace<T extends Ray>() {
    if (T == RayRgb) return toRgb() as T;
    if (T == RayHsl) return toHsl() as T;
    if (T == RayOklab) return toOklab() as T;
    if (T == RayOklch) return toOklch() as T;

    return this as T;
  }

  /// Converts this color to RGB representation.
  ///
  /// Returns a [RayRgb] instance with the same visual appearance.
  /// If this color is already RGB, it may return itself.
  RayRgb toRgb();

  /// Converts this color to HSL representation.
  ///
  /// Returns a [RayHsl] instance with the same visual appearance.
  /// If this color is already HSL, it may return itself.
  RayHsl toHsl();

  /// Converts this color to Oklab representation.
  ///
  /// Returns a [RayOklab] instance with the same visual appearance.
  /// If this color is already Oklab, it may return itself.
  RayOklab toOklab();

  /// Converts this color to Oklch representation.
  ///
  /// Returns a [RayOklch] instance with the same visual appearance.
  /// If this color is already Oklch, it may return itself.
  RayOklch toOklch();

  /// Returns the color as a JSON-serializable value.
  ///
  /// The exact format depends on the color space implementation.
  dynamic toJson();

  /// Creates a color from a JSON value.
  ///
  /// This is a factory constructor that should be implemented by subclasses.
  /// The exact format depends on the color space implementation.
  static Ray fromJson(dynamic json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }
}
