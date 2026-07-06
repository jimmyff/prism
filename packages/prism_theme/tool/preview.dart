// Generates an HTML preview of a compiled theme — the theme "showing its work".
//
//   dart run tool/preview.dart [output.html]
//
// Shows seeds, light/dark role swatches, the gradient canvas, a darkness-blend
// strip, and the full audit matrix (green = pass, red = fail, grey = advisory).
import 'dart:io';

import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';

/// The theme under preview — a Kosmos-like brand with a gradient dark sky.
final _source = PrismThemeSource(
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
  roles: const PrismRoles(
    surfaceRaised: PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.995, dark: 0.26),
      gradient: -0.05,
    ),
  ),
);

void main(List<String> args) {
  final pair = _source.compilePair();
  final out = args.isNotEmpty ? args.first : 'prism_theme_preview.html';
  File(out).writeAsStringSync(_html(pair));
  stdout.writeln('Wrote $out');
}

String _hex(RayOklch c) => c.toRgb8().toHex(8);

String _beamCss(Beam<RayOklch> beam) {
  if (!beam.isGradient) return _hex(beam.base);
  final stops = [for (var i = 0; i <= 8; i++) _hex(beam.colorAt(i / 8))];
  return 'linear-gradient(180deg, ${stops.join(', ')})';
}

String _html(PrismThemePair pair) {
  final b = StringBuffer();
  b.writeln('<!DOCTYPE html><html><head><meta charset="utf-8">');
  b.writeln('<title>prism_theme preview</title><style>');
  b.writeln('''
    body { font: 13px/1.5 -apple-system, system-ui, sans-serif;
           background: #0e0f13; color: #e8eaf0; margin: 0; padding: 32px; }
    h1 { font-size: 20px; } h2 { font-size: 15px; margin-top: 32px; }
    .grid { display: grid; gap: 8px;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); }
    .sw { border-radius: 8px; overflow: hidden; border: 1px solid #2a2c34; }
    .chip { height: 52px; }
    .meta { padding: 6px 8px; font-size: 11px; background: #17181d; }
    .meta b { display: block; font-size: 12px; }
    .mono { font-family: ui-monospace, monospace; color: #9aa0b0; }
    .strip { display: flex; height: 60px; border-radius: 8px; overflow: hidden; }
    .strip > div { flex: 1; }
    table { border-collapse: collapse; margin-top: 8px; font-size: 11px; }
    td, th { border: 1px solid #2a2c34; padding: 3px 7px; text-align: left; }
    .pass { color: #6fcf8e; } .fail { color: #ff6b6b; font-weight: bold; }
    .adv { color: #8a8f9e; }
  ''');
  b.writeln('</style></head><body>');
  b.writeln('<h1>prism_theme preview</h1>');

  b.writeln('<h2>Seeds</h2>');
  _seedGrid(b, pair.light.seeds);

  for (final theme in [pair.light, pair.dark]) {
    b.writeln('<h2>${theme.brightness.name} roles</h2>');
    b.writeln(
      '<div style="padding:12px;border-radius:8px;background:'
      '${_beamCss(theme.scheme.canvas)}">',
    );
    _roleGrid(b, theme);
    b.writeln('</div>');
  }

  b.writeln('<h2>Canvas (dark)</h2>');
  b.writeln(
    '<div class="strip" style="background:'
    '${_beamCss(pair.dark.scheme.canvas)}"></div>',
  );

  b.writeln('<h2>Fills (dark) — surface · surfaceRaised · chrome</h2>');
  b.writeln('<div class="strip">');
  for (final fill in [
    pair.dark.scheme.surface,
    pair.dark.scheme.surfaceRaised,
    pair.dark.scheme.chrome,
  ]) {
    b.writeln('<div style="background:${_beamCss(fill)}"></div>');
  }
  b.writeln('</div>');

  b.writeln('<h2>atDarkness(t) — surface · ink · action</h2>');
  b.writeln('<div class="strip">');
  for (var i = 0; i <= 10; i++) {
    final t = i / 10;
    final s = pair.atDarkness(t).scheme;
    b.writeln(
      '<div style="background:${_hex(s.surface.base)}">'
      '<div style="height:33%;background:${_hex(s.ink)}"></div>'
      '<div style="height:33%;background:${_hex(s.action.fill)}"></div>'
      '</div>',
    );
  }
  b.writeln('</div>');

  for (final theme in [pair.light, pair.dark]) {
    b.writeln('<h2>Audit matrix — ${theme.brightness.name}</h2>');
    _auditTable(b, theme);
  }

  b.writeln('</body></html>');
  return b.toString();
}

void _seedGrid(StringBuffer b, PrismSeeds seeds) {
  b.writeln('<div class="grid">');
  for (final seed in PrismSeed.values) {
    _swatch(b, seed.name, seeds[seed]);
  }
  b.writeln('</div>');
}

void _roleGrid(StringBuffer b, PrismTheme theme) {
  b.writeln('<div class="grid">');
  for (final role in PrismRole.values) {
    _swatch(b, role.name, theme.scheme.ray(role));
  }
  b.writeln('</div>');
}

void _swatch(StringBuffer b, String name, RayOklch c) {
  final oklch =
      'oklch(${c.lightness.toStringAsFixed(2)} '
      '${c.chroma.toStringAsFixed(3)} ${c.hue.toStringAsFixed(0)})';
  b.writeln(
    '<div class="sw"><div class="chip" style="background:${_hex(c)}">'
    '</div><div class="meta"><b>$name</b>'
    '<span class="mono">${_hex(c)}<br>$oklch</span></div></div>',
  );
}

void _auditTable(StringBuffer b, PrismTheme theme) {
  b.writeln(
    '<table><tr><th>role</th><th>on</th><th>ratio</th>'
    '<th>need</th><th></th></tr>',
  );
  for (final r in theme.audit()) {
    final cls = r.advisory ? 'adv' : (r.passes ? 'pass' : 'fail');
    final mark = r.advisory ? 'advisory' : (r.passes ? '✓' : '✗');
    b.writeln(
      '<tr class="$cls"><td>${r.foreground.name}</td>'
      '<td>${r.background}</td><td>${r.ratio.toStringAsFixed(2)}</td>'
      '<td>${r.required.toStringAsFixed(1)}</td><td>$mark</td></tr>',
    );
  }
  b.writeln('</table>');
}
