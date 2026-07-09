import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  // A source whose `label` slot upper-cases — proves the render-time case
  // transform while the semantic string stays untransformed.
  final source = PrismThemeSource(
    seeds: PrismSeeds(
      primary: ok(0.55, 0.16, 264),
      secondary: ok(0.60, 0.13, 300),
      tertiary: ok(0.62, 0.14, 200),
    ),
    typography: PrismTypography.fromScale().copyWith(
      label: const PrismTextStyle(
        fontSize: 13,
        fontWeight: 500,
        textCase: PrismTextCase.upper,
      ),
    ),
  );
  final theme = source.compile(PrismBrightness.light);
  final ink = PrismThemeExtension(theme).ink;

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(theme: theme.toThemeData(), home: Scaffold(body: child)),
  );

  testWidgets('label slot upper-cases glyphs but keeps the semantic string', (
    tester,
  ) async {
    await pump(tester, const PrismText.label('Continue'));
    final t = tester.widget<Text>(find.byType(Text));
    expect(t.data, 'CONTINUE');
    expect(t.semanticsLabel, 'Continue');
  });

  testWidgets('an untransformed slot leaves semanticsLabel null', (
    tester,
  ) async {
    await pump(tester, const PrismText.body('Continue'));
    final t = tester.widget<Text>(find.byType(Text));
    expect(t.data, 'Continue');
    expect(t.semanticsLabel, isNull);
  });

  testWidgets('styled hatch applies the given style\'s case', (tester) async {
    await pump(
      tester,
      const PrismText.styled(
        'quiet',
        style: PrismTextStyle(fontSize: 14, textCase: PrismTextCase.upper),
      ),
    );
    expect(find.text('QUIET'), findsOneWidget);
  });

  testWidgets('italic forces FontStyle.italic', (tester) async {
    await pump(tester, const PrismText.body('hi', italic: true));
    final t = tester.widget<Text>(find.byType(Text));
    expect(t.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('colour defaults to the ink role', (tester) async {
    await pump(tester, const PrismText.body('hi'));
    final t = tester.widget<Text>(find.byType(Text));
    expect(t.style?.color, ink);
  });

  testWidgets('colour override wins over ink', (tester) async {
    const green = Color(0xFF00FF00);
    await pump(tester, const PrismText.body('hi', color: green));
    final t = tester.widget<Text>(find.byType(Text));
    expect(t.style?.color, green);
  });
}
