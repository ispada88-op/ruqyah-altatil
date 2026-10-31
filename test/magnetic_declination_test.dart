import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/magnetic_declination.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';

/// اتجاه القبلة بصيغة مستقلة (الدائرة العظمى إلى الكعبة) لمقارنة مكتبة adhan بها.
double _bearing(double lat, double lon) {
  const kaaba = (21.4225, 39.8262);
  final p = lat * math.pi / 180;
  final k = kaaba.$1 * math.pi / 180;
  final dl = (kaaba.$2 - lon) * math.pi / 180;
  final y = math.sin(dl);
  final x = math.cos(p) * math.tan(k) - math.sin(p) * math.cos(dl);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

void main() {
  group('trueHeadingFrom', () {
    test('adds the (east-positive) declination', () {
      expect(trueHeadingFrom(100, 4.5), closeTo(104.5, 1e-9));
      expect(trueHeadingFrom(100, -3), closeTo(97, 1e-9));
    });

    test('wraps around north in both directions', () {
      expect(trueHeadingFrom(359, 5), closeTo(4, 1e-9));
      expect(trueHeadingFrom(2, -5), closeTo(357, 1e-9));
      expect(trueHeadingFrom(0, 0), 0);
    });

    test('no reading / invalid reading -> null', () {
      expect(trueHeadingFrom(null, 4), isNull);
      expect(trueHeadingFrom(-1, 4), isNull); // iOS: trueHeading unavailable
      expect(trueHeadingFrom(double.nan, 4), isNull);
    });
  });

  test('declination is 0 off Android (no platform channel in tests)', () async {
    expect(await MagneticDeclination.forLocation(18.22, 42.51), 0);
  });

  test('qibla bearing matches an independent great-circle formula (±0.3°)', () {
    const cities = {
      'Abha': (18.22, 42.51),
      'Riyadh': (24.7136, 46.6753),
      'Cairo': (30.0444, 31.2357),
      'London': (51.5072, -0.1276),
      'Jakarta': (-6.2, 106.85),
      'New York': (40.7128, -74.006),
    };
    cities.forEach((name, c) {
      final d = (qiblaBearing(c.$1, c.$2) - _bearing(c.$1, c.$2) + 540) % 360 - 180;
      expect(d.abs(), lessThan(0.3), reason: name);
    });
  });
}
