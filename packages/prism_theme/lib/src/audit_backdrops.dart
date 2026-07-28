/// Shared backdrop sampling and compositing — the single source of truth for
/// how a foreground is measured against the theme's layered backgrounds.
///
/// Used by both the contrast audit (`contrast.dart`) and the adaptive-ink
/// solve at compile time (`adaptive_ink.dart`), so a solved ink is guaranteed
/// to measure identically when audited. Internal: not exported by the barrel.
library;

import 'package:prism/prism.dart';

/// Gradient backgrounds are sampled at this many points (endpoint-only
/// sampling gives a false pass when a role's luminance falls inside the span).
const int auditCanvasSamples = 16;

/// Composites [src] over [dst] (source-over alpha compositing, sRGB math).
///
/// The pure primitive behind `PrismScheme.composite`/`over`/`wash`.
RayOklch compositeColors(Ray src, Ray dst) {
  final s = src.toRgb8();
  final d = dst.toRgb8();
  final sa = s.alpha / 255.0;
  final da = d.alpha / 255.0;
  final outA = sa + da * (1 - sa);
  if (outA <= 0) return const RayOklch.empty();
  double channel(num sc, num dc) => (sc * sa + dc * da * (1 - sa)) / outA;
  return RayRgb8.fromComponents(
    channel(s.red, d.red),
    channel(s.green, d.green),
    channel(s.blue, d.blue),
    outA * 255,
  ).toOklch();
}

/// Samples a background beam: one color if flat, [auditCanvasSamples] if a
/// gradient.
List<RayOklch> sampleBeam(Beam<RayOklch> beam) {
  if (!beam.isGradient) return [beam.base];
  return [
    for (var i = 0; i < auditCanvasSamples; i++)
      beam.colorAt(i / (auditCanvasSamples - 1)),
  ];
}

/// A fill's backdrop: its own samples if fully opaque, else the fill
/// flattened over **every** canvas sample.
///
/// A translucent panel can sit over any region of the canvas, so the minimum
/// contrast across all fill×canvas composites is the conservative measure.
/// Bounded [auditCanvasSamples]², at audit/compile time only — never per frame.
List<RayOklch> flattenBackdrop(
  Beam<RayOklch> fill,
  List<RayOklch> canvasSamples,
) {
  final fills = sampleBeam(fill);
  if (fills.every((f) => f.opacity >= 1.0)) return fills;
  return [
    for (final c in canvasSamples)
      for (final f in fills) compositeColors(f, c),
  ];
}

/// The minimum contrast of [fg] (composited if translucent) over [samples].
double minContrastOver(RayOklch fg, List<RayOklch> samples) {
  var min = double.infinity;
  for (final s in samples) {
    final rendered = fg.opacity < 1.0 ? compositeColors(fg, s) : fg;
    final ratio = rendered.contrastRatio(s);
    if (ratio < min) min = ratio;
  }
  return min;
}
