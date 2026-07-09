import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  final source = PrismThemeSource(
    seeds: PrismSeeds(
      primary: ok(0.55, 0.16, 264),
      secondary: ok(0.60, 0.13, 300),
      tertiary: ok(0.62, 0.14, 200),
    ),
  );
  final theme = source.compile(PrismBrightness.light);

  Future<void> pump(WidgetTester tester, {required bool visible}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: theme.toThemeData(),
          home: Scaffold(
            body: Center(
              child: PrismFocusRing(
                visible: visible,
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(width: 100, height: 40),
              ),
            ),
          ),
        ),
      );

  // The ring's own CustomPaint is the first CustomPaint under PrismFocusRing.
  CustomPaint ringPaint(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(PrismFocusRing),
          matching: find.byType(CustomPaint),
        ),
      )
      .first;

  testWidgets('paints a foreground painter only when visible', (tester) async {
    await pump(tester, visible: true);
    expect(ringPaint(tester).foregroundPainter, isNotNull);
    expect(tester.takeException(), isNull);

    await pump(tester, visible: false);
    expect(ringPaint(tester).foregroundPainter, isNull);
    expect(tester.takeException(), isNull);
  });
}
