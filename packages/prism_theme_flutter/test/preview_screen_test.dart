import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';
import 'package:prism_theme_flutter/preview.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  final source = PrismThemeSource(
    seeds: PrismSeeds(
      primary: ok(0.55, 0.16, 264),
      secondary: ok(0.60, 0.13, 300),
      tertiary: ok(0.62, 0.14, 200),
    ),
    typography: PrismTypography.fromScale(fontFamily: 'X').copyWith(
      data: const PrismTextStyle(fontFamily: 'Mono', fontSize: 15),
    ),
  );

  testWidgets('builds and renders its sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PrismThemePreviewScreen(source: source)),
    );

    expect(find.text('Audit — dark'), findsOneWidget); // default brightness
    expect(find.text('Roles'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);
    // Beams/Tokens sit below the test viewport (lazy ListView) — scroll to them.
    await tester.scrollUntilVisible(find.text('Tokens'), 300);
    expect(find.text('Beams'), findsOneWidget);
    expect(find.text('Tokens'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('brightness toggle flips its internal theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PrismThemePreviewScreen(
          source: source,
          initialBrightness: PrismBrightness.dark,
        ),
      ),
    );

    expect(find.text('Audit — dark'), findsOneWidget);
    expect(find.text('Audit — light'), findsNothing);

    await tester.tap(find.byTooltip('Toggle brightness'));
    await tester.pumpAndSettle();

    expect(find.text('Audit — light'), findsOneWidget);
    expect(find.text('Audit — dark'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
