import 'dart:math' as math;

import 'ray_base.dart';
import 'ray_hsl.dart';
import 'ray_oklab.dart';
import 'ray_oklch.dart';

/// Hexadecimal color format for parsing and output.
enum HexFormat {
  /// RGBA format where alpha is the last component (web standard).
  rgba,

  /// ARGB format where alpha is the first component (Flutter/Android standard).
  argb
}

/// RGB color implementation with support for multiple input/output formats.
/// 
/// Stored internally as ARGB integer for Flutter compatibility and performance.
base class RayRgb extends Ray {
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
  ColorSpace get colorSpace => ColorSpace.rgb;

  /// Creates a [RayRgb] from individual RGB component values (0-255).
  const RayRgb(
      {required int red,
      required int green,
      required int blue,
      int alpha = 255})
      : _value = ((alpha & 0xff) << _alphaShift) |
            ((red & 0xff) << _redShift) |
            ((green & 0xff) << _greenShift) |
            ((blue & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb] from a 32-bit ARGB integer value.
  const RayRgb.fromInt(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb] from a 32-bit ARGB integer value.
  const RayRgb.fromIntARGB(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb] from a 32-bit RGBA integer value.
  const RayRgb.fromIntRGBA(int value)
      : _value =
            ((value & 0xFFFFFF00) >> 8) | ((value & 0x000000FF) << _alphaShift),
        super();

  /// Creates a [RayRgb] from individual ARGB component values (0-255).
  const RayRgb.fromARGB(int a, int r, int g, int b)
      : _value = ((a & 0xff) << _alphaShift) |
            ((r & 0xff) << _redShift) |
            ((g & 0xff) << _greenShift) |
            ((b & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb] from a hexadecimal color string.
  ///
  /// Supports 3, 6, and 8 character hex strings with or without '#' prefix.
  factory RayRgb.fromHex(String value, {HexFormat format = HexFormat.rgba}) {
    String hex = value.startsWith('#') ? value.substring(1) : value;
    hex = hex.toUpperCase();

    // Validate hex characters
    if (!RegExp(r'^[0-9A-F]+$').hasMatch(hex)) {
      throw ArgumentError('Invalid hex color: $value');
    }

    switch (hex.length) {
      case 3:
        // RGB shorthand: F00 -> FF0000
        final r = int.parse(hex[0] * 2, radix: 16);
        final g = int.parse(hex[1] * 2, radix: 16);
        final b = int.parse(hex[2] * 2, radix: 16);
        return RayRgb(red: r, green: g, blue: b);

      case 6:
        // RGB: FF0000
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        return RayRgb(red: r, green: g, blue: b);

      case 8:
        // RGBA or ARGB format
        if (format == HexFormat.rgba) {
          // RGBA: FF000080 (red with 50% alpha)
          final r = int.parse(hex.substring(0, 2), radix: 16);
          final g = int.parse(hex.substring(2, 4), radix: 16);
          final b = int.parse(hex.substring(4, 6), radix: 16);
          final a = int.parse(hex.substring(6, 8), radix: 16);
          return RayRgb(red: r, green: g, blue: b, alpha: a);
        } else {
          // ARGB: 80FF0000 (red with 50% alpha)
          return RayRgb.fromIntARGB(int.parse(hex, radix: 16));
        }

      default:
        throw ArgumentError(
            'Invalid hex color length: ${hex.length}. Expected 3, 6, or 8 characters.');
    }
  }

  /// Creates a [RayRgb] for JSON deserialization.
  factory RayRgb.fromJson(int json) => RayRgb.fromInt(json);

  /// Creates a transparent black color.
  const RayRgb.empty()
      : _value = 0x00000000,
        super();

  @override
  double get opacity => alpha / 255.0;

  /// The alpha channel of this color in an 8-bit value.
  ///
  /// A value of 0 means this color is fully transparent.
  /// A value of 255 means this color is fully opaque.
  int get alpha => (_alphaMask & _value) >> _alphaShift;

  /// The red channel of this color in an 8-bit value.
  int get red => (_redMask & _value) >> _redShift;

  /// The green channel of this color in an 8-bit value.
  int get green => (_greenMask & _value) >> _greenShift;

  /// The blue channel of this color in an 8-bit value.
  int get blue => (_blueMask & _value);

  /// Creates a new [RayRgb] with the same RGB values but a different alpha.
  ///
  /// The [alpha] value should be in the range [0, 255].
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// final semiRed = red.withAlpha(128);  // Semi-transparent red
  /// ```
  RayRgb withAlpha(int alpha) =>
      RayRgb(red: red, green: green, blue: blue, alpha: alpha);

  @override
  RayRgb withOpacity(double opacity) => RayRgb(
      red: red,
      green: green,
      blue: blue,
      alpha: (opacity.clamp(0.0, 1.0) * 255).round());

  @override
  RayRgb lerp(Ray other, double t) {
    final otherRgb = other.toRgb();

    final clampedT = t.clamp(0.0, 1.0);
    return RayRgb(
      red: (red + (otherRgb.red - red) * clampedT).round(),
      green: (green + (otherRgb.green - green) * clampedT).round(),
      blue: (blue + (otherRgb.blue - blue) * clampedT).round(),
      alpha: (alpha + (otherRgb.alpha - alpha) * clampedT).round(),
    );
  }

  @override
  RayRgb get inverse => RayRgb(
        red: 0xff - red,
        green: 0xff - green,
        blue: 0xff - blue,
        alpha: alpha,
      );

  /// Returns the relative luminance of this RGB color.
  /// 
  /// Note: Computing luminance from RGB is expensive. Consider using RayScheme for pre-calculated values.
  @override
  double get luminance => computeLuminance();

  /// Computes the relative luminance using WCAG 2.0 specification (0.0-1.0).
  /// Where R, G, B are the linearized color components.
  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
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
  RayRgb toRgb() => this; // Already RGB, return self

  @override
  RayHsl toHsl() => RayHsl.fromRgb(this);

  @override
  RayOklab toOklab() => RayOklab.fromRgb(red, green, blue, opacity);

  @override
  RayOklch toOklch() => RayOklch.fromOklab(toOklab());

  /// Converts the color to a hexadecimal string (6 or 8 characters).
  String toHexStr([int length = 6, HexFormat format = HexFormat.rgba]) =>
      switch (length) {
        6 => "#${toRgbInt().toRadixString(16).padLeft(6, '0').toUpperCase()}",
        8 => format == HexFormat.rgba
            ? "#${toRgbaInt().toRadixString(16).padLeft(8, '0').toUpperCase()}"
            : "#${toArgbInt().toRadixString(16).padLeft(8, '0').toUpperCase()}",
        _ =>
          throw ArgumentError("Invalid hex length: $length. Expected 6 or 8.")
      };

  /// Converts the color to a CSS rgb() string.
  String toRgbStr() => "rgb($red, $green, $blue)";

  /// Converts the color to a CSS rgba() string.
  String toRgbaStr() =>
      "rgba($red, $green, $blue, ${(alpha / 255).toStringAsFixed(2)})";

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
      'RayRgb(0x${_value.toRadixString(16).padLeft(8, '0').toUpperCase()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayRgb &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
