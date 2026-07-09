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

/// Maps an `int` prism weight (`[100, 900]`) to a Flutter [FontWeight].
// 100→w100 … 900→w900 (FontWeight.values has 9 entries).
FontWeight _flutterWeight(int weight) =>
    FontWeight.values[((weight ~/ 100) - 1).clamp(0, 8)];

/// Maps a [PrismTextStyle] to a Flutter [TextStyle].
///
/// With no [PrismTextStyle.fontVariations] this is byte-for-byte the legacy
/// style (coarse `fontWeight ~/ 100` mapping). With variations it emits a
/// `List<FontVariation>` and reconciles the `wght` axis with Flutter's
/// [FontWeight] (used for fallback fonts and metrics):
/// - no `wght` axis present → synthesize `FontVariation('wght', fontWeight)`
///   so a static-font fallback matches the requested weight;
/// - an explicit `wght` axis wins → derive [FontWeight] from it, rounded to the
///   nearest 100 and clamped to `[100, 900]` (e.g. 450 → 500), matching
///   `PrismTextStyle`'s own weight-lerp rounding.
///
/// [PrismTextStyle.textCase] is intentionally not mapped — Flutter has no
/// case-transform on [TextStyle]; apply it at the widget layer (`textCase.apply`).
extension PrismTextStyleToFlutter on PrismTextStyle {
  TextStyle get flutter {
    final variations = fontVariations;
    if (variations == null) {
      return TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        fontWeight: _flutterWeight(fontWeight),
        fontStyle:
            fontStyle == PrismFontStyle.italic
                ? FontStyle.italic
                : FontStyle.normal,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    // Dedup to last-wins per axis, matching PrismTextStyle's set semantics.
    final axes = <String, double>{};
    for (final v in variations) {
      axes[v.axis] = v.value;
    }
    final explicitWght = axes['wght'];
    if (explicitWght == null) {
      axes['wght'] = fontWeight.toDouble(); // synthesize from the coarse int
    }
    final weight =
        explicitWght == null
            ? fontWeight
            : ((explicitWght / 100).round() * 100).clamp(100, 900);

    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: _flutterWeight(weight),
      fontVariations: [
        for (final e in axes.entries) FontVariation(e.key, e.value),
      ],
      fontStyle:
          fontStyle == PrismFontStyle.italic
              ? FontStyle.italic
              : FontStyle.normal,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
