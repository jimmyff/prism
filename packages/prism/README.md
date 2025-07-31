# Prism 🌈

A high-performance color manipulation library for Dart & Flutter with multiple color models, accessibility-focused schemes, and pre-built palettes.

See [prism_flutter](https://pub.dev/packages/prism_flutter) which adds Flutter specific extensions.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism)
- [Package on Pub.dev](https://pub.dev/packages/prism)
- [Documentation](https://pub.dev/documentation/prism/latest/)
- [Flutter package](https://pub.dev/packages/prism_flutter)

## Features

- 🎨 **Multiple color models**: RGB, HSL, Oklab, and Oklch with seamless conversion
- 🎭 **Accessibility schemes**: WCAG-compliant color schemes with optimal contrast
- 🎨 **Pre-built palettes**: Material, CSS, Spectrum, and OpenColor palettes
- 📱 **Flutter compatible**: Perfect conversion to/from Flutter's Color class
- ⚡ **High performance**: Zero dependencies with optimized bit operations
- 🌐 **Web standards**: RGBA/ARGB hex format support


## Quick Start

```dart
import 'package:prism/prism.dart';

// Create and convert colors
final red = RayRgb.fromHex('#FF0000');
final redInOklch = red.toOklch();                 // Convert to perceptual color space
final darkRed = redInOklch.withLightness(0.3);    // Darken perceptually 
print(darkRed.toRgb().toHexStr());                // #521711

// Generate accessibility schemes
final scheme = RayScheme.fromRay(red);
final darkSurface = scheme.surfaceDark;           // Dark theme surface
final textColor = darkSurface.onRay;              // Optimal contrast color
```


## Color Models

Prism supports multiple color models with seamless conversion:

### RayRgb (Red, Green, Blue)
```dart
final red = RayRgb.fromHex('#FF0000');                 // From hex
final transparent = red.withOpacity(0.5);                // With transparency
final webHex = red.toHexStr();                           // Web standard: #FF0000
final flutterHex = red.toHexStr(format: HexFormat.argb); // Flutter: #FFFF0000
```

### RayHsl (Hue, Saturation, Lightness)
```dart
final orange = RayHsl(hue: 30, saturation: 0.8, lightness: 0.6);
final green = RayHsl(hue: 120, saturation: 0.5, lightness: 0.4);
final shifted = orange.withHue(orange.hue + 60);      // Hue shift
print('Hue distance: ${orange.hueDistance(green)}°'); // Color analysis: 90.0°
```

### RayOklab (Perceptually Uniform Color Space)
```dart
final rgbBlue = RayRgb.fromHex('#0000FF').toOklab(); // Direct LAB values
final rgbRed = RayRgb.fromHex('#FF0000').toOklab();  // Convert from RGB
final midpoint = rgbBlue.lerp(rgbRed, 0.5);            // Perceptually uniform interpolation
```

### RayOklch (Cylindrical Oklab with Intuitive Controls)
```dart
final baseColor = RayOklch(l: 0.7, c: 0.15, h: 120.0);      // Lightness, Chroma, Hue
final desaturated = baseColor.withChroma(0.05);             // Reduce saturation
final complementary = baseColor.withHue(baseColor.h + 180); // Complementary color
```

### Seamless Conversion
```dart
final rgbRed = RayRgb.fromHex('#FF0000');
final hslRed = rgbRed.toHsl();              // RGB → HSL
final oklchRed = rgbRed.toOklch();          // RGB → Oklch  
final backToRgb = hslRed.toRgb();           // HSL → RGB
```


## Performance

Optimized for performance with efficient bit operations, minimal allocations, and zero dependencies.

## Color Palettes

Prism includes extensive pre-built color palettes with accessibility-focused schemes:

### Available Palettes

#### Spectrum (Prim's own color palette)
![Spectrum Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Spectrum.png)

#### Material Colors
![Material Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Material.png)

#### Open Color
![Open Color Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/OpenColor.png)

#### CSS Colors  
![CSS Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Css.png)

CSS versions of all palettes are also available in the [palette_gallery/](https://github.com/jimmyff/prism/tree/main/palette_gallery/) directory for web development use.

### Usage

```dart
import 'package:prism/palettes/rgb/css.dart';
final primaryBlue = CssRgb.blue.source;
final blueScheme = CssRgb.blue.shade700;
```


## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.