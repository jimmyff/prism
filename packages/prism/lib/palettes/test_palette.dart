// GENERATED CODE - DO NOT EDIT BY HAND
// ignore_for_file: public_member_api_docs
import 'package:prism/prism.dart';

/// RGB-based RayScheme enum for the Test palette.
/// Each enum value implements RayScheme directly for clean API access.
enum TestRgb implements PrismPalette {
  red(
    RayWithLuminanceRgb.fromRay(
        RayRgb.fromIntARGB(0xFFF44336), 0.23513748007799182), // source
    const {
      RayTone.shade50: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFFFEBEE), 0.8684970821758026),
      RayTone.shade100: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFFFCDD2), 0.6957578652800609),
      RayTone.shade200: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFEF9A9A), 0.4379501864358795),
      RayTone.shade300: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFE57373), 0.30157285719549326),
      RayTone.shade400: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFEF5350), 0.25116422505558716),
      RayTone.shade500: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFF44336), 0.23513748007799182),
      RayTone.shade600: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFE53935), 0.19841309824022663),
      RayTone.shade700: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFD32F2F), 0.16087150202123554),
      RayTone.shade800: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFC62828), 0.13676551488293315),
      RayTone.shade900: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFB71C1C), 0.10981627793559716),
    }, // tones
  ),
  blue(
    RayWithLuminanceRgb.fromRay(
        RayRgb.fromIntARGB(0xFF2196F3), 0.5403705833754745), // source
    const {
      RayTone.shade50: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFE3F2FD), 0.8824305226866426),
      RayTone.shade100: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFFBBDEFB), 0.7397569395488306),
      RayTone.shade200: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF90CAF9), 0.5922838956265552),
      RayTone.shade300: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF64B5F6), 0.45905950055851585),
      RayTone.shade400: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF42A5F5), 0.3681808653103862),
      RayTone.shade500: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF2196F3), 0.2816066866066866),
      RayTone.shade600: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF1E88E5), 0.22899862088166847),
      RayTone.shade700: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF1976D2), 0.17849079253593126),
      RayTone.shade800: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF1565C0), 0.1379055830654053),
      RayTone.shade900: RayWithLuminanceRgb.fromRay(
          RayRgb.fromIntARGB(0xFF0D47A1), 0.08459068189970473),
    }, // tones
  ),
  ;

  /// The source color with precomputed luminance
  final RayWithLuminanceRgb source;

  /// The complete tonal palette
  final Map<RayTone, RayWithLuminanceRgb> tones;

  const TestRgb(this.source, this.tones);

  // Direct tone access getters
  @override
  RayWithLuminanceRgb? get shade0 => tones[RayTone.shade0];
  @override
  RayWithLuminanceRgb? get shade50 => tones[RayTone.shade50];
  @override
  RayWithLuminanceRgb? get shade100 => tones[RayTone.shade100];
  @override
  RayWithLuminanceRgb? get shade200 => tones[RayTone.shade200];
  @override
  RayWithLuminanceRgb? get shade300 => tones[RayTone.shade300];
  @override
  RayWithLuminanceRgb? get shade400 => tones[RayTone.shade400];
  @override
  RayWithLuminanceRgb? get shade500 => tones[RayTone.shade500];
  @override
  RayWithLuminanceRgb? get shade600 => tones[RayTone.shade600];
  @override
  RayWithLuminanceRgb? get shade700 => tones[RayTone.shade700];
  @override
  RayWithLuminanceRgb? get shade800 => tones[RayTone.shade800];
  @override
  RayWithLuminanceRgb? get shade900 => tones[RayTone.shade900];
  @override
  RayWithLuminanceRgb? get shade950 => tones[RayTone.shade950];
  @override
  RayWithLuminanceRgb? get shade1000 => tones[RayTone.shade1000];
  @override
  RayWithLuminanceRgb? get accent100 => tones[RayTone.accent100];
  @override
  RayWithLuminanceRgb? get accent200 => tones[RayTone.accent200];
  @override
  RayWithLuminanceRgb? get accent400 => tones[RayTone.accent400];
  @override
  RayWithLuminanceRgb? get accent700 => tones[RayTone.accent700];

  /// Access specific tone by RayTone enum
  @override
  RayWithLuminanceRgb? tone(RayTone tone) => tones[tone];

  /// A lighter surface variant of the primary color
  @override
  RayWithLuminanceRgb get surfaceLight => shade100!;

  /// A darker surface variant of the primary color
  @override
  RayWithLuminanceRgb get surfaceDark => shade700!;
}
