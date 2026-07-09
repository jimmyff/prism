import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

void main() {
  group('brightness converters', () {
    test('PrismBrightness → Brightness', () {
      expect(PrismBrightness.dark.flutter, Brightness.dark);
      expect(PrismBrightness.light.flutter, Brightness.light);
    });

    test('Brightness → PrismBrightness', () {
      expect(Brightness.dark.prism, PrismBrightness.dark);
      expect(Brightness.light.prism, PrismBrightness.light);
    });
  });

  group('PrismTextStyle → TextStyle', () {
    test('maps size, family, fallback', () {
      const s = PrismTextStyle(
        fontSize: 14,
        fontFamily: 'X',
        fontFamilyFallback: ['Y'],
      );
      final f = s.flutter;
      expect(f.fontSize, 14);
      expect(f.fontFamily, 'X');
      expect(f.fontFamilyFallback, ['Y']);
    });

    test('maps weight to the matching FontWeight', () {
      expect(
        const PrismTextStyle(fontSize: 12, fontWeight: 100).flutter.fontWeight,
        FontWeight.w100,
      );
      expect(
        const PrismTextStyle(fontSize: 12, fontWeight: 500).flutter.fontWeight,
        FontWeight.w500,
      );
      expect(
        const PrismTextStyle(fontSize: 12, fontWeight: 900).flutter.fontWeight,
        FontWeight.w900,
      );
    });

    test('maps fontStyle to FontStyle', () {
      expect(
        const PrismTextStyle(fontSize: 12).flutter.fontStyle,
        FontStyle.normal,
      );
      expect(
        const PrismTextStyle(
          fontSize: 12,
          fontStyle: PrismFontStyle.italic,
        ).flutter.fontStyle,
        FontStyle.italic,
      );
    });
  });

  group('PrismTextStyle → TextStyle — variable fonts', () {
    Map<String, double> vmap(TextStyle s) => {
      for (final v in s.fontVariations ?? const <FontVariation>[]) v.axis: v.value,
    };

    test('null variations → null (regression, byte-for-byte legacy)', () {
      final f = const PrismTextStyle(fontSize: 12, fontWeight: 300).flutter;
      expect(f.fontVariations, isNull);
      expect(f.fontWeight, FontWeight.w300);
    });

    test('variations map 1:1 when an explicit wght is present', () {
      const s = PrismTextStyle(
        fontSize: 48,
        fontVariations: [
          PrismFontVariation('wght', 400),
          PrismFontVariation('opsz', 48),
          PrismFontVariation('WONK', 1),
        ],
      );
      expect(vmap(s.flutter), {'wght': 400, 'opsz': 48, 'WONK': 1});
    });

    test('synthesizes a wght axis from fontWeight when absent', () {
      const s = PrismTextStyle(
        fontSize: 15,
        fontWeight: 700,
        fontVariations: [PrismFontVariation('opsz', 15)],
      );
      final f = s.flutter;
      expect(vmap(f)['wght'], 700); // synthesized from the coarse int
      expect(vmap(f)['opsz'], 15);
      expect(f.fontWeight, FontWeight.w700);
    });

    test('derives FontWeight from an explicit wght (rounded to nearest 100)', () {
      const s = PrismTextStyle(
        fontSize: 16,
        fontWeight: 400, // the coarse int
        fontVariations: [PrismFontVariation('wght', 450)],
      );
      final f = s.flutter;
      expect(vmap(f)['wght'], 450); // explicit axis preserved verbatim
      expect(f.fontWeight, FontWeight.w500); // 450 → 500, not the int's 400
    });

    test('textCase is not mapped onto TextStyle', () {
      const upper = PrismTextStyle(fontSize: 12, textCase: PrismTextCase.upper);
      const none = PrismTextStyle(fontSize: 12);
      expect(upper.flutter, none.flutter);
    });
  });
}
