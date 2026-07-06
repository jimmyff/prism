# prism_theme_flutter

Flutter bindings for [prism_theme](../prism_theme).

Compile an authored source into a `PrismThemeExtension` on your `ThemeData`, then read intent roles anywhere via `context.prism`:

```dart
final pair = source.compilePair();

MaterialApp(
  theme: pair.light.toThemeData(),
  darkTheme: pair.dark.toThemeData(),
  themeMode: isDark ? ThemeMode.dark : ThemeMode.light, // your light/dark toggle
  // ...
);

// In a widget:
Container(color: context.prism.actionFill);
DecoratedBox(decoration: BoxDecoration(gradient: context.prism.canvas));
```

`MaterialApp` wraps its theme in an `AnimatedTheme`, so toggling `themeMode` cross-fades light↔dark for free.

Persist only a `PrismThemeSelection` (`sourceId` + brightness), never the compiled scheme, and recompile at boot:

```dart
final selection = PrismThemeSelection(
  sourceId: 'kosmos',
  brightness: PrismBrightness.of(isDark),
);
// store selection.toJson(); at boot: sources[selection.sourceId]!.compilePair()
```

`toThemeData` maps a **complete** `ColorScheme` (tonal containers + `on…Container`, fixed variants, an explicit inverse trio, and the `surfaceDim`/`surfaceBright`/`surfaceContainer*` ramp) and `TextTheme`, so stock Material widgets are themed; the authored `surface` is composited to an opaque `ColorScheme.surface`. The perceptual (OKLCH) interpolation guarantee holds through `context.prism` — Material animates the mapped `ColorScheme` in sRGB. `context.prism.surface` keeps the authored (possibly translucent) surface for frosted panels.

## Status

Pre-release (`publish_to: none`) — proving in kosmos2 before publishing.
