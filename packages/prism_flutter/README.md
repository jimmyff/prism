# Prism Flutter 🌈

Flutter extensions for the [Prism](https://pub.dev/packages/prism) color manipulation library. Provides conversion between `RayRgb8` and Flutter `Color` objects.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism_flutter)
- [Package on Pub.dev](https://pub.dev/packages/prism_flutter)
- [Documentation](https://pub.dev/documentation/prism_flutter/latest/)
- [Core Prism Package](https://pub.dev/packages/prism)

## Features

- 🔄 **Easy conversion**: Extensions for `RayRgb8` ↔ `Color` conversion
- 🎨 **Full ARGB support**: Perfect fidelity round-trip conversions
- ⚡ **Zero overhead**: Direct value conversions
- 🌈 **Enhanced manipulation**: Access Prism's color operations from Flutter Colors

## Quick Start

```dart
import 'package:prism_flutter/prism_flutter.dart';

// Convert RayRgb8 to Flutter Color
final ray = RayRgb8.fromHex('#FF0000');
final color = ray.toColor();

// Convert Flutter Color to RayRgb8
final backToRay = Colors.red.toRayRgb8();
```

## Usage

### RayRgb8 to Flutter Color

```dart
final red = RayRgb8.fromHex('#FF0000');
final color = red.toColor();
final transparent = red.toColorWithOpacity(0.5);
```

### Flutter Color to RayRgb8

```dart
final color = Colors.blue;
final ray = color.toRayRgb8();
```

### Enhanced Color Operations

```dart
// Chain operations using both Flutter and Prism methods
final result = Colors.red
    .toRayRgb8()
    .withOpacity(0.8)
    .lerp(Colors.blue.toRayRgb8(), 0.3)
    .toColor();

// Generate accessibility schemes
final scheme = Spectrum.fromRay(Colors.blue.toRayRgb8());
final textColor = scheme.source.onRay.toColor();
```

## Color Palettes

Access pre-built color palettes with Flutter integration:

![Material Palette](https://raw.githubusercontent.com/jimmyff/prism/refs/heads/main/palette_gallery/Material.png)

```dart
import 'package:prism_flutter/prism_flutter.dart';
import 'package:prism/palettes/rgb/material.dart';

final materialBlue = MaterialRgb.blue.shade500.toColor();
final primaryColor = MaterialRgb.indigo.source.toColor();
```

## API Reference

### RayRgb8 Extensions
- `toColor()` - Convert to Flutter Color
- `toColorWithOpacity(double opacity)` - Convert with specific opacity

### Flutter Color Extensions  
- `toRayRgb8()` - Convert to RayRgb8

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.

For an introduction to Prism see [Jimmy's blog post](https://www.jimmyff.co.uk/blog/prism-dart-flutter-color-package/).