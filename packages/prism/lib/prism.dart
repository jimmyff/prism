export 'src/ray_base.dart';
export 'src/ray_rgb.dart';
export 'src/ray_hsl.dart';
export 'src/ray_oklab.dart';
export 'src/ray_oklch.dart';
export 'src/ray_scheme.dart';

import 'src/ray_base.dart';
import 'src/ray_scheme.dart';

abstract class PrismPalette {
  abstract final RayScheme<Ray> scheme;
}
