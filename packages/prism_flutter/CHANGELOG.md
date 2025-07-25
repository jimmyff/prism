## 2.0.0-alpha.2

- **New Feature**: Full support for `RayOklch` color model with seamless Flutter integration
- **Enhanced Conversion**: All 4 color models (RGB, HSL, Oklab, Oklch) now convert perfectly to Flutter Colors
- **Updated Dependencies**: Compatible with Prism 2.0.0-alpha.3 and its enhanced color model support

## 2.0.0-alpha.1

- **BREAKING CHANGE**: Updated to use `RayRgb` class instead of `Ray` (follows Prism 1.1.0)
- **New Feature**: Support for `RayHsl` colors with automatic RGB conversion for Flutter compatibility
- **Enhanced Integration**: Full support for Prism 1.1.0 features including base `Ray` class interface
- **RayScheme Support**: Seamless conversion of RayScheme colors to Flutter Colors
  - Convert scheme colors (`onRay`, `surfaceLight`, `surfaceDark`) directly to Flutter Colors
  - Create accessibility-focused Flutter themes using RayScheme
- **Color Palette Integration**: Easy access to all Prism color palettes from Flutter
  - Convert any palette color to Flutter Color with perfect fidelity
  - Use Spectrum, Material, CSS, and OpenColor palettes in Flutter apps
- **Enhanced Examples**: Updated documentation with RayScheme and palette usage patterns
- **Dependency Update**: Updated to require Prism ^1.1.0 for new features

## 1.0.0

- Initial release of Prism Flutter extensions
- **Ray to Flutter Color**: Convert Ray objects to Flutter Color with `toColor()` and `toColorWithOpacity()`
- **Flutter Color to Ray**: Convert Flutter Colors to Ray objects with `toRay()`
- **Perfect fidelity**: All conversions preserve complete ARGB color information
- **Zero overhead**: Direct value conversions with no performance cost
- **Enhanced manipulation**: Access Ray's powerful color operations from Flutter Colors
- **Round-trip conversions**: Ray ↔ Color conversions maintain perfect fidelity
- **Comprehensive tests**: Full test coverage for all extension methods and edge cases
