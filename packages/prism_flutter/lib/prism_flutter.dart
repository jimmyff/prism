/// Flutter extensions for the Prism color manipulation library.
///
/// Provides seamless conversion between [RayRgb] and Flutter [Color] objects
/// with convenient extension methods for both directions.
library prism_flutter;

export 'package:prism/prism.dart';

import 'dart:ui';
import 'package:prism/prism.dart';

/// Extension methods for [RayRgb] to convert to Flutter [Color] objects.
extension RayToFlutterColor on RayRgb {
  /// Converts this [RayRgb] to a Flutter [Color].
  ///
  /// The conversion preserves all ARGB color information, providing
  /// perfect fidelity between Ray and Flutter Color representations.
  ///
  /// Example:
  /// ```dart
  /// final ray = RayRgb.fromHex('#FF0000');
  /// final flutterColor = ray.toColor();
  /// ```
  Color toColor() => Color(toIntARGB());

  /// Converts this [RayRgb] to a Flutter [Color] with a specific opacity.
  ///
  /// The [opacity] parameter should be in the range [0.0, 1.0].
  /// Values outside this range will be clamped to the valid range.
  /// This method preserves the original RGB values while replacing the alpha.
  ///
  /// Example:
  /// ```dart
  /// final ray = RayRgb.fromHex('#FF0000');
  /// final semiTransparent = ray.toColorWithOpacity(0.5);
  /// ```
  Color toColorWithOpacity(double opacity) =>
      Color.fromARGB((opacity.clamp(0.0, 1.0) * 255).round(), red, green, blue);
}

/// Extension methods for Flutter [Color] to convert to [RayRgb] objects.
extension FlutterColorToRay on Color {
  /// Converts this Flutter [Color] to a [RayRgb].
  ///
  /// The conversion preserves all ARGB color information, providing
  /// perfect fidelity between Flutter Color and Ray representations.
  ///
  /// Example:
  /// ```dart
  /// final flutterColor = Colors.red;
  /// final ray = flutterColor.toRay();
  /// ```
  RayRgb toRay() => RayRgb.fromIntARGB(toARGB32());
}
