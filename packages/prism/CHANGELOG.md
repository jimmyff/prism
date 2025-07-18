## 1.1.0

- **Major Feature**: Added `RayScheme` class for accessibility-focused color schemes
  - Automatic generation of contrast text colors (onRay) for optimal readability
  - Dark and light surface variants with intelligent luminance targeting
  - W3C WCAG relative luminance calculations for perceptual accuracy
  - `isDark`/`isLight` classification and theme-appropriate color generation
- **Color Palettes**: Extensive pre-built color palette system
  - **CSS Colors**: Complete 147-color CSS palette with RayScheme support
  - **Material Design**: Material Design color system
  - **Catppuccin**: All four theme variants (Latte, Frappé, Macchiato, Mocha)
  - **Solarized**: Classic Solarized color scheme
  - **Open Color**: Open Color palette system
  - Each palette color includes pre-computed RayScheme for optimal performance
- **Enhanced API**: Updated main library export to include RayScheme
- **Performance**: Optimized palette generation with pre-computed accessibility schemes
- **Documentation**: Comprehensive examples and gallery HTML files for all palettes
- **Tooling**: Added palette generation and management tools in `tools/` directory

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
