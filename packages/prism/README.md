# Prism 🌈

A powerful and efficient color manipulation library for Dart & Flutter applications with zero dependencies. See [prism_flutter](https://pub.dev/packages/prism_flutter) which adds Flutter specific extensions.

Work with colors through the `Ray` class - a clean, intuitive API for all your color needs.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism)
- [Package on Pub.dev](https://pub.dev/packages/prism)
- [Documentation](https://pub.dev/documentation/prism/latest/)
- [Flutter package](https://pub.dev/packages/prism_flutter)

## Features

- 🎨 **Multiple color formats**: RGB, ARGB, hex strings, CSS strings
- 🔀 **Format conversion**: Easy conversion between different color formats
- 📱 **Flutter compatible**: Internal ARGB format matches Flutter's Color class
- 🌐 **Web standard support**: Default RGBA hex format for web compatibility
- ⚡ **Performance optimized**: Efficient bit operations and minimal allocations
- 🎯 **Type safe**: Comprehensive API with proper error handling
- 🪶 **Zero dependencies**: Pure Dart implementation with no external dependencies

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  prism: ^1.0.0
```

## Quick Start

```dart
import 'package:prism/prism.dart';

void main() {
  // Create colors from different sources
  final red = Ray.fromHex('#FF0000');
  final blue = Ray.fromARGB(255, 0, 0, 255);
  final green = Ray.fromRGBO(0, 255, 0, 1.0);
  
  // Convert between formats
  print(red.toHex());        // #FF0000
  print(red.toRGB());        // rgb(255, 0, 0)
  print(red.toRGBA());       // rgba(255, 0, 0, 1.00)
  
  // Manipulate colors
  final semiRed = red.withOpacity(0.5);
  final purple = red.lerp(blue, 0.5);
  final cyan = red.inverse;
  
  // Access components
  print('Red: ${red.red}, Alpha: ${red.alpha}');
  print('Luminance: ${red.computeLuminance()}');
}
```

## Hex Format Support

Supports both web standard (RGBA) and Flutter/Android (ARGB) hex formats:

```dart
// Web standard - alpha last (default)
final webColor = Ray.fromHex('#FF000080');  // Red with 50% alpha

// Flutter/Android - alpha first
final flutterColor = Ray.fromHex('#80FF0000', format: HexFormat.argb);

// Both rays create the same color
print(webColor == flutterColor);  // true
```

## API Overview

### Constructors
- `Ray.fromHex(String)` - From hex string (#RGB, #RRGGBB, #RRGGBBAA)
- `Ray.fromARGB(int, int, int, int)` - From ARGB components
- `Ray.fromRGBO(int, int, int, double)` - From RGB + opacity
- `Ray.fromJson(int)` - From JSON integer

### Output Methods
- `toHex([int length, HexFormat format])` - To hex string
- `toRGB()` - To CSS rgb() string
- `toRGBA()` - To CSS rgba() string
- `toIntARGB()` - To ARGB integer
- `toIntRGBA()` - To RGBA integer

### Color Operations
- `withAlpha(int alpha)` - Copy with new alpha
- `withOpacity(double opacity)` - Copy with new opacity
- `lerp(Ray other, double t)` - Linear interpolation between rays
- `inverse` - Inverted color
- `computeLuminance()` - WCAG luminance calculation

### Properties
- `red`, `green`, `blue`, `alpha` - Component values (0-255)
- `opacity` - Alpha as double (0.0-1.0)

## Performance

Prism is optimized for performance:
- Efficient bit operations for color manipulation
- Minimal memory allocations
- Optimized string operations
- Cached component calculations

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.