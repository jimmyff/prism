import 'package:prism/prism.dart';
import 'package:test/test.dart';

void main() {
  RayOklch ok(double l, double c, double h) => RayOklch.fromComponents(l, c, h);

  group('Beam.colorAt', () {
    final beam = Beam.linear([ok(0.2, 0.1, 260), ok(0.8, 0.1, 260)]);

    test('endpoints', () {
      expect(beam.colorAt(0.0), beam.rays.first);
      expect(beam.colorAt(1.0), beam.rays.last);
    });

    test('midpoint lerps in ray space', () {
      expect(beam.colorAt(0.5).lightness, closeTo(0.5, 1e-9));
    });

    test('flat beam is constant', () {
      final flat = Beam.flat(ok(0.5, 0.1, 100));
      expect(flat.colorAt(0.0), flat.base);
      expect(flat.colorAt(0.37), flat.base);
      expect(flat.colorAt(1.0), flat.base);
      expect(flat.isGradient, isFalse);
    });

    test('clamps t outside [0,1] (RayOklch.lerp would otherwise throw)', () {
      expect(() => beam.colorAt(-0.5), returnsNormally);
      expect(() => beam.colorAt(1.5), returnsNormally);
      expect(beam.colorAt(-0.5), beam.rays.first);
      expect(beam.colorAt(1.5), beam.rays.last);
    });

    test('respects explicit (non-normalized-span) stops', () {
      final b = Beam.linear([ok(0.2, 0, 0), ok(0.8, 0, 0)], stops: [0.0, 0.25]);
      expect(b.colorAt(0.5).lightness, closeTo(0.8, 1e-9)); // past last stop
      expect(b.colorAt(0.25).lightness, closeTo(0.8, 1e-9)); // at last stop
      expect(b.colorAt(0.125).lightness, closeTo(0.5, 1e-9)); // halfway
    });
  });

  group('Beam.lerp', () {
    final a = Beam.linear([ok(0.2, 0, 0), ok(0.6, 0, 0)]);
    final b = Beam.linear([ok(0.4, 0, 0), ok(1.0, 0, 0)]);

    test('t=0/1 identity', () {
      expect(a.lerp(b, 0.0), a);
      expect(a.lerp(b, 1.0), b);
    });

    test('same shape blends stop-wise', () {
      final m = a.lerp(b, 0.5);
      expect(m.rays[0].lightness, closeTo(0.3, 1e-9));
      expect(m.rays[1].lightness, closeTo(0.8, 1e-9));
    });

    test('clamps t outside [0,1]', () {
      expect(() => a.lerp(b, -0.5), returnsNormally);
      expect(() => a.lerp(b, 1.5), returnsNormally);
      expect(a.lerp(b, -0.5), a);
      expect(a.lerp(b, 1.5), b);
    });

    test('different shapes resample to the union of stops', () {
      final three = Beam.linear(
        [ok(0.4, 0, 0), ok(0.4, 0, 0), ok(1.0, 0, 0)],
        stops: [0.0, 0.5, 1.0],
      );
      final m = a.lerp(three, 0.5);
      expect(m.rays.length, 3); // union {0,1} ∪ {0,0.5,1} = {0,0.5,1}
      expect(m.stops, [0.0, 0.5, 1.0]);
    });
  });

  group('Beam hue', () {
    test('takes the shortest path (350°→10° via 0°, not 180°)', () {
      final wheel = Beam.linear([ok(0.5, 0.1, 350), ok(0.5, 0.1, 10)]);
      final mid = wheel.colorAt(0.5);
      expect(mid.hue, anyOf(closeTo(0.0, 1e-6), closeTo(360.0, 1e-6)));
    });
  });

  group('Beam JSON', () {
    test('round-trips (oklch, explicit stops + angle)', () {
      final beam = Beam.linear(
        [ok(0.16, 0.05, 280), ok(0.24, 0.08, 250)],
        stops: [0.0, 1.0],
        angle: 135,
      );
      expect(Beam.fromJson(beam.toJson()), beam);
    });

    test('round-trips (default stops)', () {
      final beam = Beam.linear([ok(0.5, 0.1, 100), ok(0.6, 0.1, 120)]);
      expect(Beam.fromJson(beam.toJson()), beam);
    });
  });

  group('Beam invariants', () {
    test('empty rays assert', () {
      expect(() => Beam.linear(<RayOklch>[]), throwsA(isA<AssertionError>()));
    });

    test('value equality', () {
      expect(
        Beam.linear([ok(0.5, 0.1, 100)]),
        Beam.linear([ok(0.5, 0.1, 100)]),
      );
    });
  });
}
