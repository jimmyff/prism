import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  PrismTextStyle style(List<PrismFontVariation>? v) =>
      PrismTextStyle(fontSize: 10, fontVariations: v);

  group('PrismFontVariation', () {
    test('is a compile-time const (canonicalized)', () {
      const a = PrismFontVariation('wght', 400);
      const b = PrismFontVariation('wght', 400);
      expect(identical(a, b), isTrue);
    });

    test('asserts a 4-character axis tag', () {
      final tag = 'wg'; // runtime value → assert fires (not const-eval error)
      expect(
        () => PrismFontVariation(tag, 1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('equality is value-based and case-sensitive', () {
      expect(
        const PrismFontVariation('wght', 400),
        const PrismFontVariation('wght', 400),
      );
      expect(
        const PrismFontVariation('WONK', 1),
        isNot(const PrismFontVariation('wonk', 1)),
      );
    });
  });

  group('PrismTextStyle.fontVariations — set-semantics equality', () {
    test('order-insensitive', () {
      final a = style(const [
        PrismFontVariation('wght', 400),
        PrismFontVariation('opsz', 12),
      ]);
      final b = style(const [
        PrismFontVariation('opsz', 12),
        PrismFontVariation('wght', 400),
      ]);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a repeated axis is last-wins', () {
      final dup = style(const [
        PrismFontVariation('wght', 100),
        PrismFontVariation('wght', 700),
      ]);
      final single = style(const [PrismFontVariation('wght', 700)]);
      expect(dup, single);
      expect(dup.hashCode, single.hashCode);
    });

    test('null and empty compare equal', () {
      expect(style(null), style(const []));
      expect(style(null).hashCode, style(const []).hashCode);
    });

    test('is const-constructible with variations', () {
      const s = PrismTextStyle(
        fontSize: 10,
        fontVariations: [PrismFontVariation('wght', 400)],
      );
      expect(s.fontVariations, isNotNull);
    });
  });

  group('PrismTextStyle.fontVariations — lerp', () {
    test('a shared axis interpolates', () {
      final a = style(const [PrismFontVariation('wght', 100)]);
      final b = style(const [PrismFontVariation('wght', 900)]);
      final mid = a.lerp(b, 0.5).fontVariations!.single;
      expect(mid.axis, 'wght');
      expect(mid.value, closeTo(500, 1e-9));
    });

    test('a from-side-only axis holds until t=0.5, then drops', () {
      final from = style(const [PrismFontVariation('WONK', 1)]);
      final to = style(null);
      expect(from.lerp(to, 0.49).fontVariations!.single.value, 1);
      expect(from.lerp(to, 0.50).fontVariations, isNull); // empty → null
    });

    test('a to-side-only axis is absent until t=0.5, then appears', () {
      final from = style(null);
      final to = style(const [PrismFontVariation('WONK', 1)]);
      expect(from.lerp(to, 0.49).fontVariations, isNull);
      expect(from.lerp(to, 0.50).fontVariations!.single.value, 1);
    });

    test('null↔list endpoints equal their source', () {
      final withVars = style(const [PrismFontVariation('wght', 400)]);
      final none = style(null);
      expect(none.lerp(withVars, 0.0), none);
      expect(withVars.lerp(none, 0.0), withVars);
    });

    test('endpoint clamp survives differently-ordered lists (set equality)', () {
      final x = style(const [
        PrismFontVariation('wght', 400),
        PrismFontVariation('opsz', 12),
        PrismFontVariation('WONK', 1),
      ]);
      final y = style(const [
        PrismFontVariation('opsz', 48),
        PrismFontVariation('wght', 700),
      ]);
      expect(x.lerp(y, 0.0), x);
      expect(x.lerp(y, 1.0), y);
      // Clamped past the endpoints, too.
      expect(x.lerp(y, -0.5), x);
      expect(x.lerp(y, 1.5), y);
    });

    test('output is canonical — sorted by axis tag', () {
      final x = style(const [
        PrismFontVariation('wght', 400),
        PrismFontVariation('opsz', 12),
        PrismFontVariation('WONK', 1),
      ]);
      final y = style(const [
        PrismFontVariation('opsz', 48),
        PrismFontVariation('wght', 700),
      ]);
      final axes = x.lerp(y, 0.3).fontVariations!.map((v) => v.axis).toList();
      expect(axes, ['WONK', 'opsz', 'wght']); // ASCII sort: 'W'<'o'<'w'
    });
  });

  group('PrismTextCase', () {
    test('apply transforms text', () {
      expect(PrismTextCase.upper.apply('Hi there'), 'HI THERE');
      expect(PrismTextCase.lower.apply('Hi There'), 'hi there');
      expect(PrismTextCase.none.apply('Hi There'), 'Hi There');
    });

    test('snaps at t=0.5 in lerp', () {
      const none = PrismTextStyle(fontSize: 10);
      const upper = PrismTextStyle(fontSize: 10, textCase: PrismTextCase.upper);
      expect(none.lerp(upper, 0.49).textCase, PrismTextCase.none);
      expect(none.lerp(upper, 0.50).textCase, PrismTextCase.upper);
    });
  });

  group('PrismTextStyle.copyWith — keep-on-null', () {
    test('carries fontVariations and textCase through an unrelated edit', () {
      final base = PrismTextStyle(
        fontSize: 10,
        fontVariations: const [PrismFontVariation('wght', 400)],
        textCase: PrismTextCase.upper,
      );
      final copy = base.copyWith(fontSize: 12);
      expect(copy.fontSize, 12);
      expect(copy.fontVariations, base.fontVariations);
      expect(copy.textCase, PrismTextCase.upper);
    });
  });
}
