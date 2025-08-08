import 'package:prism/prism.dart';

enum ToneType {
  shade,
  accent,
}

enum RayTone {
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

  // Todo: for accents could we find the gamut cusp for the hue?
  accent100(lightnessModifier: 0.85, fixedChroma: 1.0, type: ToneType.accent),
  accent200(lightnessModifier: 0.75, fixedChroma: 1.0, type: ToneType.accent),
  accent400(lightnessModifier: 0.65, fixedChroma: 0.9, type: ToneType.accent),
  accent700(lightnessModifier: 0.42, fixedChroma: 0.8, type: ToneType.accent),
  ;

  final double lightnessModifier;
  final double? chromaModifier;
  final double? fixedChroma;
  final ToneType type;

  const RayTone(
      {required this.lightnessModifier,
      this.chromaModifier,
      this.fixedChroma,
      this.type = ToneType.shade});

  // returns a value of the range 0.4 - 1.0
  double get lightness => lightnessModifier * 0.8 + 0.2;
}

/// Color with cached luminance for performance.
final class RayWithLuminance<T extends Ray> extends Ray {
  /// The wrapped Ray instance
  final T _ray;

  /// Cached luminance value (0.0 to 1.0)
  final double _precomputedLuminance;

  /// Creates RayWithLuminance with cached luminance
  const RayWithLuminance(this._ray, this._precomputedLuminance) : super();

  /// Factory with automatic type inference
  static RayWithLuminance<T> fromRay<T extends Ray>(T ray) {
    final luminance = ray.luminance;
    return RayWithLuminance(ray, luminance);
  }

  /// Returns cached luminance
  @override
  double get luminance => _precomputedLuminance;

  /// Whether this color is considered dark
  bool get isDark => switch (colorSpace) {
        ColorSpace.oklab || ColorSpace.oklch => luminance < 0.70,
        _ => luminance < 0.5
      };

  @override
  ColorSpace get colorSpace => _ray.colorSpace;

  /// Whether this color is considered light.
  bool get isLight => !isDark;

  /// Returns contrast color for text on this color.
  RayWithLuminance get onRay {
    return switch (_ray.colorSpace) {
      ColorSpace.oklch => isDark
          ? const RayWithLuminance<RayOklch>(
              RayOklch.fromComponents(1.0, 0.0, 0.0, 1.0), 1.0)
          : const RayWithLuminance<RayOklch>(
              RayOklch.fromComponents(0.0, 0.0, 0.0, 1.0), 0.0),
      _ => isDark
          ? const RayWithLuminance<RayRgb8>(
              RayRgb8.fromArgbInt(0xFFFFFFFF), 1.0)
          : const RayWithLuminance<RayRgb8>(
              RayRgb8.fromArgbInt(0xFF000000), 0.0),
    };
  }

  @override
  double get opacity => _ray.opacity;

  /// Returns hex string.
  String toHex([int length = 6, HexFormat format = HexFormat.rgba]) {
    return _ray.toRgb8().toHex(length, format);
  }

  // Ray interface implementation - delegate to wrapped ray
  @override
  RayWithLuminance<T> withOpacity(double opacity) {
    final newRay = _ray.withOpacity(opacity) as T;
    return RayWithLuminance<T>(newRay, luminance);
  }

  @override
  Ray lerp(Ray other, double t) => _ray.lerp(other, t);

  @override
  Ray get inverse => _ray.inverse;

  @override
  RayRgb8 toRgb8() => _ray.toRgb8();

  @override
  RayRgb16 toRgb16() => _ray.toRgb16();

  @override
  RayHsl toHsl() => _ray.toHsl();

  @override
  RayOklab toOklab() => _ray.toOklab();

  @override
  RayOklch toOklch() => _ray.toOklch();

  @override
  dynamic toJson() => _ray.toJson();

  @override
  List<num> toList() => _ray.toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RayWithLuminance && other._ray == _ray);

  @override
  int get hashCode => _ray.hashCode;

  @override
  String toString() => _ray.toString();
}

/// Type alias for backward compatibility and cleaner API
typedef RayWithLuminanceRgb8 = RayWithLuminance<RayRgb8>;

/// Type alias for backward compatibility and cleaner API
typedef RayWithLuminanceOklch = RayWithLuminance<RayOklch>;

/// Type alias for the base type used in generic contexts
typedef RayWithLuminanceBase = RayWithLuminance;

/// Extension methods for RGB-specific functionality
extension RayWithLuminanceRgb8Extensions on RayWithLuminance<RayRgb8> {
  /// RGB component getters
  int get red => _ray.red.round();
  int get green => _ray.green.round();
  int get blue => _ray.blue.round();
  int get alpha => _ray.alpha.round();

  /// RGB-specific output methods
  String toRgbStr() => _ray.toRgbStr();
  String toRgbaStr() => _ray.toRgbaStr();
  int toArgbInt() => _ray.toArgbInt();
  int toRgbaInt() => _ray.toRgbaInt();
  int toRgbInt() => _ray.toRgbInt();

  /// Factory for creating RGB colors from ARGB int
  static RayWithLuminance<RayRgb8> fromArgbIntFactory(
      int value, double luminance) {
    return RayWithLuminance<RayRgb8>(RayRgb8.fromArgbInt(value), luminance);
  }
}

/// Extension methods for Oklch-specific functionality
extension RayWithLuminanceOklchExtensions on RayWithLuminance<RayOklch> {
  /// Oklch component getters
  double get l => _ray.lightness;
  double get c => _ray.chroma;
  double get h => _ray.hue;

  /// Oklch-specific manipulation methods
  RayWithLuminance<RayOklch> withLightness(double lightness) {
    final newRay = _ray.withLightness(lightness);
    return RayWithLuminance<RayOklch>(newRay, newRay.luminance);
  }

  RayWithLuminance<RayOklch> withChroma(double chroma) {
    final newRay = _ray.withChroma(chroma);
    return RayWithLuminance<RayOklch>(newRay, newRay.luminance);
  }

  RayWithLuminance<RayOklch> withHue(double hue) {
    final newRay = _ray.withHue(hue);
    return RayWithLuminance<RayOklch>(newRay, newRay.luminance);
  }
}

/// Color scheme with harmonious relationships and accessibility features.
class Spectrum<T extends RayWithLuminance> {
  /// The primary color this scheme is based on
  final T source;

  /// Complete tonal palette with cached luminance.
  final Map<RayTone, RayWithLuminance> spectrum;

  /// Access tones using Material Design naming convention
  T? get shade0 => spectrum[RayTone.shade0] as T?;
  T? get shade50 => spectrum[RayTone.shade50] as T?;
  T? get shade100 => spectrum[RayTone.shade100] as T?;
  T? get shade200 => spectrum[RayTone.shade200] as T?;
  T? get shade300 => spectrum[RayTone.shade300] as T?;
  T? get shade400 => spectrum[RayTone.shade400] as T?;
  T? get shade500 => spectrum[RayTone.shade500] as T?;
  T? get shade600 => spectrum[RayTone.shade600] as T?;
  T? get shade700 => spectrum[RayTone.shade700] as T?;
  T? get shade800 => spectrum[RayTone.shade800] as T?;
  T? get shade900 => spectrum[RayTone.shade900] as T?;
  T? get shade950 => spectrum[RayTone.shade950] as T?;
  T? get shade1000 => spectrum[RayTone.shade1000] as T?;

  // Accent tone getters (might not exist for all colors)
  T? get accent100 => spectrum[RayTone.accent100] as T?;
  T? get accent200 => spectrum[RayTone.accent200] as T?;
  T? get accent400 => spectrum[RayTone.accent400] as T?;
  T? get accent700 => spectrum[RayTone.accent700] as T?;

  /// Access specific tone by RayTone enum
  T? tone(RayTone tone) => spectrum[tone] as T?;

  /// Creates scheme with explicit properties.
  ///
  /// Prefer [Spectrum.fromRay] for automatic generation.
  const Spectrum({
    required this.source,
    required this.spectrum,
  });

  /// Creates a RGB-based scheme from tone map
  static Spectrum<RayWithLuminance<RayRgb8>> fromRgbTones({
    Ray? base,
    required Map<RayTone, Ray> tones,
  }) {
    return _createSchemeFromTones<RayWithLuminance<RayRgb8>>(
        base: base, tones: tones);
  }

  /// Creates an Oklch-based scheme from tone map
  static Spectrum<RayWithLuminance<RayOklch>> fromOklchTones({
    Ray? base,
    required Map<RayTone, Ray> tones,
  }) {
    return _createSchemeFromTones<RayWithLuminance<RayOklch>>(
        base: base, tones: tones);
  }

  static Spectrum<T> _createSchemeFromTones<T extends RayWithLuminance>({
    Ray? base,
    required Map<RayTone, Ray> tones,
  }) {
    // Convert map to RayWithLuminance values
    final Map<RayTone, RayWithLuminance> tonesMap = {};
    for (final entry in tones.entries) {
      final tone = entry.value;
      final luminance = tone.luminance;

      // Create appropriate concrete type based on T
      tonesMap[entry.key] = switch (T) {
        const (RayWithLuminance<RayRgb8>) =>
          RayWithLuminance<RayRgb8>(tone.toRgb8(), luminance),
        const (RayWithLuminance<RayOklch>) =>
          RayWithLuminance<RayOklch>(tone.toOklch(), luminance),
        _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
      };
    }

    // Use shade500 (middle tone) as default base
    final ray = base ?? tones[RayTone.shade500]!;
    final luminance = ray.luminance;

    // Create appropriate source type based on T
    final T source = switch (T) {
      const (RayWithLuminance<RayRgb8>) =>
        RayWithLuminance<RayRgb8>(ray.toRgb8(), luminance) as T,
      const (RayWithLuminance<RayOklch>) =>
        RayWithLuminance<RayOklch>(ray.toOklch(), luminance) as T,
      _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
    };

    return Spectrum<T>(
      source: source,
      spectrum: tonesMap,
    );
  }

  /// Creates a scheme with the appropriate type based on the input ray's color space
  /// Returns Spectrum&lt;RayWithLuminance&lt;RayRgb8&gt;&gt; for RGB/HSL rays
  /// Returns Spectrum&lt;RayWithLuminance&lt;RayOklch&gt;&gt; for Oklch rays
  static Spectrum fromRay(Ray ray, {bool? generateAccents}) {
    return switch (ray.colorSpace) {
      ColorSpace.oklch =>
        _createScheme<RayWithLuminance<RayOklch>>(ray, generateAccents),
      _ => _createScheme<RayWithLuminance<RayRgb8>>(ray, generateAccents),
    };
  }

  static Spectrum<T> _createScheme<T extends RayWithLuminance>(
      Ray ray, bool? generateAccents) {
    final luminance = ray.luminance;
    final rayOklch = ray.toOklch();

    // only generate accents for colors with chroma > 0.1
    generateAccents ??= rayOklch.chroma > 0.1;

    final Map<RayTone, RayWithLuminance> tonesMap = {};
    for (final tone in RayTone.values) {
      if (tone.type == ToneType.accent && !generateAccents) continue;

      final toneOklch =
          // prioritize chroma with accents
          tone.type == ToneType.accent
              ? rayOklch.withLightness(tone.lightness).withChroma(
                  tone.fixedChroma ?? (rayOklch.chroma * tone.chromaModifier!))
              // prioritize lightness with shades
              : rayOklch
                  .withChroma(tone.fixedChroma ??
                      (rayOklch.chroma * tone.chromaModifier!))
                  .withLightness(tone.lightness);

      final toneLuminance = toneOklch.luminance;

      // Create appropriate concrete type based on T
      tonesMap[tone] = switch (T) {
        const (RayWithLuminance<RayRgb8>) =>
          RayWithLuminance<RayRgb8>(toneOklch.toRgb8(), toneLuminance),
        const (RayWithLuminance<RayOklch>) =>
          RayWithLuminance<RayOklch>(toneOklch, toneLuminance),
        _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
      };
    }

    // Create appropriate source type based on T
    final T source = switch (T) {
      const (RayWithLuminance<RayRgb8>) =>
        RayWithLuminance<RayRgb8>(ray.toRgb8(), luminance) as T,
      const (RayWithLuminance<RayOklch>) =>
        RayWithLuminance<RayOklch>(ray.toOklch(), luminance) as T,
      _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
    };

    return Spectrum<T>(
      source: source,
      spectrum: tonesMap,
    );
  }

  /// Darker surface variant (shade700).
  T get surfaceDark =>
      tone(RayTone.shade700) ??
      spectrum.entries
          .firstWhere(
            (element) =>
                element.key.lightness <= RayTone.shade700.lightness &&
                element.key.type == ToneType.shade,
            orElse: () => spectrum.entries.last,
          )
          .value as T;

  /// Lighter surface variant (shade100).
  T get surfaceLight =>
      tone(RayTone.shade100) ??
      spectrum.entries
          .toList()
          .reversed
          .firstWhere(
            (element) =>
                element.key.lightness >= RayTone.shade100.lightness &&
                element.key.type == ToneType.shade,
            orElse: () => spectrum.entries.first,
          )
          .value as T;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Spectrum &&
        other.source == source &&
        _mapEquals(other.spectrum, spectrum);
  }

  @override
  int get hashCode => Object.hash(
        source,
        Object.hashAll(
            spectrum.entries.map((e) => Object.hash(e.key, e.value))),
      );

  @override
  String toString() => 'RayScheme('
      'source: ${source.colorSpace.name}(${source.toString()}), '
      'spectrum: ${spectrum.length}'
      ')';

  /// Helper function to compare two tone maps for equality
  static bool _mapEquals(
      Map<RayTone, RayWithLuminance> a, Map<RayTone, RayWithLuminance> b) {
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
