/// The brightness mode of a theme.
enum PrismBrightness {
  light,
  dark;

  /// Whether this is the dark mode.
  bool get isDark => this == PrismBrightness.dark;

  /// The opposite brightness.
  PrismBrightness get inverse =>
      isDark ? PrismBrightness.light : PrismBrightness.dark;

  /// Selects a [PrismBrightness] from a bool (`true` = dark).
  ///
  /// The bool bridge for callers that persist brightness as a bool; pairs with
  /// [isDark]. (A static method, not a factory — Dart enums cannot have those.)
  static PrismBrightness of(bool isDark) =>
      isDark ? PrismBrightness.dark : PrismBrightness.light;

  /// Parses a [PrismBrightness] from its [name] (`'light'` or `'dark'`).
  static PrismBrightness fromName(String name) => values.firstWhere(
    (b) => b.name == name,
    orElse: () => throw FormatException('Unknown PrismBrightness: "$name"'),
  );
}
