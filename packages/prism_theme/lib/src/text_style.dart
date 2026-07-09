import 'lerp.dart';

/// Whether text is drawn upright or italic (Flutter-free mirror of `FontStyle`).
enum PrismFontStyle { normal, italic }

/// A case transform applied to text at render time (locale-independent).
///
/// Deliberately omits title-case (locale-fraught). Snaps at t=0.5 in
/// [PrismTextStyle.lerp] — a discrete field.
enum PrismTextCase {
  none,
  upper,
  lower;

  /// Returns [text] transformed by this case (no-op for [none]).
  String apply(String text) => switch (this) {
    PrismTextCase.none => text,
    PrismTextCase.upper => text.toUpperCase(),
    PrismTextCase.lower => text.toLowerCase(),
  };
}

/// A single variable-font axis setting (Flutter-free mirror of `FontVariation`).
///
/// [axis] is a 4-character OpenType tag; case is significant (registered axes
/// are lower-case — `wght`, `opsz` — custom axes upper-case — `WONK`, `SOFT`).
/// [value] is the axis coordinate.
class PrismFontVariation {
  final String axis;
  final double value;

  const PrismFontVariation(this.axis, this.value)
    : assert(axis.length == 4, 'A font-variation axis tag must be 4 characters');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismFontVariation && axis == other.axis && value == other.value;

  @override
  int get hashCode => Object.hash(axis, value);

  @override
  String toString() => "PrismFontVariation('$axis', $value)";
}

/// A portable text style (no Flutter dependency).
///
/// [fontWeight] is an int in `[100, 900]`. [fontFamilyFallback] avoids web tofu
/// when [fontFamily] is null. [fontVariations] carries variable-font axes (e.g.
/// `wght`, `opsz`, `WONK`); [textCase] a render-time case transform.
/// Interpolation snaps the family, [fontStyle] and [textCase] at t=0.5, snaps
/// the weight to the nearest 100, and takes a per-axis union of [fontVariations]
/// (shared axes interpolate; one-sided axes snap at t=0.5).
class PrismTextStyle {
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double fontSize;
  final int fontWeight;

  /// Variable-font axis settings, or null. Compared with set semantics
  /// (order-insensitive, last value wins on a repeated axis).
  final List<PrismFontVariation>? fontVariations;

  final double? height;
  final double? letterSpacing;

  /// Upright or italic. Snaps at t=0.5 in [lerp] (a discrete field).
  final PrismFontStyle fontStyle;

  /// Render-time case transform. Snaps at t=0.5 in [lerp] (a discrete field).
  final PrismTextCase textCase;

  const PrismTextStyle({
    this.fontFamily,
    this.fontFamilyFallback,
    required this.fontSize,
    this.fontWeight = 400,
    this.fontVariations,
    this.height,
    this.letterSpacing,
    this.fontStyle = PrismFontStyle.normal,
    this.textCase = PrismTextCase.none,
  }) : assert(
         fontWeight >= 100 && fontWeight <= 900,
         'fontWeight must be within [100, 900]',
       ),
       assert(fontSize > 0, 'fontSize must be positive');

  /// Interpolates toward [other]; [t] is clamped to `[0, 1]`.
  ///
  /// Family and other discrete fields snap at t=0.5; size interpolates; weight
  /// interpolates then snaps to the nearest 100 (kept within `[100, 900]`);
  /// [fontVariations] takes a per-axis union.
  PrismTextStyle lerp(PrismTextStyle other, double t) {
    final tt = clampT(t);
    return PrismTextStyle(
      fontFamily: tt < 0.5 ? fontFamily : other.fontFamily,
      fontFamilyFallback:
          tt < 0.5 ? fontFamilyFallback : other.fontFamilyFallback,
      fontSize: lerpDouble(fontSize, other.fontSize, tt),
      fontWeight: _lerpWeight(fontWeight, other.fontWeight, tt),
      fontVariations: _lerpVariations(fontVariations, other.fontVariations, tt),
      height: _lerpNullable(height, other.height, tt),
      letterSpacing: _lerpNullable(letterSpacing, other.letterSpacing, tt),
      fontStyle: tt < 0.5 ? fontStyle : other.fontStyle,
      textCase: tt < 0.5 ? textCase : other.textCase,
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
    List<PrismFontVariation>? fontVariations,
    double? height,
    double? letterSpacing,
    PrismFontStyle? fontStyle,
    PrismTextCase? textCase,
  }) => PrismTextStyle(
    fontFamily: fontFamily ?? this.fontFamily,
    fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
    fontSize: fontSize ?? this.fontSize,
    fontWeight: fontWeight ?? this.fontWeight,
    fontVariations: fontVariations ?? this.fontVariations,
    height: height ?? this.height,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    fontStyle: fontStyle ?? this.fontStyle,
    textCase: textCase ?? this.textCase,
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

  /// Per-axis union: shared axes interpolate; an axis present on only one side
  /// holds (from-side) or appears (to-side) at the t=0.5 midpoint. Output is
  /// canonical — sorted by axis, one entry per axis — and empty collapses to
  /// null so endpoints stay equal to their (possibly null) source.
  static List<PrismFontVariation>? _lerpVariations(
    List<PrismFontVariation>? a,
    List<PrismFontVariation>? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    final ma = _canonVariations(a) ?? const <String, double>{};
    final mb = _canonVariations(b) ?? const <String, double>{};
    final axes = <String>{...ma.keys, ...mb.keys}.toList()..sort();
    final out = <PrismFontVariation>[];
    final tt = clampT(t);
    for (final axis in axes) {
      final va = ma[axis];
      final vb = mb[axis];
      if (va != null && vb != null) {
        out.add(PrismFontVariation(axis, lerpDouble(va, vb, tt)));
      } else if (va != null) {
        if (tt < 0.5) out.add(PrismFontVariation(axis, va));
      } else if (vb != null) {
        if (tt >= 0.5) out.add(PrismFontVariation(axis, vb));
      }
    }
    return out.isEmpty ? null : out;
  }

  /// Canonical map (axis → value, last wins) for set-semantics compare/lerp.
  /// Null and empty both collapse to null so they compare equal.
  static Map<String, double>? _canonVariations(List<PrismFontVariation>? v) {
    if (v == null || v.isEmpty) return null;
    final m = <String, double>{};
    for (final fv in v) {
      m[fv.axis] = fv.value;
    }
    return m;
  }

  static bool _variationsEqual(
    List<PrismFontVariation>? a,
    List<PrismFontVariation>? b,
  ) {
    final ca = _canonVariations(a);
    final cb = _canonVariations(b);
    if (ca == null || cb == null) return ca == null && cb == null;
    if (ca.length != cb.length) return false;
    for (final e in ca.entries) {
      if (cb[e.key] != e.value) return false;
    }
    return true;
  }

  static int _variationsHash(List<PrismFontVariation>? v) {
    final c = _canonVariations(v);
    if (c == null) return 0;
    final keys = c.keys.toList()..sort();
    return Object.hashAll([for (final k in keys) ...[k, c[k]]]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismTextStyle &&
          fontFamily == other.fontFamily &&
          _listEquals(fontFamilyFallback, other.fontFamilyFallback) &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          _variationsEqual(fontVariations, other.fontVariations) &&
          height == other.height &&
          letterSpacing == other.letterSpacing &&
          fontStyle == other.fontStyle &&
          textCase == other.textCase;

  @override
  int get hashCode => Object.hash(
    fontFamily,
    fontFamilyFallback == null ? null : Object.hashAll(fontFamilyFallback!),
    fontSize,
    fontWeight,
    _variationsHash(fontVariations),
    height,
    letterSpacing,
    fontStyle,
    textCase,
  );

  @override
  String toString() =>
      'PrismTextStyle(family: $fontFamily, size: $fontSize, weight: '
      '$fontWeight, style: ${fontStyle.name}, case: ${textCase.name}, '
      'variations: $fontVariations)';

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
