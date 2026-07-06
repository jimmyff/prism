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
}
