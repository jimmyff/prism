# Prism 🌈

A powerful and efficient color manipulation library for Dart & Flutter applications with zero dependencies. Features multiple color models (`RayRgb`, `RayHsl`, `RayOklab`) with seamless conversion, `RayScheme` for accessibility-focused color schemes, and extensive pre-built color palettes.

See [prism_flutter](https://pub.dev/packages/prism_flutter) which adds Flutter specific extensions.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism)
- [Package on Pub.dev](https://pub.dev/packages/prism)
- [Documentation](https://pub.dev/documentation/prism/latest/)
- [Flutter package](https://pub.dev/packages/prism_flutter)

## Features

- 🎨 **Multiple color models**: RGB (`RayRgb`), HSL (`RayHsl`), and Oklab (`RayOklab`) with seamless conversion
- 🔀 **Format conversion**: Easy conversion between color models and formats
- 📐 **HSL color analysis**: Distance and difference functions for color comparison
- 🎭 **Color schemes**: RayScheme for accessibility-focused UI color schemes
- 🎨 **Color palettes**: Pre-built palettes (CSS, Material, Catppuccin, Solarized, OpenColor)
- 📱 **Flutter compatible**: Perfect conversion to/from Flutter's Color class
- 🌐 **Web standard support**: Default RGBA hex format for web compatibility
- ♿ **Accessibility**: WCAG luminance calculations and contrast ratios
- ⚡ **Performance optimized**: Efficient bit operations and minimal allocations
- 🎯 **Type safe**: Comprehensive API with proper error handling
- 🪶 **Zero dependencies**: Pure Dart implementation with no external dependencies


## Quick Start

```dart
import 'package:prism/prism.dart';

void main() {
  // RGB Color Model
  final red = RayRgb.fromHex('#FF0000');
  final blue = RayRgb.fromARGB(255, 0, 0, 255);
  final green = RayRgb(red: 0, green: 255, blue: 0);
  
  // HSL Color Model  
  final hslRed = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
  final hslBlue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
  
  // Oklab Color Model (perceptually uniform)
  final oklabRed = RayOklab(l: 0.628, a: 0.225, b: 0.126);
  final oklabBlue = RayOklab(l: 0.452, a: -0.032, b: -0.312);
  
  // Convert between formats
  print(red.toHex());        // #FF0000
  print(red.toRGB());        // rgb(255, 0, 0)
  print(red.toRGBA());       // rgba(255, 0, 0, 1.00)
  
  // Convert between color models
  final rgbToHsl = red.toHsl();           // RGB → HSL
  final rgbToOklab = red.toOklab();       // RGB → Oklab
  final hslToRgb = hslRed.toRgb();        // HSL → RGB
  print('RGB Red as HSL: $rgbToHsl');     // RayHsl(0.0°, 100.0%, 50.0%)
  print('RGB Red as Oklab: $rgbToOklab'); // RayOklab(l: 0.628, a: 0.225, b: 0.126)
  
  // HSL color analysis
  final color1 = RayHsl(hue: 30, saturation: 0.8, lightness: 0.6);
  final color2 = RayHsl(hue: 150, saturation: 0.5, lightness: 0.4);
  print('Hue distance: ${color1.hueDistance(color2)}°');        // 120.0°
  print('Saturation diff: ${color1.saturationDifference(color2)}'); // -0.3
  
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
  final materialBlue = MaterialPalette.blue500.scheme.ray;
  final cssNavy = CssPalette.navy.scheme.ray;
  
  // Access components and calculations
  print('Red: ${red.red}, Alpha: ${red.alpha}');
  print('Luminance: ${red.computeLuminance()}');
}
```

## Hex Format Support

Supports both web standard (RGBA) and Flutter/Android (ARGB) hex formats:

```dart
// Web standard - alpha last (default)
final webColor = RayRgb.fromHex('#FF000080');  // Red with 50% alpha

// Flutter/Android - alpha first
final flutterColor = RayRgb.fromHex('#80FF0000', format: HexFormat.argb);

// Both rays create the same color
print(webColor == flutterColor);  // true
```

## Color Models

Prism supports multiple color models with seamless conversion:

### RayRgb (Red, Green, Blue)
```dart
// Create RGB colors
final red = RayRgb(red: 255, green: 0, blue: 0);
final blue = RayRgb.fromHex('#0000FF');
final green = RayRgb.fromARGB(255, 0, 255, 0);

// RGB-specific properties
print('Red: ${red.red}, Green: ${red.green}, Blue: ${red.blue}');
print('Alpha: ${red.alpha}, Opacity: ${red.opacity}');

// RGB-specific methods
final darkerRed = red.withAlpha(128);
```

### RayHsl (Hue, Saturation, Lightness)
```dart
// Create HSL colors
final red = RayHsl(hue: 0, saturation: 1.0, lightness: 0.5);
final blue = RayHsl(hue: 240, saturation: 1.0, lightness: 0.5);
final pastel = RayHsl(hue: 120, saturation: 0.3, lightness: 0.8, opacity: 0.7);

// HSL-specific properties  
print('Hue: ${red.hue}°, Saturation: ${red.saturation}, Lightness: ${red.lightness}');

// HSL-specific methods
final shifted = red.withHue(red.hue + 60);    // Hue shift
final vibrant = red.withSaturation(1.0);      // More saturated
final darker = red.withLightness(0.3);        // Darker

// HSL color analysis
final color1 = RayHsl(hue: 30, saturation: 0.8, lightness: 0.6);
final color2 = RayHsl(hue: 150, saturation: 0.5, lightness: 0.4);

// Signed differences (-180° to +180° for hue, -1.0 to +1.0 for s/l)
print('Hue difference: ${color1.hueDifference(color2)}°');           // 120.0°
print('Saturation difference: ${color1.saturationDifference(color2)}'); // -0.3
print('Lightness difference: ${color1.lightnessDifference(color2)}');   // -0.2

// Absolute distances (always positive)
print('Hue distance: ${color1.hueDistance(color2)}°');           // 120.0°
print('Saturation distance: ${color1.saturationDistance(color2)}'); // 0.3
print('Lightness distance: ${color1.lightnessDistance(color2)}');   // 0.2
```

### RayOklab (Perceptually Uniform Color Space)
```dart
// Create Oklab colors
final red = RayOklab(l: 0.628, a: 0.225, b: 0.126);
final green = RayOklab(l: 0.866, a: -0.234, b: 0.179);
final blue = RayOklab(l: 0.452, a: -0.032, b: -0.312);

// Convert from RGB to Oklab
final rgbRed = RayRgb(red: 255, green: 0, blue: 0);
final oklabRed = rgbRed.toOklab();

// Oklab-specific properties
print('L: ${red.l}, a: ${red.a}, b: ${red.b}');

// Perceptually uniform interpolation
final color1 = RayOklab(l: 0.5, a: 0.0, b: 0.0);
final color2 = RayOklab(l: 0.8, a: 0.1, b: -0.1);
final midpoint = color1.lerp(color2, 0.5);  // More perceptually accurate than RGB lerp

// Benefits of Oklab:
// - Better perceptual uniformity for gradients and color interpolation
// - More intuitive color manipulation
// - Improved color harmony calculations
```

### Seamless Conversion
```dart
// Convert between all color models
final rgbRed = RayRgb(red: 255, green: 0, blue: 0);
final hslRed = rgbRed.toHsl();              // RGB → HSL
final oklabRed = rgbRed.toOklab();          // RGB → Oklab
final backToRgb = hslRed.toRgb();           // HSL → RGB
final oklabToRgb = oklabRed.toRgb();        // Oklab → RGB

print(rgbRed == backToRgb);  // true - perfect round-trip conversion

// Universal base class methods work on all models
Ray anyColor = condition ? rgbRed : (anotherCondition ? hslRed : oklabRed);
final luminance = anyColor.computeLuminance();  // Works for all models
final scheme = RayScheme.fromRay(anyColor);     // Works for all models
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
final primaryBlue = CssPalette.blue.rayRgb;
final materialRed = MaterialPalette.red500.rayRgb;

// Get complete accessibility schemes
final blueScheme = CssPalette.blue.scheme;
final textColor = blueScheme.onRay;          // Optimal contrast color
final lightSurface = blueScheme.surfaceLight; // Light theme surface
final darkSurface = blueScheme.surfaceDark;   // Dark theme surface
```

## API Overview

### Constructors
- `RayRgb.fromHex(String)` - From hex string (#RGB, #RRGGBB, #RRGGBBAA)
- `RayRgb.fromARGB(int, int, int, int)` - From ARGB components
- `RayRgb.fromRGBO(int, int, int, double)` - From RGB + opacity
- `RayRgb.fromJson(int)` - From JSON integer

### Output Methods
- `toHex([int length, HexFormat format])` - To hex string
- `toRGB()` - To CSS rgb() string
- `toRGBA()` - To CSS rgba() string
- `toIntARGB()` - To ARGB integer
- `toIntRGBA()` - To RGBA integer

### Color Operations
- `withAlpha(int alpha)` - Copy with new alpha
- `withOpacity(double opacity)` - Copy with new opacity
- `lerp(RayRgb other, double t)` - Linear interpolation between rays
- `inverse` - Inverted color
- `computeLuminance()` - WCAG luminance calculation

### Properties
- `red`, `green`, `blue`, `alpha` - Component values (0-255)
- `opacity` - Alpha as double (0.0-1.0)

### Color Schemes (RayScheme)
- `RayScheme.fromRay(RayRgb)` - Create accessibility scheme from color
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