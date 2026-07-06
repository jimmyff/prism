import 'package:flutter/widgets.dart';
import 'package:prism_theme/prism_theme.dart';

/// Maps prism_theme's [PrismBrightness] to Flutter's [Brightness].
extension PrismBrightnessToFlutter on PrismBrightness {
  Brightness get flutter => isDark ? Brightness.dark : Brightness.light;
}

/// Maps Flutter's [Brightness] to prism_theme's [PrismBrightness].
extension FlutterBrightnessToPrism on Brightness {
  PrismBrightness get prism =>
      this == Brightness.dark ? PrismBrightness.dark : PrismBrightness.light;
}

/// Maps a [PrismTextStyle] to a Flutter [TextStyle].
extension PrismTextStyleToFlutter on PrismTextStyle {
  TextStyle get flutter => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: fontSize,
    // 100→w100 … 900→w900 (FontWeight.values has 9 entries).
    fontWeight: FontWeight.values[((fontWeight ~/ 100) - 1).clamp(0, 8)],
    fontStyle:
        fontStyle == PrismFontStyle.italic
            ? FontStyle.italic
            : FontStyle.normal,
    height: height,
    letterSpacing: letterSpacing,
  );
}
