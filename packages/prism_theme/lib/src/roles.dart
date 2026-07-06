import 'accent_spec.dart';
import 'role_spec.dart';
import 'seed.dart';

/// The authored role table — the theme document's core.
///
/// The `const` defaults below **are** the standard table (M3-tone-informed
/// approximations, tuned via the preview tool). Override any line by passing
/// that argument; everything else keeps its default.
class PrismRoles {
  // Surfaces and structure.
  final PrismRoleSpec surface;
  final PrismRoleSpec surfaceRaised;
  final PrismRoleSpec chrome;
  final PrismRoleSpec scrim;

  // Ink hierarchy (alpha inks that work over any surface).
  final PrismRoleSpec ink;
  final PrismRoleSpec inkMuted;
  final PrismRoleSpec inkFaint;

  // Interaction / lines.
  final PrismRoleSpec focus;
  final PrismRoleSpec outline;
  final PrismRoleSpec divider;

  // Accent families — three brand intents + four status. `action` = primary
  // interactive; `hero` = expressive brand moments (unrelated to Flutter's
  // `Hero` widget); `highlight` = attention / CTAs (the accent *role* — Flutter's
  // `highlightColor` interaction state is `stateLayers`, not this).
  final PrismAccentSpec action;
  final PrismAccentSpec hero;
  final PrismAccentSpec highlight;
  final PrismAccentSpec error;
  final PrismAccentSpec warning;
  final PrismAccentSpec success;
  final PrismAccentSpec info;

  const PrismRoles({
    this.surface = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.97, dark: 0.21),
    ),
    this.surfaceRaised = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.995, dark: 0.26),
    ),
    this.chrome = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.95, dark: 0.18),
    ),
    this.scrim = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.15, dark: 0.05),
      alpha: 0.55,
    ),
    this.ink = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.20, dark: 0.95),
    ),
    this.inkMuted = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.20, dark: 0.95),
      alpha: 0.65,
    ),
    this.inkFaint = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.20, dark: 0.95),
      alpha: 0.40,
    ),
    this.focus = const PrismRoleSpec(
      PrismSeed.primary,
      l: (light: 0.55, dark: 0.75),
    ),
    this.outline = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.20, dark: 0.95),
      alpha: 0.35,
    ),
    this.divider = const PrismRoleSpec(
      PrismSeed.neutral,
      l: (light: 0.20, dark: 0.95),
      alpha: 0.15,
    ),
    this.action = const PrismAccentSpec(PrismSeed.primary),
    this.hero = const PrismAccentSpec(PrismSeed.secondary),
    this.highlight = const PrismAccentSpec(PrismSeed.tertiary),
    this.error = const PrismAccentSpec(PrismSeed.error),
    this.warning = const PrismAccentSpec(PrismSeed.warning),
    this.success = const PrismAccentSpec(PrismSeed.success),
    this.info = const PrismAccentSpec(PrismSeed.info),
  });

  /// Returns a copy with the given role specs replaced (omit to keep).
  PrismRoles copyWith({
    PrismRoleSpec? surface,
    PrismRoleSpec? surfaceRaised,
    PrismRoleSpec? chrome,
    PrismRoleSpec? scrim,
    PrismRoleSpec? ink,
    PrismRoleSpec? inkMuted,
    PrismRoleSpec? inkFaint,
    PrismRoleSpec? focus,
    PrismRoleSpec? outline,
    PrismRoleSpec? divider,
    PrismAccentSpec? action,
    PrismAccentSpec? hero,
    PrismAccentSpec? highlight,
    PrismAccentSpec? error,
    PrismAccentSpec? warning,
    PrismAccentSpec? success,
    PrismAccentSpec? info,
  }) => PrismRoles(
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    chrome: chrome ?? this.chrome,
    scrim: scrim ?? this.scrim,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    inkFaint: inkFaint ?? this.inkFaint,
    focus: focus ?? this.focus,
    outline: outline ?? this.outline,
    divider: divider ?? this.divider,
    action: action ?? this.action,
    hero: hero ?? this.hero,
    highlight: highlight ?? this.highlight,
    error: error ?? this.error,
    warning: warning ?? this.warning,
    success: success ?? this.success,
    info: info ?? this.info,
  );

  /// The single-role specs, in enum-adjacent order.
  List<PrismRoleSpec> get singleSpecs => [
    surface,
    surfaceRaised,
    chrome,
    scrim,
    ink,
    inkMuted,
    inkFaint,
    focus,
    outline,
    divider,
  ];

  /// The accent specs, in enum-adjacent order.
  List<PrismAccentSpec> get accentSpecs => [
    action,
    hero,
    highlight,
    error,
    warning,
    success,
    info,
  ];

  List<Object> get _fields => [...singleSpecs, ...accentSpecs];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PrismRoles) return false;
    final a = _fields;
    final b = other._fields;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_fields);

  @override
  String toString() => 'PrismRoles(...)';
}
