# prism_theme

An authored, compilable theme system built on [prism](https://pub.dev/packages/prism)'s perceptual Oklch colors.

Themes are **documents, not generators**: you author a readable `PrismThemeSource` — seeds plus a visible role table — and a pure `compile()` turns it into a `PrismTheme`. Roles are **intents** (`action`, `ink`, `hero`, `surface`, …), never palette slots.

## Principles

- **Authored, not generated.** Every role assignment is visible in one value; `compile()` is a pure function.
- **Intent roles.** A closed, minimal vocabulary of *usage* — three brand accents (`action`/`hero`/`highlight` ← primary/secondary/tertiary) plus four status accents, each a `fill`/`onFill`/`ink` trio; neutrals are `ink`/`inkMuted`/`inkFaint`.
- **Checked, never corrected.** `audit()` reports contrast failures against a policy; it never silently adjusts an authored color.
- **Alpha ink over a declared canvas.** Ink/structure roles are alpha colors that work over any surface — including a gradient `Beam` sky.
- **Everything lerps.** theme↔theme and light↔dark. `atDarkness(t)` is a *transition/effect* hook (animate light→dark), not a parked state — a linear crossfade sits ~1:1 ink/surface contrast near t=0.5.

## Roles

Intents, not palette slots. Each brand/status accent compiles to a `fill` / `onFill` / `ink` trio; neutrals are alpha inks that work over any surface.

| Role | Intent |
|---|---|
| `action` | primary interactive — buttons, links (← primary seed) |
| `hero` | expressive brand moments (← secondary seed; *not* Flutter's `Hero` widget) |
| `highlight` | attention / CTAs / live values (← tertiary seed; the accent *role* — Flutter's `highlightColor` interaction state is `stateLayers`) |
| `error` / `warning` / `success` / `info` | status accents |
| `ink` / `inkMuted` / `inkFaint` | text over any surface |
| `surface` / `surfaceRaised` / `chrome` | content / elevated / persistent chrome (`Beam` fills) |
| `focus` / `outline` / `divider` | interaction ring / borders / hairlines |

## Usage

```dart
import 'package:prism/prism.dart';
import 'package:prism_theme/prism_theme.dart';

final source = PrismThemeSource(
  seeds: PrismSeeds(
    primary:   RayOklch.fromComponents(0.55, 0.16, 264),
    secondary: RayOklch.fromComponents(0.60, 0.13, 200),
    tertiary:  RayOklch.fromComponents(0.62, 0.14, 320),
  ),
  // Optional gradient sky; omit for a flat neutral canvas.
  canvas: (
    light: Beam.flat(RayOklch.fromComponents(0.985, 0.004, 264)),
    dark: Beam.linear([
      RayOklch.fromComponents(0.16, 0.06, 300),
      RayOklch.fromComponents(0.22, 0.08, 262),
    ]),
  ),
);

final pair = source.compilePair();     // light + dark
final theme = pair.resolve(PrismBrightness.dark);
final ink = theme.scheme.ink;          // a RayOklch
final frame = pair.atDarkness(0.5);    // a light↔dark transition frame (animate, don't park)

// Accessibility is checked, not corrected:
assert(theme.audit().where((r) => !r.passes && !r.advisory).isEmpty);
```

Override any role by passing it — the rest keep the standard table:

```dart
PrismThemeSource(
  seeds: seeds,
  roles: const PrismRoles(
    focus: PrismRoleSpec(PrismSeed.tertiary, l: (light: 0.6, dark: 0.75)),
  ),
);
```

## Gradient fills

The three fill roles — `surface`, `surfaceRaised`, `chrome` — compile to `Beam`s (like `canvas`). They're flat by default; a `gradient` lightness delta on the role spec makes a subtle 2-stop top→bottom gradient — e.g. atmospheric dialogs:

```dart
PrismThemeSource(
  seeds: seeds,
  roles: const PrismRoles(
    surfaceRaised: PrismRoleSpec(
      PrismSeed.neutral, l: (light: 0.995, dark: 0.26), gradient: -0.05,
    ),
  ),
);
```

Add `gradientSeed` to shift the far stop's *hue* toward another seed — e.g. a purple → blue dialog:

```dart
surfaceRaised: PrismRoleSpec(
  PrismSeed.primary, l: (light: 0.98, dark: 0.28),
  gradient: -0.04, gradientSeed: PrismSeed.secondary,
),
```

Read a fill as a flat color via `scheme.surface.base` (or `context.prism.surface` in Flutter), or as a gradient via `scheme.surface` / `context.prism.surfaceGradient`. The contrast `audit()` samples gradient fills the same way it samples the canvas.

## Absolute colors & the `resolve` seam

A role or accent usually derives from a seed, but you can pin an **absolute** color with `.absolute` — it acts as an inline seed (the spec's `l`/`chroma`/`alpha` still apply, re-clamped to gamut, so it is not verbatim output):

```dart
PrismRoles(
  surface: PrismRoleSpec.absolute(
    RayOklch.fromComponents(0.97, 0.02, 264), l: (light: 0.97, dark: 0.21),
  ),
);
```

Every spec exposes that same transform as a public seam — apply a role's lightness/chroma/alpha to *any* base color (e.g. an app-domain color like a planet's hue), no theme seeds required:

```dart
final (:color, :clampDelta) = spec.resolve(planetColor, PrismBrightness.dark);
final resolved = spec.resolveSeed(seeds, brightness); // sugar; == the compiled role
```

`resolve` returns the flat color plus any chroma lost to gamut clamping; gradients stay compile-only (a gradient spec resolves to its top stop). Distinct from `PrismThemePair.resolve(brightness)`, which selects light vs dark.

## Conventions (primitives, not roles)

Some patterns are expressed with primitives rather than named roles:

- **Tonal fills / selection** — `scheme.wash(role, background, strength)` (accent tint at a given alpha over a background).
- **Hover / pressed state layers** — `scheme.composite(src, dst)` (the public source-over primitive).
- **Inverse chip** (tooltip/snackbar) — swap `ink`/`surface`.
- **Status as a continuum** — `scheme.success.ink.lerp(scheme.error.ink, t)`.
- **Disabled** — text uses `inkFaint`; a disabled fill is `wash(ink, surface, 0.12)`.
- **Stacking** — no third raised level: a menu over a dialog uses `outline` + `scrim`, not another surface tier.

The **focus ring** is modelled as an offset ring drawn *outside* the widget bounds (`PrismGeometry.focusOffset`/`focusWidth`) so it contrasts with the surface, never the fill — which is why the `focus` role can safely share the action seed. Ring rendering lands in the interface layer.

The `structure` contrast level (1.5) sits below WCAG's 3:1 non-text minimum — it is for decorative hairlines (`divider`), not functional boundaries.

## Persistence

Persist a tiny `PrismThemeSelection` (`sourceId` + brightness), not the compiled scheme. Keep sources in code keyed by `sourceId` and recompile at boot. Brightness is a discrete light/dark choice — store it as a bool and rebuild with `PrismBrightness.of(isDark)` if you prefer.

See [prism_theme_flutter](../prism_theme_flutter) for the Flutter `ThemeData` + `PrismThemeExtension` bridge, and `example/example.dart` / `tool/preview.dart` to see a theme "show its work".

## Status

Pre-release (`publish_to: none`) — proving in kosmos2 before publishing.
