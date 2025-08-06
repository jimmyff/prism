## 2.0.0-beta.2

**API Standardization:**
- **Unified channel access**: Both RayRgb8 and RayRgb16 now provide standardized `red`, `green`, `blue`, `alpha` getters returning 0-255 range (type `num`)
- **Native value access**: Added `redNative`, `greenNative`, `blueNative`, `alphaNative` getters for accessing native bit precision values
- **Consistent API**: Simplified color channel access across different bit depths while preserving precision
- **Private primary constructors**: All color model classes now use private primary constructors with consistent factory method APIs
- **Simplified API**: Removed redundant `fromArgb` constructor from RayRgb8 in favor of `fromComponents`
- **Consistent patterns**: Standardized constructor naming across RGB8, RGB16, HSL, Oklab, and Oklch classes

## 2.0.0-beta.1

**Major Changes:**
- **Multi-color space support**: Added RayHsl, RayOklab, and RayOklch alongside RayRgb8/RayRgb16
- **Perceptually uniform color operations**: via Oklab color space
- **RayScheme system**: Intelligent color schemes with accessibility and tonal palettes
- **Pre-built palettes**: CSS, Material, OpenColor, and Spectrum with pre-computed luminance
- **Palette output generation**: Efficient dart enums, PNG palette previews, CSS output
- **Enhanced gallery**: Compact Oklch-focused HTML previews with luminance data

**Breaking Changes:**
- **RayRgb split**: Separated `RayRgb` into `RayRgb8` (8-bit) and `RayRgb16` (16-bit)
- **Multi-precision RGB**: Support for both 8-bit (0-255) and 16-bit (0-65535) color channels
- **API structure**: Updated to support multiple color spaces (RayRgb8, RayRgb16, RayHsl, RayOklab, RayOklch)
- **New palette system**: Enhanced palette generation with pre-computed schemes

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
