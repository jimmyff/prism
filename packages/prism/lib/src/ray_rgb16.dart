import 'ray_base.dart';
import 'ray_rgb_base.dart';
import 'ray_rgb8.dart';

/// 16-bit RGB color implementation with support for high precision color operations.
///
/// Stored internally as 64-bit integer with four 16-bit components (ARGB).
/// Each color channel uses 16 bits (0-65535 range) for professional imaging applications.
base class RayRgb16 extends RayRgbBase<int> {
  /// Bit mask constants for efficient color component extraction (16-bit)
  static const int _alphaMask = 0xFFFF000000000000;
  static const int _redMask = 0x0000FFFF00000000;
  static const int _greenMask = 0x00000000FFFF0000;
  static const int _blueMask = 0x000000000000FFFF;
  static const int _fullMask = 0xFFFFFFFFFFFFFFFF;

  /// Component bit shift amounts for 16-bit channels
  static const int _alphaShift = 48;
  static const int _redShift = 32;
  static const int _greenShift = 16;
  static const int _blueShift = 0;

  /// An ARGB color value stored as a 64-bit integer
  final int _value;

  @override
  ColorSpace get colorSpace => ColorSpace.rgb16;

  /// Creates a [RayRgb16] from individual RGB component values (0-65535).
  const RayRgb16(
      {required int red,
      required int green,
      required int blue,
      int alpha = 65535})
      : _value = ((alpha & 0xffff) << _alphaShift) |
            ((red & 0xffff) << _redShift) |
            ((green & 0xffff) << _greenShift) |
            ((blue & 0xffff) << _blueShift),
        super();

  /// Creates a [RayRgb16] from a 64-bit ARGB integer value.
  const RayRgb16.fromInt(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb16] from a 64-bit ARGB integer value.
  const RayRgb16.fromIntARGB(int value)
      : _value = value & _fullMask,
        super();

  /// Creates a [RayRgb16] from individual ARGB component values (0-65535).
  const RayRgb16.fromARGB(int a, int r, int g, int b)
      : _value = ((a & 0xffff) << _alphaShift) |
            ((r & 0xffff) << _redShift) |
            ((g & 0xffff) << _greenShift) |
            ((b & 0xffff) << _blueShift),
        super();

  /// Creates a [RayRgb16] from an 8-bit RGB color, upscaling to 16-bit.
  factory RayRgb16.fromRgb8(dynamic rgb8Color) => RayRgb16(
        red: rgb8Color.red * 257, // 8-bit to 16-bit conversion
        green: rgb8Color.green * 257,
        blue: rgb8Color.blue * 257,
        alpha: rgb8Color.alpha * 257,
      );

  /// Creates a [RayRgb16] for JSON deserialization.
  factory RayRgb16.fromJson(int json) => RayRgb16.fromInt(json);

  /// Creates a transparent black color.
  const RayRgb16.empty()
      : _value = 0x0000000000000000,
        super();

  /// The alpha channel of this color in a 16-bit value.
  ///
  /// A value of 0 means this color is fully transparent.
  /// A value of 65535 means this color is fully opaque.
  @override
  int get alphaInt => ((_alphaMask & _value) >> _alphaShift) & 0xFFFF;

  /// The red channel of this color in a 16-bit value.
  @override
  int get redInt => ((_redMask & _value) >> _redShift) & 0xFFFF;

  /// The green channel of this color in a 16-bit value.
  @override
  int get greenInt => ((_greenMask & _value) >> _greenShift) & 0xFFFF;

  /// The blue channel of this color in a 16-bit value.
  @override
  int get blueInt => (_blueMask & _value) & 0xFFFF;

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
      RayRgb16(red: redInt, green: greenInt, blue: blueInt, alpha: alpha);

  @override
  RayRgb16 withOpacity(double opacity) => RayRgb16(
      red: redInt,
      green: greenInt,
      blue: blueInt,
      alpha: (opacity.clamp(0.0, 1.0) * 65535).round());

  @override
  RayRgb16 lerp(Ray other, double t) {
    final (red, green, blue, alpha) = lerpComponents(other, t);
    // Convert 8-bit back to 16-bit for our result
    return RayRgb16(
        red: red * 257,
        green: green * 257,
        blue: blue * 257,
        alpha: alpha * 257);
  }

  @override
  RayRgb16 get inverse {
    final (red, green, blue, alpha) = inverseComponents;
    // Convert 8-bit back to 16-bit for our result
    return RayRgb16(
        red: red * 257,
        green: green * 257,
        blue: blue * 257,
        alpha: alpha * 257);
  }

  // luminance, toHsl, toOklab, toOklch methods are provided by RayRgbBase

  @override
  RayRgb8 toRgb() =>
      toRgb8(); // Convert to 8-bit for Ray interface compatibility

  /// Converts the color to a hexadecimal string (12 or 16 characters for 16-bit).
  @override
  String toHexStr([int? length]) {
    final actualLength = length ?? 12;
    final format = HexFormat.rgba;
    return switch (actualLength) {
      12 => "#${toRgbInt().toRadixString(16).padLeft(12, '0').toUpperCase()}",
      16 => format == HexFormat.rgba
          ? "#${toRgbaInt().toRadixString(16).padLeft(16, '0').toUpperCase()}"
          : "#${toArgbInt().toRadixString(16).padLeft(16, '0').toUpperCase()}",
      _ => throw ArgumentError(
          "Invalid hex length: $actualLength. Expected 12 or 16.")
    };
  }

  // toRgbStr and toRgbaStr methods are provided by RayRgbBase

  /// Optimized bit-depth conversion methods
  @override
  RayRgb8 toRgb8() {
    // Convert 16-bit to 8-bit (high byte for best precision)
    return RayRgb8(
      red: redInt >> 8,
      green: greenInt >> 8,
      blue: blueInt >> 8,
      alpha: alphaInt >> 8,
    );
  }

  @override
  RayRgb16 toRgb16() => this; // Already 16-bit, return self

  @override
  int toJson() => _value;

  /// Returns the color as a 64-bit ARGB integer.
  int toArgbInt() => _value;

  /// Returns the color as a 48-bit RGB integer, discarding alpha.
  int toRgbInt() => _value & 0x0000FFFFFFFFFFFF;

  /// Returns the color as a 64-bit RGBA integer (alpha last).
  int toRgbaInt() => ((toRgbInt()) << 16) | (alphaInt);

  @override
  String toString() =>
      'RayRgb16(0x${_value.toRadixString(16).padLeft(16, '0').toUpperCase()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayRgb16 &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
