/// An authored, compilable, fully-interpolatable theme system built on Prism.
///
/// Author a [PrismThemeSource] (seeds + a visible role table), then compile it
/// to a [PrismTheme] for a given [PrismBrightness]. Roles are intents, colors
/// are perceptual (Oklch), and everything interpolates.
library;

export 'src/accent.dart';
export 'src/accent_spec.dart';
export 'src/brightness.dart';
export 'src/color_base.dart';
export 'src/contrast.dart'
    show PrismAuditResult, PrismContrastLevel, PrismContrastPolicy;
export 'src/geometry.dart';
export 'src/role.dart';
export 'src/role_spec.dart';
export 'src/roles.dart';
export 'src/scheme.dart';
export 'src/seed.dart';
export 'src/seeds.dart';
export 'src/selection.dart';
export 'src/source.dart';
export 'src/spacing.dart';
export 'src/splash.dart';
export 'src/state_layers.dart';
export 'src/text_style.dart';
export 'src/theme.dart';
export 'src/theme_pair.dart';
export 'src/typography.dart';
