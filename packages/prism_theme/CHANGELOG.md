# Changelog

## 0.2.0

- `PrismTextStyle.fontVariations` — variable-font axes (`PrismFontVariation(tag, value)`, 4-char tag). Compared with set semantics (order-insensitive, last-wins per axis); `lerp` takes a per-axis union (shared axes interpolate, one-sided axes snap at t=0.5) and emits a canonical sorted list.
- `PrismTextStyle.textCase` — a render-time case transform (`PrismTextCase.none`/`upper`/`lower`, with `apply(String)`); snaps at t=0.5 in `lerp`.
- `PrismTypography` gains an eighth slot, `data` — a same-size `body` sibling for a second (typically monospace) voice. `fromScale` gives it `body`'s step (`data == body`), so its signature is unchanged. **Breaking:** the `PrismTypography` const constructor now requires `data`.

## 0.1.0

- Initial release: authored `PrismThemeSource` → pure `compile()` → `PrismTheme`; intent-based roles, `Beam` canvas, contrast `audit()`, and light/dark/`atDarkness(t)` interpolation.
- Fill roles (`surface`/`surfaceRaised`/`chrome`) are `Beam`s — flat by default, or a gradient via a role's `gradient` lightness delta and/or `gradientSeed` hue shift.
- Three brand accents — `action` (primary), `hero` (secondary), `highlight` (tertiary, for attention/CTAs) — plus four status accents, each a `fill`/`onFill`/`ink` trio.
- Interaction tokens: `PrismGeometry.outlineWidth` (default 1.2), `PrismStateLayers` (hover/focus/pressed opacities), and a `PrismSplash` enum — carried on the theme.
- Absolute-color escape hatch: `PrismColorBase` sealed union (`.seed`/`.inline`) with `PrismRoleSpec.absolute` / `PrismAccentSpec.absolute`; a public `resolve`/`resolveSeed` seam applying a spec's lightness/chroma/alpha to any base color.
- `PrismThemeSelection` persists `sourceId` + brightness (a discrete light/dark choice); `PrismBrightness.of(bool)` bridges a stored bool. `atDarkness(t)` is a transition/effect hook, not a parked state.
- `copyWith` on `PrismRoles` and `PrismScheme` (drops `clampDeltas` as un-audited); clearable `copyWith` (pass `null`) for the nullable fields of `PrismThemeSource` / `PrismRoleSpec`.
- New tokens: `PrismGeometry.radiusFull` (stadium/max radius) and `PrismTextStyle.fontStyle` (`PrismFontStyle.normal`/`italic`).
- `audit()` flattens translucent fills over the canvas before measuring, and adds coverage rows (accent `ink` vs chrome, `fill` vs canvas, `focus` vs chrome; advisory `divider` rows).
