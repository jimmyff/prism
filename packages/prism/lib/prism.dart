export 'src/ray_base.dart';
export 'src/ray_rgb_base.dart';
export 'src/ray_rgb8.dart';
export 'src/ray_rgb16.dart';
export 'src/ray_hsl.dart';
export 'src/ray_oklab.dart';
export 'src/ray_oklch.dart';
export 'src/ray_scheme.dart';

import 'src/ray_scheme.dart';

abstract class PrismPalette implements RayScheme<RayWithLuminanceBase> {
  // Palette enums now implement RayScheme directly for RGB-based schemes
  // This eliminates the need for .scheme property wrapper
}
