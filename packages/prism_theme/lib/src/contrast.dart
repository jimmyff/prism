import 'package:prism/prism.dart';

import 'role.dart';
import 'scheme.dart';

/// Contrast thresholds an [auditScheme] pass is measured against.
///
/// `body` (4.5) = normal text; `large` (3.0) = large text and non-text UI;
/// `structure` (1.5) = structural lines (outlines).
class PrismContrastPolicy {
  final double body;
  final double large;
  final double structure;

  const PrismContrastPolicy({
    this.body = 4.5,
    this.large = 3.0,
    this.structure = 1.5,
  });

  double threshold(PrismContrastLevel level) => switch (level) {
    PrismContrastLevel.body => body,
    PrismContrastLevel.large => large,
    PrismContrastLevel.structure => structure,
  };
}

/// The kind of contrast a pair is held to.
enum PrismContrastLevel { body, large, structure }

/// One contrast check: a [foreground] role against a [background], measured.
class PrismAuditResult {
  /// The role under test (composited over the background if it has alpha).
  final PrismRole foreground;

  /// A label for what it was checked against (e.g. `'canvas'`, `'actionFill'`).
  final String background;

  /// The measured WCAG ratio (the minimum across a gradient background).
  final double ratio;

  /// The threshold required to pass.
  final double required;

  /// Which policy level applied.
  final PrismContrastLevel level;

  /// Whether this is advisory (informational, non-blocking — e.g. `inkFaint`).
  final bool advisory;

  const PrismAuditResult({
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.required,
    required this.level,
    this.advisory = false,
  });

  /// Whether the measured ratio meets the requirement.
  bool get passes => ratio >= required;

  @override
  String toString() =>
      '${passes ? "PASS" : "FAIL"} ${foreground.name} on $background: '
      '${ratio.toStringAsFixed(2)} (need ${required.toStringAsFixed(1)}, '
      '${level.name})${advisory ? " [advisory]" : ""}';
}

const int _canvasSamples = 16;

/// Audits [scheme] against [policy], returning **every** checked pair.
///
/// Alpha roles are composited over the background before measuring, and a
/// gradient canvas is sampled at [_canvasSamples] points with the minimum ratio
/// taken (endpoint-only sampling gives a false pass when a role's luminance
/// falls inside the canvas span). Filter `.where((r) => !r.passes)` for
/// failures.
List<PrismAuditResult> auditScheme(
  PrismScheme scheme, [
  PrismContrastPolicy policy = const PrismContrastPolicy(),
]) {
  final out = <PrismAuditResult>[];

  // Fills may be authored translucent (frosted panels); flatten them over the
  // canvas before measuring, so a role is audited against what actually renders.
  final canvasSamples = _sample(scheme.canvas);
  final canvas = ('canvas', canvasSamples);
  final surface = ('surface', _backdrop(scheme, scheme.surface, canvasSamples));
  final surfaceRaised = (
    'surfaceRaised',
    _backdrop(scheme, scheme.surfaceRaised, canvasSamples),
  );
  final chrome = ('chrome', _backdrop(scheme, scheme.chrome, canvasSamples));

  void add(
    PrismRole fgRole,
    RayOklch fg,
    (String, List<RayOklch>) bg,
    PrismContrastLevel level, {
    bool advisory = false,
  }) {
    out.add(
      PrismAuditResult(
        foreground: fgRole,
        background: bg.$1,
        ratio: _minContrast(scheme, fg, bg.$2),
        required: policy.threshold(level),
        level: level,
        advisory: advisory,
      ),
    );
  }

  // Ink hierarchy vs backdrops.
  for (final bg in [canvas, surface, surfaceRaised, chrome]) {
    add(PrismRole.ink, scheme.ink, bg, PrismContrastLevel.body);
    add(PrismRole.inkMuted, scheme.inkMuted, bg, PrismContrastLevel.body);
    add(
      PrismRole.inkFaint,
      scheme.inkFaint,
      bg,
      PrismContrastLevel.large,
      advisory: true,
    );
  }

  // Accents.
  final accents = [
    (
      scheme.action,
      PrismRole.actionFill,
      PrismRole.actionOnFill,
      PrismRole.actionInk,
    ),
    (scheme.hero, PrismRole.heroFill, PrismRole.heroOnFill, PrismRole.heroInk),
    (
      scheme.highlight,
      PrismRole.highlightFill,
      PrismRole.highlightOnFill,
      PrismRole.highlightInk,
    ),
    (
      scheme.error,
      PrismRole.errorFill,
      PrismRole.errorOnFill,
      PrismRole.errorInk,
    ),
    (
      scheme.warning,
      PrismRole.warningFill,
      PrismRole.warningOnFill,
      PrismRole.warningInk,
    ),
    (
      scheme.success,
      PrismRole.successFill,
      PrismRole.successOnFill,
      PrismRole.successInk,
    ),
    (scheme.info, PrismRole.infoFill, PrismRole.infoOnFill, PrismRole.infoInk),
  ];
  for (final (accent, fillRole, onFillRole, inkRole) in accents) {
    // Content on the fill.
    add(onFillRole, accent.onFill, (
      fillRole.name,
      [accent.fill],
    ), PrismContrastLevel.body);
    // Accent-as-foreground vs canvas/surfaces/chrome.
    for (final bg in [canvas, surface, surfaceRaised, chrome]) {
      add(inkRole, accent.ink, bg, PrismContrastLevel.body);
    }
    // Solid fill vs canvas/surfaces (non-text).
    for (final bg in [canvas, surface, surfaceRaised]) {
      add(fillRole, accent.fill, bg, PrismContrastLevel.large);
    }
  }

  // Focus ring (non-text) vs canvas/surfaces/chrome.
  for (final bg in [canvas, surface, surfaceRaised, chrome]) {
    add(PrismRole.focus, scheme.focus, bg, PrismContrastLevel.large);
  }

  // Outline (structure) vs surfaces.
  for (final bg in [surface, surfaceRaised]) {
    add(PrismRole.outline, scheme.outline, bg, PrismContrastLevel.structure);
  }

  // Divider (structure) vs surfaces — advisory: decorative hairlines that
  // intentionally sit below the structure bar (especially in light mode).
  for (final bg in [surface, surfaceRaised]) {
    add(
      PrismRole.divider,
      scheme.divider,
      bg,
      PrismContrastLevel.structure,
      advisory: true,
    );
  }

  return out;
}

/// Debug-only guard: throws if any non-advisory pair fails [policy].
///
/// Wrapped in `assert`, so it is stripped from release builds. The recommended
/// convention is a package test that runs [auditScheme] over authored themes.
void assertSchemeAccessible(
  PrismScheme scheme, [
  PrismContrastPolicy policy = const PrismContrastPolicy(),
]) {
  assert(() {
    final failures =
        auditScheme(
          scheme,
          policy,
        ).where((r) => !r.passes && !r.advisory).toList();
    if (failures.isNotEmpty) {
      throw StateError(
        'prism_theme contrast audit failed:\n${failures.join('\n')}',
      );
    }
    return true;
  }());
}

/// The minimum contrast of [fg] (composited if translucent) over [bgSamples].
double _minContrast(PrismScheme scheme, RayOklch fg, List<RayOklch> bgSamples) {
  var min = double.infinity;
  for (final s in bgSamples) {
    final rendered = fg.opacity < 1.0 ? scheme.composite(fg, s) : fg;
    final ratio = rendered.contrastRatio(s);
    if (ratio < min) min = ratio;
  }
  return min;
}

/// Samples a background beam: one color if flat, [_canvasSamples] if a gradient.
List<RayOklch> _sample(Beam<RayOklch> beam) {
  if (!beam.isGradient) return [beam.base];
  return [
    for (var i = 0; i < _canvasSamples; i++)
      beam.colorAt(i / (_canvasSamples - 1)),
  ];
}

/// A fill's audit backdrop: its own samples if fully opaque, else the fill
/// flattened over **every** canvas sample.
///
/// A translucent panel can sit over any region of the canvas, so the minimum
/// contrast across all fill×canvas composites is the conservative measure.
/// Bounded [_canvasSamples]², at audit (test/tool/debug-assert) time only —
/// never per frame.
List<RayOklch> _backdrop(
  PrismScheme scheme,
  Beam<RayOklch> fill,
  List<RayOklch> canvasSamples,
) {
  final fills = _sample(fill);
  if (fills.every((f) => f.opacity >= 1.0)) return fills;
  return [
    for (final c in canvasSamples)
      for (final f in fills) scheme.composite(f, c),
  ];
}
