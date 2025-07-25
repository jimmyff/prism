# Prism Flutter 🌈

Flutter extensions for the [Prism](https://pub.dev/packages/prism) color manipulation library.

Seamlessly convert between `RayRgb` and Flutter `Color` objects with intuitive extension methods.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism_flutter)
- [Package on Pub.dev](https://pub.dev/packages/prism_flutter)
- [Documentation](https://pub.dev/documentation/prism_flutter/latest/)
- [Dart Package](https://pub.dev/packages/prism)

## Features

- 🔄 **Seamless conversion**: Extensions for both `RayRgb` → `Color` and `Color` → `RayRgb`
- 🎨 **Perfect fidelity**: Preserves all ARGB color information
- ⚡ **Zero overhead**: Direct value conversions with no performance cost
- 🔧 **Enhanced manipulation**: Access RayRgb's powerful color operations from Flutter Colors
- 🎯 **Type safe**: Comprehensive API with proper error handling


## Usage

### RayRgb to Flutter Color

```dart
import 'package:prism_flutter/prism_flutter.dart';

// Convert RayRgb to Flutter Color
final ray = RayRgb.fromHex('#FF0000');
final color = ray.toColor();

// Convert with specific opacity
final semiTransparent = ray.toColorWithOpacity(0.5);
```

### Flutter Color to RayRgb

```dart
import 'package:flutter/material.dart';
import 'package:prism_flutter/prism_flutter.dart';

// Convert Flutter Color to RayRgb
final color = Colors.red;
final ray = color.toRayRgb();

```

### Enhanced Color Manipulation

```dart
// Chain RayRgb operations on Flutter Colors
final result = Colors.red
    .toRayRgb()
    .withOpacity(0.8)
    .lerp(Colors.blue.toRayRgb(), 0.3)
    .inverse
    .toColor();

// Create accessibility schemes from Flutter Colors
final scheme = RayScheme.fromRay(Colors.blue);
final textColor = scheme.onRayRgb.toColor();        // Optimal contrast
final darkSurface = scheme.surfaceDark.toColor(); // Dark theme surface

// Use pre-built palettes with Flutter
final materialBlue = MaterialRgb.blue500.rayRgb.toColor();
final cssRed = CssRgb.red.rayRgb.toColor();

// Access RayRgb analysis methods
final luminance = Colors.grey.toRayRgb().computeLuminance();
final bestContrast = Colors.grey.toRayRgb().maxContrast(
  Colors.black.toRayRgb(),
  Colors.white.toRayRgb(),
);
```

### Perfect Round-Trip Conversions

```dart
// RayRgb → Color → RayRgb maintains perfect fidelity
final originalRay = RayRgb.fromHex('#7F123456');
final color = originalRay.toColor();
final backToRay = color.toRayRgb();
assert(backToRay == originalRay); // ✅ Always true

// Color → RayRgb → Color maintains perfect fidelity
const originalColor = Color(0x7F123456);
final ray = originalColor.toRayRgb();
final backToColor = ray.toColor();
assert(backToColor == originalColor); // ✅ Always true
```

## API Reference

### RayRgb Extensions

- `toColor()` - Convert RayRgb to Flutter Color
- `toColorWithOpacity(double opacity)` - Convert RayRgb to Flutter Color with specific opacity

### Flutter Color Extensions

- `toRayRgb()` - Convert Flutter Color to RayRgb


All conversions preserve complete ARGB color information with perfect fidelity.

## Related Packages

- [prism](https://pub.dev/packages/prism) - The core color manipulation library

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.