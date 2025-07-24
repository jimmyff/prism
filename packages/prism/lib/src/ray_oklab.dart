import 'dart:math' as math;

import 'package:prism/prism.dart';

/// A color in the Oklab color space.
///
/// Oklab is a perceptually uniform color space designed to be more intuitive
/// for color manipulation tasks. It provides better perceptual uniformity
/// compared to RGB or HSL, making it ideal for color interpolation, gradient
/// generation, and other color operations.
///
/// The Oklab color space consists of:
/// - L: Lightness (0.0 to 1.0, with 0.0 being black and 1.0 being white)
/// - a: Green-red axis (negative values are more green, positive more red)
/// - b: Blue-yellow axis (negative values are more blue, positive more yellow)
///
/// Example:
/// ```dart
/// // Create an Oklab color
/// final color = RayOklab(l: 0.7, a: 0.1, b: -0.1, opacity: 1.0);
///
/// // Convert from RGB
/// final red = RayRgb.fromARGB(255, 255, 0, 0);
/// final redOklab = red.toOklab();
///
/// // Interpolate between colors (perceptually uniform)
/// final midpoint = color.lerp(redOklab, 0.5);
/// ```
base class RayOklab extends Ray {
  /// The lightness component (0.0 to 1.0).
  final double l;

  /// The green-red axis component.
  final double a;

  /// The blue-yellow axis component.
  final double b;

  /// The opacity component (0.0 to 1.0).
  final double _opacity;

  /// Creates an Oklab color with the specified components.
  ///
  /// Parameters:
  /// - [l]: Lightness (0.0 to 1.0)
  /// - [a]: Green-red axis
  /// - [b]: Blue-yellow axis
  /// - [opacity]: Opacity (0.0 to 1.0, defaults to 1.0)
  const RayOklab({
    required this.l,
    required this.a,
    required this.b,
    double opacity = 1.0,
  }) : _opacity = opacity;

  /// Creates an Oklab color from individual LAB components.
  const RayOklab.fromLab(this.l, this.a, this.b, [this._opacity = 1.0]);

  /// Creates a transparent black Oklab color.
  const RayOklab.empty()
      : l = 0.0,
        a = 0.0,
        b = 0.0,
        _opacity = 0.0;

  /// Creates an Oklab color from a JSON value.
  ///
  /// The JSON should be a Map with 'l', 'a', 'b', and 'o' keys.
  factory RayOklab.fromJson(Map<String, dynamic> json) {
    return RayOklab(
      l: (json['l'] as num).toDouble(),
      a: (json['a'] as num).toDouble(),
      b: (json['b'] as num).toDouble(),
      opacity: (json['o'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  ColorModel get colorModel => ColorModel.oklab;

  @override
  double get opacity => _opacity;

  @override
  RayOklab withOpacity(double opacity) {
    if (opacity < 0.0 || opacity > 1.0) {
      throw ArgumentError.value(
          opacity, 'opacity', 'Opacity must be between 0.0 and 1.0');
    }
    return RayOklab(l: l, a: a, b: b, opacity: opacity);
  }

  @override
  RayOklab lerp(Ray other, double t) {
    if (t < 0.0 || t > 1.0) {
      throw ArgumentError.value(
          t, 't', 'Interpolation factor must be between 0.0 and 1.0');
    }

    if (t == 0.0) return this;
    if (t == 1.0) return other.toOklab();

    final otherOklab = other.toOklab();
    return RayOklab(
      l: l + (otherOklab.l - l) * t,
      a: a + (otherOklab.a - a) * t,
      b: b + (otherOklab.b - b) * t,
      opacity: opacity + (otherOklab.opacity - opacity) * t,
    );
  }

  @override
  RayOklab get inverse {
    // In Oklab, inversion means inverting lightness and flipping a/b axes
    return RayOklab(
      l: 1.0 - l,
      a: -a,
      b: -b,
      opacity: opacity,
    );
  }

  @override
  double computeLuminance() {
    // Convert to RGB to compute luminance using the standard formula
    return toRgb().computeLuminance();
  }

  @override
  RayRgb toRgb() {
    // Convert Oklab to linear sRGB using the inverse transformation
    final lCubed = math.pow(l + 0.3963377774 * a + 0.2158037573 * b, 3.0);
    final mCubed = math.pow(l - 0.1055613458 * a - 0.0638541728 * b, 3.0);
    final sCubed = math.pow(l - 0.0894841775 * a - 1.2914855480 * b, 3.0);

    final linearR =
        4.0767416621 * lCubed - 3.3077115913 * mCubed + 0.2309699292 * sCubed;
    final linearG =
        -1.2684380046 * lCubed + 2.6097574011 * mCubed - 0.3413193965 * sCubed;
    final linearB =
        -0.0041960863 * lCubed - 0.7034186147 * mCubed + 1.7076147010 * sCubed;

    // Convert from linear RGB to sRGB
    final srgbR = _linearToSrgb(linearR);
    final srgbG = _linearToSrgb(linearG);
    final srgbB = _linearToSrgb(linearB);

    // Clamp values to valid range and convert to 0-255
    final redInt = (srgbR.clamp(0.0, 1.0) * 255).round();
    final greenInt = (srgbG.clamp(0.0, 1.0) * 255).round();
    final blueInt = (srgbB.clamp(0.0, 1.0) * 255).round();
    final alphaInt = (opacity * 255).round();

    return RayRgb.fromARGB(alphaInt, redInt, greenInt, blueInt);
  }

  @override
  RayHsl toHsl() {
    return toRgb().toHsl();
  }

  @override
  RayOklab toOklab() {
    return this;
  }

  @override
  RayOklch toOklch() => RayOklch.fromOklab(this);

  @override
  Map<String, dynamic> toJson() {
    return {
      'l': l,
      'a': a,
      'b': b,
      'o': opacity,
    };
  }

  /// Converts a linear RGB component to sRGB gamma-corrected value.
  static double _linearToSrgb(double component) {
    if (component <= 0.0031308) {
      return component * 12.92;
    }
    return 1.055 * math.pow(component, 1.0 / 2.4) - 0.055;
  }

  /// Converts an sRGB gamma-corrected component to linear RGB.
  static double _srgbToLinear(double component) {
    if (component <= 0.04045) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  /// Creates an Oklab color from RGB values.
  ///
  /// Takes RGB values (0-255) and opacity (0.0-1.0) and returns an Oklab color.
  factory RayOklab.fromRgb(int r, int g, int b, [double opacity = 1.0]) {
    return _fromLinearRgb(r / 255.0, g / 255.0, b / 255.0, opacity);
  }

  /// Converts RGB components to Oklab.
  ///
  /// Takes normalized RGB values (0.0 to 1.0) and returns an Oklab color.
  static RayOklab _fromLinearRgb(double r, double g, double b, double opacity) {
    // Convert to linear RGB first
    final linearR = _srgbToLinear(r);
    final linearG = _srgbToLinear(g);
    final linearB = _srgbToLinear(b);

    // Transform to LMS space
    final lms1 = 0.4122214708 * linearR +
        0.5363325363 * linearG +
        0.0514459929 * linearB;
    final lms2 = 0.2119034982 * linearR +
        0.6806995451 * linearG +
        0.1073969566 * linearB;
    final lms3 = 0.0883024619 * linearR +
        0.2817188376 * linearG +
        0.6299787005 * linearB;

    // Apply cube root
    final lmsCbrt1 = _signedCbrt(lms1);
    final lmsCbrt2 = _signedCbrt(lms2);
    final lmsCbrt3 = _signedCbrt(lms3);

    // Transform to Oklab
    final labL = 0.2104542553 * lmsCbrt1 +
        0.7936177850 * lmsCbrt2 -
        0.0040720468 * lmsCbrt3;
    final labA = 1.9779984951 * lmsCbrt1 -
        2.4285922050 * lmsCbrt2 +
        0.4505937099 * lmsCbrt3;
    final labB = 0.0259040371 * lmsCbrt1 +
        0.7827717662 * lmsCbrt2 -
        0.8086757660 * lmsCbrt3;

    return RayOklab(l: labL, a: labA, b: labB, opacity: opacity);
  }

  /// Computes cube root while preserving sign.
  static double _signedCbrt(double value) {
    if (value >= 0) {
      return math.pow(value, 1.0 / 3.0) as double;
    } else {
      return -math.pow(-value, 1.0 / 3.0) as double;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RayOklab &&
        (l - other.l).abs() < 1e-10 &&
        (a - other.a).abs() < 1e-10 &&
        (b - other.b).abs() < 1e-10 &&
        (opacity - other.opacity).abs() < 1e-10;
  }

  @override
  int get hashCode => Object.hash(
        (l * 1e10).round(),
        (a * 1e10).round(),
        (b * 1e10).round(),
        (opacity * 1e10).round(),
      );

  @override
  String toString() {
    return 'RayOklab(l: ${l.toStringAsFixed(3)}, a: ${a.toStringAsFixed(3)}, b: ${b.toStringAsFixed(3)}, opacity: ${opacity.toStringAsFixed(3)})';
  }
}
