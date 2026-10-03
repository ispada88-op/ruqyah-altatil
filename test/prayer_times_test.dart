import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/prayer_cities.dart';
import 'package:roqia_altatil/pages/prayer_times_page.dart';
import 'package:roqia_altatil/pages/qibla_page.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/utils/hijri.dart';

void main() {
  group('hijri (tabular)', () {
    test('Ramadan 1446/1447 start where Umm al-Qura puts it', () {
      expect(gregorianToHijri(DateTime(2025, 3, 1)).toString(), '1446-9-1');
      expect(gregorianToHijri(DateTime(2026, 2, 18)).toString(), '1447-9-1');
      expect(gregorianToHijri(DateTime(2026, 2, 17)).isRamadan, isFalse);
      expect(gregorianToHijri(DateTime(2026, 3, 19)).isRamadan, isTrue);
      expect(gregorianToHijri(DateTime(2026, 3, 20)).isRamadan, isFalse);
    });
  });

  group('computePrayerDay', () {
    const makkah = (21.4225, 39.8262);
    PrayerDay day(DateTime d,
            {PrayerMethod m = PrayerMethod.ummAlQura,
            PrayerMadhab madhab = PrayerMadhab.shafi}) =>
        computePrayerDay(
            lat: makkah.$1, lon: makkah.$2, date: d, method: m, madhab: madhab);

    test('order and Makkah noon window (UTC, independent of device zone)', () {
      final d = day(DateTime(2026, 10, 3));
      final t = [for (final k in PrayerKind.values) d[k]];
      for (var i = 1; i < t.length; i++) {
        expect(t[i].isAfter(t[i - 1]), isTrue, reason: '${PrayerKind.values[i]}');
      }
      final noonUtc = d[PrayerKind.dhuhr].toUtc();
      final minutes = noonUtc.hour * 60 + noonUtc.minute;
      // ظهر مكة بالتوقيت العالمي ≈ ٩:٠٥–٩:١٥ في أكتوبر (٣ ساعات = توقيت مكة).
      expect(minutes, inInclusiveRange(8 * 60 + 55, 9 * 60 + 25));
    });

    test('Umm al-Qura: Isha = Maghrib + 90 min, +120 in Ramadan', () {
      final normal = day(DateTime(2026, 10, 3));
      final gap = normal[PrayerKind.isha].difference(normal[PrayerKind.maghrib]).inMinutes;
      expect(gap, inInclusiveRange(89, 91));
      final ramadan = day(DateTime(2026, 2, 25));
      final gapR = ramadan[PrayerKind.isha].difference(ramadan[PrayerKind.maghrib]).inMinutes;
      expect(gapR, inInclusiveRange(119, 121));
    });

    test('other methods do not get the Ramadan bonus', () {
      final d = day(DateTime(2026, 2, 25), m: PrayerMethod.muslimWorldLeague);
      final gap = d[PrayerKind.isha].difference(d[PrayerKind.maghrib]).inMinutes;
      expect(gap, lessThan(110));
    });

    test('Hanafi Asr is later than the majority Asr', () {
      final a = day(DateTime(2026, 10, 3));
      final h = day(DateTime(2026, 10, 3), madhab: PrayerMadhab.hanafi);
      expect(h[PrayerKind.asr].isAfter(a[PrayerKind.asr]), isTrue);
      expect(h[PrayerKind.fajr], a[PrayerKind.fajr]);
    });
  });

  group('qibla', () {
    test('known bearings', () {
      expect(qiblaBearing(24.7136, 46.6753), closeTo(244.7, 2)); // الرياض
      expect(qiblaBearing(30.0444, 31.2357), closeTo(136.2, 2)); // القاهرة
      expect(qiblaBearing(51.5072, -0.1276), closeTo(119, 2)); // لندن
    });

    test('angleDelta wraps around north', () {
      expect(angleDelta(10, 350), closeTo(20, 1e-9));
      expect(angleDelta(350, 10), closeTo(-20, 1e-9));
      expect(angleDelta(180, 0).abs(), closeTo(180, 1e-9));
    });
  });

  test('default method: Umm al-Qura inside Saudi, MWL elsewhere', () {
    expect(defaultMethodFor(24.7, 46.7), PrayerMethod.ummAlQura);
    expect(defaultMethodFor(51.5, -0.1), PrayerMethod.muslimWorldLeague);
  });

  test('city list is sane: valid ids and unique', () {
    final ids = <String>{};
    for (final c in kPrayerCities) {
      expect(PrayerMethod.byId(c.method), isNotNull, reason: c.name);
      expect(c.lat.abs() <= 90 && c.lon.abs() <= 180, isTrue, reason: c.name);
      expect(ids.add(c.id), isTrue, reason: 'duplicate ${c.id}');
    }
  });

  group('service', () {
    test('nextPrayer skips sunrise and rolls to tomorrow after Isha', () {
      final svc = PrayerTimesService.instance
        ..debugSet(lat: 21.4225, lon: 39.8262, label: 'مكة');
      final d = svc.dayFor(DateTime(2026, 10, 3))!;
      // بعد الفجر وقبل الشروق ⇒ التالية الظهر (لا الشروق).
      final afterFajr = d[PrayerKind.fajr].add(const Duration(minutes: 1));
      expect(svc.nextPrayer(afterFajr)!.kind, PrayerKind.dhuhr);
      // بعد العشاء ⇒ فجر الغد.
      final afterIsha = d[PrayerKind.isha].add(const Duration(minutes: 1));
      final n = svc.nextPrayer(afterIsha)!;
      expect(n.kind, PrayerKind.fajr);
      expect(n.time.isAfter(afterIsha), isTrue);
    });

    test('no location ⇒ no times', () {
      final svc = PrayerTimesService.instance..debugSet();
      expect(svc.hasLocation, isFalse);
      expect(svc.nextPrayer(DateTime.now()), isNull);
      expect(svc.qibla, isNull);
    });
  });

  test('formatCountdown / Friday label', () {
    expect(formatCountdown(const Duration(hours: 2, minutes: 5, seconds: 3)), '٢:٠٥:٠٣');
    expect(formatCountdown(const Duration(seconds: -5)), '٠:٠٠:٠٠');
    expect(prayerLabelOn(PrayerKind.dhuhr, DateTime(2026, 10, 2)), 'الجمعة'); // جمعة
    expect(prayerLabelOn(PrayerKind.dhuhr, DateTime(2026, 10, 3)), 'الظهر');
    expect(prayerLabelOn(PrayerKind.fajr, DateTime(2026, 10, 2)), 'الفجر');
  });

  testWidgets('prayer page shows the six times for a saved location', (t) async {
    PrayerTimesService.instance
        .debugSet(lat: 24.7136, lon: 46.6753, label: 'الرياض');
    await t.pumpWidget(const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: PrayerTimesPage(),
      ),
    ));
    await t.pump();
    expect(find.text('الفجر'), findsWidgets);
    expect(find.text('العشاء'), findsWidgets);
    expect(find.text('الصلاة القادمة'), findsOneWidget);
    // أزل المؤقّت الدوري قبل نهاية الاختبار.
    await t.pumpWidget(const SizedBox());
  });
}
