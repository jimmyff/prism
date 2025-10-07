# Prism 🌈

An optimized, zero-dependency color manipulation library for Dart & Flutter with multiple color models, accessibility tools, and pre-built palettes.

See [prism_flutter](https://pub.dev/packages/prism_flutter) which adds Flutter specific extensions.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism)
- [Package on Pub.dev](https://pub.dev/packages/prism)
- [Documentation](https://pub.dev/documentation/prism/latest/)
- [Flutter package](https://pub.dev/packages/prism_flutter)

## Features

- 🎨 **Multiple color models**: RGB (8-bit & 16-bit), HSL, Oklab, and Oklch with seamless conversion
- 🎭 **Accessibility schemes**: WCAG-compliant color schemes with optimal contrast
- 🎨 **Pre-built palettes**: Material, CSS, Rainbow, and OpenColor palettes
- 📱 **Flutter compatible**: Perfect conversion to/from Flutter's Color class
- ⚡ **High performance**: Zero dependencies with optimized bit operations 
- 🌐 **Web standards**: RGBA/ARGB hex format support

## Quick Start

```dart
import 'package:prism/prism.dart';

// Parse, convert, and manipulate colors
final red = Ray.parse('#FF0000');
final darkRed = red.toOklch().withLightness(0.3);
print(darkRed.toRgb8().toHex()); // #521711

```

## Color Models

Prism supports multiple color models with seamless conversion:

### RayRgb8 & RayRgb16 (Red, Green, Blue)

```dart
final red = Ray.parse('#FF0000');
final transparent = red.withOpacity(0.5);
print(transparent.toHex(8)); // #FF000080
```

### RayHsl (Hue, Saturation, Lightness)

```dart
final orange = Ray.parse('hsl(30, 80%, 60%)');
final shifted = orange.withHue(orange.hue + 60); // Shift hue by 60°
```

### RayOklab (Perceptually Uniform Color Space)

```dart
final blue = Ray.parse('oklch(0.45 0.31 264)').toOklab();
final red = Ray.parse('#FF0000').toOklab();
final midpoint = blue.lerp(red, 0.5); // Perceptually smooth gradient
```

### RayOklch (Cylindrical Oklab with Intuitive Controls)

```dart
final green = Ray.parse('oklch(0.7 0.15 120)');
final darker = green.withLightness(0.3);    // Adjust brightness
final vibrant = green.withChroma(0.25);     // Adjust saturation
```

### Easy Conversion

```dart
final red = Ray.parse('#FF0000');
final hsl = red.toHsl();      // RGB → HSL
final oklch = red.toOklch();  // RGB → Oklch
final back = hsl.toRgb8();    // HSL → RGB
```

## Parsing Color Strings

Parse color strings with automatic format detection:

```dart
final color = Ray.parse('#FF0000');              // Hex → RayRgb8
final color = Ray.parse('rgb(255, 0, 0)');       // CSS RGB → RayRgb8
final color = Ray.parse('hsl(120, 100%, 50%)'); // CSS HSL → RayHsl
final color = Ray.parse('oklch(0.6 0.2 300)');  // CSS Oklch → RayOklch

// Or use type-specific parsing
final rgb = RayRgb8.parse('rgba(255, 0, 0, 0.5)');
```

Supports modern and legacy CSS syntax, hex formats, and alpha channels.

## Performance

Optimized for performance with efficient bit operations (in RayRgb8), minimal allocations, and zero dependencies.

_Note: RayRgb16 uses component arrays instead of bit operations for web compatibility (JavaScript lacks 64-bit integer support). Future platform-specific optimizations planned when Flutter adds 16-bit color support._

## Color Palettes

Prism includes extensive pre-built color palettes with accessibility-focused schemes:

### Available Palettes

#### Rainbow (Prism's own color palette)

![Rainbow Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Rainbow.png)

#### Material Colors

![Material Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Material.png)

#### Open Color

![Open Color Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/OpenColor.png)

#### CSS Colors  

![CSS Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Css.png)

CSS versions of all palettes are also available in the [palette_gallery/](https://github.com/jimmyff/prism/tree/main/palette_gallery/) directory for web development use.

### Usage

```dart
import 'package:prism/palettes/rgb/rainbow.dart';
final primaryBlue = RainbowRgb.blue.source;
final darkBlue = RainbowRgb.blue.shade700;
```

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.

For an introduction to Prsim see [Jimmy's blog post](https://www.jimmyff.co.uk/blog/prism-dart-flutter-color-package/).
