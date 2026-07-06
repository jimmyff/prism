import 'lerp.dart';

/// Interaction state-layer opacities — the translucent overlay drawn over a
/// role on hover / focus / press. `prism_theme_flutter` builds a
/// `WidgetStateProperty` overlay from these.
class PrismStateLayers {
  final double hover;
  final double focus;
  final double pressed;

  const PrismStateLayers({
    this.hover = 0.13,
    this.focus = 0.18,
    this.pressed = 0.24,
  });

  /// Interpolates every opacity toward [other]; [t] is clamped to `[0, 1]`.
  PrismStateLayers lerp(PrismStateLayers other, double t) => PrismStateLayers(
    hover: lerpDouble(hover, other.hover, t),
    focus: lerpDouble(focus, other.focus, t),
    pressed: lerpDouble(pressed, other.pressed, t),
  );

  PrismStateLayers copyWith({double? hover, double? focus, double? pressed}) =>
      PrismStateLayers(
        hover: hover ?? this.hover,
        focus: focus ?? this.focus,
        pressed: pressed ?? this.pressed,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismStateLayers &&
          hover == other.hover &&
          focus == other.focus &&
          pressed == other.pressed;

  @override
  int get hashCode => Object.hash(hover, focus, pressed);

  @override
  String toString() =>
      'PrismStateLayers(hover: $hover, focus: $focus, pressed: $pressed)';
}
