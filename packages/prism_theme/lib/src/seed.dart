/// The named seed colors a theme is authored from.
///
/// `primary`/`secondary`/`tertiary` are the brand colors (required in
/// `PrismSeeds`); the rest carry conventional, overridable defaults. Roles
/// reference seeds by *intent* — nothing consumes a seed's name as a component.
enum PrismSeed {
  primary,
  secondary,
  tertiary,
  neutral,
  error,
  warning,
  success,
  info,
}
