import 'package:prism/prism.dart';
import 'package:test/test.dart';

void main() {
  final black = RayRgb8.fromHex('#000000');
  final white = RayRgb8.fromHex('#FFFFFF');

  group('Ray.contrastRatio', () {
    test('black vs white is 21', () {
      expect(black.contrastRatio(white), closeTo(21.0, 1e-9));
    });

    test('identical colors are 1', () {
      expect(white.contrastRatio(white), closeTo(1.0, 1e-12));
      expect(black.contrastRatio(black), closeTo(1.0, 1e-12));
    });

    test('is symmetric', () {
      expect(
        black.contrastRatio(white),
        closeTo(white.contrastRatio(black), 1e-12),
      );
    });

    // The mid-tone cases below are the ONLY ones that expose an incorrect
    // Oklch-L implementation: 21/1/symmetric pass either way.
    test('mid-tone #777777 vs white ≈ 4.5', () {
      final mid = RayRgb8.fromHex('#777777');
      expect(mid.contrastRatio(white), closeTo(4.48, 0.15));
    });

    test('oklch mid-grey vs white ≈ 6.0 (down-converts, not perceptual L)', () {
      // oklch(.5 0 0) has perceptual L = 0.5; using .luminance would give a
      // bogus ratio near 1.9. The correct WCAG ratio is ~6.0.
      final grey = const RayOklch.fromComponents(0.5, 0.0, 0.0);
      expect(grey.contrastRatio(white), closeTo(6.0, 0.3));
    });
  });
}
