import 'package:prism/prism.dart';

/// Clamps [t] to `[0, 1]`.
///
/// The single choke point for the package's interpolation invariant: Flutter
/// animation curves can overshoot (t < 0 or t > 1), and [RayOklch.lerp] throws
/// outside `[0, 1]`. Every `lerp`/`colorAt` in prism_theme routes through this,
/// so the guarantee is structural rather than repeated per call site.
double clampT(double t) => t.clamp(0.0, 1.0);

/// Linearly interpolates two doubles with [t] clamped to `[0, 1]`.
double lerpDouble(double a, double b, double t) => a + (b - a) * clampT(t);

/// Interpolates two Oklch colors with [t] clamped to `[0, 1]`.
RayOklch lerpRay(RayOklch a, RayOklch b, double t) => a.lerp(b, clampT(t));
