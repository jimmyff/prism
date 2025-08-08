# Changelog

## 2.0.0

- Private color components with named getters
- Added `with$Component()` transformers to all color models
- Unified `RayWithLuminance<T extends Ray>` implementation
- Renamed internal palette types: `Spectrum` → `Rainbow`, `RayScheme` → `Spectrum`
- Added `fixedRays` to palettes for non-converted colors (black, white)

## 2.0.0-beta.2

- Unified RGB channel access: standardized getters return 0-255 range
- Added native value getters for full bit precision
- Private primary constructors with consistent factory methods
- Removed redundant `fromArgb` constructor
- Standardized constructor naming across all color models

## 2.0.0-beta.1

**New Features:**

- Multi-color space support: HSL, Oklab, Oklch alongside RGB8/RGB16
- Perceptually uniform color operations via Oklab
- Intelligent color schemes with accessibility tools
- Pre-built palettes: CSS, Material, OpenColor, Rainbow
- Palette generation tools with PNG and CSS output

**Breaking Changes:**

- Split `RayRgb` into `RayRgb8` (8-bit) and `RayRgb16` (16-bit)
- Updated API structure for multiple color spaces
- Enhanced palette system with pre-computed schemes

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
