import 'dart:math' as math;

import 'text_style.dart';

/// Seven text slots on a single modular scale.
///
/// Slots (with their scale steps): `caption` −2 · `bodySmall` −1 ·
/// `label` −1 (weight 500) · `body` 0 · `title` +2 · `headline` +4 ·
/// `display` +6.
class PrismTypography {
  final PrismTextStyle display;
  final PrismTextStyle headline;
  final PrismTextStyle title;
  final PrismTextStyle body;
  final PrismTextStyle bodySmall;
  final PrismTextStyle label;
  final PrismTextStyle caption;

  const PrismTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caption,
  });

  /// Builds a typography from a modular scale: `size(step) = base · ratio^step`.
  factory PrismTypography.fromScale({
    double base = 14,
    double ratio = 1.2,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    PrismTextStyle at(int step, {int weight = 400}) => PrismTextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: base * math.pow(ratio, step),
      fontWeight: weight,
    );
    return PrismTypography(
      caption: at(-2),
      bodySmall: at(-1),
      label: at(-1, weight: 500),
      body: at(0),
      title: at(2),
      headline: at(4),
      display: at(6),
    );
  }

  /// The default scale (`fromScale` with default arguments).
  factory PrismTypography.standard() => PrismTypography.fromScale();

  /// Returns a copy with [fontFamily]/[fontFamilyFallback] applied to all slots.
  PrismTypography apply({
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    PrismTextStyle a(PrismTextStyle s) =>
        s.apply(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback);
    return PrismTypography(
      display: a(display),
      headline: a(headline),
      title: a(title),
      body: a(body),
      bodySmall: a(bodySmall),
      label: a(label),
      caption: a(caption),
    );
  }

  /// Interpolates every slot toward [other]; [t] is clamped to `[0, 1]`.
  PrismTypography lerp(PrismTypography other, double t) => PrismTypography(
    display: display.lerp(other.display, t),
    headline: headline.lerp(other.headline, t),
    title: title.lerp(other.title, t),
    body: body.lerp(other.body, t),
    bodySmall: bodySmall.lerp(other.bodySmall, t),
    label: label.lerp(other.label, t),
    caption: caption.lerp(other.caption, t),
  );

  PrismTypography copyWith({
    PrismTextStyle? display,
    PrismTextStyle? headline,
    PrismTextStyle? title,
    PrismTextStyle? body,
    PrismTextStyle? bodySmall,
    PrismTextStyle? label,
    PrismTextStyle? caption,
  }) => PrismTypography(
    display: display ?? this.display,
    headline: headline ?? this.headline,
    title: title ?? this.title,
    body: body ?? this.body,
    bodySmall: bodySmall ?? this.bodySmall,
    label: label ?? this.label,
    caption: caption ?? this.caption,
  );

  List<Object> get _slots => [
    display,
    headline,
    title,
    body,
    bodySmall,
    label,
    caption,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PrismTypography) return false;
    final a = _slots;
    final b = other._slots;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_slots);

  @override
  String toString() => 'PrismTypography(body: $body, display: $display)';
}
