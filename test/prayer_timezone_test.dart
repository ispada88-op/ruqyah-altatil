// يوم الموقع المحلي قرب خط التاريخ، وشفافية مصدر المواقيت.
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('the requested date is the site-local day (date line)', () {
    const places = [
      ("Nuku'alofa", -21.1394, -175.2049, 'Pacific/Tongatapu'),
      ('Apia', -13.8333, -171.7667, 'Pacific/Apia'),
      ('Kiritimati', 1.8721, -157.4278, 'Pacific/Kiritimati'),
      ('Honolulu', 21.3069, -157.8583, 'Pacific/Honolulu'),
      ('Auckland', -36.8485, 174.7633, 'Pacific/Auckland'),
      ('Makkah', 21.4225, 39.8262, 'Asia/Riyadh'),
    ];
    for (final p in places) {
      test(p.$1, () {
        final zone = tz.getLocation(p.$4);
        for (final date in [
          DateTime(2026, 1, 15),
          DateTime(2026, 6, 15),
          DateTime(2026, 10, 31),
        ]) {
          final day = computePrayerDay(
            lat: p.$2,
            lon: p.$3,
            date: date,
            method: PrayerMethod.muslimWorldLeague,
            madhab: PrayerMadhab.shafi,
            zone: zone,
          );
          for (final k in PrayerKind.values) {
            final w = tz.TZDateTime.from(day[k], zone);
            expect(DateTime(w.year, w.month, w.day), date,
                reason: '${p.$1} $date ${k.name}');
          }
          final dhuhr = tz.TZDateTime.from(day[PrayerKind.dhuhr], zone);
          expect(dhuhr.hour, inInclusiveRange(11, 13), reason: '${p.$1} $date');
          for (var i = 1; i < PrayerKind.values.length; i++) {
            expect(
                day[PrayerKind.values[i]]
                    .isAfter(day[PrayerKind.values[i - 1]]),
                isTrue,
                reason: '${p.$1} $date order');
          }
        }
      });
    }
  });

  group('source transparency', () {
    final svc = PrayerTimesService.instance;
    test('official method in its own country is marked verified', () {
      svc.debugSet(lat: 3.139, lon: 101.6869, method: PrayerMethod.jakim);
      expect(svc.country, 'ماليزيا');
      expect(svc.methodVerifiedHere, isTrue);
      svc.debugSet(lat: 18.2164, lon: 42.5053, method: PrayerMethod.ummAlQura);
      expect(svc.methodVerifiedHere, isTrue);
    });
    test('same method elsewhere, or an unverified method, is general', () {
      svc.debugSet(lat: 23.588, lon: 58.3829, method: PrayerMethod.ummAlQura);
      expect(svc.country, 'عُمان');
      expect(svc.methodVerifiedHere, isFalse);
      svc.debugSet(
          lat: 33.3152, lon: 44.3661, method: PrayerMethod.muslimWorldLeague);
      expect(svc.methodVerifiedHere, isFalse);
      svc.debugSet(lat: 10, lon: -150); // المحيط: لا بلد معروف
      expect(svc.country, isNull);
      expect(svc.methodVerifiedHere, isFalse);
    });
    test('high latitude is flagged', () {
      svc.debugSet(lat: 51.5072, lon: -0.1276);
      expect(svc.isHighLatitude, isTrue);
      svc.debugSet(lat: 21.4225, lon: 39.8262);
      expect(svc.isHighLatitude, isFalse);
    });
  });
}
