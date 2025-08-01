import 'package:prism/prism.dart';

enum ShadeType {
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
  accent100(lightnessModifier: 0.75, fixedChroma: 1.0, type: ShadeType.accent),
  accent200(lightnessModifier: 0.63, fixedChroma: 1.0, type: ShadeType.accent),
  accent400(lightnessModifier: 0.55, fixedChroma: 0.8, type: ShadeType.accent),
  accent700(lightnessModifier: 0.42, fixedChroma: 0.9, type: ShadeType.accent),
  ;

  final double lightnessModifier;
  final double? chromaModifier;
  final double? fixedChroma;
  final ShadeType type;

  const RayTone(
      {required this.lightnessModifier,
      this.chromaModifier,
      this.fixedChroma,
      this.type = ShadeType.shade});

  // returns a value of the range 0.4 - 1.0
  double get lightness => lightnessModifier * 0.8 + 0.2;
}

/// Base class for colors with precomputed luminance values.
abstract base class RayWithLuminanceBase extends Ray {
  /// The precomputed luminance value (0.0 to 1.0)
  final double _precomputedLuminance;

  /// Creates a RayWithLuminanceBase with precomputed luminance
  const RayWithLuminanceBase(this._precomputedLuminance) : super();

  /// Returns the precomputed luminance instead of calculating it
  @override
  double get luminance => _precomputedLuminance;

  /// Whether this color is considered dark
  bool get isDark => switch (colorSpace) {
        ColorSpace.oklab || ColorSpace.oklch => luminance < 0.70,

        //rgb luminance
        _ => luminance < 0.5
      };

  ColorSpace get colorSpace;

  /// Whether this color is considered light.
  bool get isLight => !isDark;

  /// Returns appropriate contrast color (black/white) for text on this color.
  RayWithLuminanceBase get onRay;

  /// Returns hex string representation.
  String toHexStr([int length = 6, HexFormat format = HexFormat.rgba]);
}

/// RGB color with precomputed luminance for optimal performance.
final class RayWithLuminanceRgb8 extends RayWithLuminanceBase {
  /// The RayRgb8 instance this luminance-cached color wraps
  final RayRgb8 _ray;

  /// Creates an RGB color with precomputed luminance.
  const RayWithLuminanceRgb8._(this._ray, double luminance) : super(luminance);

  /// Creates from a RayRgb8 instance with precomputed luminance.
  factory RayWithLuminanceRgb8(RayRgb8 ray, double luminance) {
    return RayWithLuminanceRgb8._(ray, luminance);
  }

  /// Creates a const RGB color with precomputed luminance from ARGB int
  const RayWithLuminanceRgb8.fromRay(RayRgb8 ray, double luminance)
      : _ray = ray,
        super(luminance);

  /// Creates a const RGB color with precomputed luminance from ARGB int
  factory RayWithLuminanceRgb8.fromArgbIntFactory(int value, double luminance) {
    return RayWithLuminanceRgb8._(RayRgb8.fromIntARGB(value), luminance);
  }

  /// Returns appropriate contrast color (black/white) for text on this color
  @override
  RayWithLuminanceRgb8 get onRay {
    return isDark
        ? const RayWithLuminanceRgb8.fromRay(
            RayRgb8.fromIntARGB(0xFFFFFFFF), 1.0) // White
        : const RayWithLuminanceRgb8.fromRay(
            RayRgb8.fromIntARGB(0xFF000000), 0.0); // Black
  }

  @override
  ColorSpace get colorSpace => ColorSpace.rgb8;

  // RGB-specific component getters
  int get red => _ray.red;
  int get green => _ray.green;
  int get blue => _ray.blue;
  int get alpha => _ray.alpha;

  @override
  double get opacity => alpha / 255.0;

  // RGB-specific output methods
  @override
  String toHexStr([int length = 6, HexFormat format = HexFormat.rgba]) {
    return _ray.toHexStr(length, format);
  }

  String toRgbStr() => _ray.toRgbStr();
  String toRgbaStr() => _ray.toRgbaStr();
  int toArgbInt() => _ray.toArgbInt();
  int toRgbaInt() => _ray.toRgbaInt();
  int toRgbInt() => _ray.toRgbInt();

  // Ray interface implementation
  @override
  RayWithLuminanceRgb8 withOpacity(double opacity) {
    final ray = _ray.withOpacity(opacity);
    return RayWithLuminanceRgb8.fromRay(ray, ray.luminance);
  }

  @override
  Ray lerp(Ray other, double t) {
    return _ray.lerp(other, t);
  }

  @override
  Ray get inverse => _ray.inverse;

  @override
  RayRgb8 toRgb() => _ray;

  @override
  RayHsl toHsl() => _ray.toHsl();

  @override
  RayOklab toOklab() => _ray.toOklab();

  @override
  RayOklch toOklch() => _ray.toOklch();

  @override
  dynamic toJson() => _ray.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RayWithLuminanceRgb8 && other._ray == _ray);

  @override
  int get hashCode => _ray.hashCode;

  @override
  String toString() => _ray.toString();
}

/// Oklch color with precomputed luminance for optimal performance.
///
/// Extends RayOklch functionality while caching luminance to avoid recalculations.
final class RayWithLuminanceOklch extends RayWithLuminanceBase {
  final double _l;
  final double _c;
  final double _h;
  final double _opacity;

  /// Creates an Oklch color with precomputed luminance from raw values
  const RayWithLuminanceOklch._(
      this._l, this._c, this._h, this._opacity, double luminance)
      : super(luminance);

  /// Creates from a RayOklch instance with precomputed luminance
  factory RayWithLuminanceOklch(RayOklch ray, double luminance) {
    return RayWithLuminanceOklch._(ray.l, ray.c, ray.h, ray.opacity, luminance);
  }

  /// Creates a const Oklch color with precomputed luminance from components
  const RayWithLuminanceOklch.fromComponents(
      this._l, this._c, this._h, this._opacity, double luminance)
      : super(luminance);

  /// Returns appropriate contrast color (black/white) for text on this color
  RayWithLuminanceOklch get onRay {
    return isDark
        ? const RayWithLuminanceOklch.fromComponents(
            1.0, 0.0, 0.0, 1.0, 1.0) // White
        : const RayWithLuminanceOklch.fromComponents(
            0.0, 0.0, 0.0, 1.0, 0.0); // Black
  }

  @override
  ColorSpace get colorSpace => ColorSpace.oklch;

  // Oklch-specific component getters
  double get l => _l;
  double get c => _c;
  double get h => _h;

  @override
  double get opacity => _opacity;

  // Oklch-specific manipulation methods
  RayWithLuminanceOklch withLightness(double lightness) {
    final newRay = RayOklch(l: lightness, c: _c, h: _h, opacity: _opacity);
    return RayWithLuminanceOklch.fromComponents(
        lightness, _c, _h, _opacity, newRay.luminance);
  }

  RayWithLuminanceOklch withChroma(double chroma) {
    final newRay = RayOklch(l: _l, c: chroma, h: _h, opacity: _opacity);
    return RayWithLuminanceOklch.fromComponents(
        _l, chroma, _h, _opacity, newRay.luminance);
  }

  RayWithLuminanceOklch withHue(double hue) {
    final newRay = RayOklch(l: _l, c: _c, h: hue, opacity: _opacity);
    return RayWithLuminanceOklch.fromComponents(
        _l, _c, hue, _opacity, newRay.luminance);
  }

  // Ray interface implementation
  @override
  RayWithLuminanceOklch withOpacity(double opacity) {
    return RayWithLuminanceOklch.fromComponents(l, c, h, opacity, luminance);
  }

  @override
  Ray lerp(Ray other, double t) {
    return RayOklch(l: _l, c: _c, h: _h, opacity: _opacity).lerp(other, t);
  }

  @override
  Ray get inverse => RayOklch(l: _l, c: _c, h: _h, opacity: _opacity).inverse;

  @override
  RayRgb8 toRgb() => RayOklch(l: _l, c: _c, h: _h, opacity: _opacity).toRgb();

  @override
  RayHsl toHsl() => RayOklch(l: _l, c: _c, h: _h, opacity: _opacity).toHsl();

  @override
  RayOklab toOklab() =>
      RayOklch(l: _l, c: _c, h: _h, opacity: _opacity).toOklab();

  @override
  RayOklch toOklch() => RayOklch(l: _l, c: _c, h: _h, opacity: _opacity);

  @override
  dynamic toJson() => {'l': _l, 'c': _c, 'h': _h, 'opacity': _opacity};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RayWithLuminanceOklch &&
          other._l == _l &&
          other._c == _c &&
          other._h == _h &&
          other._opacity == _opacity);

  @override
  int get hashCode => Object.hash(_l, _c, _h, _opacity);

  @override
  String toString() =>
      'RayWithLuminanceOklch(l: ${_l.toStringAsFixed(3)}, c: ${_c.toStringAsFixed(3)}, h: ${_h.toStringAsFixed(1)}°, opacity: ${_opacity.toStringAsFixed(2)})';

  @override
  String toHexStr([int length = 6, HexFormat format = HexFormat.rgba]) =>
      toRgb().toHexStr(length, format);
}

/// Color scheme that provides harmonious relationships and accessibility features.
///
/// Generates contrast text colors and complete tonal palette from a primary color.
class RayScheme<T extends RayWithLuminanceBase> {

  /// The primary color this scheme is based on
  final T source;

  /// Complete tonal palette with cached luminance values.
  final Map<RayTone, RayWithLuminanceBase> tones;

  /// Access tones using Material Design naming convention
  T? get shade0 => tones[RayTone.shade0] as T?;
  T? get shade50 => tones[RayTone.shade50] as T?;
  T? get shade100 => tones[RayTone.shade100] as T?;
  T? get shade200 => tones[RayTone.shade200] as T?;
  T? get shade300 => tones[RayTone.shade300] as T?;
  T? get shade400 => tones[RayTone.shade400] as T?;
  T? get shade500 => tones[RayTone.shade500] as T?;
  T? get shade600 => tones[RayTone.shade600] as T?;
  T? get shade700 => tones[RayTone.shade700] as T?;
  T? get shade800 => tones[RayTone.shade800] as T?;
  T? get shade900 => tones[RayTone.shade900] as T?;
  T? get shade950 => tones[RayTone.shade950] as T?;
  T? get shade1000 => tones[RayTone.shade1000] as T?;

  // Accent tone getters (might not exist for all colors)
  T? get accent100 => tones[RayTone.accent100] as T?;
  T? get accent200 => tones[RayTone.accent200] as T?;
  T? get accent400 => tones[RayTone.accent400] as T?;
  T? get accent700 => tones[RayTone.accent700] as T?;

  /// Access specific tone by RayTone enum
  T? tone(RayTone tone) => tones[tone] as T?;

  /// Creates a color scheme with all properties explicitly specified.
  ///
  /// For most use cases, prefer [RayScheme.fromRay] which automatically
  /// computes all derived colors and properties.
  const RayScheme({
    required this.source,
    required this.tones,
  });

  /// Creates a RGB-based scheme from tone map
  static RayScheme<RayWithLuminanceRgb8> fromRgbTones({
    Ray? base,
    required Map<RayTone, Ray> tones,
  }) {
    return _createSchemeFromTones<RayWithLuminanceRgb8>(
        base: base, tones: tones);
  }

  /// Creates an Oklch-based scheme from tone map
  static RayScheme<RayWithLuminanceOklch> fromOklchTones({
    Ray? base,
    required Map<RayTone, Ray> tones,
  }) {
    return _createSchemeFromTones<RayWithLuminanceOklch>(
        base: base, tones: tones);
  }

  static RayScheme<T> _createSchemeFromTones<T extends RayWithLuminanceBase>({
    Ray? base,
    required Map<RayTone, Ray> tones,
  }) {
    // Convert map to RayWithLuminanceBase values
    final Map<RayTone, RayWithLuminanceBase> tonesMap = {};
    for (final entry in tones.entries) {
      final tone = entry.value;
      final luminance = tone.luminance;

      // Create appropriate concrete type based on T
      tonesMap[entry.key] = switch (T) {
        const (RayWithLuminanceRgb8) =>
          RayWithLuminanceRgb8(tone.toRgb(), luminance),
        const (RayWithLuminanceOklch) =>
          RayWithLuminanceOklch(tone.toOklch(), luminance),
        _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
      };
    }

    // Use shade500 (middle tone) as default base
    final ray = base ?? tones[RayTone.shade500]!;
    final luminance = ray.luminance;

    // Create appropriate source type based on T
    final T source = switch (T) {
      const (RayWithLuminanceRgb8) =>
        RayWithLuminanceRgb8(ray.toRgb(), luminance) as T,
      const (RayWithLuminanceOklch) =>
        RayWithLuminanceOklch(ray.toOklch(), luminance) as T,
      _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
    };

    return RayScheme<T>(
      source: source,
      tones: tonesMap,
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
  /// final blueScheme = RayScheme.fromRay(RayRgb8.fromHex('#2196F3'));
  /// final redScheme = RayScheme.fromRay(
  ///   RayRgb8.fromHex('#F44336'),
  ///   hueTransform: (hue, delta) => hue + (delta * 20), // Rotate hue based on lightness
  ///   chromaTransform: (chroma, delta) => chroma - delta.abs() * 0.1,
  /// );
  /// ```
  /// Creates a scheme with RGB-based colors
  static RayScheme<RayWithLuminanceRgb8> fromRgb(RayRgb8 ray,
      {bool? generateAccents}) {
    return _createScheme<RayWithLuminanceRgb8>(ray, generateAccents);
  }

  /// Creates a scheme with Oklch-based colors
  static RayScheme<RayWithLuminanceOklch> fromOklch(RayOklch ray,
      {bool? generateAccents}) {
    return _createScheme<RayWithLuminanceOklch>(ray, generateAccents);
  }

  /// Creates a scheme with the appropriate type based on the input ray's color space
  /// Returns RayScheme<RayWithLuminanceRgb> for RGB/HSL rays
  /// Returns RayScheme<RayWithLuminanceOklch> for Oklch rays
  /// For explicit type control, use `fromRgb` or `fromOklch` directly
  static RayScheme fromRay(Ray ray, {bool? generateAccents}) {
    return switch (ray.colorSpace) {
      ColorSpace.oklch =>
        fromOklch(ray.toOklch(), generateAccents: generateAccents),
      _ => fromRgb(ray.toRgb(), generateAccents: generateAccents),
    };
  }

  static RayScheme<T> _createScheme<T extends RayWithLuminanceBase>(
      Ray ray, bool? generateAccents) {
    final luminance = ray.luminance;
    final rayOklch = ray.toOklch();

    // only generate accents for colors with chroma > 0.1
    generateAccents ??= rayOklch.c > 0.1;

    final Map<RayTone, RayWithLuminanceBase> tonesMap = {};
    for (final tone in RayTone.values) {
      if (tone.type == ShadeType.accent && !generateAccents) continue;

      final toneOklch = rayOklch
          .withChroma(tone.fixedChroma ?? (rayOklch.c * tone.chromaModifier!))
          .withLightness(tone.lightness);

      final toneLuminance = toneOklch.luminance;

      // Create appropriate concrete type based on T
      tonesMap[tone] = switch (T) {
        const (RayWithLuminanceRgb8) =>
          RayWithLuminanceRgb8(toneOklch.toRgb(), toneLuminance),
        const (RayWithLuminanceOklch) =>
          RayWithLuminanceOklch(toneOklch, toneLuminance),
        _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
      };
    }

    // Create appropriate source type based on T
    final T source = switch (T) {
      const (RayWithLuminanceRgb8) =>
        RayWithLuminanceRgb8(ray.toRgb(), luminance) as T,
      const (RayWithLuminanceOklch) =>
        RayWithLuminanceOklch(ray.toOklch(), luminance) as T,
      _ => throw ArgumentError('Unsupported RayWithLuminance type: $T'),
    };

    return RayScheme<T>(
      source: source,
      tones: tonesMap,
    );
  }

  /// A darker surface variant of the primary color
  ///
  /// Returns shade700 for dark surface usage.
  T get surfaceDark => shade700!;

  /// A lighter surface variant of the primary color
  ///
  /// Returns shade100 for light surface usage.
  T get surfaceLight => shade100!;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RayScheme &&
        other.source == source &&
        _mapEquals(other.tones, tones);
  }

  @override
  int get hashCode => Object.hash(
        source,
        Object.hashAll(tones.entries.map((e) => Object.hash(e.key, e.value))),
      );

  @override
  String toString() => 'RayScheme('
      'source: ${source.colorSpace.name}(${source.toString()}), '
      'tones: ${tones.length}'
      ')';

  /// Helper function to compare two tone maps for equality
  static bool _mapEquals(Map<RayTone, RayWithLuminanceBase> a,
      Map<RayTone, RayWithLuminanceBase> b) {
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
