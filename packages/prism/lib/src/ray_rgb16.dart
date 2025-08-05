import 'dart:math' as math;

import 'ray_base.dart';
import 'ray_hsl.dart';
import 'ray_oklab.dart';
import 'ray_rgb_base.dart';
import 'ray_rgb8.dart';

/// 16-bit RGB color implementation with support for high precision color operations.
///
/// Stored internally as four separate 16-bit integer components (ARGB).
/// Each color channel uses 16 bits (0-65535 range) for professional imaging applications.
///
/// ## Constructor Options:
///
/// **Const constructors (compile-time constants):**
/// - `RayRgb16()` - Native 16-bit values (0-65535)
/// - `RayRgb16.fromRgbNative()` - Native 16-bit RGB values
/// - `RayRgb16.fromArgbNative()` - Native 16-bit ARGB values
/// - `RayRgb16.empty()` - Transparent black
///
/// **Factory constructors (runtime flexibility):**
/// - `RayRgb16.fromRgb()` - 0-255 range with `num` support
/// - `RayRgb16.fromRgbNormalized()` - 0.0-1.0 normalized values
/// - `RayRgb16.fromArgb()` - ARGB format with `num` support
/// - `RayRgb16.fromArgbNormalized()` - ARGB format with 0.0-1.0 values
base class RayRgb16 extends RayRgbBase<int> {
  /// Individual 16-bit color components
  final int _alpha;
  final int _red;
  final int _green;
  final int _blue;

  @override
  ColorSpace get colorSpace => ColorSpace.rgb16;

  /// Creates a [RayRgb16] from individual RGB component values (0-65535).
  const RayRgb16(
      {required int red,
      required int green,
      required int blue,
      int alpha = 65535})
      : _alpha = alpha & 0xFFFF,
        _red = red & 0xFFFF,
        _green = green & 0xFFFF,
        _blue = blue & 0xFFFF,
        super();

  /// Creates a [RayRgb16] from 0.0-1.0 normalized values.
  factory RayRgb16.fromComponentsNormalized(num red, num green, num blue, [num alpha = 1.0]) =>
      RayRgb16(
        red: (red.clamp(0.0, 1.0) * 65535).round(),
        green: (green.clamp(0.0, 1.0) * 65535).round(),
        blue: (blue.clamp(0.0, 1.0) * 65535).round(),
        alpha: (alpha.clamp(0.0, 1.0) * 65535).round(),
      );

  /// Creates a [RayRgb16] from an 8-bit RGB color, upscaling to 16-bit.
  factory RayRgb16.fromRgb8(dynamic rgb8Color) => RayRgb16(
        red: rgb8Color.redNative * 257, // 8-bit to 16-bit conversion
        green: rgb8Color.greenNative * 257,
        blue: rgb8Color.blueNative * 257,
        alpha: rgb8Color.alphaNative * 257,
      );

  /// Creates a [RayRgb16] for JSON deserialization.
  factory RayRgb16.fromJson(List<dynamic> json) => RayRgb16(
        alpha: json[0],
        red: json[1],
        green: json[2],
        blue: json[3],
      );

  /// Creates a [RayRgb16] from individual RGBA component values (0-255).
  factory RayRgb16.fromComponents(num red, num green, num blue, [num alpha = 255]) => 
      RayRgb16(
        red: (red.clamp(0, 255) * 257).round(),
        green: (green.clamp(0, 255) * 257).round(),
        blue: (blue.clamp(0, 255) * 257).round(),
        alpha: (alpha.clamp(0, 255) * 257).round(),
      );

  /// Creates a [RayRgb16] from individual RGBA component values with native 16-bit precision.
  const RayRgb16.fromComponentsNative(int red, int green, int blue,
      [int alpha = 65535])
      : _red = red & 0xFFFF,
        _green = green & 0xFFFF,
        _blue = blue & 0xFFFF,
        _alpha = alpha & 0xFFFF,
        super();

  /// Creates a [RayRgb16] from a list of component values.
  ///
  /// Accepts [red, green, blue] or [red, green, blue, alpha] in 0-255 range.
  factory RayRgb16.fromList(List<num> values) {
    if (values.length < 3 || values.length > 4) {
      throw ArgumentError('RGB color list must have 3 or 4 components (RGBA)');
    }
    return RayRgb16.fromComponents(
      values[0],
      values[1],
      values[2],
      values.length > 3 ? values[3] : 255,
    );
  }

  /// Creates a [RayRgb16] from a list of native 16-bit component values (0-65535).
  ///
  /// Accepts [red, green, blue] or [red, green, blue, alpha] as integers.
  RayRgb16.fromListNative(List<int> values)
      : _red = values[0] & 0xFFFF,
        _green = values[1] & 0xFFFF,
        _blue = values[2] & 0xFFFF,
        _alpha = values.length > 3 ? values[3] & 0xFFFF : 65535,
        super();

  /// Creates a transparent black color.
  const RayRgb16.empty()
      : _alpha = 0,
        _red = 0,
        _green = 0,
        _blue = 0,
        super();

  /// The alpha channel of this color as a normalized 8-bit value (0-255).
  ///
  /// A value of 0 means this color is fully transparent.
  /// A value of 255 means this color is fully opaque.
  /// Returns precise fractional values for 16-bit colors.
  @override
  num get alpha => _alpha / 65535 * 255;

  /// The red channel of this color as a normalized 8-bit value (0-255).
  /// Returns precise fractional values for 16-bit colors.
  @override
  num get red => _red / 65535 * 255;

  /// The green channel of this color as a normalized 8-bit value (0-255).
  /// Returns precise fractional values for 16-bit colors.
  @override
  num get green => _green / 65535 * 255;

  /// The blue channel of this color as a normalized 8-bit value (0-255).
  /// Returns precise fractional values for 16-bit colors.
  @override
  num get blue => _blue / 65535 * 255;

  /// The alpha channel of this color in native 16-bit value (0-65535).
  @override
  int get alphaNative => _alpha;

  /// The red channel of this color in native 16-bit value (0-65535).
  @override
  int get redNative => _red;

  /// The green channel of this color in native 16-bit value (0-65535).
  @override
  int get greenNative => _green;

  /// The blue channel of this color in native 16-bit value (0-65535).
  @override
  int get blueNative => _blue;

  /// Creates a new [RayRgb16] with the same RGB values but a different alpha.
  ///
  /// The [alpha] value should be in the range [0, 65535].
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb16(red: 65535, green: 0, blue: 0);
  /// final semiRed = red.withAlpha(32768);  // Semi-transparent red
  /// ```
  RayRgb16 withAlpha(int alpha) =>
      RayRgb16(red: _red, green: _green, blue: _blue, alpha: alpha);

  @override
  RayRgb16 withOpacity(double opacity) => RayRgb16(
      red: _red,
      green: _green,
      blue: _blue,
      alpha: (opacity.clamp(0.0, 1.0) * 65535).round());

  @override
  RayRgb16 lerp(Ray other, double t) {
    // Use the precise lerp helper to preserve fractional precision
    final (interpRed, interpGreen, interpBlue, interpAlpha) =
        lerpPrecise(other, t);

    // Create RayRgb16 using fromComponents which preserves fractional precision
    return RayRgb16.fromComponents(interpRed, interpGreen, interpBlue, interpAlpha);
  }

  @override
  RayRgb16 get inverse {
    // Use the precise inverse helper to preserve fractional precision
    final (invRed, invGreen, invBlue, invAlpha) = inversePrecise;
    return RayRgb16.fromComponents(invRed, invGreen, invBlue, invAlpha);
  }

  // luminance, toOklch methods are provided by RayRgbBase

  @override
  RayHsl toHsl() {
    // Direct conversion from RGB to HSL to avoid circular reference
    final r = redNative / 65535.0;
    final g = greenNative / 65535.0;
    final b = blueNative / 65535.0;

    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final delta = max - min;

    final lightness = (max + min) / 2.0;
    double saturation = 0.0;
    double hue = 0.0;

    if (delta != 0.0) {
      saturation =
          lightness > 0.5 ? delta / (2.0 - max - min) : delta / (max + min);

      if (max == r) {
        hue = ((g - b) / delta + (g < b ? 6 : 0)) * 60;
      } else if (max == g) {
        hue = ((b - r) / delta + 2) * 60;
      } else {
        hue = ((r - g) / delta + 4) * 60;
      }
    }

    return RayHsl(
        hue: hue,
        saturation: saturation,
        lightness: lightness,
        opacity: alphaNative / 65535.0);
  }

  // Reference: https://bottosson.github.io/posts/oklab/
  @override
  RayOklab toOklab() {
    // Direct conversion from RGB to Oklab to avoid circular reference
    final r = redNative / 65535.0;
    final g = greenNative / 65535.0;
    final b = blueNative / 65535.0;

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
    final lComponent = 0.2104542553 * lmsCbrt1 +
        0.7936177850 * lmsCbrt2 -
        0.0040720468 * lmsCbrt3;
    final aComponent = 1.9779984951 * lmsCbrt1 -
        2.4285922050 * lmsCbrt2 +
        0.4505937099 * lmsCbrt3;
    final bComponent = 0.0259040371 * lmsCbrt1 +
        0.7827717662 * lmsCbrt2 -
        0.8086757660 * lmsCbrt3;

    return RayOklab(
        l: lComponent,
        a: aComponent,
        b: bComponent,
        opacity: alphaNative / 65535.0);
  }

  /// Converts sRGB component to linear RGB
  static double _srgbToLinear(double component) {
    if (component <= 0.04045) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  /// Signed cube root function
  static double _signedCbrt(double value) {
    if (value >= 0) {
      return math.pow(value, 1.0 / 3.0) as double;
    } else {
      return -math.pow(-value, 1.0 / 3.0) as double;
    }
  }

  // toRgbStr and toRgbaStr methods are provided by RayRgbBase

  /// Optimized bit-depth conversion methods
  @override
  RayRgb8 toRgb8() {
    // Convert 16-bit to 8-bit (high byte for best precision)
    return RayRgb8(
      red: redNative >> 8,
      green: greenNative >> 8,
      blue: blueNative >> 8,
      alpha: alphaNative >> 8,
    );
  }

  @override
  RayRgb16 toRgb16() => this; // Already 16-bit, return self

  @override
  List<num> toList() => [red, green, blue, alpha];

  @override
  List<int> toJson() => [_alpha, _red, _green, _blue];

  @override
  String toString() => 'RayRgb16(a: $_alpha, r: $_red, g: $_green, b: $_blue)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayRgb16 &&
          runtimeType == other.runtimeType &&
          _alpha == other._alpha &&
          _red == other._red &&
          _green == other._green &&
          _blue == other._blue;

  @override
  int get hashCode => Object.hash(_alpha, _red, _green, _blue);
}
