import 'brightness.dart';
import 'theme.dart';

/// A light/dark pair of compiled themes.
///
/// The two members may be compiled from *different* sources (fully separate
/// light and dark documents) — [atDarkness] still blends them, so the honest
/// path (diverged light/dark) is never blocked.
class PrismThemePair {
  final PrismTheme light;
  final PrismTheme dark;

  const PrismThemePair({required this.light, required this.dark});

  /// The theme for [brightness].
  PrismTheme resolve(PrismBrightness brightness) =>
      brightness.isDark ? dark : light;

  /// A continuous blend from [light] (t=0) to [dark] (t=1) — a transition/effect
  /// hook, **not** a parked state.
  ///
  /// Use it to *animate* between the members (e.g. a cosmic-clock day→night
  /// sweep); persist a discrete [PrismBrightness], never a mid-blend. A linear
  /// crossfade sits near 1:1 ink/surface contrast around t=0.5, so a parked
  /// midpoint is illegible — fine in motion, wrong as a resting theme. [t] is
  /// clamped to `[0, 1]`; endpoints are the unblended members.
  PrismTheme atDarkness(double t) => light.lerp(dark, t);

  PrismThemePair copyWith({PrismTheme? light, PrismTheme? dark}) =>
      PrismThemePair(light: light ?? this.light, dark: dark ?? this.dark);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismThemePair && light == other.light && dark == other.dark;

  @override
  int get hashCode => Object.hash(light, dark);

  @override
  String toString() => 'PrismThemePair(light: $light, dark: $dark)';
}
