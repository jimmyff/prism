## 2.0.0-alpha.2

### Breaking Changes
- Added `RayOklab` class - extends color model count from 2 to 3 (RGB, HSL, Oklab)
- Added `ColorModel.oklab` enum value for runtime type identification

### New Features
- **RayOklab Color Space**: Perceptually uniform Oklab color space for better color manipulation and more accurate interpolation
  - Components: L (lightness), a (green-red axis), b (blue-yellow axis)
  - Full conversion support: RGB ↔ Oklab, HSL ↔ Oklab
- **Universal Conversion**: Added `toOklab()` method to `Ray` base class

### Improvements
- Optimized Oklab conversion algorithms with proper gamma correction
- Updated documentation with Oklab usage examples and benefits

## 2.0.0-alpha.1

### Breaking Changes
- Renamed `Ray` class to `RayRgb` for multiple color model support
- Updated `RayRgb` constructor to use named parameters: `RayRgb(red: r, green: g, blue: b)`
- Removed `fromRGBO()` method in favor of named parameter constructor

### New Features
- **Ray Base Class**: Abstract base class for unified color model interface
  - Shared methods: `computeLuminance()`, `withOpacity()`, `lerp()`, `inverse`, `maxContrast()`
  - `ColorModel` enum for runtime type identification
- **RayHsl Color Model**: HSL (Hue, Saturation, Lightness) color manipulation
  - HSL-specific methods: `withHue()`, `withSaturation()`, `withLightness()`
  - Intelligent hue interpolation with color wheel wraparound
- **RayScheme**: Accessibility-focused color schemes
  - Automatic contrast text colors (onRay) for readability
  - Dark and light surface variants with luminance targeting
  - W3C WCAG luminance calculations
- **Color Palettes**: Pre-built palette system with RayScheme support
  - CSS Colors (147 colors), Material Design, Catppuccin (4 variants), Solarized, Open Color

### Improvements
- Seamless RGB ↔ HSL conversion with round-trip fidelity
- Palette generation tools in `tools/` directory
- Updated main library export to include RayScheme

## 1.0.0

- Initial release of Prism - a comprehensive color manipulation library
- **Ray class**: Clean, intuitive API for color operations
- **Multiple formats**: Support for RGB, ARGB, hex strings, and CSS strings
- **Dual hex format support**: Both web standard (RGBA) and Flutter/Android (ARGB) formats
- **Performance optimized**: Efficient bit operations with zero dependencies
- **Type safe**: Comprehensive error handling and validation
- **WCAG compliance**: Luminance calculations for accessibility
- **Color operations**: Interpolation, inversion, opacity/alpha manipulation
- **Flutter compatible**: Internal ARGB format matches Flutter's Color class
- **Comprehensive test coverage**: 38+ tests covering all functionality
