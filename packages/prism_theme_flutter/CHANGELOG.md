# Changelog

## 0.1.0

- Initial release: `PrismThemeExtension` (+ `context.prism`), `PrismTheme.toThemeData`/`toColorScheme`/`toTextTheme`, and `PrismBrightness`/`PrismTextStyle` converters. Re-exports `prism_flutter` and `prism_theme`.
- `context.prism` exposes `surfaceGradient`/`surfaceRaisedGradient`/`chromeGradient` for gradient fills.
- `context.prism` exposes `geometry`/`spacing`/`typography`/`stateLayers` getters and a `stateLayer(color)` overlay builder; `toThemeData` maps `PrismSplash` → `splashFactory`.
- Completed `toColorScheme`: tonal containers (+ `on…Container`), fixed variants, an explicit inverse trio, and the `surfaceDim`/`surfaceBright`/`surfaceContainer*` ramp (`surfaceTint` off). The authored `surface` is composited to an opaque `ColorScheme.surface`. `toThemeData` also sets the legacy `dividerColor`/`cardColor`/`hintColor`/`disabledColor` fallbacks.
- `PrismTextStyle.fontStyle` → Flutter `FontStyle` (italic support).
