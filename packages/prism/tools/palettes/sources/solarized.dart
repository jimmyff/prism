import 'package:prism/prism.dart';

/// Solarized color palette
/// A sixteen color palette designed for use with terminal and gui applications
Map<String, Ray> solarizedColors = {
  // Base colors (background and content tones)
  'base03': RayRgb.fromHex('#002b36'), // brblack - darkest background
  'base02': RayRgb.fromHex('#073642'), // black - dark background
  'base01': RayRgb.fromHex('#586e75'), // brgreen - light content
  'base00': RayRgb.fromHex('#657b83'), // bryellow - content
  'base0': RayRgb.fromHex('#839496'), // brblue - content
  'base1': RayRgb.fromHex('#93a1a1'), // brcyan - light content
  'base2': RayRgb.fromHex('#eee8d5'), // white - light background
  'base3': RayRgb.fromHex('#fdf6e3'), // brwhite - lightest background

  // Accent colors
  'yellow': RayRgb.fromHex('#b58900'),
  'orange': RayRgb.fromHex('#cb4b16'),
  'red': RayRgb.fromHex('#dc322f'),
  'magenta': RayRgb.fromHex('#d33682'),
  'violet': RayRgb.fromHex('#6c71c4'),
  'blue': RayRgb.fromHex('#268bd2'),
  'cyan': RayRgb.fromHex('#2aa198'),
  'green': RayRgb.fromHex('#859900'),
};
