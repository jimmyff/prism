import 'dart:math' as math;

import 'package:prism/prism.dart';

/// Enumeration of supported color spaces.
enum ColorSpace {
  /// RGB (Red, Green, Blue) color space stored as an 32 bit int
  rgb8,

  /// RGB (Red, Green, Blue) color space stored as a 64 bit int
  rgb16,

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
  ///
  /// Note: this compares the polymorphic [luminance] (perceptual Oklch L for
  /// Oklch/Oklab rays), not WCAG contrast. For accessibility use
  /// [contrastRatio].
  Ray maxContrast(Ray a, Ray b) {
    final lum = luminance;
    final lumA = a.luminance;
    final lumB = b.luminance;
    final contrastA = (lum - lumA).abs();
    final contrastB = (lum - lumB).abs();
    return contrastA > contrastB ? a : b;
  }

  /// The WCAG 2.x relative luminance of this color (0.0–1.0).
  ///
  /// Computed from the sRGB representation — deliberately NOT the [luminance]
  /// getter, which returns Oklch L for Oklch/Oklab rays. Down-converts via
  /// [toRgb8] so the value matches the gamut-clipped, 8-bit pixel Flutter
  /// renders.
  double _wcagRelativeLuminance() {
    final rgb = toRgb8();
    double channel(num value) {
      final s = value / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4) as double;
    }

    return 0.2126 * channel(rgb.red) +
        0.7152 * channel(rgb.green) +
        0.0722 * channel(rgb.blue);
  }

  /// The WCAG 2.x contrast ratio between this color and [other].
  ///
  /// Returns a value in [1, 21]: 1 for identical luminance, 21 for
  /// black-on-white. Symmetric. Down-converts to sRGB (not the perceptual
  /// [luminance] getter), so it is correct for every [Ray] type.
  double contrastRatio(Ray other) {
    final a = _wcagRelativeLuminance();
    final b = other._wcagRelativeLuminance();
    final hi = math.max(a, b);
    final lo = math.min(a, b);
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Converts this color to a different color space.
  T toColorSpace<T extends Ray>() {
    if (T == RayRgb8) return toRgb8() as T;
    if (T == RayRgb16) return toRgb16() as T;
    if (T == RayHsl) return toHsl() as T;
    if (T == RayOklab) return toOklab() as T;
    if (T == RayOklch) return toOklch() as T;

    return this as T;
  }

  /// Converts this color to 8-bit RGB representation.
  RayRgb8 toRgb8() => this is RayRgb8 ? this as RayRgb8 : toRgb16().toRgb8();

  /// Converts this color to 16-bit RGB representation.
  RayRgb16 toRgb16();

  /// Converts this color to HSL representation.
  RayHsl toHsl();

  /// Converts this color to Oklab representation.
  RayOklab toOklab();

  /// Converts this color to Oklch representation.
  RayOklch toOklch();

  /// Returns the color as a JSON-serializable value.
  dynamic toJson();

  /// Creates a color from a list of component values.
  ///
  /// The expected format depends on the color space:
  /// - RGB: [red, green, blue] or [red, green, blue, alpha] (0-255 range)
  /// - HSL: [hue, saturation, lightness] or [hue, saturation, lightness, opacity] (hue: 0-360°, others: 0-1)
  /// - Oklab: [l, a, b] or [l, a, b, opacity] (standard Oklab ranges)
  /// - Oklch: [l, c, h] or [l, c, h, opacity] (l: 0-1, c: 0+, h: 0-360°)
  static Ray fromList(List<num> values) {
    throw UnimplementedError('fromList must be implemented by subclasses');
  }

  /// Parses a color string and returns the appropriate [Ray] subclass.
  ///
  /// Automatically detects the format and returns the corresponding color type:
  /// - Hex formats → [RayRgb8]
  /// - `rgb()`/`rgba()` → [RayRgb8]
  /// - `hsl()`/`hsla()` → [RayHsl]
  /// - `oklab()` → [RayOklab]
  /// - `oklch()` → [RayOklch]
  ///
  /// Throws [ArgumentError] if the string format is not recognized.
  ///
  /// Example:
  /// ```dart
  /// final red = Ray.parse('#FF0000');          // RayRgb8
  /// final blue = Ray.parse('rgb(0, 0, 255)');  // RayRgb8
  /// final green = Ray.parse('hsl(120, 100%, 50%)'); // RayHsl
  /// final color = Ray.parse('oklch(0.6 0.2 300)');  // RayOklch
  /// ```
  static Ray parse(String value) {
    final trimmed = value.trim();
    final lowerCased = trimmed.toLowerCase();

    return switch (lowerCased) {
      _ when trimmed.startsWith('#') => RayRgb8.parse(trimmed),
      _ when lowerCased.startsWith('rgb') => RayRgb8.parse(trimmed),
      _ when lowerCased.startsWith('hsl') => RayHsl.parse(trimmed),
      _ when lowerCased.startsWith('oklab') => RayOklab.parse(trimmed),
      _ when lowerCased.startsWith('oklch') => RayOklch.parse(trimmed),
      _ => throw ArgumentError('Unknown color format: $value'),
    };
  }

  /// Returns the color components as a list.
  ///
  /// The format matches what fromList expects:
  /// - RGB: [red, green, blue, alpha] (0-255 range)
  /// - HSL: [hue, saturation, lightness, opacity]
  /// - Oklab: [l, a, b, opacity]
  /// - Oklch: [l, c, h, opacity]
  List<num> toList();

  /// Creates a color from a JSON value.
  static Ray fromJson(dynamic json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }
}
