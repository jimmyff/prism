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

// Create and convert colors
final red = RayRgb8.fromHex('#FF0000');
final redInOklch = red.toOklch();
final darkRed = redInOklch.withLightness(0.3);
print(darkRed.toRgb8().toHex()); // #521711

```

## Color Models

Prism supports multiple color models with seamless conversion:

### RayRgb8 & RayRgb16 (Red, Green, Blue)

```dart
final red8 = RayRgb8.fromHex('#FF0000');
final red16 = RayRgb16.fromComponents(220, 137, 180);
final transparent = red8.withOpacity(0.5);
print(red8.toHex()); // #FF0000
```

### RayHsl (Hue, Saturation, Lightness)

```dart
final orange = RayHsl.fromComponents(30, 0.8, 0.6);
final shifted = orange.withHue(orange.hue + 60);
print(orange.hueDistance(shifted)); // 60.0°
```

### RayOklab (Perceptually Uniform Color Space)

```dart
final blue = RayOklab.fromComponents(0.452, -0.032, -0.312);
final red = RayOklab.fromComponents(0.628, 0.225, 0.126);
final midpoint = blue.lerp(red, 0.5); // Perceptually uniform
final brighter = blue.withLightness(blue.lightness + 0.2);
```

### RayOklch (Cylindrical Oklab with Intuitive Controls)

```dart
final green = RayOklch.fromComponents(0.7, 0.15, 120.0);
final desaturated = green.withChroma(0.05);
final complementary = green.withHue(green.h + 180);
```

### Easy Conversion

```dart
final red = RayRgb8.fromHex('#FF0000');
final hsl = red.toHsl();    // RGB → HSL
final oklch = red.toOklch(); // RGB → Oklch
final back = hsl.toRgb8();  // HSL → RGB
```

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
