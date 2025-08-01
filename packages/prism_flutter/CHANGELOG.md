## 2.0.0-beta.1

**Breaking Changes:**
- **RayRgb split**: Updated extensions for `RayRgb8` and `RayRgb16` classes (replaces `RayRgb`)
- **Extension methods**: `toRayRgb()` renamed to `toRayRgb8()` for 8-bit color support
- **Multi-precision RGB**: Support for both 8-bit (0-255) and 16-bit (0-65535) color channels


## 1.0.0

- Initial release of Prism Flutter extensions
- **RayRgb8 to Flutter Color**: Convert RayRgb8 objects to Flutter Color with `toColor()` and `toColorWithOpacity()`
- **Flutter Color to RayRgb8**: Convert Flutter Colors to RayRgb8 objects with `toRayRgb8()`
- **Perfect fidelity**: All conversions preserve complete ARGB color information
- **Zero overhead**: Direct value conversions with no performance cost
- **Enhanced manipulation**: Access RayRgb8's powerful color operations from Flutter Colors
- **Round-trip conversions**: RayRgb8 ↔ Color conversions maintain perfect fidelity
- **Comprehensive tests**: Full test coverage for all extension methods and edge cases
