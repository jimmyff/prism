import 'package:prism/prism.dart';

/// Material Design colors palette
/// Contains all Material Design colors as RayScheme objects
Map<String, RayScheme> spectrumColors = {
  // Red
  'red': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.2268,
    h: 24.87,
  )),
  'pink': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.2302,
    h: 5.28,
  )),
  'purple': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.334,
    h: 321.35,
  )),
  'violet': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.20,
    h: 297.66,
  )),
  'indigo': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.6146,
    c: 0.2285,
    h: 279.28,
  )),
  'blue': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.1888,
    h: 248.81,
  )),
  'cyan': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.1501,
    h: 210.8169,
  )),
  'teal': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.1561,
    h: 183.38,
  )),
  'green': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.65,
    c: 0.2,
    h: 144.21,
  )),
  'lime': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.8,
    c: 0.21,
    h: 116.06,
  )),
  'yellow': RayScheme<RayOklch>.fromRay(
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
  'amber': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.8369,
    c: 0.1947,
    h: 84.83,
  )),
  'tangerine': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.7941,
    c: 0.1914,
    h: 64.05,
  )),
  'orange': RayScheme<RayOklch>.fromRay(RayOklch(
    l: 0.7147,
    c: 0.2274,
    h: 46.15,
  )),

  'brown': RayScheme<RayOklab>.fromRay(
    RayRgb.fromHex('#795548').toOklab(),
    generateAccents: false,
  ),
  'gray': RayScheme<RayOklab>.fromRay(
    RayRgb.fromHex('#9E9E9E').toOklab(),
    generateAccents: false,
  ),
  'blueGray': RayScheme<RayOklab>.fromRay(
    RayRgb.fromHex('#607D8B').toOklab(),
    generateAccents: false,
  ),
  'black': RayScheme<RayOklab>.fromRay(
    RayRgb.fromHex('#000000').toOklab(),
    generateAccents: false,
  ),
  'white': RayScheme<RayOklab>.fromRay(
    RayRgb.fromHex('#FFFFFF').toOklab(),
    generateAccents: false,
  ),
};
