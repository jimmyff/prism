import 'package:flutter/material.dart';
import 'package:prism_flutter/prism_flutter.dart';
import 'package:prism_theme/prism_theme.dart';

/// Carries a compiled [PrismTheme] on Flutter's [ThemeData] as an extension.
///
/// The perceptual (OKLCH) interpolation guarantee holds through this extension:
/// [lerp] delegates to [PrismTheme.lerp]. (The mapped `ColorScheme` on the
/// same `ThemeData` is animated by Flutter in sRGB, independently.)
class PrismThemeExtension extends ThemeExtension<PrismThemeExtension> {
  /// The compiled theme.
  final PrismTheme theme;

  final Map<PrismRole, Color> _cache = {};

  PrismThemeExtension(this.theme);

  /// The Flutter [Color] for [role] (cached per instance).
  Color color(PrismRole role) =>
      _cache.putIfAbsent(role, () => theme.scheme.ray(role).toColor());

  /// The page background as a Flutter [Gradient] (flat beams yield two stops).
  LinearGradient get canvas => theme.scheme.canvas.toLinearGradient();

  /// The base color of the canvas (the flat-fill fallback).
  Color get canvasBase => theme.scheme.canvas.base.toColor();

  /// The `surface` fill as a Flutter [Gradient] (a flat fill yields two stops).
  LinearGradient get surfaceGradient => theme.scheme.surface.toLinearGradient();

  /// The `surfaceRaised` fill as a Flutter [Gradient].
  LinearGradient get surfaceRaisedGradient =>
      theme.scheme.surfaceRaised.toLinearGradient();

  /// The `chrome` fill as a Flutter [Gradient].
  LinearGradient get chromeGradient => theme.scheme.chrome.toLinearGradient();

  /// The theme's geometry tokens (radii, focus + outline widths).
  PrismGeometry get geometry => theme.geometry;

  /// The theme's spacing scale.
  PrismSpacing get spacing => theme.spacing;

  /// The theme's typography.
  PrismTypography get typography => theme.typography;

  /// The theme's interaction state-layer opacities.
  PrismStateLayers get stateLayers => theme.stateLayers;

  /// A [WidgetStateProperty] overlay for [on] using the theme's state layers.
  ///
  /// Feed to an `InkWell`/`ButtonStyle` `overlayColor` for hover/focus/press.
  WidgetStateProperty<Color?> stateLayer(Color on) {
    Color at(double opacity) => on.withAlpha((opacity * 255).round());
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return at(stateLayers.pressed);
      if (states.contains(WidgetState.focused)) return at(stateLayers.focus);
      if (states.contains(WidgetState.hovered)) return at(stateLayers.hover);
      return null;
    });
  }

  Color get surface => color(PrismRole.surface);
  Color get surfaceRaised => color(PrismRole.surfaceRaised);
  Color get chrome => color(PrismRole.chrome);
  Color get scrim => color(PrismRole.scrim);
  Color get ink => color(PrismRole.ink);
  Color get inkMuted => color(PrismRole.inkMuted);
  Color get inkFaint => color(PrismRole.inkFaint);
  Color get actionFill => color(PrismRole.actionFill);
  Color get actionOnFill => color(PrismRole.actionOnFill);
  Color get actionInk => color(PrismRole.actionInk);
  Color get heroFill => color(PrismRole.heroFill);
  Color get heroOnFill => color(PrismRole.heroOnFill);
  Color get heroInk => color(PrismRole.heroInk);
  Color get highlightFill => color(PrismRole.highlightFill);
  Color get highlightOnFill => color(PrismRole.highlightOnFill);
  Color get highlightInk => color(PrismRole.highlightInk);
  Color get errorFill => color(PrismRole.errorFill);
  Color get errorOnFill => color(PrismRole.errorOnFill);
  Color get errorInk => color(PrismRole.errorInk);
  Color get warningFill => color(PrismRole.warningFill);
  Color get warningOnFill => color(PrismRole.warningOnFill);
  Color get warningInk => color(PrismRole.warningInk);
  Color get successFill => color(PrismRole.successFill);
  Color get successOnFill => color(PrismRole.successOnFill);
  Color get successInk => color(PrismRole.successInk);
  Color get infoFill => color(PrismRole.infoFill);
  Color get infoOnFill => color(PrismRole.infoOnFill);
  Color get infoInk => color(PrismRole.infoInk);
  Color get focus => color(PrismRole.focus);
  Color get outline => color(PrismRole.outline);
  Color get divider => color(PrismRole.divider);

  @override
  PrismThemeExtension copyWith({PrismTheme? theme}) =>
      PrismThemeExtension(theme ?? this.theme);

  @override
  PrismThemeExtension lerp(
    covariant ThemeExtension<PrismThemeExtension>? other,
    double t,
  ) {
    // Flutter passes null when a target ThemeData lacks this extension.
    if (other is! PrismThemeExtension) return this;
    return PrismThemeExtension(theme.lerp(other.theme, t));
  }

  // == / hashCode delegate to the theme (ThemeData.== compares extensions;
  // hashCode must derive from the same quantities == uses, or animations
  // restart on every rebuild).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismThemeExtension && theme == other.theme;

  @override
  int get hashCode => theme.hashCode;
}

/// Reads the [PrismThemeExtension] from the ambient [Theme].
extension PrismContextExtension on BuildContext {
  /// The prism theme in scope. Throws a descriptive error if absent.
  PrismThemeExtension get prism {
    final ext = Theme.of(this).extension<PrismThemeExtension>();
    if (ext == null) {
      throw FlutterError(
        'PrismThemeExtension not found on the ambient ThemeData.\n'
        'Build your ThemeData with PrismTheme.toThemeData() so the extension '
        'is attached.',
      );
    }
    return ext;
  }
}
