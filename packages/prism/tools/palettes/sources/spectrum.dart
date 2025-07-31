import 'package:prism/prism.dart';

/// Material Design colors palette
/// Contains all Material Design colors as RayScheme objects
Map<String, RayScheme<RayWithLuminanceOklch>> spectrumColors = {
  // Red
  'red': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.2268,
    h: 24.87,
  )),
  'pink': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.2302,
    h: 5.28,
  )),
  'purple': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.334,
    h: 321.35,
  )),
  'violet': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.20,
    h: 297.66,
  )),
  'indigo': RayScheme.fromOklch(RayOklch(
    l: 0.6146,
    c: 0.2285,
    h: 279.28,
  )),
  'blue': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.1888,
    h: 248.81,
  )),
  'cyan': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.1501,
    h: 210.8169,
  )),
  'teal': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.1561,
    h: 183.38,
  )),
  'green': RayScheme.fromOklch(RayOklch(
    l: 0.65,
    c: 0.2,
    h: 144.21,
  )),
  'lime': RayScheme.fromOklch(RayOklch(
    l: 0.8,
    c: 0.21,
    h: 116.06,
  )),
  'yellow': RayScheme.fromOklch(
    RayOklch(
      l: 0.9116,
      c: 0.2016,
      h: 101.6,
    ),
    // hueTransform: (double hue, double lightnessDelta) =>
    //     hue + (lightnessDelta.clamp(-0.2, 0) * 200.0),
    // chromaTransform: (double chroma, double lightnessDelta) =>
    //     chroma * (1.0 - lightnessDelta.abs() * 0.5),
  ),
  'amber': RayScheme.fromOklch(RayOklch(
    l: 0.8369,
    c: 0.1947,
    h: 84.83,
  )),
  'tangerine': RayScheme.fromOklch(RayOklch(
    l: 0.7941,
    c: 0.1914,
    h: 64.05,
  )),
  'orange': RayScheme.fromOklch(RayOklch(
    l: 0.7147,
    c: 0.2274,
    h: 46.15,
  )),

  'brown': RayScheme.fromOklch(
    RayRgb.fromHex('#795548').toOklch(),
    generateAccents: false,
  ),
  'gray': RayScheme.fromOklch(
    RayRgb.fromHex('#9E9E9E').toOklch(),
    generateAccents: false,
  ),
  'blueGray': RayScheme.fromOklch(
    RayRgb.fromHex('#607D8B').toOklch(),
    generateAccents: false,
  ),
  'black': RayScheme.fromOklch(
    RayRgb.fromHex('#000000').toOklch(),
    generateAccents: false,
  ),
  'white': RayScheme.fromOklch(
    RayRgb.fromHex('#FFFFFF').toOklch(),
    generateAccents: false,
  ),
};
