import 'package:prism/prism.dart';

enum ShadeType {
  shade,
  accent,
}

enum Shade {
  shade0(lightnessModifier: 0.98, chromaModifier: 0.12),
  shade50(lightnessModifier: 0.96, chromaModifier: 0.28),
  shade100(lightnessModifier: 0.9, chromaModifier: 0.4),
  shade200(lightnessModifier: 0.79, chromaModifier: 0.6),
  shade300(lightnessModifier: 0.7, chromaModifier: 0.8),
  shade400(lightnessModifier: 0.62, chromaModifier: 0.9),
  shade500(lightnessModifier: 0.55, chromaModifier: 1.0),
  shade600(lightnessModifier: 0.5, chromaModifier: 1.0),
  shade700(lightnessModifier: 0.42, chromaModifier: 1.0),
  shade800(lightnessModifier: 0.35, chromaModifier: 1.0),
  shade900(lightnessModifier: 0.25, chromaModifier: 1.0),
  shade950(lightnessModifier: 0.15, chromaModifier: 1.1),
  shade1000(lightnessModifier: 0.01, chromaModifier: 1.2),
  accent100(lightnessModifier: 0.75, fixedChroma: 1.0, type: ShadeType.accent),
  accent200(lightnessModifier: 0.63, fixedChroma: 1.0, type: ShadeType.accent),
  accent400(lightnessModifier: 0.55, fixedChroma: 0.8, type: ShadeType.accent),
  accent700(lightnessModifier: 0.42, fixedChroma: 0.9, type: ShadeType.accent),
  ;

  final double lightnessModifier;
  final double? chromaModifier;
  final double? fixedChroma;
  final ShadeType type;

  const Shade(
      {required this.lightnessModifier,
      this.chromaModifier,
      this.fixedChroma,
      this.type = ShadeType.shade});

  // returns a value of the range 0.4 - 1.0
  double get lightness => lightnessModifier * 0.8 + 0.2;
}

/// A color with precomputed luminance and convenient accessibility getters.
///
/// Combines a Ray color with its luminance value and provides convenient
/// methods for accessibility calculations.
class RayWithLuminance<T extends Ray> {
  /// Luminance threshold for dark vs light classification
  static const double _darkThreshold = 0.5;
  
  /// The color value
  final T ray;
  
  /// The precomputed luminance value (0.0 to 1.0)
  final double luminance;
  
  /// Creates a RayWithLuminance with the given ray and luminance
  const RayWithLuminance({required this.ray, required this.luminance});
  
  /// Whether this color is considered dark (luminance < 0.5)
  bool get isDark => luminance < _darkThreshold;
  
  /// Whether this color is considered light (luminance >= 0.5)
  bool get isLight => !isDark;
  
  /// Returns appropriate contrast color (black/white) for text on this color
  T get onRay {
    final black = RayOklch(l: 0.0, c: 0.0, h: 0.0, opacity: 1.0);
    final white = RayOklch(l: 1.0, c: 0.0, h: 0.0, opacity: 1.0);
    return isDark ? white.toColorSpace<T>() : black.toColorSpace<T>();
  }
  
  @override
  bool operator ==(Object other) => 
      identical(this, other) || 
      (other is RayWithLuminance && 
       other.ray == ray && 
       other.luminance == luminance);
       
  @override
  int get hashCode => Object.hash(ray, luminance);
  
  @override
  String toString() => 'RayWithLuminance(ray: $ray, luminance: ${luminance.toStringAsFixed(3)})';
}

/// A color scheme that provides harmonious color relationships based on a primary color.
///
/// Automatically generates:
/// - Contrast text color (onRay) for accessibility
/// - A complete tonal palette with shades from darkest to lightest
/// - Accessibility-compliant luminance calculations using W3C WCAG standards
///
/// The scheme uses perceptual luminance to determine appropriate contrast colors
/// and generates a full range of tonal variations by adjusting lightness in Oklch space.
///
/// Example:
/// ```dart
/// final scheme = RayScheme.fromRay(RayRgb.fromHex('#2196F3'));
/// print(scheme.source.isDark); // false
/// print(scheme.source.onRay.toHexStr()); // '#000000' (black text on blue)
/// print(scheme.source.luminance); // 0.540 (computed luminance)
///
/// // Access different shades
/// final lightestShade = scheme.shade50;    // Lightest shade 
/// final darkestShade = scheme.shade900;    // Darkest shade
/// final midShade = scheme.shade500;        // Mid-tone shade
/// ```
class RayScheme<T extends Ray> {
  /// Luminance threshold for dark vs light classification
  static const double _darkThreshold = 0.5;

  /// The primary color this scheme is based on
  final RayWithLuminance source;

  /// A complete tonal palette along with their luminance values
  ///
  /// Contains shades from shade50 (lightest) to shade900 (darkest)
  /// following Material Design shade naming conventions.
  /// Each shade maps to a RayWithLuminance object containing both the
  /// color and its cached luminance value.
  final Map<Shade, RayWithLuminance> shades;

  /// Access shades using Material Design naming convention
  RayWithLuminance get shade50 => shades[Shade.shade50]!;
  RayWithLuminance get shade100 => shades[Shade.shade100]!;
  RayWithLuminance get shade200 => shades[Shade.shade200]!;
  RayWithLuminance get shade300 => shades[Shade.shade300]!;
  RayWithLuminance get shade400 => shades[Shade.shade400]!;
  RayWithLuminance get shade500 => shades[Shade.shade500]!;
  RayWithLuminance get shade600 => shades[Shade.shade600]!;
  RayWithLuminance get shade700 => shades[Shade.shade700]!;
  RayWithLuminance get shade800 => shades[Shade.shade800]!;
  RayWithLuminance get shade900 => shades[Shade.shade900]!;

  /// Creates a color scheme with all properties explicitly specified.
  ///
  /// For most use cases, prefer [RayScheme.fromRay] which automatically
  /// computes all derived colors and properties.
  const RayScheme({
    required this.source,
    required this.shades,
  });

  factory RayScheme.fromShades({
    T? base,
    required Map<Shade, T> shades,
  }) {
    // Convert map to RayWithLuminance values
    final Map<Shade, RayWithLuminance<T>> shadesMap = {};
    for (final entry in shades.entries) {
      final shade = entry.value;
      shadesMap[entry.key] = RayWithLuminance(ray: shade, luminance: shade.luminance);
    }

    // Use shade500 (middle shade) as default base
    final ray = base ?? shades[Shade.shade500]!;
    final luminance = ray.luminance;

    return RayScheme(
      source: RayWithLuminance(ray: ray, luminance: luminance),
      shades: shadesMap,
    );
  }

  /// Creates a complete color scheme from a primary color.
  ///
  /// Automatically computes:
  /// - Luminance using W3C WCAG standards
  /// - Appropriate contrast color (onRay)
  /// - Complete tonal palette with Material Design shades
  /// - Dark/light classification
  ///
  /// The tonal palette is generated by creating variations of the base color
  /// with lightness values from 0.0 to 1.0 in increments of 0.1, preserving
  /// the original hue and chroma characteristics.
  ///
  /// The optional [hueTransform] function allows for custom hue adjustments
  /// based on the lightness difference between a shade and the base color.
  /// It receives the base hue and a lightness delta (positive for lighter,
  /// negative for darker) and should return the new hue.
  ///
  /// The optional [chromaTransform] function allows for custom chroma
  /// adjustments. It receives the shade's base chroma (after applying
  /// `chromeModifier`) and the lightness delta, and should return the new chroma.
  ///
  /// Example:
  /// ```dart
  /// final blueScheme = RayScheme.fromRay(RayRgb.fromHex('#2196F3'));
  /// final redScheme = RayScheme.fromRay(
  ///   RayRgb.fromHex('#F44336'),
  ///   hueTransform: (hue, delta) => hue + (delta * 20), // Rotate hue based on lightness
  ///   chromaTransform: (chroma, delta) => chroma - delta.abs() * 0.1,
  /// );
  /// ```
  factory RayScheme.fromRay(T ray, {bool? generateAccents}) {
    final luminance = ray.luminance;
    final rayOklch = ray.toOklch();

    // only generate accents for colors with chroma > 0.1
    generateAccents ??= rayOklch.c > 0.1;

    // Generate tonal palette using Shade enum lightness values
    final Map<Shade, RayWithLuminance<T>> shadesMap = {};
    for (final shade in Shade.values) {
      if (shade.type == ShadeType.accent && !generateAccents) continue;

      final shadeOklch = rayOklch
          .withChroma(shade.fixedChroma ?? (rayOklch.c * shade.chromaModifier!))
          .withLightness(shade.lightness);
      final shadeRay = shadeOklch.toColorSpace<T>();
      shadesMap[shade] = RayWithLuminance(ray: shadeRay, luminance: shadeRay.luminance);
    }

    return RayScheme(
      source: RayWithLuminance(ray: ray, luminance: luminance),
      shades: shadesMap,
    );
  }

  /// A darker surface variant of the primary color
  ///
  /// Returns shade700 for dark surface usage.
  T get surfaceDark => shade700.ray as T;

  /// A lighter surface variant of the primary color
  ///
  /// Returns shade100 for light surface usage.
  T get surfaceLight => shade100.ray as T;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RayScheme &&
        other.source == source &&
        _mapEquals(other.shades, shades);
  }

  @override
  int get hashCode => Object.hash(
        source,
        Object.hashAll(shades.entries
            .map((e) => Object.hash(e.key, e.value))),
      );

  @override
  String toString() => 'RayScheme('
      'source: ${source.ray.colorSpace.name}(${source.ray.toString()}), '
      'shades: ${shades.length}'
      ')';

  /// Helper function to compare two shade maps for equality
  static bool _mapEquals(
      Map<Shade, RayWithLuminance> a, Map<Shade, RayWithLuminance> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final bValue = b[entry.key];
      if (bValue == null || bValue != entry.value) {
        return false;
      }
    }
    return true;
  }
}
