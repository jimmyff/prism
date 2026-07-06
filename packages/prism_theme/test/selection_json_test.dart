import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  group('PrismThemeSelection JSON', () {
    test('round-trips', () {
      const sel = PrismThemeSelection(
        sourceId: 'kosmos',
        brightness: PrismBrightness.dark,
      );
      expect(PrismThemeSelection.fromJson(sel.toJson()), sel);
    });

    test('an unknown key (e.g. a legacy darkness) is ignored', () {
      final sel = PrismThemeSelection.fromJson({
        'v': 1,
        'sourceId': 'k',
        'brightness': 'light',
        'darkness':
            0.5, // dropped from the schema; forward-safe parse ignores it
      });
      expect(
        sel,
        const PrismThemeSelection(
          sourceId: 'k',
          brightness: PrismBrightness.light,
        ),
      );
    });

    test('rejects an unsupported version', () {
      expect(
        () => PrismThemeSelection.fromJson({
          'v': 2,
          'sourceId': 'k',
          'brightness': 'light',
        }),
        throwsFormatException,
      );
    });

    test('rejects missing keys', () {
      expect(
        () => PrismThemeSelection.fromJson({'v': 1, 'sourceId': 'k'}),
        throwsFormatException,
      );
    });
  });

  group('leaf JSON round-trips', () {
    test('RayOklch', () {
      const c = RayOklch.fromComponents(0.16, 0.06, 280, 0.8);
      expect(RayOklch.fromJson(c.toJson()), c);
    });

    test('Beam (oklch canvas)', () {
      final beam = Beam.linear([
        const RayOklch.fromComponents(0.16, 0.06, 300),
        const RayOklch.fromComponents(0.22, 0.08, 265),
      ], angle: 200);
      expect(Beam.fromJson(beam.toJson()), beam);
    });
  });
}
