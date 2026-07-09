import 'package:flutter/material.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';

/// A self-contained developer tool for inspecting and calibrating a
/// [PrismThemeSource].
///
/// Push it from any consumer app with that app's own source; it compiles the
/// pair itself, wraps its body in its own [Theme], and offers a brightness
/// toggle plus role, typography, beam and token sections and a live `audit()`
/// panel. Read-only (no `atDarkness` scrubber — that arrives when the dynamic
/// engine drives darkness). Written purely against the public prism API.
class PrismThemePreviewScreen extends StatefulWidget {
  /// The theme document to inspect.
  final PrismThemeSource source;

  /// The brightness shown first (defaults to dark).
  final PrismBrightness initialBrightness;

  const PrismThemePreviewScreen({
    required this.source,
    this.initialBrightness = PrismBrightness.dark,
    super.key,
  });

  @override
  State<PrismThemePreviewScreen> createState() =>
      _PrismThemePreviewScreenState();
}

class _PrismThemePreviewScreenState extends State<PrismThemePreviewScreen> {
  late PrismThemePair _pair = widget.source.compilePair();
  late PrismBrightness _brightness = widget.initialBrightness;

  @override
  void didUpdateWidget(covariant PrismThemePreviewScreen old) {
    super.didUpdateWidget(old);
    if (old.source != widget.source) _pair = widget.source.compilePair();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _pair.resolve(_brightness);
    return Theme(
      data: theme.toThemeData(),
      child: Builder(
        builder: (context) {
          final p = context.prism;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Theme preview'),
              actions: [
                IconButton(
                  tooltip: 'Toggle brightness',
                  icon: Icon(
                    _brightness.isDark ? Icons.dark_mode : Icons.light_mode,
                  ),
                  onPressed:
                      () => setState(() => _brightness = _brightness.inverse),
                ),
              ],
            ),
            body: DecoratedBox(
              decoration: BoxDecoration(gradient: p.canvas),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
                    title: 'Audit — ${_brightness.name}',
                    child: _AuditPanel(theme: p.theme),
                  ),
                  _Section(title: 'Roles', child: _Roles(p: p)),
                  _Section(title: 'Typography', child: _Typography(p: p)),
                  _Section(title: 'Beams', child: _Beams(p: p)),
                  _Section(title: 'Tokens', child: _Tokens(p: p)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A titled card over the theme's `surface`.
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.prism;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: p.surfaceGradient,
        borderRadius: BorderRadius.circular(p.geometry.radiusLg),
        border: Border.all(color: p.outline, width: p.geometry.outlineWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: p.typography.label.flutter.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Live contrast audit, non-advisory failures highlighted.
class _AuditPanel extends StatelessWidget {
  final PrismTheme theme;
  const _AuditPanel({required this.theme});

  @override
  Widget build(BuildContext context) {
    final p = context.prism;
    final results = theme.audit();
    final failures = results.where((r) => !r.passes && !r.advisory).toList();
    final advisories = results.where((r) => !r.passes && r.advisory).toList();
    final passes = results.where((r) => r.passes).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              failures.isEmpty ? Icons.check_circle : Icons.error,
              color: failures.isEmpty ? p.successInk : p.errorInk,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '$passes/${results.length} pass · '
              '${failures.length} failing · ${advisories.length} advisory',
              style: p.typography.body.flutter.copyWith(color: p.ink),
            ),
          ],
        ),
        for (final r in failures)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              r.toString(),
              style: p.typography.data.flutter.copyWith(color: p.errorInk),
            ),
          ),
        for (final r in advisories)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              r.toString(),
              style: p.typography.caption.flutter.copyWith(color: p.inkFaint),
            ),
          ),
      ],
    );
  }
}

/// Role swatches: inks, fills, accent trios, lines.
class _Roles extends StatelessWidget {
  final PrismThemeExtension p;
  const _Roles({required this.p});

  Widget _swatch(String label, Color fill, {Color? on}) => Container(
    width: 96,
    height: 56,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(p.geometry.radiusSm),
      border: Border.all(color: p.outline, width: p.geometry.outlineWidth),
    ),
    alignment: Alignment.bottomLeft,
    child: Text(
      label,
      style: p.typography.caption.flutter.copyWith(color: on ?? p.ink),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final accents = <(String, Color, Color, Color)>[
      ('action', p.actionFill, p.actionOnFill, p.actionInk),
      ('hero', p.heroFill, p.heroOnFill, p.heroInk),
      ('highlight', p.highlightFill, p.highlightOnFill, p.highlightInk),
      ('error', p.errorFill, p.errorOnFill, p.errorInk),
      ('warning', p.warningFill, p.warningOnFill, p.warningInk),
      ('success', p.successFill, p.successOnFill, p.successInk),
      ('info', p.infoFill, p.infoOnFill, p.infoInk),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _swatch('ink', p.surface, on: p.ink),
        _swatch('inkMuted', p.surface, on: p.inkMuted),
        _swatch('inkFaint', p.surface, on: p.inkFaint),
        _swatch('surface', p.surface),
        _swatch('surfaceRaised', p.surfaceRaised),
        _swatch('chrome', p.chrome),
        for (final (name, fill, on, ink) in accents) ...[
          _swatch('$name.fill', fill, on: on),
          _swatch('$name.ink', p.surface, on: ink),
        ],
        _swatch('focus', p.focus),
        _swatch('outline', p.outline),
        _swatch('divider', p.divider),
      ],
    );
  }
}

/// The 8 typography slots with two-voice content (textCase.apply demonstrated).
class _Typography extends StatelessWidget {
  final PrismThemeExtension p;
  const _Typography({required this.p});

  // A multi-paragraph body sample so line-height and paragraph spacing read.
  static const _body = [
    'Two voices share one page: a warm serif for prose and a precise '
        'monospace for data. Set them side by side to judge rhythm, colour, '
        'and contrast at a glance.',
    'Line height controls how the eye moves down a paragraph; paragraph '
        'spacing sets the pause between thoughts. Both should feel calm at '
        'reading sizes and tighten as the type grows.',
    'Everything here is authored, not guessed — tune a value, hot-reload, '
        'and watch the audit panel above stay honest about contrast.',
  ];

  @override
  Widget build(BuildContext context) {
    final t = p.typography;
    final slots = <(String, PrismTextStyle, List<String>)>[
      ('display', t.display, const ['Kosmos']),
      ('headline', t.headline, const [
        'A warm serif for prose and a precise mono for data',
      ]),
      ('title', t.title, const ['Ascendant in Aquarius']),
      ('body', t.body, _body),
      ('data', t.data, const ['ASC 23°34′ · MC 11°02′ · ☉ 289.7°']),
      ('bodySmall', t.bodySmall, const ['Sampled against the c2 wireframes.']),
      ('label', t.label, const ['Rising sign']),
      ('caption', t.caption, const ['source: hellenistic']),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style, paragraphs) in slots)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · ${style.fontFamily ?? "—"}',
                  style: p.typography.caption.flutter.copyWith(color: p.inkFaint),
                ),
                for (var i = 0; i < paragraphs.length; i++) ...[
                  if (i > 0) SizedBox(height: p.spacing.sm),
                  Text(
                    style.textCase.apply(paragraphs[i]),
                    style: style.flutter.copyWith(color: p.ink),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Canvas / surface / raised / chrome gradient bars.
class _Beams extends StatelessWidget {
  final PrismThemeExtension p;
  const _Beams({required this.p});

  Widget _bar(String label, Gradient gradient) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: p.typography.caption.flutter.copyWith(color: p.inkFaint),
        ),
        Container(
          height: 28,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(p.geometry.radiusSm),
            border: Border.all(color: p.outline, width: p.geometry.outlineWidth),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _bar('canvas', p.canvas),
      _bar('surface', p.surfaceGradient),
      _bar('surfaceRaised', p.surfaceRaisedGradient),
      _bar('chrome', p.chromeGradient),
    ],
  );
}

/// Spacing / geometry / state-layer numeric tokens.
class _Tokens extends StatelessWidget {
  final PrismThemeExtension p;
  const _Tokens({required this.p});

  @override
  Widget build(BuildContext context) {
    final s = p.spacing;
    final g = p.geometry;
    final l = p.stateLayers;
    final lines = <String>[
      'spacing  unit ${s.unit} · xs ${s.xs} sm ${s.sm} md ${s.md} '
          'lg ${s.lg} xl ${s.xl}',
      'radius   sm ${g.radiusSm} md ${g.radiusMd} lg ${g.radiusLg} '
          'full ${g.radiusFull}',
      'lines    outline ${g.outlineWidth} · focus ${g.focusWidth} '
          '@ ${g.focusOffset}',
      'state    hover ${l.hover} · focus ${l.focus} · pressed ${l.pressed}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Text(
            line,
            style: p.typography.data.flutter.copyWith(color: p.inkMuted),
          ),
      ],
    );
  }
}
