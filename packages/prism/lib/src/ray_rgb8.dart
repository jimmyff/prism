import 'dart:math' as math;

import 'ray_base.dart';
import 'ray_hsl.dart';
import 'ray_oklab.dart';
import 'ray_rgb_base.dart';
import 'ray_rgb16.dart';

/// 8-bit RGB color implementation with support for multiple input/output formats.
///
/// Stored internally as ARGB integer for Flutter compatibility and performance.
/// Each color channel uses 8 bits (0-255 range).
base class RayRgb8 extends RayRgbBase<int> {
  /// Bit mask constants for efficient color component extraction
  static const int _alphaMask = 0xFF000000;
  static const int _redMask = 0x00FF0000;
  static const int _greenMask = 0x0000FF00;
  static const int _blueMask = 0x000000FF;
  static const int _rgbMask = 0x00FFFFFF;
  static const int _fullMask = 0xFFFFFFFF;

  /// Component bit shift amounts
  static const int _alphaShift = 24;
  static const int _redShift = 16;
  static const int _greenShift = 8;
  static const int _blueShift = 0;

  /// An ARGB color value stored as a 32-bit integer
  final int _value;

  @override
  ColorSpace get colorSpace => ColorSpace.rgb8;

  /// Creates a [RayRgb8] from individual RGB component values (0-255).
  const RayRgb8._(
      {required int red,
      required int green,
      required int blue,
      int alpha = 255})
      : _value = ((alpha & 0xff) << _alphaShift) |
            ((red & 0xff) << _redShift) |
            ((green & 0xff) << _greenShift) |
            ((blue & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb8] from a 32-bit ARGB integer value.
  const RayRgb8.fromArgbInt(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb8] from a 32-bit RGBA integer value.
  const RayRgb8.fromRgbaInt(int value)
      : _value =
            ((value & 0xFFFFFF00) >> 8) | ((value & 0x000000FF) << _alphaShift),
        super();

  /// Creates a [RayRgb8] from a hexadecimal color string.
  ///
  /// Supports 3, 6, and 8 character hex strings with or without '#' prefix.
  factory RayRgb8.fromHex(String value, {HexFormat format = HexFormat.rgba}) {
    final (r, g, b, a) = _parseHex(value, format: format);
    return RayRgb8._(red: r, green: g, blue: b, alpha: a);
  }

  /// Creates a [RayRgb8] from a 16-bit RGB color, downscaling to 8-bit.
  factory RayRgb8.fromRgb16(dynamic rgb16Color) => RayRgb8._(
        red: rgb16Color.redNative >> 8, // Convert 16-bit to 8-bit (high byte)
        green: rgb16Color.greenNative >> 8,
        blue: rgb16Color.blueNative >> 8,
        alpha: rgb16Color.alphaNative >> 8,
      );

  /// Creates a [RayRgb8] for JSON deserialization.
  factory RayRgb8.fromJson(int json) => RayRgb8.fromArgbInt(json);

  /// Creates a [RayRgb8] from individual RGBA component values (0-255).
  factory RayRgb8.fromComponents(num red, num green, num blue,
          [num alpha = 255]) =>
      RayRgb8._(
        red: red.round().clamp(0, 255),
        green: green.round().clamp(0, 255),
        blue: blue.round().clamp(0, 255),
        alpha: alpha.round().clamp(0, 255),
      );

  /// Creates a [RayRgb8] from normalized component values (0.0-1.0).
  factory RayRgb8.fromComponentsNormalized(num red, num green, num blue,
          [num alpha = 1.0]) =>
      RayRgb8._(
        red: (red.clamp(0.0, 1.0) * 255).round(),
        green: (green.clamp(0.0, 1.0) * 255).round(),
        blue: (blue.clamp(0.0, 1.0) * 255).round(),
        alpha: (alpha.clamp(0.0, 1.0) * 255).round(),
      );

  /// Creates a [RayRgb8] from individual RGBA component values (0-255) with native precision.
  const RayRgb8.fromComponentsNative(int red, int green, int blue,
      [int alpha = 255])
      : _value = ((alpha & 0xff) << _alphaShift) |
            ((red & 0xff) << _redShift) |
            ((green & 0xff) << _greenShift) |
            ((blue & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb8] from a list of component values.
  ///
  /// Accepts [red, green, blue] or [red, green, blue, alpha] in 0-255 range.
  factory RayRgb8.fromList(List<num> values) {
    if (values.length < 3 || values.length > 4) {
      throw ArgumentError('RGB color list must have 3 or 4 components (RGBA)');
    }
    return RayRgb8.fromComponents(
      values[0],
      values[1],
      values[2],
      values.length > 3 ? values[3] : 255,
    );
  }

  /// Creates a [RayRgb8] from a list of native component values (0-255).
  ///
  /// Accepts [red, green, blue] or [red, green, blue, alpha] as integers.
  RayRgb8.fromListNative(List<int> values)
      : _value = values.length == 3
            ? ((255 & 0xff) << _alphaShift) |
                ((values[0] & 0xff) << _redShift) |
                ((values[1] & 0xff) << _greenShift) |
                ((values[2] & 0xff) << _blueShift)
            : ((values[3] & 0xff) << _alphaShift) |
                ((values[0] & 0xff) << _redShift) |
                ((values[1] & 0xff) << _greenShift) |
                ((values[2] & 0xff) << _blueShift),
        super();

  /// Creates a transparent black color.
  const RayRgb8.empty()
      : _value = 0x00000000,
        super();

  /// The alpha channel of this color as a normalized 8-bit value (0-255).
  ///
  /// A value of 0 means this color is fully transparent.
  /// A value of 255 means this color is fully opaque.
  @override
  num get alpha => (_alphaMask & _value) >> _alphaShift;

  /// The red channel of this color as a normalized 8-bit value (0-255).
  @override
  num get red => (_redMask & _value) >> _redShift;

  /// The green channel of this color as a normalized 8-bit value (0-255).
  @override
  num get green => (_greenMask & _value) >> _greenShift;

  /// The blue channel of this color as a normalized 8-bit value (0-255).
  @override
  num get blue => (_blueMask & _value);

  /// The alpha channel of this color in native 8-bit value (0-255).
  @override
  int get alphaNative => (_alphaMask & _value) >> _alphaShift;

  /// The red channel of this color in native 8-bit value (0-255).
  @override
  int get redNative => (_redMask & _value) >> _redShift;

  /// The green channel of this color in native 8-bit value (0-255).
  @override
  int get greenNative => (_greenMask & _value) >> _greenShift;

  /// The blue channel of this color in native 8-bit value (0-255).
  @override
  int get blueNative => (_blueMask & _value);

  /// Creates a new [RayRgb8] with the same RGB values but a different alpha.
  ///
  /// The [alpha] value should be in the range [0, 255].
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb8.fromComponents(255, 0, 0);
  /// final semiRed = red.withAlpha(128);  // Semi-transparent red
  /// ```
  RayRgb8 withAlpha(int alpha) => RayRgb8._(
      red: redNative, green: greenNative, blue: blueNative, alpha: alpha);

  @override
  RayRgb8 withOpacity(double opacity) => RayRgb8._(
      red: redNative,
      green: greenNative,
      blue: blueNative,
      alpha: (opacity.clamp(0.0, 1.0) * 255).round());

  @override
  RayRgb8 lerp(Ray other, double t) {
    // Use the precise lerp helper and round to integers for 8-bit precision
    final (interpRed, interpGreen, interpBlue, interpAlpha) =
        lerpPrecise(other, t);
    return RayRgb8._(
      red: interpRed.round(),
      green: interpGreen.round(),
      blue: interpBlue.round(),
      alpha: interpAlpha.round(),
    );
  }

  @override
  RayRgb8 get inverse {
    // Use the precise inverse helper and round to integers for 8-bit precision
    final (invRed, invGreen, invBlue, invAlpha) = inversePrecise;
    return RayRgb8._(
      red: invRed.round(),
      green: invGreen.round(),
      blue: invBlue.round(),
      alpha: invAlpha.round(),
    );
  }

  // luminance, toOklch methods are provided by RayRgbBase

  @override
  RayHsl toHsl() {
    // Direct conversion from RGB to HSL to avoid circular reference
    final r = red / 255.0;
    final g = green / 255.0;
    final b = blue / 255.0;

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
        opacity: opacity);
  }

  @override
  RayOklab toOklab() {
    // Direct conversion from RGB to Oklab to avoid circular reference
    final rNorm = red / 255.0;
    final gNorm = green / 255.0;
    final bNorm = blue / 255.0;

    // Convert to linear RGB first
    final linearR = _srgbToLinear(rNorm);
    final linearG = _srgbToLinear(gNorm);
    final linearB = _srgbToLinear(bNorm);

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

    return RayOklab.fromComponents(lComponent, aComponent, bComponent, opacity);
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

  /// Parses an sRGB hex string and returns RGBA components (0-255).
  /// Supports standard web hex formats: 3, 6, and 8 character strings with or without '#' prefix.
  /// Note: Hex colors are limited to the sRGB gamut (24-bit color space).
  static (int r, int g, int b, int a) _parseHex(String value,
      {HexFormat format = HexFormat.rgba}) {
    String hex = value.startsWith('#') ? value.substring(1) : value;
    hex = hex.toUpperCase();

    // Validate hex characters
    if (!RegExp(r'^[0-9A-F]+$').hasMatch(hex)) {
      throw ArgumentError('Invalid hex color: $value');
    }

    switch (hex.length) {
      case 3:
        // RGB shorthand: F00 -> FF0000
        return (
          int.parse(hex[0] * 2, radix: 16),
          int.parse(hex[1] * 2, radix: 16),
          int.parse(hex[2] * 2, radix: 16),
          255
        );

      case 6:
        // RGB: FF0000
        return (
          int.parse(hex.substring(0, 2), radix: 16),
          int.parse(hex.substring(2, 4), radix: 16),
          int.parse(hex.substring(4, 6), radix: 16),
          255
        );

      case 8:
        // RGBA or ARGB format
        if (format == HexFormat.rgba) {
          // RGBA: FF000080 (red with 50% alpha)
          return (
            int.parse(hex.substring(0, 2), radix: 16),
            int.parse(hex.substring(2, 4), radix: 16),
            int.parse(hex.substring(4, 6), radix: 16),
            int.parse(hex.substring(6, 8), radix: 16)
          );
        } else {
          // ARGB: 80FF0000 (red with 50% alpha)
          return (
            int.parse(hex.substring(2, 4), radix: 16),
            int.parse(hex.substring(4, 6), radix: 16),
            int.parse(hex.substring(6, 8), radix: 16),
            int.parse(hex.substring(0, 2), radix: 16)
          );
        }

      default:
        throw ArgumentError(
            'Invalid sRGB hex color length: ${hex.length}. Expected 3, 6, or 8 characters for standard web hex colors.');
    }
  }

  @override
  RayRgb8 toRgb8() => this; // Already 8-bit RGB, return self

  // toRgbStr and toRgbaStr methods are provided by RayRgbBase

  /// Optimized bit-depth conversion methods

  @override
  RayRgb16 toRgb16() => RayRgb16.fromComponentsNative(
        redNative * 257, // Convert 8-bit to 16-bit (0-255 -> 0-65535)
        greenNative * 257,
        blueNative * 257,
        alphaNative * 257,
      );

  /// Converts the color to an sRGB hexadecimal string (6 or 8 characters).
  ///
  /// Note: Hex colors are limited to the sRGB gamut (24-bit color space).
  /// For extended precision colors, use direct constructor values instead.
  String toHex([int? length, HexFormat format = HexFormat.rgba]) {
    final actualLength = length ?? 6;
    return switch (actualLength) {
      6 => "#${toRgbInt().toRadixString(16).padLeft(6, '0').toUpperCase()}",
      8 => format == HexFormat.rgba
          ? "#${toRgbaInt().toRadixString(16).padLeft(8, '0').toUpperCase()}"
          : "#${toArgbInt().toRadixString(16).padLeft(8, '0').toUpperCase()}",
      _ => throw ArgumentError(
          "Invalid sRGB hex length: $actualLength. Expected 6 or 8 characters for standard web hex colors.")
    };
  }

  @override
  List<num> toList() => [red, green, blue, alpha];

  @override
  int toJson() => _value;

  /// Returns the color as a 32-bit ARGB integer.
  int toArgbInt() => _value;

  /// Returns the color as a 24-bit RGB integer, discarding alpha.
  int toRgbInt() => _value & _rgbMask;

  /// Returns the color as a 32-bit RGBA integer (alpha last).
  int toRgbaInt() =>
      ((_value & _rgbMask) << 8) | ((_value & _alphaMask) >> _alphaShift);

  @override
  String toString() =>
      'RayRgb8(0x${_value.toRadixString(16).padLeft(8, '0').toUpperCase()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayRgb8 &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

/// Backward compatibility typedef for existing code.
typedef RayRgb = RayRgb8;
