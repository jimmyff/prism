import 'ray_base.dart';
import 'ray_rgb_base.dart';
import 'ray_rgb16.dart';

/// Hexadecimal color format for parsing and output.
enum HexFormat {
  /// RGBA format where alpha is the last component (web standard).
  rgba,

  /// ARGB format where alpha is the first component (Flutter/Android standard).
  argb
}

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
  const RayRgb8(
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
  const RayRgb8.fromInt(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb8] from a 32-bit ARGB integer value.
  const RayRgb8.fromIntARGB(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb8] from a 32-bit RGBA integer value.
  const RayRgb8.fromIntRGBA(int value)
      : _value =
            ((value & 0xFFFFFF00) >> 8) | ((value & 0x000000FF) << _alphaShift),
        super();

  /// Creates a [RayRgb8] from individual ARGB component values (0-255).
  const RayRgb8.fromARGB(int a, int r, int g, int b)
      : _value = ((a & 0xff) << _alphaShift) |
            ((r & 0xff) << _redShift) |
            ((g & 0xff) << _greenShift) |
            ((b & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb8] from a hexadecimal color string.
  ///
  /// Supports 3, 6, and 8 character hex strings with or without '#' prefix.
  factory RayRgb8.fromHex(String value, {HexFormat format = HexFormat.rgba}) {
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
        return RayRgb8(red: r, green: g, blue: b);

      case 6:
        // RGB: FF0000
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        return RayRgb8(red: r, green: g, blue: b);

      case 8:
        // RGBA or ARGB format
        if (format == HexFormat.rgba) {
          // RGBA: FF000080 (red with 50% alpha)
          final r = int.parse(hex.substring(0, 2), radix: 16);
          final g = int.parse(hex.substring(2, 4), radix: 16);
          final b = int.parse(hex.substring(4, 6), radix: 16);
          final a = int.parse(hex.substring(6, 8), radix: 16);
          return RayRgb8(red: r, green: g, blue: b, alpha: a);
        } else {
          // ARGB: 80FF0000 (red with 50% alpha)
          return RayRgb8.fromIntARGB(int.parse(hex, radix: 16));
        }

      default:
        throw ArgumentError(
            'Invalid hex color length: ${hex.length}. Expected 3, 6, or 8 characters.');
    }
  }

  /// Creates a [RayRgb8] from a 16-bit RGB color, downscaling to 8-bit.
  factory RayRgb8.fromRgb16(dynamic rgb16Color) => RayRgb8(
        red: rgb16Color.redInt >> 8, // Convert 16-bit to 8-bit (high byte)
        green: rgb16Color.greenInt >> 8,
        blue: rgb16Color.blueInt >> 8,
        alpha: rgb16Color.alphaInt >> 8,
      );

  /// Creates a [RayRgb8] for JSON deserialization.
  factory RayRgb8.fromJson(int json) => RayRgb8.fromInt(json);

  /// Creates a transparent black color.
  const RayRgb8.empty()
      : _value = 0x00000000,
        super();

  /// The alpha channel of this color in an 8-bit value.
  ///
  /// A value of 0 means this color is fully transparent.
  /// A value of 255 means this color is fully opaque.
  @override
  int get alphaInt => (_alphaMask & _value) >> _alphaShift;

  /// The red channel of this color in an 8-bit value.
  @override
  int get redInt => (_redMask & _value) >> _redShift;

  /// The green channel of this color in an 8-bit value.
  @override
  int get greenInt => (_greenMask & _value) >> _greenShift;

  /// The blue channel of this color in an 8-bit value.
  @override
  int get blueInt => (_blueMask & _value);

  /// Creates a new [RayRgb8] with the same RGB values but a different alpha.
  ///
  /// The [alpha] value should be in the range [0, 255].
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb8(red: 255, green: 0, blue: 0);
  /// final semiRed = red.withAlpha(128);  // Semi-transparent red
  /// ```
  RayRgb8 withAlpha(int alpha) =>
      RayRgb8(red: red, green: green, blue: blue, alpha: alpha);

  @override
  RayRgb8 withOpacity(double opacity) => RayRgb8(
      red: red,
      green: green,
      blue: blue,
      alpha: (opacity.clamp(0.0, 1.0) * 255).round());

  @override
  RayRgb8 lerp(Ray other, double t) {
    final (red, green, blue, alpha) = lerpComponents(other, t);
    return RayRgb8(red: red, green: green, blue: blue, alpha: alpha);
  }

  @override
  RayRgb8 get inverse {
    final (red, green, blue, alpha) = inverseComponents;
    return RayRgb8(red: red, green: green, blue: blue, alpha: alpha);
  }

  // luminance, toHsl, toOklab, toOklch methods are provided by RayRgbBase

  @override
  RayRgb8 toRgb() => this; // Already 8-bit RGB, return self

  /// Converts the color to a hexadecimal string (6 or 8 characters).
  @override
  String toHexStr([int? length, HexFormat format = HexFormat.rgba]) {
    final actualLength = length ?? 6;
    return switch (actualLength) {
      6 => "#${toRgbInt().toRadixString(16).padLeft(6, '0').toUpperCase()}",
      8 => format == HexFormat.rgba
          ? "#${toRgbaInt().toRadixString(16).padLeft(8, '0').toUpperCase()}"
          : "#${toArgbInt().toRadixString(16).padLeft(8, '0').toUpperCase()}",
      _ => throw ArgumentError(
          "Invalid hex length: $actualLength. Expected 6 or 8.")
    };
  }

  // toRgbStr and toRgbaStr methods are provided by RayRgbBase

  /// Optimized bit-depth conversion methods
  @override
  RayRgb8 toRgb8() => this; // Already 8-bit, return self

  @override
  RayRgb16 toRgb16() => RayRgb16(
        red: red * 257, // Convert 8-bit to 16-bit (0-255 -> 0-65535)
        green: green * 257,
        blue: blue * 257,
        alpha: alpha * 257,
      );

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
