// Run with: dart run example/example.dart
//
// Dumps a compiled theme's roles (light + dark), shows an atDarkness transition
// sample, and round-trips a PrismThemeSelection — the "theme showing its work".
import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';

void main() {
  // An authored document: brand seeds + a Kosmos-like gradient dark sky.
  final source = PrismThemeSource(
    seeds: PrismSeeds(
      primary: RayOklch.fromComponents(0.55, 0.16, 264),
      secondary: RayOklch.fromComponents(0.60, 0.13, 200),
      tertiary: RayOklch.fromComponents(0.62, 0.14, 320),
    ),
    canvas: (
      light: Beam.flat(RayOklch.fromComponents(0.985, 0.004, 264)),
      dark: Beam.linear([
        RayOklch.fromComponents(0.16, 0.06, 300),
        RayOklch.fromComponents(0.22, 0.08, 262),
      ]),
    ),
  );

  final pair = source.compilePair();

  print('== LIGHT ==');
  _dumpRoles(pair.light);
  print('\n== DARK ==');
  _dumpRoles(pair.dark);

  print(
    '\n== atDarkness(0.5) — transition sample (a motion frame, not parked) ==',
  );
  print('  surface: ${_fmt(pair.atDarkness(0.5).scheme.surface.base)}');

  print('\n== gamut-clamp deltas (dark) ==');
  pair.dark.scheme.clampDeltas.forEach((role, delta) {
    print('  ${role.name.padRight(16)} -${delta.toStringAsFixed(4)} chroma');
  });

  print('\n== audit (dark), failures only ==');
  final failures = pair.dark.audit().where((r) => !r.passes).toList();
  print(
    failures.isEmpty ? '  all pass' : failures.map((r) => '  $r').join('\n'),
  );

  print('\n== resolve seam — an app-domain color through a role transform ==');
  const inkSpec = PrismRoleSpec(
    PrismSeed.primary,
    l: (light: 0.44, dark: 0.80),
  );
  final planet = RayOklch.fromComponents(0.62, 0.15, 30); // e.g. a Mars-orange
  final resolved = inkSpec.resolve(planet, PrismBrightness.dark);
  print('  planet ${_fmt(planet)}  ->  ink ${_fmt(resolved.color)}');

  print('\n== absolute role — a fixed color pinned as an inline seed ==');
  final brandSurface = PrismThemeSource(
    seeds: source.seeds,
    roles: PrismRoles(
      surface: PrismRoleSpec.absolute(
        RayOklch.fromComponents(0.95, 0.03, 150),
        l: (light: 0.95, dark: 0.20),
      ),
    ),
  ).compile(PrismBrightness.light);
  print('  surface ${_fmt(brandSurface.scheme.surface.base)}');

  print('\n== PrismThemeSelection round-trip ==');
  const selection = PrismThemeSelection(
    sourceId: 'kosmos',
    brightness: PrismBrightness.dark,
  );
  final restored = PrismThemeSelection.fromJson(selection.toJson());
  print('  ${selection.toJson()}');
  print('  restored == original: ${restored == selection}');
}

void _dumpRoles(PrismTheme theme) {
  print('  canvas.base: ${_fmt(theme.scheme.canvas.base)}');
  for (final role in PrismRole.values) {
    print('  ${role.name.padRight(16)} ${_fmt(theme.scheme.ray(role))}');
  }
}

String _fmt(RayOklch c) {
  final hex = c.toRgb8().toHex(8);
  final oklch =
      'oklch(${c.lightness.toStringAsFixed(3)} '
      '${c.chroma.toStringAsFixed(3)} ${c.hue.toStringAsFixed(0)})';
  final alpha = c.opacity == 1.0 ? '' : ' @${c.opacity.toStringAsFixed(2)}';
  return '${oklch.padRight(26)} $hex$alpha';
}
