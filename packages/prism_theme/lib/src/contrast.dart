import 'package:prism/prism.dart';

import 'audit_backdrops.dart';
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

/// Audits [scheme] against [policy], returning **every** checked pair.
///
/// Alpha roles are composited over the background before measuring, and a
/// gradient canvas is sampled at [auditCanvasSamples] points with the minimum
/// ratio taken (endpoint-only sampling gives a false pass when a role's
/// luminance falls inside the canvas span). Filter `.where((r) => !r.passes)`
/// for failures. Sampling/compositing live in `audit_backdrops.dart`, shared
/// with the adaptive-ink compile solve so both measure identically.
List<PrismAuditResult> auditScheme(
  PrismScheme scheme, [
  PrismContrastPolicy policy = const PrismContrastPolicy(),
]) {
  final out = <PrismAuditResult>[];

  // Fills may be authored translucent (frosted panels); flatten them over the
  // canvas before measuring, so a role is audited against what actually renders.
  final canvasSamples = sampleBeam(scheme.canvas);
  final canvas = ('canvas', canvasSamples);
  final surface = (
    'surface',
    flattenBackdrop(scheme.surface, canvasSamples),
  );
  final surfaceRaised = (
    'surfaceRaised',
    flattenBackdrop(scheme.surfaceRaised, canvasSamples),
  );
  final chrome = ('chrome', flattenBackdrop(scheme.chrome, canvasSamples));

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
        ratio: minContrastOver(fg, bg.$2),
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

