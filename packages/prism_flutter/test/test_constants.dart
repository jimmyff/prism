/// Test tolerance constants for Flutter color conversions and comparisons.
///
/// This file contains standardized tolerance values used across all test files
/// to ensure consistency and maintainability in test assertions, particularly
/// for Flutter Color ↔ RayRgb conversions where floating-point precision
/// and rounding can introduce small variations.
library test_constants;

// ============================================================================
// Flutter Color Conversion Tolerance Constants
// ============================================================================

/// High precision tolerance for exact mathematical conversions.
///
/// Used for precise calculations where minimal floating-point error is expected,
/// such as perfect color space transformations and exact value comparisons.
const double precisionTolerance = 1e-10;

/// Standard tolerance for floating-point color component values (0.0-1.0 range).
///
/// Used for opacity, saturation, lightness, and other normalized color components
/// where small floating-point precision differences are acceptable.
const double componentTolerance = 0.01;

/// Tolerance for RGB component values (0-255 integer range).
///
/// Used when comparing RGB color components that have been converted through
/// Flutter Color ↔ RayRgb transformations, accounting for rounding in integer conversion.
/// This is particularly important when converting between Flutter's double-based
/// color representation and RayRgb's integer-based representation.
const double rgbTolerance = 1.0;

/// Tolerance for Flutter Color alpha/RGB component conversions.
///
/// Used specifically for Flutter Color conversions where floating-point
/// to integer conversions can introduce rounding differences (e.g., 0.5 * 255 = 127.5
/// could round to either 127 or 128 depending on the implementation).
const double flutterColorTolerance = 1.0;

/// Tolerance for opacity conversions between double (0.0-1.0) and int (0-255).
///
/// Used when converting opacity values between Flutter's normalized double
/// representation and RayRgb's integer alpha representation.
const double opacityTolerance = 0.01;

/// Tolerance for round-trip conversions with cumulative precision loss.
///
/// Used for testing round-trip conversions (e.g., RayRgb → Color → RayRgb)
/// where multiple transformations can accumulate small precision errors.
const double roundTripTolerance = 2.0;