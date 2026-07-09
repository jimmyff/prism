# Changelog

## 0.2.0

- Converter maps `PrismTextStyle.fontVariations` → Flutter `FontVariation`s and reconciles `wght`: synthesizes `FontVariation('wght', fontWeight)` when absent, or derives `FontWeight` from an explicit `wght` axis (rounded to the nearest 100, clamped `[100, 900]`) so fallback fonts and metrics agree. Styles with no variations are byte-for-byte unchanged. `textCase` is intentionally not mapped (apply it at the widget layer).
- `toTextTheme` documents the new `data` slot as extension-only (unmapped); read it via `context.prism.typography.data`.
- New `package:prism_theme_flutter/preview.dart` entrypoint exporting `PrismThemePreviewScreen` — a self-contained dev tool that compiles any `PrismThemeSource`, toggles brightness, and shows role/typography/beam/token sections plus a live `audit()` panel. Requires `prism_theme ^0.2.0`.

## 0.1.0

- Initial release: `PrismThemeExtension` (+ `context.prism`), `PrismTheme.toThemeData`/`toColorScheme`/`toTextTheme`, and `PrismBrightness`/`PrismTextStyle` converters. Re-exports `prism_flutter` and `prism_theme`.
- `context.prism` exposes `surfaceGradient`/`surfaceRaisedGradient`/`chromeGradient` for gradient fills.
- `context.prism` exposes `geometry`/`spacing`/`typography`/`stateLayers` getters and a `stateLayer(color)` overlay builder; `toThemeData` maps `PrismSplash` → `splashFactory`.
- Completed `toColorScheme`: tonal containers (+ `on…Container`), fixed variants, an explicit inverse trio, and the `surfaceDim`/`surfaceBright`/`surfaceContainer*` ramp (`surfaceTint` off). The authored `surface` is composited to an opaque `ColorScheme.surface`. `toThemeData` also sets the legacy `dividerColor`/`cardColor`/`hintColor`/`disabledColor` fallbacks.
- `PrismTextStyle.fontStyle` → Flutter `FontStyle` (italic support).
