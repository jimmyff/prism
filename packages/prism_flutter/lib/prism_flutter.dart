/// Flutter extensions for the Prism color manipulation library.
///
/// Provides conversion between [RayRgb8] and Flutter [Color] objects.
library prism_flutter;

export 'package:prism/prism.dart';

import 'dart:ui';
import 'package:prism/prism.dart';

/// Extension methods for [Ray] to convert to Flutter [Color] objects.
extension RayToFlutterColor on Ray {
  /// Converts this [RayRgb8] to a Flutter [Color].
  ///
  /// ```dart
  /// final ray = RayRgb8.fromHex('#FF0000');
  /// final color = ray.toColor();
  /// ```
  Color toColor() => Color(toRgb8().toArgbInt());

  /// Converts this [Ray] to a Flutter [Color] with specific opacity.
  ///
  /// ```dart
  /// final ray = RayRgb8.fromHex('#FF0000');
  /// final transparent = ray.toColorWithOpacity(0.5);
  /// ```
  Color toColorWithOpacity(double opacity) {
    final rgb = toRgb8();
    return Color.fromARGB(
      (opacity.clamp(0.0, 1.0) * 255).round(),
      rgb.red.round(),
      rgb.green.round(),
      rgb.blue.round(),
    );
  }
}

/// Extension methods for Flutter [Color] to convert to [RayRgb8] objects.
extension FlutterColorToRay on Color {
  /// Converts this Flutter [Color] to a [RayRgb8].
  ///
  /// ```dart
  /// final color = Colors.red;
  /// final ray = color.toRayRgb8();
  /// ```
  RayRgb8 toRayRgb8() => RayRgb8.fromArgbInt(toARGB32());
}
