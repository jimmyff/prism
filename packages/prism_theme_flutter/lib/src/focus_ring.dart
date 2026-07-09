import 'package:flutter/widgets.dart';

import 'theme_extension.dart';

/// Paints prism's focus ring *outside* a [child]'s bounds.
///
/// This is the rendering half of the [PrismGeometry] focus contract: a stroke
/// of `geometry.focusWidth`, sitting `geometry.focusOffset` beyond the child
/// edge, in the `focus` role. It paints only when [visible].
///
/// The ring paints outside the child and is deliberately not clipped, so a
/// clipping ancestor will crop it — clipping components (cards, chips) should
/// reserve a `focusOffset + focusWidth` inset. [borderRadius] should match the
/// child's own rounding so the ring stays concentric.
class PrismFocusRing extends StatelessWidget {
  /// Whether the ring is drawn.
  final bool visible;

  /// The widget the ring surrounds.
  final Widget child;

  /// The child's corner rounding (the ring grows each corner to stay parallel).
  final BorderRadius borderRadius;

  const PrismFocusRing({
    required this.visible,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.prism;
    final g = p.geometry;
    return CustomPaint(
      foregroundPainter: visible
          ? _FocusRingPainter(
              color: p.focus,
              offset: g.focusOffset,
              strokeWidth: g.focusWidth,
              borderRadius: borderRadius,
            )
          : null,
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  final Color color;
  final double offset;
  final double strokeWidth;
  final BorderRadius borderRadius;

  const _FocusRingPainter({
    required this.color,
    required this.offset,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The stroke centre sits offset + strokeWidth/2 beyond the child edge, so
    // the ring's inner edge is exactly `offset` clear of the child.
    final inflate = offset + strokeWidth / 2;
    final rect = (Offset.zero & size).inflate(inflate);
    Radius grow(Radius r) => r == Radius.zero
        ? Radius.zero
        : Radius.elliptical(r.x + inflate, r.y + inflate);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: grow(borderRadius.topLeft),
      topRight: grow(borderRadius.topRight),
      bottomLeft: grow(borderRadius.bottomLeft),
      bottomRight: grow(borderRadius.bottomRight),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.color != color ||
      old.offset != offset ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius;
}
