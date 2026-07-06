import 'package:prism/prism.dart';

import 'accent.dart';
import 'accent_spec.dart';
import 'brightness.dart';
import 'geometry.dart';
import 'role.dart';
import 'role_spec.dart';
import 'roles.dart';
import 'scheme.dart';
import 'seed.dart';
import 'seeds.dart';
import 'sentinel.dart';
import 'spacing.dart';
import 'splash.dart';
import 'state_layers.dart';
import 'theme.dart';
import 'theme_pair.dart';
import 'typography.dart';

/// The authored theme document.
///
/// Everything a theme is, in one readable value: [seeds] (plus optional
/// [darkSeeds] divergence), an optional gradient [canvas], the [roles] table,
/// and the token sets. [compile] is a pure function producing a [PrismTheme];
/// there is no runtime generation magic.
class PrismThemeSource {
  /// The seed colors (used for both brightnesses unless [darkSeeds] is given).
  final PrismSeeds seeds;

  /// Optional separate dark-mode seeds (the graduated-divergence escape hatch).
  final PrismSeeds? darkSeeds;

  /// Optional authored canvas beams; null derives a flat neutral canvas.
  final ({Beam<RayOklch> light, Beam<RayOklch> dark})? canvas;

  /// The role table (defaults to the standard table).
  final PrismRoles roles;

  /// Typography; null compiles to [PrismTypography.standard].
  final PrismTypography? typography;

  /// The spacing scale.
  final PrismSpacing spacing;

  /// Corner radii and focus metrics.
  final PrismGeometry geometry;

  /// Interaction state-layer opacities (hover / focus / press).
  final PrismStateLayers stateLayers;

  /// The interaction splash style.
  final PrismSplash splash;

  const PrismThemeSource({
    required this.seeds,
    this.darkSeeds,
    this.canvas,
    this.roles = const PrismRoles(),
    this.typography,
    this.spacing = const PrismSpacing(),
    this.geometry = const PrismGeometry(),
    this.stateLayers = const PrismStateLayers(),
    this.splash = PrismSplash.ripple,
  });

  /// The default canvas: neutral, near-white in light / near-black in dark.
  static const _defaultCanvas = PrismRoleSpec(
    PrismSeed.neutral,
    l: (light: 0.985, dark: 0.16),
  );

  PrismTypography get _typography => typography ?? PrismTypography.standard();

  /// Compiles this document into a [PrismTheme] for [brightness] (pure).
  PrismTheme compile(PrismBrightness brightness) {
    final effectiveSeeds = brightness.isDark ? (darkSeeds ?? seeds) : seeds;
    return PrismTheme(
      brightness: brightness,
      scheme: _compileScheme(effectiveSeeds, brightness),
      typography: _typography,
      spacing: spacing,
      geometry: geometry,
      stateLayers: stateLayers,
      splash: splash,
      seeds: effectiveSeeds,
    );
  }

  /// Compiles both brightnesses into a [PrismThemePair].
  PrismThemePair compilePair() => PrismThemePair(
    light: compile(PrismBrightness.light),
    dark: compile(PrismBrightness.dark),
  );

  PrismScheme _compileScheme(PrismSeeds seeds, PrismBrightness b) {
    final deltas = <PrismRole, double>{};

    RayOklch single(PrismRole role, PrismRoleSpec spec) {
      final r = spec.resolveSeed(seeds, b);
      if (r.clampDelta > _deltaEpsilon) deltas[role] = r.clampDelta;
      return r.color;
    }

    // Fill roles compile to Beams: flat unless the spec carries a `gradient`
    // lightness delta and/or a `gradientSeed` hue shift, which yield a 2-stop
    // top→bottom gradient (top = the role's seed, bottom = the far stop).
    Beam<RayOklch> fillBeam(PrismRole role, PrismRoleSpec spec) {
      final r = spec.resolveSeed(seeds, b);
      if (r.clampDelta > _deltaEpsilon) deltas[role] = r.clampDelta;
      if (spec.gradient == null && spec.gradientSeed == null) {
        return Beam.flat(r.color);
      }
      final endL = (r.color.lightness + (spec.gradient ?? 0.0)).clamp(0.0, 1.0);
      // gradientSeed is seed-only; else the spec's own base (seed or inline).
      final endSeed =
          spec.gradientSeed != null
              ? seeds[spec.gradientSeed!]
              : spec.base.baseColor(seeds);
      var end = endSeed
          .withLightness(endL)
          .withChroma(endSeed.chroma * spec.chroma);
      if (spec.alpha != 1.0) end = end.withOpacity(spec.alpha);
      return Beam.linear([r.color, end]);
    }

    PrismAccent accent(
      PrismAccentSpec spec,
      PrismRole fillRole,
      PrismRole onFillRole,
      PrismRole inkRole,
    ) {
      final r = spec.resolveSeed(seeds, b);
      if (r.fillDelta > _deltaEpsilon) deltas[fillRole] = r.fillDelta;
      if (r.onFillDelta > _deltaEpsilon) deltas[onFillRole] = r.onFillDelta;
      if (r.inkDelta > _deltaEpsilon) deltas[inkRole] = r.inkDelta;
      return r.accent;
    }

    final canvasBeam =
        canvas == null
            ? Beam.flat(_defaultCanvas.resolveSeed(seeds, b).color)
            : (b.isDark ? canvas!.dark : canvas!.light);

    // Evaluate every role first (this populates `deltas`), then assemble.
    final surface = fillBeam(PrismRole.surface, roles.surface);
    final surfaceRaised = fillBeam(
      PrismRole.surfaceRaised,
      roles.surfaceRaised,
    );
    final chrome = fillBeam(PrismRole.chrome, roles.chrome);
    final scrim = single(PrismRole.scrim, roles.scrim);
    final ink = single(PrismRole.ink, roles.ink);
    final inkMuted = single(PrismRole.inkMuted, roles.inkMuted);
    final inkFaint = single(PrismRole.inkFaint, roles.inkFaint);
    final action = accent(
      roles.action,
      PrismRole.actionFill,
      PrismRole.actionOnFill,
      PrismRole.actionInk,
    );
    final hero = accent(
      roles.hero,
      PrismRole.heroFill,
      PrismRole.heroOnFill,
      PrismRole.heroInk,
    );
    final highlight = accent(
      roles.highlight,
      PrismRole.highlightFill,
      PrismRole.highlightOnFill,
      PrismRole.highlightInk,
    );
    final error = accent(
      roles.error,
      PrismRole.errorFill,
      PrismRole.errorOnFill,
      PrismRole.errorInk,
    );
    final warning = accent(
      roles.warning,
      PrismRole.warningFill,
      PrismRole.warningOnFill,
      PrismRole.warningInk,
    );
    final success = accent(
      roles.success,
      PrismRole.successFill,
      PrismRole.successOnFill,
      PrismRole.successInk,
    );
    final info = accent(
      roles.info,
      PrismRole.infoFill,
      PrismRole.infoOnFill,
      PrismRole.infoInk,
    );
    final focus = single(PrismRole.focus, roles.focus);
    final outline = single(PrismRole.outline, roles.outline);
    final divider = single(PrismRole.divider, roles.divider);

    return PrismScheme(
      canvas: canvasBeam,
      surface: surface,
      surfaceRaised: surfaceRaised,
      chrome: chrome,
      scrim: scrim,
      ink: ink,
      inkMuted: inkMuted,
      inkFaint: inkFaint,
      action: action,
      hero: hero,
      highlight: highlight,
      error: error,
      warning: warning,
      success: success,
      info: info,
      focus: focus,
      outline: outline,
      divider: divider,
      clampDeltas: Map.unmodifiable(deltas),
    );
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// [darkSeeds], [canvas] and [typography] are **clearable**: pass `null` to
  /// reset to the un-diverged / default-canvas / standard-typography behaviour,
  /// or omit the argument to keep the current value.
  PrismThemeSource copyWith({
    PrismSeeds? seeds,
    Object? darkSeeds = unset,
    Object? canvas = unset,
    PrismRoles? roles,
    Object? typography = unset,
    PrismSpacing? spacing,
    PrismGeometry? geometry,
    PrismStateLayers? stateLayers,
    PrismSplash? splash,
  }) => PrismThemeSource(
    seeds: seeds ?? this.seeds,
    darkSeeds:
        identical(darkSeeds, unset) ? this.darkSeeds : darkSeeds as PrismSeeds?,
    canvas:
        identical(canvas, unset)
            ? this.canvas
            : canvas as ({Beam<RayOklch> light, Beam<RayOklch> dark})?,
    roles: roles ?? this.roles,
    typography:
        identical(typography, unset)
            ? this.typography
            : typography as PrismTypography?,
    spacing: spacing ?? this.spacing,
    geometry: geometry ?? this.geometry,
    stateLayers: stateLayers ?? this.stateLayers,
    splash: splash ?? this.splash,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismThemeSource &&
          seeds == other.seeds &&
          darkSeeds == other.darkSeeds &&
          canvas == other.canvas &&
          roles == other.roles &&
          typography == other.typography &&
          spacing == other.spacing &&
          geometry == other.geometry &&
          stateLayers == other.stateLayers &&
          splash == other.splash;

  @override
  int get hashCode => Object.hash(
    seeds,
    darkSeeds,
    canvas,
    roles,
    typography,
    spacing,
    geometry,
    stateLayers,
    splash,
  );

  @override
  String toString() => 'PrismThemeSource(seeds: $seeds, roles: $roles)';
}

/// Chroma deltas below this are treated as noise (not reported).
///
/// The lightness-first resolve logic (a gamut-clamp safeguard) now lives on the
/// specs: `PrismRoleSpec.resolve` / `PrismAccentSpec.resolve` in `role_spec.dart`.
const double _deltaEpsilon = 1e-4;
