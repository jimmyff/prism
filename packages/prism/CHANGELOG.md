## 2.0.0-alpha.4

### New Features
- **Gamut Clipping**: Added smart gamut clipping for Oklab and Oklch color spaces (based on Björn Ottosson's research)
  - `getMaxValidChroma()` calculates maximum valid chroma for any lightness/hue combination
  - `findMaxChromaPoint()` determines cusp points for color boundaries
  - Automatic clipping in `withChroma()` and `withLightness()` methods keeps colors within sRGB gamut
- **Expanded RayScheme**: Redesigned shade system with Material Design-style organization
  - **13 tonal shades**: `shade0` through `shade1000` (including 50, 950 variants)
  - **4 accent variants**: `accent100`, `accent200`, `accent400`, `accent700` for UI emphasis
  - Fine-grained control over color relationships for design systems
- **Gallery Generation**: New palette visualization and export tools
  - Interactive HTML galleries with side-by-side RGB/Oklch comparisons
  - PNG image exports and web-ready CSS files in both RGB and Oklch formats
  - Automated generation via `build_gallery.dart`, `palette_html_generator.dart`, and `palette_image_generator.dart`

### Improvements
- Better color accuracy with precise gamut boundary calculations
- Streamlined palette generation with multiple output formats

## 2.0.0-alpha.3

### New Features
- **RayOklch Color Space**: Cylindrical form of Oklab with intuitive lightness, chroma, and hue controls
  - Components: L (lightness 0.0-1.0), C (chroma ≥0), H (hue 0.0-360.0°)
  - Intuitive manipulation methods: `withChroma()`, `withHue()`, `withLightness()`
  - Hue-aware interpolation with shortest path around color wheel
  - Perfect for color harmonies and systematic color generation
- **Universal Conversion**: Added `toOklch()` method to `Ray` base class and all color models
- **ColorModel Enhancement**: Added `ColorModel.oklch` enum value for runtime type identification

### Improvements
- Extended color conversion tests to cover all 4 color models (RGB, HSL, Oklab, Oklch)
- Updated documentation and examples with comprehensive Oklch usage patterns
- Enhanced `RayScheme` to support Oklch color model

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
  - Spectrum (Prism's own palette), CSS Colors (147 colors), Material Design, Open Color

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
