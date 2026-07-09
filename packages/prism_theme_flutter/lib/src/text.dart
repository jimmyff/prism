import 'package:flutter/widgets.dart';
import 'package:prism_theme/prism_theme.dart';

import 'converters.dart';
import 'theme_extension.dart';

/// The typography slot a [PrismText] renders from.
enum _Slot { display, headline, title, body, data, bodySmall, label, caption }

/// Text drawn from a prism typography slot.
///
/// Resolves its [PrismTextStyle] from `context.prism.typography` at build time,
/// applies the slot's [PrismTextCase] to the visible string (keeping the
/// original in `semanticsLabel` when casing transforms it), and colours it with
/// [color] (defaulting to the `ink` role). This is the text widget prism
/// consumers use — rkf_ui ships none of its own and renders through this.
///
/// Slot constructors cover the eight typography slots; [PrismText.styled] is an
/// escape hatch for an explicit style (it still applies the style's case).
class PrismText extends StatelessWidget {
  /// The source string (before any case transform).
  final String text;

  /// The slot to resolve, or null when [_style] is supplied.
  final _Slot? _slot;

  /// An explicit style (the `.styled` hatch), or null for a slot.
  final PrismTextStyle? _style;

  /// Text colour; defaults to the `ink` role when null.
  final Color? color;

  /// Forces italic on top of the resolved style.
  final bool italic;

  /// Passed through to the underlying [Text].
  final int? maxLines;

  /// Passed through to the underlying [Text].
  final TextOverflow? overflow;

  /// Passed through to the underlying [Text].
  final TextAlign? textAlign;

  const PrismText.display(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.display,
        _style = null;

  const PrismText.headline(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.headline,
        _style = null;

  const PrismText.title(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.title,
        _style = null;

  const PrismText.body(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.body,
        _style = null;

  const PrismText.data(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.data,
        _style = null;

  const PrismText.bodySmall(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.bodySmall,
        _style = null;

  const PrismText.label(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.label,
        _style = null;

  const PrismText.caption(
    this.text, {
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = _Slot.caption,
        _style = null;

  /// Renders [text] with an explicit [style] (its case is still applied).
  const PrismText.styled(
    this.text, {
    required PrismTextStyle style,
    this.color,
    this.italic = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  })  : _slot = null,
        _style = style;

  PrismTextStyle _resolve(PrismTypography t) => switch (_slot!) {
        _Slot.display => t.display,
        _Slot.headline => t.headline,
        _Slot.title => t.title,
        _Slot.body => t.body,
        _Slot.data => t.data,
        _Slot.bodySmall => t.bodySmall,
        _Slot.label => t.label,
        _Slot.caption => t.caption,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.prism;
    final base = _style ?? _resolve(p.typography);
    final style = italic ? base.copyWith(fontStyle: PrismFontStyle.italic) : base;
    final display = style.textCase.apply(text);
    // Keep the untransformed string for assistive tech when casing changed it.
    final semanticsLabel =
        (text.isNotEmpty && display != text) ? text : null;
    return Text(
      display,
      semanticsLabel: semanticsLabel,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style.flutter.copyWith(color: color ?? p.ink),
    );
  }
}
