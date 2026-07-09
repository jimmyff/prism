import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  const mono = PrismTextStyle(fontFamily: 'Mono', fontSize: 15);

  group('PrismTypography.data slot', () {
    test('fromScale gives data == body (single-font default)', () {
      final t = PrismTypography.fromScale();
      expect(t.data, t.body);
    });

    test('participates in copyWith', () {
      final t = PrismTypography.fromScale().copyWith(data: mono);
      expect(t.data, mono);
      expect(t.body, isNot(mono)); // only data changed
    });

    test('participates in apply', () {
      final t = PrismTypography.fromScale().apply(fontFamily: 'Inter');
      expect(t.data.fontFamily, 'Inter');
    });

    test('participates in lerp', () {
      final a = PrismTypography.fromScale(base: 10);
      final b = PrismTypography.fromScale(base: 20);
      expect(a.lerp(b, 0.5).data.fontSize, closeTo(15, 1e-9));
    });

    test('participates in equality', () {
      final a = PrismTypography.fromScale();
      final b = a.copyWith(data: mono);
      expect(a == b, isFalse);
      expect(a == a.copyWith(), isTrue);
    });

    test('compile carries all 8 slots through to the theme', () {
      final source = PrismThemeSource(
        seeds: PrismSeeds(
          primary: RayOklch.fromComponents(0.5, 0.15, 264),
          secondary: RayOklch.fromComponents(0.55, 0.12, 300),
          tertiary: RayOklch.fromComponents(0.6, 0.10, 340),
        ),
        typography: PrismTypography.fromScale().copyWith(data: mono),
      );
      final theme = source.compile(PrismBrightness.light);
      expect(theme.typography.data, mono);
      expect(theme.typography.body, isNot(mono));
    });
  });
}
