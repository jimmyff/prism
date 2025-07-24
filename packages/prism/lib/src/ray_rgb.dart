import 'ray_base.dart';
import 'ray_hsl.dart';
import 'ray_oklab.dart';

/// Hexadecimal color format for parsing and output.
enum HexFormat {
  /// RGBA format where alpha is the last component (web standard).
  rgba,

  /// ARGB format where alpha is the first component (Flutter/Android standard).
  argb
}

/// RGB color implementation of the Ray color system.
///
/// The [RayRgb] class provides a comprehensive API for RGB color manipulation,
/// supporting multiple input formats (RGB, ARGB, hex strings) and output
/// formats (hex, CSS strings, integers).
///
/// Colors are stored internally in ARGB format (32-bit integer) for
/// compatibility with Flutter's Color class and optimal performance.
///
/// Example usage:
/// ```dart
/// // Create colors from different sources
/// final red = RayRgb(red: 255, green: 0, blue: 0);
/// final semiTransparent = RayRgb(red: 255, green: 0, blue: 0, alpha: 128);
/// final fromHex = RayRgb.fromHex('#FF0000');
///
/// // Convert to different formats
/// print(red.toHex());        // #FF0000
/// print(red.toRGB());        // rgb(255, 0, 0)
/// print(red.toRGBA());       // rgba(255, 0, 0, 1.00)
///
/// // Work with color properties
/// final lighter = red.withOpacity(0.5);
/// final inverted = red.inverse;
/// final luminance = red.computeLuminance();
/// ```
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
  ColorModel get colorModel => ColorModel.rgb;

  /// Creates a [RayRgb] from individual RGB component values with named parameters.
  ///
  /// Each component should be in the range [0, 255].
  ///
  /// Parameters:
  /// - [red]: Red component (0 = no red, 255 = full red)
  /// - [green]: Green component (0 = no green, 255 = full green)
  /// - [blue]: Blue component (0 = no blue, 255 = full blue)
  /// - [alpha]: Alpha component (0 = transparent, 255 = opaque, default: 255)
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// final semiRed = RayRgb(red: 255, green: 0, blue: 0, alpha: 128);
  /// ```
  const RayRgb({required int red, required int green, required int blue, int alpha = 255})
      : _value = ((alpha & 0xff) << _alphaShift) |
            ((red & 0xff) << _redShift) |
            ((green & 0xff) << _greenShift) |
            ((blue & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb] from a 32-bit ARGB integer value.
  ///
  /// The [value] should be in ARGB format (same as Flutter's Colors).
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb.fromInt(0xFFFF0000);  // Opaque red
  /// final blue = RayRgb.fromInt(0xFF0000FF); // Opaque blue
  /// ```
  const RayRgb.fromInt(int value) : _value = value & _fullMask, super();

  /// Creates a [RayRgb] from a 32-bit ARGB integer value.
  ///
  /// This is identical to [fromInt] but with a more explicit name.
  const RayRgb.fromIntARGB(int value) : _value = value & _fullMask, super();

  /// Creates a [RayRgb] from a 32-bit RGBA integer value.
  ///
  /// Converts from RGBA format (alpha last) to internal ARGB format.
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb.fromIntRGBA(0xFF0000FF);  // Red with full alpha
  /// ```
  const RayRgb.fromIntRGBA(int value)
      : _value =
            ((value & 0xFFFFFF00) >> 8) | ((value & 0x000000FF) << _alphaShift),
        super();

  /// Creates a [RayRgb] from individual ARGB component values.
  ///
  /// Each component should be in the range [0, 255].
  ///
  /// Parameters:
  /// - [a]: Alpha component (0 = transparent, 255 = opaque)
  /// - [r]: Red component (0 = no red, 255 = full red)
  /// - [g]: Green component (0 = no green, 255 = full green)
  /// - [b]: Blue component (0 = no blue, 255 = full blue)
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb.fromARGB(255, 255, 0, 0);      // Opaque red
  /// final semiRed = RayRgb.fromARGB(128, 255, 0, 0);  // Semi-transparent red
  /// ```
  const RayRgb.fromARGB(int a, int r, int g, int b)
      : _value = ((a & 0xff) << _alphaShift) |
            ((r & 0xff) << _redShift) |
            ((g & 0xff) << _greenShift) |
            ((b & 0xff) << _blueShift),
        super();

  /// Creates a [RayRgb] from a hexadecimal color string.
  ///
  /// Supports 3, 6, and 8 character hex strings with or without '#' prefix.
  /// The [format] parameter determines how 8-character hex strings are interpreted.
  ///
  /// Supported formats:
  /// - 3 characters: RGB (e.g., "F00" = red)
  /// - 6 characters: RGB (e.g., "FF0000" = red)
  /// - 8 characters: RGBA or ARGB depending on [format]
  ///
  /// Parameters:
  /// - [value]: Hex string (with or without '#' prefix)
  /// - [format]: How to interpret 8-character hex (default: [HexFormat.rgba])
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb.fromHex('#FF0000');           // Red
  /// final shortRed = RayRgb.fromHex('#F00');         // Red (shorthand)
  /// final semiRed = RayRgb.fromHex('#FF000080');     // Semi-transparent red (RGBA)
  /// final argbRed = RayRgb.fromHex('#80FF0000', format: HexFormat.argb);
  /// ```
  ///
  /// Throws [ArgumentError] if the hex string is invalid.
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
        throw ArgumentError('Invalid hex color length: ${hex.length}. Expected 3, 6, or 8 characters.');
    }
  }

  /// Creates a [RayRgb] for JSON deserialization.
  ///
  /// Expects an integer value in ARGB format.
  factory RayRgb.fromJson(int json) => RayRgb.fromInt(json);

  /// Creates a transparent black color.
  ///
  /// This is equivalent to `RayRgb(red: 0, green: 0, blue: 0, alpha: 0)`.
  ///
  /// Example:
  /// ```dart
  /// final transparent = RayRgb.empty();
  /// print(transparent.alpha); // 0
  /// print(transparent.toHex(8)); // #00000000
  /// ```
  const RayRgb.empty() : _value = 0x00000000, super();

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
  RayRgb withAlpha(int alpha) => RayRgb(red: red, green: green, blue: blue, alpha: alpha);

  @override
  RayRgb withOpacity(double opacity) => 
      RayRgb(red: red, green: green, blue: blue, alpha: (opacity.clamp(0.0, 1.0) * 255).round());

  @override
  RayRgb lerp(Ray other, double t) {
    // Convert other to RGB if needed
    final otherRgb = other.colorModel == ColorModel.rgb ? other as RayRgb : other.toRgb();
    
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

  @override
  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
    final double R = Ray.linearizeColorComponent(red / 0xFF);
    final double G = Ray.linearizeColorComponent(green / 0xFF);
    final double B = Ray.linearizeColorComponent(blue / 0xFF);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  @override
  RayRgb toRgb() => this; // Already RGB, return self

  @override
  RayHsl toHsl() => RayHsl.fromRgb(this);

  @override
  RayOklab toOklab() => RayOklab.fromRgb(red, green, blue, opacity);

  /// Converts the color to a hexadecimal string representation.
  ///
  /// Parameters:
  /// - [length]: Output length - 6 for RGB, 8 for RGBA/ARGB (default: 6)
  /// - [format]: For 8-character output, determines RGBA vs ARGB format (default: RGBA)
  ///
  /// Returns a hex string with '#' prefix and uppercase letters.
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// print(red.toHex());                    // #FF0000
  /// print(red.toHex(8));                   // #FF0000FF (RGBA)
  /// print(red.toHex(8, HexFormat.argb));   // #FFFF0000 (ARGB)
  /// ```
  ///
  /// Throws [ArgumentError] if [length] is not 6 or 8.
  String toHex([int length = 6, HexFormat format = HexFormat.rgba]) =>
      switch (length) {
        6 => "#${toIntRGB().toRadixString(16).padLeft(6, '0').toUpperCase()}",
        8 => format == HexFormat.rgba
            ? "#${toIntRGBA().toRadixString(16).padLeft(8, '0').toUpperCase()}"
            : "#${toIntARGB().toRadixString(16).padLeft(8, '0').toUpperCase()}",
        _ =>
          throw ArgumentError("Invalid hex length: $length. Expected 6 or 8.")
      };

  /// Converts the color to a CSS rgb() string.
  ///
  /// Returns a CSS-compatible rgb() string with integer values.
  /// Alpha channel is ignored.
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// print(red.toRGB()); // rgb(255, 0, 0)
  /// ```
  String toRGB() => "rgb($red, $green, $blue)";

  /// Converts the color to a CSS rgba() string.
  ///
  /// Returns a CSS-compatible rgba() string with integer color values
  /// and decimal alpha value (0.00 to 1.00).
  ///
  /// Example:
  /// ```dart
  /// final semiRed = RayRgb(red: 255, green: 0, blue: 0, alpha: 128);
  /// print(semiRed.toRGBA()); // rgba(255, 0, 0, 0.50)
  /// ```
  String toRGBA() =>
      "rgba($red, $green, $blue, ${(alpha / 255).toStringAsFixed(2)})";

  @override
  int toJson() => _value;

  /// Returns the color as a 32-bit ARGB integer.
  ///
  /// This is the native storage format used internally.
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// print(red.toIntARGB().toRadixString(16)); // ffff0000
  /// ```
  int toIntARGB() => _value;

  /// Returns the color as a 24-bit RGB integer, discarding alpha.
  ///
  /// The returned value contains only the RGB components.
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0, alpha: 128);
  /// print(red.toIntRGB().toRadixString(16)); // ff0000 (alpha discarded)
  /// ```
  int toIntRGB() => _value & _rgbMask;

  /// Returns the color as a 32-bit RGBA integer (alpha last).
  ///
  /// Converts from internal ARGB format to RGBA format where
  /// alpha is the last component.
  ///
  /// Example:
  /// ```dart
  /// final red = RayRgb(red: 255, green: 0, blue: 0);
  /// print(red.toIntRGBA().toRadixString(16)); // ff0000ff
  /// ```
  int toIntRGBA() =>
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