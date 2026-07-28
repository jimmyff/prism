/// The adaptive accent-ink solve (`PrismInkMode.adaptive`).
///
/// An accent ink compiles at an authored absolute lightness, but its WCAG
/// luminance depends on hue — a lightness calibrated for one seed hue can fail
/// body contrast when a dynamic theme rotates that seed. This solver finds the
/// closest-to-authored lightness that passes against the scheme's real
/// backdrops. Backdrop math is shared with the audit (`audit_backdrops.dart`),
/// so a solved ink is guaranteed to measure identically when audited.
/// Internal: not exported by the barrel.
library;

import 'dart:math' as math;

import 'package:prism/prism.dart';

import 'audit_backdrops.dart';

/// Bisection iterations for the lightness solve. The bracket is at most the
/// full L range, so the solved value is quantized to ≈ 1/2^14 ≈ 6e-5 — far
/// below any visible step, without an epsilon termination loop.
const int kInkSolveSteps = 14;

/// The backdrop set an adaptive ink is solved against: the WCAG luminances of
/// every audit sample (canvas + surface/surfaceRaised/chrome flattened over
/// it), precomputed once per compile and shared by all accents.
class InkSolveBackdrops {
  final List<double> luminances;

  InkSolveBackdrops._(this.luminances);

  /// Samples and flattens the backdrops exactly as `auditScheme` does.
  factory InkSolveBackdrops.of(
    Beam<RayOklch> canvas,
    Beam<RayOklch> surface,
    Beam<RayOklch> surfaceRaised,
    Beam<RayOklch> chrome,
  ) {
    final canvasSamples = sampleBeam(canvas);
    return InkSolveBackdrops._([
      for (final s in [
        ...canvasSamples,
        ...flattenBackdrop(surface, canvasSamples),
        ...flattenBackdrop(surfaceRaised, canvasSamples),
        ...flattenBackdrop(chrome, canvasSamples),
      ])
        s.wcagLuminance,
    ]);
  }
}

/// The ink lightness closest to [authoredL] whose compiled ink meets [target]
/// contrast against every backdrop sample.
///
/// Returns [authoredL] unchanged when it already passes (identity — a passing
/// theme compiles bit-identically to `PrismInkMode.fixed`), or when even the
/// bracket extreme fails (unsolvable backdrops stay the audit's problem).
/// Otherwise bisects between the authored (failing) lightness and the member's
/// extreme — light member darkens toward 0, dark member brightens toward 1 —
/// and returns a lightness measured passing against these exact samples.
double solveInkLightness({
  required RayOklch base,
  required double chromaMult,
  required double authoredL,
  required bool isDark,
  required double target,
  required InkSolveBackdrops backdrops,
}) {
  // Candidates use the exact accent-slot resolve math (lightness first, then
  // chroma, gamut-clamped), so the final compile reproduces them bit-for-bit.
  // Inks are opaque: min contrast reduces to arithmetic over luminances.
  double minRatio(double l) {
    final y = base
        .withLightness(l)
        .withChroma(base.chroma * chromaMult)
        .wcagLuminance;
    var min = double.infinity;
    for (final s in backdrops.luminances) {
      final r = (math.max(y, s) + 0.05) / (math.min(y, s) + 0.05);
      if (r < min) min = r;
    }
    return min;
  }

  if (minRatio(authoredL) >= target) return authoredL;

  var pass = isDark ? 1.0 : 0.0;
  if (minRatio(pass) < target) return authoredL;
  var fail = authoredL;
  for (var i = 0; i < kInkSolveSteps; i++) {
    final mid = (pass + fail) / 2;
    if (minRatio(mid) >= target) {
      pass = mid;
    } else {
      fail = mid;
    }
  }
  return pass;
}
