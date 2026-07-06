import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  group('PrismBrightness', () {
    test('isDark', () {
      expect(PrismBrightness.dark.isDark, isTrue);
      expect(PrismBrightness.light.isDark, isFalse);
    });

    test('inverse', () {
      expect(PrismBrightness.light.inverse, PrismBrightness.dark);
      expect(PrismBrightness.dark.inverse, PrismBrightness.light);
    });

    test('name / fromName round-trip', () {
      for (final b in PrismBrightness.values) {
        expect(PrismBrightness.fromName(b.name), b);
      }
    });

    test('fromName throws on unknown', () {
      expect(() => PrismBrightness.fromName('dusk'), throwsFormatException);
    });

    test('of(bool) selects by darkness', () {
      expect(PrismBrightness.of(true), PrismBrightness.dark);
      expect(PrismBrightness.of(false), PrismBrightness.light);
    });

    test('of / isDark round-trip', () {
      for (final b in PrismBrightness.values) {
        expect(PrismBrightness.of(b.isDark), b);
      }
    });
  });
}
