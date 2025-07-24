/// Test tolerance constants for color space conversions and comparisons.
///
/// This file contains standardized tolerance values used across all test files
/// to ensure consistency and maintainability in test assertions.
library;

// ============================================================================
// Color Conversion Tolerance Constants
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
/// color space transformations, accounting for rounding in integer conversion.
const double rgbTolerance = 1.0;

/// Tolerance for hue angle values in degrees (0-360 range).
///
/// Used for hue comparisons where slight variations due to color space
/// conversions or floating-point precision are acceptable.
const double hueTolerance = 1.0;

/// Tolerance for Oklab conversions (accounts for gamma correction precision).
///
/// Used specifically for Oklab color space conversions which involve complex
/// mathematical transformations with gamma correction that can introduce
/// small precision differences.
const double oklabTolerance = 0.001;

/// Tolerance for perceptual color space conversions with some expected drift.
///
/// Used for color space conversions where perceptual differences are expected
/// due to the nature of the transformation algorithms.
const double perceptualTolerance = 0.1;

/// Tolerance for round-trip conversions with cumulative precision loss.
///
/// Used for testing round-trip conversions (e.g., RGB → HSL → Oklab → RGB)
/// where multiple transformations can accumulate small precision errors.
const double roundTripTolerance = 0.2;
