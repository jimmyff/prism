# Changelog

## 2.0.0

- Updated for Prism 2.0.0 compatibility

## 2.0.0-beta.2

- Uses Prism 2.0.0-beta.2 with standardized API

## 2.0.0-beta.1

**Breaking Changes:**

- Updated extensions for `RayRgb8` and `RayRgb16` classes (replaces `RayRgb`)
- Renamed `toRayRgb()` to `toRayRgb8()` for 8-bit color support
- Support for both 8-bit and 16-bit RGB precision

## 1.0.0

- Initial release with Flutter Color extensions
- Convert between RayRgb8 and Flutter Color objects
- Perfect fidelity conversions preserving ARGB information
- Zero overhead direct value conversions
