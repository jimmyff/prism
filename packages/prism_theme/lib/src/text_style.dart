import 'lerp.dart';

/// Whether text is drawn upright or italic (Flutter-free mirror of `FontStyle`).
enum PrismFontStyle { normal, italic }

/// A portable text style (no Flutter dependency).
///
/// [fontWeight] is an int in `[100, 900]`. [fontFamilyFallback] avoids web tofu
/// when [fontFamily] is null. Interpolation snaps the family and [fontStyle] at
/// t=0.5 and snaps the weight to the nearest 100.
class PrismTextStyle {
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double fontSize;
  final int fontWeight;
  final double? height;
  final double? letterSpacing;

  /// Upright or italic. Snaps at t=0.5 in [lerp] (a discrete field).
  final PrismFontStyle fontStyle;

  const PrismTextStyle({
    this.fontFamily,
    this.fontFamilyFallback,
    required this.fontSize,
    this.fontWeight = 400,
    this.height,
    this.letterSpacing,
    this.fontStyle = PrismFontStyle.normal,
  }) : assert(
         fontWeight >= 100 && fontWeight <= 900,
         'fontWeight must be within [100, 900]',
       ),
       assert(fontSize > 0, 'fontSize must be positive');

  /// Interpolates toward [other]; [t] is clamped to `[0, 1]`.
  ///
  /// Family and other discrete fields snap at t=0.5; size interpolates; weight
  /// interpolates then snaps to the nearest 100 (kept within `[100, 900]`).
  PrismTextStyle lerp(PrismTextStyle other, double t) {
    final tt = clampT(t);
    return PrismTextStyle(
      fontFamily: tt < 0.5 ? fontFamily : other.fontFamily,
      fontFamilyFallback:
          tt < 0.5 ? fontFamilyFallback : other.fontFamilyFallback,
      fontSize: lerpDouble(fontSize, other.fontSize, tt),
      fontWeight: _lerpWeight(fontWeight, other.fontWeight, tt),
      height: _lerpNullable(height, other.height, tt),
      letterSpacing: _lerpNullable(letterSpacing, other.letterSpacing, tt),
      fontStyle: tt < 0.5 ? fontStyle : other.fontStyle,
    );
  }

  /// Returns a copy with [fontFamily]/[fontFamilyFallback] applied.
  PrismTextStyle apply({
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) => copyWith(
    fontFamily: fontFamily ?? this.fontFamily,
    fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
  );

  PrismTextStyle copyWith({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double? fontSize,
    int? fontWeight,
    double? height,
    double? letterSpacing,
    PrismFontStyle? fontStyle,
  }) => PrismTextStyle(
    fontFamily: fontFamily ?? this.fontFamily,
    fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
    fontSize: fontSize ?? this.fontSize,
    fontWeight: fontWeight ?? this.fontWeight,
    height: height ?? this.height,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    fontStyle: fontStyle ?? this.fontStyle,
  );

  static int _lerpWeight(int a, int b, double t) {
    final raw = a + (b - a) * t;
    return ((raw / 100).round() * 100).clamp(100, 900);
  }

  static double? _lerpNullable(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    if (a == null || b == null) return t < 0.5 ? a : b;
    return lerpDouble(a, b, t);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismTextStyle &&
          fontFamily == other.fontFamily &&
          _listEquals(fontFamilyFallback, other.fontFamilyFallback) &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          height == other.height &&
          letterSpacing == other.letterSpacing &&
          fontStyle == other.fontStyle;

  @override
  int get hashCode => Object.hash(
    fontFamily,
    fontFamilyFallback == null ? null : Object.hashAll(fontFamilyFallback!),
    fontSize,
    fontWeight,
    height,
    letterSpacing,
    fontStyle,
  );

  @override
  String toString() =>
      'PrismTextStyle(family: $fontFamily, size: $fontSize, weight: '
      '$fontWeight, style: ${fontStyle.name})';

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
