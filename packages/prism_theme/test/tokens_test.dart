import 'dart:math' as math;

import 'package:prism_theme/prism_theme.dart';
import 'package:test/test.dart';

void main() {
  group('PrismTypography.fromScale', () {
    test('sizes follow base · ratio^step', () {
      final t = PrismTypography.fromScale(base: 14, ratio: 1.2);
      expect(t.body.fontSize, closeTo(14, 1e-9)); // step 0
      expect(t.title.fontSize, closeTo(14 * math.pow(1.2, 2), 1e-9)); // +2
      expect(t.caption.fontSize, closeTo(14 * math.pow(1.2, -2), 1e-9)); // -2
      expect(t.display.fontSize, closeTo(14 * math.pow(1.2, 6), 1e-9)); // +6
    });

    test('label carries weight 500', () {
      expect(PrismTypography.fromScale().label.fontWeight, 500);
    });

    test('standard() equals fromScale defaults', () {
      expect(PrismTypography.standard(), PrismTypography.fromScale());
    });

    test('apply swaps the family across all slots', () {
      final t = PrismTypography.fromScale().apply(fontFamily: 'Inter');
      expect(t.body.fontFamily, 'Inter');
      expect(t.display.fontFamily, 'Inter');
    });
  });

  group('PrismTextStyle.lerp', () {
    final a = const PrismTextStyle(
      fontFamily: 'A',
      fontSize: 10,
      fontWeight: 300,
    );
    final b = const PrismTextStyle(
      fontFamily: 'B',
      fontSize: 20,
      fontWeight: 700,
    );

    test('family switches at exactly t=0.5', () {
      expect(a.lerp(b, 0.49).fontFamily, 'A');
      expect(a.lerp(b, 0.50).fontFamily, 'B');
    });

    test('size interpolates', () {
      expect(a.lerp(b, 0.5).fontSize, closeTo(15, 1e-9));
    });

    test('weight snaps to a multiple of 100 within [100, 900]', () {
      final w = a.lerp(b, 0.5).fontWeight;
      expect(w % 100, 0);
      expect(w, inInclusiveRange(100, 900));
    });

    test('asserts weight in range at authoring time', () {
      expect(
        () => PrismTextStyle(fontSize: 12, fontWeight: 950),
        throwsA(isA<AssertionError>()),
      );
    });

    test('fontStyle snaps at t=0.5 like the family', () {
      const upright = PrismTextStyle(fontSize: 10);
      const italic = PrismTextStyle(
        fontSize: 10,
        fontStyle: PrismFontStyle.italic,
      );
      expect(upright.lerp(italic, 0.49).fontStyle, PrismFontStyle.normal);
      expect(upright.lerp(italic, 0.50).fontStyle, PrismFontStyle.italic);
    });
  });

  group('PrismSpacing', () {
    test('scale steps derive from the unit', () {
      const s = PrismSpacing(unit: 4);
      expect(s.xs, 4);
      expect(s.sm, 8);
      expect(s.md, 16);
      expect(s.lg, 24);
      expect(s.xl, 32);
    });
  });

  group('PrismGeometry', () {
    test('carries the standard defaults', () {
      const g = PrismGeometry();
      expect(g.radiusSm, 4);
      expect(g.radiusMd, 8);
      expect(g.radiusLg, 16);
      expect(g.radiusFull, 999);
      expect(g.focusWidth, 2);
      expect(g.focusOffset, 2);
      expect(g.outlineWidth, 1.2);
    });

    test('radiusFull interpolates', () {
      final mid = const PrismGeometry(
        radiusFull: 100,
      ).lerp(const PrismGeometry(radiusFull: 200), 0.5);
      expect(mid.radiusFull, closeTo(150, 1e-9));
    });
  });

  group('PrismStateLayers', () {
    test('defaults and lerp', () {
      const s = PrismStateLayers();
      expect(s.hover, 0.13);
      expect(s.focus, 0.18);
      expect(s.pressed, 0.24);
      final mid = const PrismStateLayers(
        hover: 0.1,
      ).lerp(const PrismStateLayers(hover: 0.3), 0.5);
      expect(mid.hover, closeTo(0.2, 1e-9));
    });
  });
}
