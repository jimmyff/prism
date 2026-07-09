/// A developer tool for inspecting and calibrating a `PrismThemeSource`.
///
/// A deliberately separate entrypoint from the main library so the core API
/// surface stays clean and importing the dev tool is intentional:
///
/// ```dart
/// import 'package:prism_theme_flutter/preview.dart';
/// // ...
/// Navigator.of(context).push(MaterialPageRoute(
///   builder: (_) => PrismThemePreviewScreen(source: myThemeSource),
/// ));
/// ```
library;

export 'src/preview/preview_screen.dart';
