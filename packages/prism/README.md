# Prism 🌈

A powerful and efficient color manipulation library for Dart & Flutter applications with zero dependencies. Features the `Ray` class for color manipulation, `RayScheme` for accessibility-focused color schemes, and extensive pre-built color palettes.

See [prism_flutter](https://pub.dev/packages/prism_flutter) which adds Flutter specific extensions.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism)
- [Package on Pub.dev](https://pub.dev/packages/prism)
- [Documentation](https://pub.dev/documentation/prism/latest/)
- [Flutter package](https://pub.dev/packages/prism_flutter)

## Features

- 🎨 **Multiple color formats**: RGB, ARGB, hex strings, CSS strings
- 🔀 **Format conversion**: Easy conversion between different color formats
- 🎭 **Color schemes**: RayScheme for accessibility-focused UI color schemes
- 🎨 **Color palettes**: Pre-built palettes (CSS, Material, Catppuccin, Solarized, OpenColor)
- 📱 **Flutter compatible**: Internal ARGB format matches Flutter's Color class
- 🌐 **Web standard support**: Default RGBA hex format for web compatibility
- ♿ **Accessibility**: WCAG luminance calculations and contrast ratios
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
  
  // Create accessibility-focused color schemes
  final scheme = RayScheme.fromRay(red);
  final textColor = scheme.onRay;        // Contrasting text color
  final darkSurface = scheme.surfaceDark; // Dark theme surface
  final isLight = scheme.isLight;         // Theme classification
  
  // Use pre-built color palettes
  final materialBlue = MaterialPalette.blue500.ray;
  final cssNavy = CssPalette.navy.ray;
  
  // Access components and calculations
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

## Color Palettes

Prism includes extensive pre-built color palettes with accessibility-focused schemes:

### Available Palettes

- **[CSS Colors](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/CssPalette.html)** - Complete CSS color palette
- **[Material Design](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/MaterialPalette.html)** - Material Design color system
- **[Open Color](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/OpenColorPalette.html)** - Open Color palette system
- Catppuccin flavors: **[Latte](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/CatppuccinLattePalette.html)**, **[Frappé](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/CatppuccinFrappePalette.html)**, **[Macchiato](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/CatppuccinMacchiatoPalette.html)**, **[Mocha](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/CatppuccinMochaPalette.html)**
- **[Solarized](https://raw.githubusercontent.com/jimmyff/prism/main/packages/prism/tools/palettes/gallery/SolarizedPalette.html)** - Solarized color scheme


### Usage

**Note**: Palettes are not exported by default to avoid namespace pollution. Import only the palettes you need:

```dart
// Import specific palettes as needed
import 'package:prism/palettes/css.dart';
import 'package:prism/palettes/material.dart';

// Access colors from imported palettes
final primaryBlue = CssPalette.blue.ray;
final materialRed = MaterialPalette.red500.ray;

// Get complete accessibility schemes
final blueScheme = CssPalette.blue.scheme;
final textColor = blueScheme.onRay;          // Optimal contrast color
final lightSurface = blueScheme.surfaceLight; // Light theme surface
final darkSurface = blueScheme.surfaceDark;   // Dark theme surface
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

### Color Schemes (RayScheme)
- `RayScheme.fromRay(Ray)` - Create accessibility scheme from color
- `ray` - Primary color
- `onRay` - Optimal contrast text color
- `surfaceLight`/`surfaceDark` - Light and dark surface variants
- `luminance` - WCAG relative luminance
- `isDark`/`isLight` - Theme classification

## Performance

Prism is optimized for performance:
- Efficient bit operations for color manipulation
- Minimal memory allocations
- Optimized string operations
- Cached component calculations

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.