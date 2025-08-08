import 'package:prism/prism.dart';
import 'package:test/test.dart';

void main() {
  group('RayRgb16 Serialization', () {
    test('toJson() excludes alpha when 65535 (full opacity)', () {
      final color = RayRgb16.fromComponentsNative(32768, 16384, 49152);
      final json = color.toJson();
      
      expect(json, {
        'r': 32768,
        'g': 16384,
        'b': 49152,
      });
      expect(json.containsKey('a'), false);
    });

    test('toJson() includes alpha when not 65535', () {
      final color = RayRgb16.fromComponentsNative(32768, 16384, 49152, 32768);
      final json = color.toJson();
      
      expect(json, {
        'r': 32768,
        'g': 16384,
        'b': 49152,
        'a': 32768,
      });
    });

    test('fromJson() works with alpha present', () {
      final json = {
        'r': 32768,
        'g': 16384,
        'b': 49152,
        'a': 32768,
      };
      final color = RayRgb16.fromJson(json);
      
      expect(color.redNative, 32768);
      expect(color.greenNative, 16384);
      expect(color.blueNative, 49152);
      expect(color.alphaNative, 32768);
    });

    test('fromJson() defaults alpha to 65535 when absent', () {
      final json = {
        'r': 32768,
        'g': 16384,
        'b': 49152,
      };
      final color = RayRgb16.fromJson(json);
      
      expect(color.redNative, 32768);
      expect(color.greenNative, 16384);
      expect(color.blueNative, 49152);
      expect(color.alphaNative, 65535);
    });

    test('roundtrip serialization preserves data', () {
      final original = RayRgb16.fromComponentsNative(12345, 23456, 34567, 45678);
      final json = original.toJson();
      final deserialized = RayRgb16.fromJson(json);
      
      expect(deserialized, equals(original));
    });

    test('roundtrip serialization without alpha preserves data', () {
      final original = RayRgb16.fromComponentsNative(12345, 23456, 34567);
      final json = original.toJson();
      final deserialized = RayRgb16.fromJson(json);
      
      expect(deserialized, equals(original));
    });
  });

  group('RayOklab Serialization', () {
    test('toJson() excludes opacity when 1.0', () {
      final color = RayOklab.fromComponents(0.5, 0.1, -0.2);
      final json = color.toJson();
      
      expect(json, {
        'l': 0.5,
        'a': 0.1,
        'b': -0.2,
      });
      expect(json.containsKey('o'), false);
    });

    test('toJson() includes opacity when not 1.0', () {
      final color = RayOklab.fromComponents(0.5, 0.1, -0.2, 0.8);
      final json = color.toJson();
      
      expect(json, {
        'l': 0.5,
        'a': 0.1,
        'b': -0.2,
        'o': 0.8,
      });
    });

    test('fromJson() works with opacity present', () {
      final json = {
        'l': 0.5,
        'a': 0.1,
        'b': -0.2,
        'o': 0.8,
      };
      final color = RayOklab.fromJson(json);
      
      expect(color.lightness, 0.5);
      expect(color.opponentA, 0.1);
      expect(color.opponentB, -0.2);
      expect(color.opacity, 0.8);
    });

    test('fromJson() defaults opacity to 1.0 when absent', () {
      final json = {
        'l': 0.5,
        'a': 0.1,
        'b': -0.2,
      };
      final color = RayOklab.fromJson(json);
      
      expect(color.lightness, 0.5);
      expect(color.opponentA, 0.1);
      expect(color.opponentB, -0.2);
      expect(color.opacity, 1.0);
    });

    test('roundtrip serialization preserves data', () {
      final original = RayOklab.fromComponents(0.7, -0.15, 0.25, 0.6);
      final json = original.toJson();
      final deserialized = RayOklab.fromJson(json);
      
      expect(deserialized, equals(original));
    });

    test('roundtrip serialization without opacity preserves data', () {
      final original = RayOklab.fromComponents(0.7, -0.15, 0.25);
      final json = original.toJson();
      final deserialized = RayOklab.fromJson(json);
      
      expect(deserialized, equals(original));
    });
  });

  group('RayOklch Serialization', () {
    test('toJson() excludes opacity when 1.0', () {
      final color = RayOklch.fromComponents(0.5, 0.2, 120.0);
      final json = color.toJson();
      
      expect(json, {
        'l': 0.5,
        'c': 0.2,
        'h': 120.0,
      });
      expect(json.containsKey('o'), false);
    });

    test('toJson() includes opacity when not 1.0', () {
      final color = RayOklch.fromComponents(0.5, 0.2, 120.0, 0.75);
      final json = color.toJson();
      
      expect(json, {
        'l': 0.5,
        'c': 0.2,
        'h': 120.0,
        'o': 0.75,
      });
    });

    test('fromJson() works with opacity present', () {
      final json = {
        'l': 0.5,
        'c': 0.2,
        'h': 120.0,
        'o': 0.75,
      };
      final color = RayOklch.fromJson(json);
      
      expect(color.lightness, 0.5);
      expect(color.chroma, 0.2);
      expect(color.hue, 120.0);
      expect(color.opacity, 0.75);
    });

    test('fromJson() defaults opacity to 1.0 when absent', () {
      final json = {
        'l': 0.5,
        'c': 0.2,
        'h': 120.0,
      };
      final color = RayOklch.fromJson(json);
      
      expect(color.lightness, 0.5);
      expect(color.chroma, 0.2);
      expect(color.hue, 120.0);
      expect(color.opacity, 1.0);
    });

    test('roundtrip serialization preserves data', () {
      final original = RayOklch.fromComponents(0.8, 0.15, 240.0, 0.9);
      final json = original.toJson();
      final deserialized = RayOklch.fromJson(json);
      
      expect(deserialized, equals(original));
    });

    test('roundtrip serialization without opacity preserves data', () {
      final original = RayOklch.fromComponents(0.8, 0.15, 240.0);
      final json = original.toJson();
      final deserialized = RayOklch.fromJson(json);
      
      expect(deserialized, equals(original));
    });
  });
}