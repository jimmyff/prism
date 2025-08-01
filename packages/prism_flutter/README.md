# Prism Flutter 🌈

Flutter extensions for the [Prism](https://pub.dev/packages/prism) color manipulation library.

Seamlessly convert between `RayRgb8`/`RayRgb16` and Flutter `Color` objects with intuitive extension methods.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism_flutter)
- [Package on Pub.dev](https://pub.dev/packages/prism_flutter)
- [Documentation](https://pub.dev/documentation/prism_flutter/latest/)
- [Dart Package](https://pub.dev/packages/prism)

## Features

- 🔄 **Seamless conversion**: Extensions for both `RayRgb8` → `Color` and `Color` → `RayRgb8`
- 🎨 **Perfect fidelity**: Preserves all ARGB color information
- ⚡ **Zero overhead**: Direct value conversions with no performance cost
- 🔧 **Enhanced manipulation**: Access RayRgb8's powerful color operations from Flutter Colors
- 🎯 **Type safe**: Comprehensive API with proper error handling


## Usage

### RayRgb8 to Flutter Color

```dart
import 'package:prism_flutter/prism_flutter.dart';

// Convert RayRgb8 to Flutter Color
final ray = RayRgb8.fromHex('#FF0000');
final color = ray.toColor();

// Convert with specific opacity
final semiTransparent = ray.toColorWithOpacity(0.5);
```

### Flutter Color to RayRgb8

```dart
import 'package:flutter/material.dart';
import 'package:prism_flutter/prism_flutter.dart';

// Convert Flutter Color to RayRgb8
final color = Colors.red;
final ray = color.toRayRgb8();

```

### Enhanced Color Manipulation

```dart
// Chain RayRgb8 operations on Flutter Colors
final result = Colors.red
    .toRayRgb8()
    .withOpacity(0.8)
    .lerp(Colors.blue.toRayRgb8(), 0.3)
    .inverse
    .toColor();

// Create accessibility schemes from Flutter Colors
final scheme = RayScheme.fromRay(Colors.blue.toRayRgb8());
final textColor = scheme.source.onRay.toColor();     // Optimal contrast
final darkSurface = scheme.surfaceDark.toColor();    // Dark theme surface

// Use pre-built palettes with Flutter
final materialBlue = MaterialRgb.blue.shade500?.toColor();
final cssRed = CssRgb.red.source.toColor();

// Access RayRgb8 analysis methods
final luminance = Colors.grey.toRayRgb8().computeLuminance();
final bestContrast = Colors.grey.toRayRgb8().maxContrast(
  Colors.black.toRayRgb8(),
  Colors.white.toRayRgb8(),
);
```

### Perfect Round-Trip Conversions

```dart
// RayRgb8 → Color → RayRgb8 maintains perfect fidelity
final originalRay = RayRgb8.fromHex('#7F123456');
final color = originalRay.toColor();
final backToRay = color.toRayRgb8();
assert(backToRay == originalRay); // ✅ Always true

// Color → RayRgb8 → Color maintains perfect fidelity
const originalColor = Color(0x7F123456);
final ray = originalColor.toRayRgb8();
final backToColor = ray.toColor();
assert(backToColor == originalColor); // ✅ Always true
```

## API Reference

### RayRgb8 Extensions

- `toColor()` - Convert RayRgb8 to Flutter Color
- `toColorWithOpacity(double opacity)` - Convert RayRgb8 to Flutter Color with specific opacity

### Flutter Color Extensions

- `toRayRgb8()` - Convert Flutter Color to RayRgb8


All conversions preserve complete ARGB color information with perfect fidelity.

## Related Packages

- [prism](https://pub.dev/packages/prism) - The core color manipulation library

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.