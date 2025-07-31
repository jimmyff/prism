import 'package:prism/prism.dart';

final base = RayOklch.validated(l: 0.50, c: 0.3, h: 0);
final offset = 8;
var structure = [
  (name: 'pink', lightness: 0.62, bright: false),
  (name: 'crimson', lightness: 0.6, bright: false),
  (name: 'red', lightness: 0.61, bright: false),
  (name: 'rust', lightness: 0.65, bright: false),
  (name: 'orange', lightness: 0.67, bright: false),
  (name: 'amber', lightness: 0.83, bright: true),
  (name: 'yellow', lightness: 0.92, bright: true),
  (name: 'lemon', lightness: 0.88, bright: true),
  (name: 'lime', lightness: 0.79, bright: true),
  (name: 'green', lightness: 0.69, bright: false),
  (name: 'emerald', lightness: 0.63, bright: false),
  (name: 'teal', lightness: 0.6, bright: false),
  (name: 'turquoise', lightness: 0.75, bright: true),
  (name: 'cyan', lightness: 0.8, bright: true),
  (name: 'cerulean', lightness: 0.66, bright: false),
  (name: 'azure', lightness: 0.65, bright: false),
  (name: 'sky', lightness: 0.63, bright: false),
  (name: 'blue', lightness: 0.61, bright: false),
  (name: 'indigo', lightness: 0.55, bright: false),
  (name: 'berry', lightness: 0.57, bright: false),
  (name: 'violet', lightness: 0.62, bright: false),
  (name: 'purple', lightness: 0.62, bright: false),
  (name: 'fuchsia', lightness: 0.65, bright: true),
  (name: 'magenta', lightness: 0.61, bright: false),
];

var structureFilled = List.generate(
    24,
    (i) => i < structure.length
        ? structure[i]
        : (name: "filled_$i", lightness: 0.6, bright: false));

Map<String, RayScheme<RayWithLuminanceOklch>> spectrumColors = Map.fromEntries([
  ...structureFilled.map((e) => MapEntry(
      e.name,
      RayScheme.fromOklch(e.bright
          ? base
              .withHue(offset +
                  (structureFilled.indexOf(e) * (360 / structureFilled.length)))
              .withLightness(e.lightness)
          : base.withLightness(e.lightness).withHue(offset +
              (structureFilled.indexOf(e) * (360 / structureFilled.length)))))),
  MapEntry(
      'neutralCool',
      RayScheme.fromOklch(
        RayOklch.validated(l: 0.55, c: 0.023, h: 250.0),
        generateAccents: false,
      )),
  MapEntry(
      'neutral',
      RayScheme.fromOklch(
        RayOklch.validated(l: 0.55, c: 0.0, h: 0.0),
        generateAccents: false,
      )),
  MapEntry(
      'neutralWarm',
      RayScheme.fromOklch(
        RayOklch.validated(l: 0.55, c: 0.018, h: 40.0),
        generateAccents: false,
      )),
]);
