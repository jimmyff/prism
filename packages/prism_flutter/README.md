# Prism Flutter 🌈

Flutter extensions for the [Prism](https://pub.dev/packages/prism) color manipulation library.

Seamlessly convert between `Ray` and Flutter `Color` objects with intuitive extension methods.

## Resources

- [Repository on GitHub](https://github.com/jimmyff/prism/tree/main/packages/prism_flutter)
- [Package on Pub.dev](https://pub.dev/packages/prism_flutter)
- [Documentation](https://pub.dev/documentation/prism_flutter/latest/)
- [Pure Dart package](https://pub.dev/packages/prism)

## Features

- 🔄 **Seamless conversion**: Extensions for both `Ray` → `Color` and `Color` → `Ray`
- 🎨 **Perfect fidelity**: Preserves all ARGB color information
- ⚡ **Zero overhead**: Direct value conversions with no performance cost
- 🔧 **Enhanced manipulation**: Access Ray's powerful color operations from Flutter Colors
- 🎯 **Type safe**: Comprehensive API with proper error handling

## Installation

Add both packages to your `pubspec.yaml`:

```yaml
dependencies:
  prism: ^1.0.0
  prism_flutter: ^1.0.0
```

## Usage

### Ray to Flutter Color

```dart
import 'package:prism_flutter/prism_flutter.dart';

// Convert Ray to Flutter Color
final ray = Ray.fromHex('#FF0000');
final color = ray.toColor();

// Convert with specific opacity
final semiTransparent = ray.toColorWithOpacity(0.5);
```

### Flutter Color to Ray

```dart
import 'package:flutter/material.dart';
import 'package:prism_flutter/prism_flutter.dart';

// Convert Flutter Color to Ray
final color = Colors.red;
final ray = color.toRay();

```

### Enhanced Color Manipulation

```dart
// Chain Ray operations on Flutter Colors
final result = Colors.red
    .toRay()
    .withOpacity(0.8)
    .lerp(Colors.blue.toRay(), 0.3)
    .inverse
    .toColor();

// Use Ray analysis methods
final luminance = Colors.grey.toRay().computeLuminance();
final bestContrast = Colors.grey.toRay().maxContrast(
  Colors.black.toRay(),
  Colors.white.toRay(),
);
```

### Perfect Round-Trip Conversions

```dart
// Ray → Color → Ray maintains perfect fidelity
final originalRay = Ray.fromHex('#7F123456');
final color = originalRay.toColor();
final backToRay = color.toRay();
assert(backToRay == originalRay); // ✅ Always true

// Color → Ray → Color maintains perfect fidelity
const originalColor = Color(0x7F123456);
final ray = originalColor.toRay();
final backToColor = ray.toColor();
assert(backToColor == originalColor); // ✅ Always true
```

## API Reference

### Ray Extensions

- `toColor()` - Convert Ray to Flutter Color
- `toColorWithOpacity(double opacity)` - Convert Ray to Flutter Color with specific opacity

### Flutter Color Extensions

- `toRay()` - Convert Flutter Color to Ray


All conversions preserve complete ARGB color information with perfect fidelity.

## Related Packages

- [prism](https://pub.dev/packages/prism) - The core color manipulation library

## License

MIT License © 2025 [Jimmy Forrester-Fellowes](https://github.com/jimmyff) - see LICENSE file for details.