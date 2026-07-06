import 'dart:math' as math;

import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  PrismSeeds brand() => PrismSeeds(
    primary: ok(0.5, 0.15, 264),
    secondary: ok(0.55, 0.13, 200),
    tertiary: ok(0.6, 0.12, 320),
  );

  List<PrismAuditResult> hardFailures(PrismTheme theme) =>
      theme.audit().where((r) => !r.passes && !r.advisory).toList();

  group('audit — mechanism', () {
    test('composited-alpha ratio matches a hand-computed value', () {
      final theme = PrismThemeSource(
        seeds: brand(),
      ).compile(PrismBrightness.light);
      final s = theme.scheme;
      final composited = s.composite(s.inkMuted, s.surface.base);
      final expected = composited.contrastRatio(s.surface.base);
      final result = theme.audit().firstWhere(
        (r) => r.foreground == PrismRole.inkMuted && r.background == 'surface',
      );
      expect(result.ratio, closeTo(expected, 1e-9));
    });

    test('broken theme (inkMuted alpha 0.2) fails, naming the pair', () {
      final broken = PrismThemeSource(
        seeds: brand(),
        roles: const PrismRoles(
          inkMuted: PrismRoleSpec(
            PrismSeed.neutral,
            l: (light: 0.20, dark: 0.95),
            alpha: 0.2,
          ),
        ),
      ).compile(PrismBrightness.light);
      final fail = hardFailures(
        broken,
      ).firstWhere((r) => r.foreground == PrismRole.inkMuted);
      expect(fail.toString(), contains('inkMuted'));
      expect(fail.toString(), contains('FAIL'));
    });
  });

  group('audit — gradient canvas interior crossover', () {
    test('min-of-samples catches an interior crossover an endpoint miss', () {
      final canvas = Beam.linear([ok(0.2, 0, 0), ok(0.8, 0, 0)]);
      final src = PrismThemeSource(
        seeds: brand(),
        canvas: (light: canvas, dark: canvas),
        // Force ink to a mid lightness that the canvas span straddles.
        roles: const PrismRoles(
          ink: PrismRoleSpec(PrismSeed.neutral, l: (light: 0.5, dark: 0.5)),
        ),
      );
      final theme = src.compile(PrismBrightness.light);
      final inkVsCanvas = theme.audit().firstWhere(
        (r) => r.foreground == PrismRole.ink && r.background == 'canvas',
      );

      // What a naive endpoint-only audit would have measured.
      final ink = theme.scheme.ink;
      final endpointMin = math.min(
        ink.contrastRatio(canvas.colorAt(0)),
        ink.contrastRatio(canvas.colorAt(1)),
      );

      expect(inkVsCanvas.ratio, lessThan(endpointMin)); // interior is worse
      expect(inkVsCanvas.ratio, closeTo(1.0, 0.3)); // crossover ≈ 1
      expect(inkVsCanvas.passes, isFalse);
    });
  });

  group('audit — translucent fill flattening', () {
    test('a frosted surface is flattened over canvas before measuring', () {
      final theme = PrismThemeSource(
        seeds: brand(),
        // Dark canvas, so a translucent light panel visibly composites down.
        canvas: (
          light: Beam.flat(ok(0.16, 0.0, 264)),
          dark: Beam.flat(ok(0.16, 0.0, 264)),
        ),
        roles: const PrismRoles(
          surface: PrismRoleSpec(
            PrismSeed.neutral,
            l: (light: 0.90, dark: 0.90),
            alpha: 0.35,
          ),
        ),
      ).compile(PrismBrightness.light);
      final s = theme.scheme;

      final flattened = s.composite(s.surface.base, s.canvas.base);
      final expected = s.ink.contrastRatio(
        flattened,
      ); // composite-then-contrast
      final naive = s.ink.contrastRatio(s.surface.base); // unflattened (wrong)

      final row = theme.audit().firstWhere(
        (r) => r.foreground == PrismRole.ink && r.background == 'surface',
      );
      expect(row.ratio, closeTo(expected, 1e-9));
      expect((row.ratio - naive).abs(), greaterThan(0.1)); // differs from naive
    });

    test('an all-opaque theme keeps its fill backdrop rows unchanged', () {
      // The flatten helper is a no-op for opaque fills: surface/surfaceRaised/
      // chrome rows still measure against the raw fill base.
      final theme = PrismThemeSource(
        seeds: brand(),
      ).compile(PrismBrightness.light);
      final s = theme.scheme;
      for (final (label, bg) in [
        ('surface', s.surface.base),
        ('surfaceRaised', s.surfaceRaised.base),
        ('chrome', s.chrome.base),
      ]) {
        final row = theme.audit().firstWhere(
          (r) => r.foreground == PrismRole.ink && r.background == label,
        );
        expect(row.ratio, closeTo(s.ink.contrastRatio(bg), 1e-9));
      }
    });
  });

  group('audit — coverage rows', () {
    final rows =
        PrismThemeSource(seeds: brand()).compile(PrismBrightness.light).audit();

    bool has(PrismRole fg, String bg) =>
        rows.any((r) => r.foreground == fg && r.background == bg);

    test('accent ink is checked against chrome', () {
      expect(has(PrismRole.actionInk, 'chrome'), isTrue);
    });

    test('accent fill is checked against canvas', () {
      expect(has(PrismRole.actionFill, 'canvas'), isTrue);
    });

    test('focus is checked against chrome', () {
      expect(has(PrismRole.focus, 'chrome'), isTrue);
    });

    test('divider rows are present and advisory (non-blocking)', () {
      final dividerRows = rows.where((r) => r.foreground == PrismRole.divider);
      expect(
        dividerRows.map((r) => r.background),
        containsAll(['surface', 'surfaceRaised']),
      );
      expect(dividerRows.every((r) => r.advisory), isTrue);
    });

    test(
      'new non-advisory rows clear the standard table (both brightnesses)',
      () {
        final pair = PrismThemeSource(seeds: brand()).compilePair();
        for (final t in [pair.light, pair.dark]) {
          final newRows = t.audit().where(
            (r) =>
                (r.foreground == PrismRole.actionInk &&
                    r.background == 'chrome') ||
                (r.foreground == PrismRole.actionFill &&
                    r.background == 'canvas') ||
                (r.foreground == PrismRole.focus && r.background == 'chrome'),
          );
          expect(newRows, isNotEmpty);
          expect(
            newRows.every((r) => r.passes),
            isTrue,
            reason: '${t.brightness}: ${newRows.where((r) => !r.passes)}',
          );
        }
      },
    );
  });

  group('audit — standard table', () {
    test('ink stays legible against every backdrop (both brightnesses)', () {
      final pair = PrismThemeSource(seeds: brand()).compilePair();
      for (final theme in [pair.light, pair.dark]) {
        final inkResults = theme.audit().where(
          (r) => r.foreground == PrismRole.ink,
        );
        expect(inkResults, isNotEmpty);
        expect(
          inkResults.every((r) => r.passes),
          isTrue,
          reason: '${theme.brightness}: ${inkResults.where((r) => !r.passes)}',
        );
      }
    });

    test('has no non-advisory failures on a flat canvas', () {
      final pair = PrismThemeSource(seeds: brand()).compilePair();
      expect(
        hardFailures(pair.light),
        isEmpty,
        reason: 'light: ${hardFailures(pair.light)}',
      );
      expect(
        hardFailures(pair.dark),
        isEmpty,
        reason: 'dark: ${hardFailures(pair.dark)}',
      );
    });

    test('passes over a Kosmos-like purple→blue gradient canvas (dark)', () {
      final gradient = Beam.linear([ok(0.16, 0.06, 300), ok(0.22, 0.08, 265)]);
      final src = PrismThemeSource(
        seeds: brand(),
        canvas: (light: Beam.flat(ok(0.985, 0.004, 264)), dark: gradient),
      );
      expect(
        hardFailures(src.compile(PrismBrightness.dark)),
        isEmpty,
        reason: '${hardFailures(src.compile(PrismBrightness.dark))}',
      );
    });

    test('a gradient surfaceRaised is audited and stays legible', () {
      final src = PrismThemeSource(
        seeds: brand(),
        roles: const PrismRoles(
          surfaceRaised: PrismRoleSpec(
            PrismSeed.neutral,
            l: (light: 0.30, dark: 0.30),
            gradient: -0.06,
          ),
        ),
      );
      final results = src
          .compile(PrismBrightness.dark)
          .audit()
          .where((r) => r.background == 'surfaceRaised');
      expect(results, isNotEmpty);
      expect(
        results.every((r) => r.passes || r.advisory),
        isTrue,
        reason: '${results.where((r) => !r.passes && !r.advisory)}',
      );
    });
  });
}
