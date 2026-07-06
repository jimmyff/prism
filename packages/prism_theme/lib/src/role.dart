/// Every compiled scheme color, as a flat enum.
///
/// Used by `PrismScheme.ray` for enum-driven lookups; the typed getters on the
/// scheme cover the same 31 colors. The gradient `canvas` is addressed
/// separately (it is a `Beam`, not a flat ray).
///
/// Role intents (naming) live on `PrismRoles`; note `hero`/`highlight` are brand
/// accent roles, unrelated to Flutter's `Hero` widget / `highlightColor`.
enum PrismRole {
  surface,
  surfaceRaised,
  chrome,
  scrim,
  ink,
  inkMuted,
  inkFaint,
  actionFill,
  actionOnFill,
  actionInk,
  heroFill,
  heroOnFill,
  heroInk,
  highlightFill,
  highlightOnFill,
  highlightInk,
  errorFill,
  errorOnFill,
  errorInk,
  warningFill,
  warningOnFill,
  warningInk,
  successFill,
  successOnFill,
  successInk,
  infoFill,
  infoOnFill,
  infoInk,
  focus,
  outline,
  divider,
}
