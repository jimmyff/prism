import 'package:flutter/material.dart';
import 'package:prism_theme_flutter/prism_theme_flutter.dart';
import 'package:prism_theme_flutter/preview.dart';

void main() => runApp(const DemoApp());

RayOklch _ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

/// Four authored sources, each leaning on different customisation levers:
/// Kosmos (tinted neutral + hue-shift gradient dialog + themed lines),
/// Daytime (its blue, light-friendly cousin), Eclipse (extreme L + a darkSeeds
/// divergence), and Sunset (a warm orange→red palette).
///
/// Public so the example's audit test can compile and check every source.
final demoSources = <({String name, PrismThemeSource source})>[
  (
    name: 'Kosmos',
    source: PrismThemeSource(
      // A purple-tinted neutral tints every surface and ink toward violet.
      seeds: PrismSeeds(
        primary: _ok(0.58, 0.17, 300),
        secondary: _ok(0.60, 0.15, 264),
        tertiary: _ok(0.85, 0.17, 100), // yellow → the `highlight` accent
        neutral: _ok(0.5, 0.03, 300),
      ),
      canvas: (
        light: Beam.flat(_ok(0.985, 0.006, 300)),
        dark: Beam.linear([_ok(0.15, 0.09, 300), _ok(0.22, 0.12, 275)]),
      ),
      roles: const PrismRoles(
        // Deep purple surface (deeper than the standard table).
        surface: PrismRoleSpec(
          PrismSeed.neutral,
          l: (light: 0.96, dark: 0.17),
          alpha: 0.5,
        ),
        // A purple → blue gradient dialog (hue shift via gradientSeed).
        surfaceRaised: PrismRoleSpec(
          PrismSeed.primary,
          l: (light: 0.98, dark: 0.28),
          chroma: 0.55,
          gradient: -0.04,
          gradientSeed: PrismSeed.secondary,
        ),
        // Themed lines: purple-tinted instead of neutral.
        outline: PrismRoleSpec(
          PrismSeed.primary,
          l: (light: 0.35, dark: 0.82),
          alpha: 0.45,
        ),
        divider: PrismRoleSpec(
          PrismSeed.secondary,
          l: (light: 0.35, dark: 0.9),
          alpha: 0.35,
        ),
        // Muted (secondary) text follows the `secondary` hue, not the neutral.
        // Pulling L toward the mid keeps enough chroma for the tint to read.
        inkMuted: PrismRoleSpec(
          PrismSeed.secondary,
          l: (light: 0.42, dark: 0.85),
          alpha: 0.8,
        ),
      ),
      splash: PrismSplash.sparkle,
    ),
  ),
  (
    name: 'Daytime',
    source: PrismThemeSource(
      // The blue counterpart to Kosmos — a bright daytime sky.
      seeds: PrismSeeds(
        primary: _ok(0.55, 0.17, 250),
        secondary: _ok(0.62, 0.14, 210),
        tertiary: _ok(0.60, 0.15, 230),
        neutral: _ok(0.5, 0.025, 240),
      ),
      canvas: (
        // A bright blue-white sky (shines in light mode).
        light: Beam.linear([_ok(0.97, 0.03, 235), _ok(0.99, 0.015, 210)]),
        dark: Beam.linear([_ok(0.16, 0.06, 250), _ok(0.22, 0.08, 232)]),
      ),
      roles: const PrismRoles(
        surfaceRaised: PrismRoleSpec(
          PrismSeed.primary,
          l: (light: 0.99, dark: 0.27),
          chroma: 0.5,
          gradient: -0.03,
          gradientSeed: PrismSeed.secondary,
        ),
      ),
    ),
  ),
  (
    name: 'Eclipse',
    source: PrismThemeSource(
      // Light mode is cool + near-white; dark mode diverges to a warm "corona"
      // glow over near-black — a dramatic darkSeeds divergence.
      seeds: PrismSeeds(
        primary: _ok(0.45, 0.13, 240),
        secondary: _ok(0.5, 0.1, 280),
        tertiary: _ok(0.5, 0.1, 200),
        neutral: _ok(0.5, 0.006, 240),
      ),
      darkSeeds: PrismSeeds(
        primary: _ok(0.72, 0.18, 45),
        secondary: _ok(0.66, 0.2, 22),
        tertiary: _ok(0.74, 0.15, 65),
        neutral: _ok(0.5, 0.012, 40),
      ),
      canvas: (
        light: Beam.flat(_ok(0.995, 0.002, 240)),
        dark: Beam.linear([_ok(0.05, 0.02, 30), _ok(0.10, 0.05, 45)]),
      ),
      roles: const PrismRoles(
        // Pushed to extremes: near-white light, near-black dark.
        surface: PrismRoleSpec(PrismSeed.neutral, l: (light: 0.99, dark: 0.10)),
        surfaceRaised: PrismRoleSpec(
          PrismSeed.neutral,
          l: (light: 1.0, dark: 0.14),
          gradient: -0.03,
        ),
        chrome: PrismRoleSpec(PrismSeed.neutral, l: (light: 0.98, dark: 0.07)),
      ),
    ),
  ),
  (
    name: 'Sunset',
    source: PrismThemeSource(
      // Warm — deep orange and red, with a warm-tinted neutral.
      seeds: PrismSeeds(
        primary: _ok(0.62, 0.17, 50),
        secondary: _ok(0.55, 0.2, 25),
        tertiary: _ok(0.68, 0.15, 75),
        neutral: _ok(0.5, 0.03, 40),
      ),
      canvas: (
        light: Beam.flat(_ok(0.985, 0.012, 60)),
        // Deep orange → deep red dusk.
        dark: Beam.linear([_ok(0.21, 0.09, 45), _ok(0.15, 0.13, 22)]),
      ),
      roles: const PrismRoles(
        surface: PrismRoleSpec(PrismSeed.neutral, l: (light: 0.97, dark: 0.19)),
        // Orange → red gradient dialog.
        surfaceRaised: PrismRoleSpec(
          PrismSeed.primary,
          l: (light: 0.98, dark: 0.28),
          chroma: 0.5,
          gradient: -0.03,
          gradientSeed: PrismSeed.secondary,
        ),
      ),
    ),
  ),
];

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  // Compile each source once (light + dark); lerp per brightness per build.
  late final List<PrismThemePair> _pairs = [
    for (final s in demoSources) s.source.compilePair(),
  ];

  int _a = 0;
  int _b = 1;
  double _morph = 0;
  bool _isDark = true; // start dark to show the gradient sky

  ThemeData _themeData(PrismBrightness brightness) {
    final a = _pairs[_a].resolve(brightness);
    final b = _pairs[_b].resolve(brightness);
    return a.lerp(b, _morph).toThemeData();
  }

  @override
  Widget build(BuildContext context) {
    // theme/darkTheme + themeMode: MaterialApp's AnimatedTheme animates the
    // light↔dark switch; the morph slider re-lerps both.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _themeData(PrismBrightness.light),
      darkTheme: _themeData(PrismBrightness.dark),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Builder(builder: _scaffold),
    );
  }

  Widget _scaffold(BuildContext context) {
    final p = context.prism;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: p.canvas),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _chromeBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _controls(context),
                    const SizedBox(height: 24),
                    _inkHierarchy(context),
                    const SizedBox(height: 20),
                    _actions(context),
                    const SizedBox(height: 20),
                    _highlight(context),
                    const SizedBox(height: 20),
                    _statusChips(context),
                    const SizedBox(height: 20),
                    _surfaces(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Persistent app chrome (bars / nav / rails) — the `chrome` role, distinct
  // from content `surface` and elevated `surfaceRaised`.
  Widget _chromeBar(BuildContext context) {
    final p = context.prism;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(gradient: p.chromeGradient),
      child: Row(
        children: [
          Icon(Icons.menu, color: p.ink, size: 20),
          const SizedBox(width: 12),
          Text(
            'chrome — app bar / nav',
            style: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Icon(Icons.more_vert, color: p.inkMuted, size: 20),
        ],
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final p = context.prism;
    return _panel(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sourcePicker(context, 'A', _a, (v) => setState(() => _a = v)),
              const SizedBox(width: 16),
              _sourcePicker(context, 'B', _b, (v) => setState(() => _b = v)),
            ],
          ),
          _slider(
            context,
            'morph  A → B',
            _morph,
            (v) => setState(() => _morph = v),
          ),
          _brightnessToggle(context),
          const SizedBox(height: 8),
          // The dev preview tool, launched with source A.
          OutlinedButton.icon(
            icon: const Icon(Icons.palette_outlined),
            label: Text('Open preview tool — ${demoSources[_a].name}'),
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (_) => PrismThemePreviewScreen(
                          source: demoSources[_a].source,
                        ),
                  ),
                ),
          ),
          const SizedBox(height: 8),
          // A stock filled TextField — themed entirely by the ColorScheme.
          const TextField(
            decoration: InputDecoration(
              filled: true,
              labelText: 'Filled field (stock widget)',
              hintText: 'themed by the ColorScheme',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything interpolates in OKLCH.',
            style: TextStyle(color: p.inkFaint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _sourcePicker(
    BuildContext context,
    String label,
    int value,
    ValueChanged<int> onSet,
  ) {
    final p = context.prism;
    return Expanded(
      child: Row(
        children: [
          Text('$label ', style: TextStyle(color: p.inkMuted)),
          Expanded(
            child: DropdownButton<int>(
              isExpanded: true,
              value: value,
              onChanged: (v) => onSet(v ?? value),
              items: [
                for (var i = 0; i < demoSources.length; i++)
                  DropdownMenuItem(value: i, child: Text(demoSources[i].name)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context,
    String label,
    double value,
    ValueChanged<double> f,
  ) {
    final p = context.prism;
    return Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(label, style: TextStyle(color: p.inkMuted, fontSize: 13)),
        ),
        Expanded(
          child: Slider(value: value, activeColor: p.actionInk, onChanged: f),
        ),
      ],
    );
  }

  Widget _brightnessToggle(BuildContext context) {
    final p = context.prism;
    return Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(
            'brightness  light ⇄ dark',
            style: TextStyle(color: p.inkMuted, fontSize: 13),
          ),
        ),
        Switch(value: _isDark, onChanged: (v) => setState(() => _isDark = v)),
        const Spacer(),
      ],
    );
  }

  Widget _inkHierarchy(BuildContext context) {
    final p = context.prism;
    final text = Theme.of(context).textTheme;
    return _panel(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ink hierarchy', style: text.titleLarge?.copyWith(color: p.ink)),
          const SizedBox(height: 8),
          Container(height: 1, color: p.divider), // a hairline divider
          const SizedBox(height: 8),
          Text('ink — primary reading text', style: TextStyle(color: p.ink)),
          Text('inkMuted — secondary', style: TextStyle(color: p.inkMuted)),
          Text('inkFaint — hints', style: TextStyle(color: p.inkFaint)),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final p = context.prism;
    return _panel(
      context,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _filled(context, 'Action', p.actionFill, p.actionOnFill),
          _filled(context, 'Hero', p.heroFill, p.heroOnFill),
          _outlined(context, 'Outlined', p.actionInk),
          Text(
            'Link',
            style: TextStyle(color: p.actionInk, fontWeight: FontWeight.w600),
          ),
          _iconButton(Icons.favorite_border, p.actionInk),
          _iconButton(Icons.settings, p.ink),
        ],
      ),
    );
  }

  Widget _statusChips(BuildContext context) {
    final p = context.prism;
    return _panel(
      context,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _chip('error', p.errorFill, p.errorOnFill),
          _chip('warning', p.warningFill, p.warningOnFill),
          _chip('success', p.successFill, p.successOnFill),
          _chip('info', p.infoFill, p.infoOnFill),
        ],
      ),
    );
  }

  // The `highlight` accent (tertiary) — attention / CTAs / important values,
  // e.g. Kosmos's yellow chart-time indicator.
  Widget _highlight(BuildContext context) {
    final p = context.prism;
    return _panel(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'highlight — the tertiary accent for attention',
            style: TextStyle(color: p.inkMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, color: p.highlightInk, size: 18),
              const SizedBox(width: 6),
              // A chart-time-style highlighted value (highlightInk).
              Text(
                '13:32:00',
                style: TextStyle(
                  color: p.highlightInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _chip('LIVE', p.highlightFill, p.highlightOnFill),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _filled(
              context,
              'Highlight CTA',
              p.highlightFill,
              p.highlightOnFill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _surfaces(BuildContext context) {
    final p = context.prism;
    return _panel(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'surface / raised / chrome + scrim',
            style: TextStyle(color: p.inkMuted),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: p.surfaceRaisedGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'surfaceRaised gradient',
              style: TextStyle(color: p.ink),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: _filled(
              context,
              'Open dialog',
              p.chrome,
              p.ink,
              onTap: () => _openDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openDialog(BuildContext context) {
    final p = context.prism;
    showDialog<void>(
      context: context,
      barrierColor: p.scrim,
      builder:
          (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: p.surfaceRaisedGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: p.outline,
                  width: p.geometry.outlineWidth,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dialog',
                    style: TextStyle(
                      color: p.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'surfaceRaised gradient over a scrim.',
                    style: TextStyle(color: p.inkMuted),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(color: p.actionInk),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // --- small role-driven building blocks ---

  Widget _panel(BuildContext context, {required Widget child}) {
    final p = context.prism;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.outline, width: p.geometry.outlineWidth),
      ),
      child: child,
    );
  }

  Widget _filled(
    BuildContext context,
    String label,
    Color fill,
    Color onFill, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        overlayColor: context.prism.stateLayer(onFill), // theme-driven
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(color: onFill, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // Outlined button: the accent used AS foreground (`ink`) for border + label.
  Widget _outlined(BuildContext context, String label, Color ink) => Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: ink, width: 1.3),
      borderRadius: BorderRadius.circular(8),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      overlayColor: context.prism.stateLayer(ink),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style: TextStyle(color: ink, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  Widget _iconButton(IconData icon, Color color) =>
      IconButton(onPressed: () {}, icon: Icon(icon, color: color));

  Widget _chip(String label, Color fill, Color onFill) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(color: onFill, fontSize: 13)),
  );
}
