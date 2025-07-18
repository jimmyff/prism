library prism;

import 'dart:math' as math;

/// Hexadecimal color format for parsing and output.
enum HexFormat { 
  /// RGBA format where alpha is the last component (web standard).
  rgba, 
  /// ARGB format where alpha is the first component (Flutter/Android standard).
  argb 
}

/// A utility class for working with colors in various formats.
/// 
/// The [Ray] class provides a comprehensive API for color manipulation,
/// supporting multiple input formats (RGB, ARGB, hex strings) and output
/// formats (hex, CSS strings, integers).
/// 
/// Colors are stored internally in ARGB format (32-bit integer) for 
/// compatibility with Flutter's Color class.
/// 
/// Example usage:
/// ```dart
/// // Create colors from different sources
/// final red = Ray.fromHex('#FF0000');
/// final semiTransparent = Ray.fromRGBO(255, 0, 0, 0.5);
/// final fromComponents = Ray.fromARGB(255, 255, 0, 0);
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
class Ray {
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

  /// Creates a [Ray] from a 32-bit ARGB integer value.
  /// 
  /// The [value] should be in ARGB format (same as Flutter's Colors).
  /// Use other constructors for different input formats.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray(0xFFFF0000);  // Opaque red
  /// final blue = Ray(0xFF0000FF); // Opaque blue
  /// ```
  const Ray(int value) : _value = value & _fullMask;
  
  /// Creates a [Ray] from a 32-bit ARGB integer value.
  /// 
  /// This is identical to the default constructor but with a more explicit name.
  const Ray.fromIntARGB(int value) : _value = value & _fullMask;
  
  /// Creates a [Ray] from a 32-bit RGBA integer value.
  /// 
  /// Converts from RGBA format (alpha last) to internal ARGB format.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromIntRGBA(0xFF0000FF);  // Red with full alpha
  /// ```
  const Ray.fromIntRGBA(int value)
      : _value = ((value & 0xFFFFFF00) >> 8) | ((value & 0x000000FF) << _alphaShift);
  
  /// Creates a [Ray] from individual ARGB component values.
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
  /// final red = Ray.fromARGB(255, 255, 0, 0);      // Opaque red
  /// final semiRed = Ray.fromARGB(128, 255, 0, 0);  // Semi-transparent red
  /// ```
  const Ray.fromARGB(int a, int r, int g, int b)
      : _value = ((a & 0xff) << _alphaShift) |
                ((r & 0xff) << _redShift) |
                ((g & 0xff) << _greenShift) |
                ((b & 0xff) << _blueShift);

  /// Creates a [Ray] from RGB components with opacity.
  /// 
  /// Each color component should be in the range [0, 255].
  /// The [opacity] should be in the range [0.0, 1.0].
  /// 
  /// Parameters:
  /// - [r]: Red component (0 = no red, 255 = full red)
  /// - [g]: Green component (0 = no green, 255 = full green)  
  /// - [b]: Blue component (0 = no blue, 255 = full blue)
  /// - [opacity]: Opacity (0.0 = transparent, 1.0 = opaque)
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromRGBO(255, 0, 0, 1.0);    // Opaque red
  /// final semiRed = Ray.fromRGBO(255, 0, 0, 0.5); // Semi-transparent red
  /// ```
  const Ray.fromRGBO(int r, int g, int b, double opacity)
      : _value = (((opacity * 0xff) ~/ 1 & 0xff) << _alphaShift) |
                ((r & 0xff) << _redShift) |
                ((g & 0xff) << _greenShift) |
                ((b & 0xff) << _blueShift);

  /// Creates a [Ray] from a hexadecimal color string.
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
  /// final red = Ray.fromHex('#FF0000');           // Red
  /// final shortRed = Ray.fromHex('#F00');         // Red (shorthand)
  /// final semiRed = Ray.fromHex('#FF000080');     // Semi-transparent red (RGBA)
  /// final argbRed = Ray.fromHex('#80FF0000', format: HexFormat.argb);
  /// ```
  /// 
  /// Throws [ArgumentError] if the hex string has an invalid length or format.
  factory Ray.fromHex(String value, {HexFormat format = HexFormat.rgba}) {
    final hex = value.startsWith("#") ? value.substring(1) : value;
    
    // Validate hex string contains only valid characters
    if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hex)) {
      throw ArgumentError("Invalid hex string: '$value'. Must contain only hexadecimal characters.");
    }
    
    return switch (hex.length) {
      3 => _fromHex3(hex),
      6 => _fromHex6(hex),
      8 => format == HexFormat.rgba 
          ? Ray.fromIntRGBA(int.parse(hex, radix: 16))
          : Ray(int.parse(hex, radix: 16)),
      _ => throw ArgumentError("Invalid hex string length: ${hex.length}. Expected 3, 6, or 8 characters.")
    };
  }
  
  /// Creates a [Ray] from a 3-character hex string using bit operations.
  static Ray _fromHex3(String hex) {
    final r = int.parse(hex[0], radix: 16);
    final g = int.parse(hex[1], radix: 16);
    final b = int.parse(hex[2], radix: 16);
    
    // Duplicate each hex digit: F -> FF, 0 -> 00
    return Ray.fromARGB(
      255,
      (r << 4) | r,
      (g << 4) | g,
      (b << 4) | b,
    );
  }
  
  /// Creates a [Ray] from a 6-character hex string.
  static Ray _fromHex6(String hex) {
    return Ray(0xFF000000 | int.parse(hex, radix: 16));
  }
  /// Creates a [Ray] from a JSON integer value.
  /// 
  /// This is a convenience constructor for deserializing colors from JSON.
  /// The [json] value should be a 32-bit ARGB integer.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromJson(0xFFFF0000);
  /// ```
  factory Ray.fromJson(int json) => Ray(json);

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
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// print(red.toHex());                    // #FF0000
  /// print(red.toHex(8));                   // #FF0000FF (RGBA)
  /// print(red.toHex(8, HexFormat.argb));   // #FFFF0000 (ARGB)
  /// ```
  /// 
  /// Throws [ArgumentError] if [length] is not 6 or 8.
  String toHex([int length = 6, HexFormat format = HexFormat.rgba]) => switch (length) {
        6 => "#${toIntRGB().toRadixString(16).padLeft(6, '0').toUpperCase()}",
        8 => format == HexFormat.rgba
          ? "#${toIntRGBA().toRadixString(16).padLeft(8, '0').toUpperCase()}"
          : "#${toIntARGB().toRadixString(16).padLeft(8, '0').toUpperCase()}",
        _ => throw ArgumentError("Invalid hex length: $length. Expected 6 or 8.")
      };
  
  /// Converts the color to a CSS rgb() string.
  /// 
  /// Returns a CSS-compatible rgb() string with integer values.
  /// Alpha channel is ignored.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(255, 255, 0, 0);
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
  /// final semiRed = Ray.fromARGB(128, 255, 0, 0);
  /// print(semiRed.toRGBA()); // rgba(255, 0, 0, 0.50)
  /// ```
  String toRGBA() => "rgba($red, $green, $blue, ${(alpha / 255).toStringAsFixed(2)})";

  /// Returns the color as a 32-bit ARGB integer for JSON serialization.
  /// 
  /// This is the same as [toIntARGB] but with a more specific name for JSON use.
  int toJson() => _value;
  
  /// Returns the color as a 32-bit ARGB integer.
  /// 
  /// This is the native storage format used internally.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// print(red.toIntARGB().toRadixString(16)); // ffff0000
  /// ```
  int toIntARGB() => _value;

  /// Returns the color as a 24-bit RGB integer, discarding alpha.
  /// 
  /// The returned value contains only the RGB components.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(128, 255, 0, 0);  // Semi-transparent red
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
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// print(red.toIntRGBA().toRadixString(16)); // ff0000ff
  /// ```
  int toIntRGBA() => ((_value & _rgbMask) << 8) | ((_value & _alphaMask) >> _alphaShift);

  @override
  String toString() =>
      'Ray(0x${_value.toRadixString(16).padLeft(8, '0').toUpperCase()})';

  /// Creates a new [Ray] with the same RGB values but a different alpha.
  /// 
  /// The [alpha] value should be in the range [0, 255].
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// final semiRed = red.withAlpha(128);  // Semi-transparent red
  /// ```
  Ray withAlpha(int alpha) => Ray.fromARGB(alpha, red, green, blue);
  
  /// Creates a new [Ray] with the same RGB values but a different opacity.
  /// 
  /// The [opacity] value should be in the range [0.0, 1.0].
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// final semiRed = red.withOpacity(0.5);  // Semi-transparent red
  /// ```
  Ray withOpacity(double opacity) => Ray.fromRGBO(red, green, blue, opacity);
  
  /// Linearly interpolates between this color and [other].
  /// 
  /// The [t] parameter should be in the range [0.0, 1.0], where:
  /// - t = 0.0 returns this color
  /// - t = 1.0 returns [other]
  /// - t = 0.5 returns the midpoint between the colors
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// final blue = Ray.fromARGB(255, 0, 0, 255);
  /// final purple = red.lerp(blue, 0.5);  // Midpoint between red and blue
  /// ```
  Ray lerp(Ray other, double t) {
    final clampedT = t.clamp(0.0, 1.0);
    return Ray.fromARGB(
      (alpha + (other.alpha - alpha) * clampedT).round(),
      (red + (other.red - red) * clampedT).round(),
      (green + (other.green - green) * clampedT).round(),
      (blue + (other.blue - blue) * clampedT).round(),
    );
  }

  /// Returns the color with inverted RGB values, preserving alpha.
  /// 
  /// Each RGB component is inverted using the formula: 255 - component.
  /// The alpha channel remains unchanged.
  /// 
  /// Example:
  /// ```dart
  /// final red = Ray.fromARGB(255, 255, 0, 0);
  /// final cyan = red.inverse;  // Cyan (0, 255, 255) with same alpha
  /// ```
  Ray get inverse => Ray.fromARGB(
        alpha,
        0xff - red,
        0xff - green,
        0xff - blue,
      );

  /// The alpha channel of this color in an 8-bit value.
  ///
  /// A value of 0 means this color is fully transparent. 
  /// A value of 255 means this color is fully opaque.
  int get alpha => (_alphaMask & _value) >> _alphaShift;

  /// The alpha channel of this color as a double.
  ///
  /// A value of 0.0 means this color is fully transparent. 
  /// A value of 1.0 means this color is fully opaque.
  double get opacity => alpha / 0xFF;

  /// The red channel of this color in an 8-bit value.
  int get red => (_redMask & _value) >> _redShift;

  /// The green channel of this color in an 8-bit value.
  int get green => (_greenMask & _value) >> _greenShift;

  /// The blue channel of this color in an 8-bit value.
  int get blue => (_blueMask & _value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ray &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  /// Linearizes a color component for luminance calculation.
  /// 
  /// See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  /// Returns the relative luminance of the color.
  ///
  /// Represents a brightness value between 0 (darkest) and 1 (lightest).
  /// This calculation is computationally expensive and follows the WCAG 2.0 
  /// specification for accessibility.
  ///
  /// The luminance is calculated using the formula:
  /// L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  /// 
  /// Where R, G, B are the linearized color components.
  ///
  /// Example:
  /// ```dart
  /// final black = Ray.fromARGB(255, 0, 0, 0);
  /// final white = Ray.fromARGB(255, 255, 255, 255);
  /// print(black.computeLuminance()); // 0.0
  /// print(white.computeLuminance()); // 1.0
  /// ```
  ///
  /// See <https://en.wikipedia.org/wiki/Relative_luminance>.
  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
    final double R = _linearizeColorComponent(red / 0xFF);
    final double G = _linearizeColorComponent(green / 0xFF);
    final double B = _linearizeColorComponent(blue / 0xFF);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  /// Returns the color with the highest contrast relative to this color.
  /// 
  /// Compares the luminance contrast between this color and the two provided
  /// colors, returning the one with higher contrast. This calculation is
  /// computationally expensive as it involves luminance calculations.
  /// 
  /// Parameters:
  /// - [a]: First color to compare
  /// - [b]: Second color to compare
  /// 
  /// Returns the color ([a] or [b]) with the highest contrast to this color.
  /// 
  /// Example:
  /// ```dart
  /// final gray = Ray.fromARGB(255, 128, 128, 128);
  /// final black = Ray.fromARGB(255, 0, 0, 0);
  /// final white = Ray.fromARGB(255, 255, 255, 255);
  /// final bestContrast = gray.maxContrast(black, white); // Returns white
  /// ```
  Ray maxContrast(Ray a, Ray b) {
    final lum = computeLuminance();
    final lumA = a.computeLuminance();
    final lumB = b.computeLuminance();
    final contrastA = (lum - lumA).abs();
    final contrastB = (lum - lumB).abs();
    return contrastA > contrastB ? a : b;
  }

  /// Creates a transparent black color.
  /// 
  /// This is equivalent to `Ray.fromARGB(0, 0, 0, 0)`.
  /// 
  /// Example:
  /// ```dart
  /// final transparent = Ray.empty();
  /// print(transparent.alpha); // 0
  /// print(transparent.toHex(8)); // #00000000
  /// ```
  const Ray.empty() : _value = 0x00000000;
}
