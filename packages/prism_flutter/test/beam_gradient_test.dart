import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_flutter/prism_flutter.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  group('Beam.toLinearGradient', () {
    test('gradient beam densifies to `resolution` stops', () {
      final g = Beam.linear([
        ok(0.2, 0.1, 260),
        ok(0.8, 0.1, 260),
      ]).toLinearGradient(resolution: 8);
      expect(g.colors.length, 8);
      expect(g.stops, hasLength(8));
      expect(g.stops!.first, 0.0);
      expect(g.stops!.last, 1.0);
    });

    test('colors equal colorAt().toColor() at each sample', () {
      final beam = Beam.linear([ok(0.2, 0.1, 260), ok(0.8, 0.1, 260)]);
      final g = beam.toLinearGradient(resolution: 4);
      for (var i = 0; i < 4; i++) {
        expect(g.colors[i], beam.colorAt(i / 3).toColor());
      }
    });

    test('flat beam yields two identical stops', () {
      final flat = Beam.flat(ok(0.5, 0.1, 100));
      final g = flat.toLinearGradient();
      expect(g.colors.length, 2);
      expect(g.colors[0], g.colors[1]);
      expect(g.colors[0], flat.base.toColor());
    });

    test('angle 180° maps to top→bottom begin/end', () {
      final g = Beam.flat(ok(0.5, 0, 0)).toLinearGradient();
      final begin = g.begin as Alignment;
      final end = g.end as Alignment;
      expect(begin.x, closeTo(0.0, 1e-9));
      expect(begin.y, closeTo(-1.0, 1e-9)); // topCenter
      expect(end.x, closeTo(0.0, 1e-9));
      expect(end.y, closeTo(1.0, 1e-9)); // bottomCenter
    });
  });
}
