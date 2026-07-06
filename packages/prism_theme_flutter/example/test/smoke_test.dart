import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter_example/main.dart';

void main() {
  testWidgets('demo builds, reads roles, and interpolates without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(const DemoApp());

    expect(find.text('Ink hierarchy'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget); // morph only (was 2)
    expect(find.byType(Switch), findsOneWidget); // light/dark brightness

    // Drive the morph slider — exercises PrismTheme.lerp across a rebuild.
    await tester.drag(find.byType(Slider).first, const Offset(80, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Toggle brightness — exercises the themeMode switch + AnimatedTheme.
    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
