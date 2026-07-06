/// Flutter extensions for the Prism color manipulation library.
///
/// Provides conversion between [RayRgb8] and Flutter [Color] objects.
library;

export 'package:prism/prism.dart';

import 'dart:math' as math;
import 'package:prism/prism.dart';

import 'package:flutter/material.dart';

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

extension PrismPaletteFlutter on PrismPalette {
  /// Provides the ray's surface color for the themes brightness
  Ray surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;
}

/// Extension to render a [Beam] as a Flutter [LinearGradient].
extension BeamToFlutterGradient<T extends Ray> on Beam<T> {
  /// Densifies this beam into a Flutter [LinearGradient].
  ///
  /// Flutter interpolates gradient stops in sRGB on the GPU, so a perceptual
  /// (Oklch) beam is sampled at [resolution] evenly-spaced points via
  /// [colorAt] to approximate its true interpolation path. A flat beam yields
  /// two identical stops. The beam's [angle] is mapped to [begin]/[end]
  /// (CSS convention: 180° = top→bottom).
  LinearGradient toLinearGradient({int resolution = 16}) {
    assert(resolution >= 2, 'resolution must be at least 2');
    final n = isGradient ? resolution : 2;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      colors.add(colorAt(t).toColor());
      stops.add(t);
    }
    final end = _alignmentForAngle(angle);
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: Alignment(-end.x, -end.y),
      end: end,
    );
  }

  /// Maps a CSS-convention gradient [angleDeg] (180° = top→bottom) to the
  /// Flutter [Alignment] of the gradient's end point.
  static Alignment _alignmentForAngle(double angleDeg) {
    final r = angleDeg * math.pi / 180.0;
    return Alignment(math.sin(r), -math.cos(r));
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
