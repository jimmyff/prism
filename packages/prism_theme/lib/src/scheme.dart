import 'package:prism/prism.dart';

import 'accent.dart';
import 'lerp.dart';
import 'role.dart';

/// A compiled color scheme — the 31 flat role colors plus the gradient canvas.
///
/// Produced by `PrismThemeSource.compile`. Alpha ink/structure roles are stored
/// as alpha colors that work over any surface (including the gradient canvas);
/// [over]/[wash] flatten them against a background when a solid color is needed.
class PrismScheme {
  /// The page background — a [Beam] (flat color or gradient sky).
  final Beam<RayOklch> canvas;

  /// Fill surfaces — [Beam]s (flat, or a gradient via a role's `gradient`).
  final Beam<RayOklch> surface;
  final Beam<RayOklch> surfaceRaised;
  final Beam<RayOklch> chrome;

  final RayOklch scrim;

  final RayOklch ink;
  final RayOklch inkMuted;
  final RayOklch inkFaint;

  final PrismAccent action;
  final PrismAccent hero;
  final PrismAccent highlight;
  final PrismAccent error;
  final PrismAccent warning;
  final PrismAccent success;
  final PrismAccent info;

  final RayOklch focus;
  final RayOklch outline;
  final RayOklch divider;

  /// Per-role chroma lost to gamut clamping, for roles where it was material.
  ///
  /// Diagnostic only (radical transparency: `withChroma` silently desaturates a
  /// color requested past gamut). Deliberately excluded from [==]/[hashCode]
  /// and [lerp] — it does not affect a rendered pixel, and Dart's `Map ==` is
  /// reference-based.
  final Map<PrismRole, double> clampDeltas;

  const PrismScheme({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.chrome,
    required this.scrim,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.action,
    required this.hero,
    required this.highlight,
    required this.error,
    required this.warning,
    required this.success,
    required this.info,
    required this.focus,
    required this.outline,
    required this.divider,
    this.clampDeltas = const {},
  });

  /// The flat color for [role]. Equivalent to the matching typed getter.
  RayOklch ray(PrismRole role) => switch (role) {
    PrismRole.surface => surface.base,
    PrismRole.surfaceRaised => surfaceRaised.base,
    PrismRole.chrome => chrome.base,
    PrismRole.scrim => scrim,
    PrismRole.ink => ink,
    PrismRole.inkMuted => inkMuted,
    PrismRole.inkFaint => inkFaint,
    PrismRole.actionFill => action.fill,
    PrismRole.actionOnFill => action.onFill,
    PrismRole.actionInk => action.ink,
    PrismRole.heroFill => hero.fill,
    PrismRole.heroOnFill => hero.onFill,
    PrismRole.heroInk => hero.ink,
    PrismRole.highlightFill => highlight.fill,
    PrismRole.highlightOnFill => highlight.onFill,
    PrismRole.highlightInk => highlight.ink,
    PrismRole.errorFill => error.fill,
    PrismRole.errorOnFill => error.onFill,
    PrismRole.errorInk => error.ink,
    PrismRole.warningFill => warning.fill,
    PrismRole.warningOnFill => warning.onFill,
    PrismRole.warningInk => warning.ink,
    PrismRole.successFill => success.fill,
    PrismRole.successOnFill => success.onFill,
    PrismRole.successInk => success.ink,
    PrismRole.infoFill => info.fill,
    PrismRole.infoOnFill => info.onFill,
    PrismRole.infoInk => info.ink,
    PrismRole.focus => focus,
    PrismRole.outline => outline,
    PrismRole.divider => divider,
  };

  /// Composites [src] over [dst] (source-over alpha compositing, sRGB math).
  ///
  /// The public primitive behind [over]/[wash] and hover/pressed state layers.
  RayOklch composite(Ray src, Ray dst) {
    final s = src.toRgb8();
    final d = dst.toRgb8();
    final sa = s.alpha / 255.0;
    final da = d.alpha / 255.0;
    final outA = sa + da * (1 - sa);
    if (outA <= 0) return const RayOklch.empty();
    double channel(num sc, num dc) => (sc * sa + dc * da * (1 - sa)) / outA;
    return RayRgb8.fromComponents(
      channel(s.red, d.red),
      channel(s.green, d.green),
      channel(s.blue, d.blue),
      outA * 255,
    ).toOklch();
  }

  /// The [role] color composited over [background].
  ///
  /// Flattens an alpha role (ink/outline/divider/scrim) into a solid color.
  /// [alpha] overrides the role's own opacity when given.
  RayOklch over(PrismRole role, Ray background, {double? alpha}) {
    final c = alpha == null ? ray(role) : ray(role).withOpacity(alpha);
    return composite(c, background);
  }

  /// An accent [role] applied at [strength] opacity over [background].
  ///
  /// The primitive for tonal fills and selection highlights.
  RayOklch wash(PrismRole role, Ray background, double strength) =>
      over(role, background, alpha: strength);

  /// Interpolates every role toward [other]; [t] is clamped to `[0, 1]`.
  PrismScheme lerp(PrismScheme other, double t) => PrismScheme(
    canvas: canvas.lerp(other.canvas, clampT(t)),
    surface: surface.lerp(other.surface, clampT(t)),
    surfaceRaised: surfaceRaised.lerp(other.surfaceRaised, clampT(t)),
    chrome: chrome.lerp(other.chrome, clampT(t)),
    scrim: lerpRay(scrim, other.scrim, t),
    ink: lerpRay(ink, other.ink, t),
    inkMuted: lerpRay(inkMuted, other.inkMuted, t),
    inkFaint: lerpRay(inkFaint, other.inkFaint, t),
    action: action.lerp(other.action, t),
    hero: hero.lerp(other.hero, t),
    highlight: highlight.lerp(other.highlight, t),
    error: error.lerp(other.error, t),
    warning: warning.lerp(other.warning, t),
    success: success.lerp(other.success, t),
    info: info.lerp(other.info, t),
    focus: lerpRay(focus, other.focus, t),
    outline: lerpRay(outline, other.outline, t),
    divider: lerpRay(divider, other.divider, t),
  );

  /// Returns a copy with the given roles replaced.
  ///
  /// Produces an **un-audited derived** scheme: a copyWith'd role cannot
  /// recompute its gamut-clamp delta, so [clampDeltas] is dropped rather than
  /// forwarding a stale one (consistent with [lerp]). Re-run `audit()` if the
  /// provenance matters.
  PrismScheme copyWith({
    Beam<RayOklch>? canvas,
    Beam<RayOklch>? surface,
    Beam<RayOklch>? surfaceRaised,
    Beam<RayOklch>? chrome,
    RayOklch? scrim,
    RayOklch? ink,
    RayOklch? inkMuted,
    RayOklch? inkFaint,
    PrismAccent? action,
    PrismAccent? hero,
    PrismAccent? highlight,
    PrismAccent? error,
    PrismAccent? warning,
    PrismAccent? success,
    PrismAccent? info,
    RayOklch? focus,
    RayOklch? outline,
    RayOklch? divider,
  }) => PrismScheme(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    chrome: chrome ?? this.chrome,
    scrim: scrim ?? this.scrim,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    inkFaint: inkFaint ?? this.inkFaint,
    action: action ?? this.action,
    hero: hero ?? this.hero,
    highlight: highlight ?? this.highlight,
    error: error ?? this.error,
    warning: warning ?? this.warning,
    success: success ?? this.success,
    info: info ?? this.info,
    focus: focus ?? this.focus,
    outline: outline ?? this.outline,
    divider: divider ?? this.divider,
  );

  List<Object> get _identity => [
    canvas,
    surface,
    surfaceRaised,
    chrome,
    scrim,
    ink,
    inkMuted,
    inkFaint,
    action,
    hero,
    highlight,
    error,
    warning,
    success,
    info,
    focus,
    outline,
    divider,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PrismScheme) return false;
    final a = _identity;
    final b = other._identity;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_identity);

  @override
  String toString() =>
      'PrismScheme(surface: $surface, ink: $ink, '
      'action: $action, canvas: $canvas)';
}
