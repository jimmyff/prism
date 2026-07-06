import 'package:flutter_test/flutter_test.dart';
import 'package:prism_theme_flutter_example/main.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

void main() {
  // Turns the four shipped example themes — previously eyeball-only, incl.
  // Kosmos's translucent surface + themed divider — into caught failures.
  test(
    'every demo source has no non-advisory audit failures (light + dark)',
    () {
      for (final entry in demoSources) {
        for (final brightness in PrismBrightness.values) {
          final failures =
              entry.source
                  .compile(brightness)
                  .audit()
                  .where((r) => !r.passes && !r.advisory)
                  .toList();
          expect(
            failures,
            isEmpty,
            reason:
                '${entry.name} (${brightness.name}):\n${failures.join('\n')}',
          );
        }
      }
    },
  );
}
