import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roqia_altatil/data/prayer_cities.dart';
import 'package:roqia_altatil/data/saudi_places.dart';
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
        expect(t[i].isAfter(t[i - 1]), isTrue,
            reason: '${PrayerKind.values[i]}');
      }
      final noonUtc = d[PrayerKind.dhuhr].toUtc();
      final minutes = noonUtc.hour * 60 + noonUtc.minute;
      // ظهر مكة بالتوقيت العالمي ≈ ٩:٠٥–٩:١٥ في أكتوبر (٣ ساعات = توقيت مكة).
      expect(minutes, inInclusiveRange(8 * 60 + 55, 9 * 60 + 25));
    });

    test('Umm al-Qura: Isha = Maghrib + 90 min, +120 in Ramadan', () {
      final normal = day(DateTime(2026, 10, 3));
      final gap = normal[PrayerKind.isha]
          .difference(normal[PrayerKind.maghrib])
          .inMinutes;
      expect(gap, inInclusiveRange(89, 91));
      final ramadan = day(DateTime(2026, 2, 25));
      final gapR = ramadan[PrayerKind.isha]
          .difference(ramadan[PrayerKind.maghrib])
          .inMinutes;
      expect(gapR, inInclusiveRange(119, 121));
    });

    test('other methods do not get the Ramadan bonus', () {
      final d = day(DateTime(2026, 2, 25), m: PrayerMethod.muslimWorldLeague);
      final gap =
          d[PrayerKind.isha].difference(d[PrayerKind.maghrib]).inMinutes;
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
    // الأقرب مدينة ذات طريقة خاصة: الكويت وقطر والإمارات ومصر لا أم القرى/الرابطة.
    expect(defaultMethodFor(29.4, 47.9), PrayerMethod.kuwait);
    expect(defaultMethodFor(25.3, 51.5), PrayerMethod.qatar);
    expect(defaultMethodFor(30.05, 31.25), PrayerMethod.egyptian);
    // بعيد (> ٣٠٠ كم عن أي مدينة جاهزة) خارج السعودية: رابطة العالم الإسلامي.
    expect(defaultMethodFor(-33.9, 151.2), PrayerMethod.muslimWorldLeague);
  });

  test('city list is sane: valid ids and unique', () {
    final ids = <String>{};
    for (final c in kPrayerCities) {
      expect(PrayerMethod.byId(c.method), isNotNull, reason: c.name);
      expect(c.lat.abs() <= 90 && c.lon.abs() <= 180, isTrue, reason: c.name);
      expect(ids.add(c.id), isTrue, reason: 'duplicate ${c.id}');
    }
  });

  group('placeLabelFor (اسم المدينة من GPS، محلياً)', () {
    test('Saudi cities by coordinates', () {
      expect(placeLabelFor(18.22, 42.51), 'أبها');
      expect(placeLabelFor(24.71, 46.68), 'الرياض');
      expect(placeLabelFor(21.49, 39.19), 'جدة');
      expect(placeLabelFor(26.57, 50.00), 'القطيف'); // لا الدمام
      expect(placeLabelFor(19.13, 41.08), 'القنفذة');
      expect(placeLabelFor(28.43, 45.97), 'حفر الباطن');
    });

    test('outside Saudi shows the country; far away falls back', () {
      expect(placeLabelFor(25.20, 55.27), 'دبي، الإمارات');
      expect(placeLabelFor(-33.9, 151.2), kUnknownPlaceLabel);
    });

    test('between cities says «قرب» the nearest one', () {
      // ~٦٠ كم شمال حائل، ولا مدينة أقرب.
      expect(placeLabelFor(28.06, 41.72), 'قرب حائل');
    });

    test('every known place resolves to itself (no shadowed duplicates)', () {
      for (final c in [...kPrayerCities, ...kSaudiPlaces]) {
        final want =
            c.country == 'السعودية' ? c.name : '${c.name}، ${c.country}';
        expect(placeLabelFor(c.lat, c.lon), want, reason: c.id);
      }
    });

    test('extra Saudi places are sane and not repeated from the picker list',
        () {
      final ids = {for (final c in kPrayerCities) c.id};
      for (final c in kSaudiPlaces) {
        expect(PrayerMethod.byId(c.method), isNotNull, reason: c.name);
        expect(c.country, 'السعودية', reason: c.name);
        expect(c.lat >= 16 && c.lat <= 32.2, isTrue, reason: c.name);
        expect(c.lon >= 34.5 && c.lon <= 55.7, isTrue, reason: c.name);
        expect(ids.add(c.id), isTrue, reason: 'duplicate ${c.id}');
      }
    });
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

    test('previousPrayer: last adhan so far; sunrise skipped; before Fajr = yesterday Isha',
        () {
      final svc = PrayerTimesService.instance
        ..debugSet(lat: 21.4225, lon: 39.8262, label: 'مكة');
      final d = svc.dayFor(DateTime(2026, 10, 3))!;
      const min = Duration(minutes: 1);
      // بعد الفجر بدقيقة ⇒ الفجر.
      final afterFajr = d[PrayerKind.fajr].add(min);
      expect(svc.previousPrayer(afterFajr)!.kind, PrayerKind.fajr);
      // بعد الشروق وقبل الظهر ⇒ ما زالت «آخر صلاة» الفجر (الشروق ليس صلاة).
      final afterSunrise = d[PrayerKind.sunrise].add(min);
      final p = svc.previousPrayer(afterSunrise)!;
      expect(p.kind, PrayerKind.fajr);
      expect(afterSunrise.difference(p.time), greaterThan(Duration.zero));
      // لحظة الأذان نفسها تُحسب (مضى ٠).
      expect(svc.previousPrayer(d[PrayerKind.dhuhr])!.kind, PrayerKind.dhuhr);
      // قبل فجر اليوم ⇒ عشاء الأمس.
      final beforeFajr = d[PrayerKind.fajr].subtract(min);
      final y = svc.dayFor(DateTime(2026, 10, 2))!;
      final prev = svc.previousPrayer(beforeFajr)!;
      expect(prev.kind, PrayerKind.isha);
      expect(prev.time, y[PrayerKind.isha]);
      // بعد العشاء ⇒ العشاء.
      expect(svc.previousPrayer(d[PrayerKind.isha].add(min))!.kind,
          PrayerKind.isha);
      // previous < now < next دائماً.
      final now = d[PrayerKind.asr].add(const Duration(minutes: 20));
      expect(svc.previousPrayer(now)!.time.isBefore(now), isTrue);
      expect(svc.nextPrayer(now)!.time.isAfter(now), isTrue);
    });

    test('load(): old «موقعك الحالي» label is replaced by the city name',
        () async {
      SharedPreferences.setMockInitialValues({
        'prayer_lat': 18.22,
        'prayer_lon': 42.51,
        'prayer_label': kUnknownPlaceLabel,
        'prayer_source': 'gps',
      });
      final svc = PrayerTimesService.instance;
      await svc.load();
      expect(svc.label, 'أبها');
      // المدينة المختارة يدوياً لا يمسّها الحساب.
      SharedPreferences.setMockInitialValues({
        'prayer_lat': 18.22,
        'prayer_lon': 42.51,
        'prayer_label': 'مكة المكرمة',
        'prayer_source': 'city',
      });
      await svc.load();
      expect(svc.label, 'مكة المكرمة');
    });

    test('no location ⇒ no times', () {
      final svc = PrayerTimesService.instance..debugSet();
      expect(svc.hasLocation, isFalse);
      expect(svc.nextPrayer(DateTime.now()), isNull);
      expect(svc.previousPrayer(DateTime.now()), isNull);
      expect(svc.qibla, isNull);
    });
  });

  test('formatCountdown / Friday label', () {
    expect(formatCountdown(const Duration(hours: 2, minutes: 5, seconds: 3)),
        '2:05:03');
    expect(formatCountdown(const Duration(seconds: -5)), '0:00:00');
    expect(prayerLabelOn(PrayerKind.dhuhr, DateTime(2026, 10, 2)),
        'الجمعة'); // جمعة
    expect(prayerLabelOn(PrayerKind.dhuhr, DateTime(2026, 10, 3)), 'الظهر');
    expect(prayerLabelOn(PrayerKind.fajr, DateTime(2026, 10, 2)), 'الفجر');
  });

  testWidgets('prayer page shows the six times for a saved location',
      (t) async {
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

  group('isRamadanUmmAlQura (embedded table)', () {
    bool r(int y, int m, int d) => isRamadanUmmAlQura(DateTime(y, m, d));

    test('Ramadan boundaries match the Umm al-Qura calendar', () {
      // ١٤٤٦: ١ مارس ٢٠٢٥ ← ٢٩ يوماً
      expect(r(2025, 2, 28), isFalse);
      expect(r(2025, 3, 1), isTrue);
      expect(r(2025, 3, 29), isTrue);
      expect(r(2025, 3, 30), isFalse);
      // ١٤٤٧: ١٨ فبراير ٢٠٢٦ ← ٣٠ يوماً
      expect(r(2026, 2, 17), isFalse);
      expect(r(2026, 2, 18), isTrue);
      expect(r(2026, 3, 19), isTrue);
      expect(r(2026, 3, 20), isFalse);
      // ١٤٤٨: ٨ فبراير ٢٠٢٧ ← ٢٩ يوماً (التحويل الجدولي كان يمدّه يوماً)
      expect(r(2027, 2, 7), isFalse);
      expect(r(2027, 2, 8), isTrue);
      expect(r(2027, 3, 8), isTrue);
      expect(r(2027, 3, 9), isFalse);
    });

    test('Isha is +30 min only inside Ramadan, and not on Eid day', () {
      Duration gap(DateTime d) {
        final p = computePrayerDay(
            lat: 18.22,
            lon: 42.51,
            date: d,
            method: PrayerMethod.ummAlQura,
            madhab: PrayerMadhab.shafi);
        return p[PrayerKind.isha].difference(p[PrayerKind.maghrib]);
      }

      expect(gap(DateTime(2027, 3, 8)), const Duration(minutes: 120));
      expect(gap(DateTime(2027, 3, 9)), const Duration(minutes: 90));
      expect(gap(DateTime(2027, 2, 7)), const Duration(minutes: 90));
    });

    test('outside the table it falls back instead of failing', () {
      expect(() => r(2100, 6, 1), returnsNormally);
      expect(() => r(2010, 6, 1), returnsNormally);
    });
  });

  group('worldwide robustness', () {
    PrayerDay day(double lat, double lon, DateTime d,
            {PrayerMethod method = PrayerMethod.muslimWorldLeague,
            PrayerHighLat hl = PrayerHighLat.auto,
            PrayerMadhab madhab = PrayerMadhab.shafi}) =>
        computePrayerDay(
            lat: lat, lon: lon, date: d, method: method, madhab: madhab, highLat: hl);

    test('polar day/night no longer throws and stays in order', () {
      for (final d in [DateTime(2027, 6, 21), DateTime(2026, 12, 21)]) {
        final t = day(69.65, 18.96, d); // Tromsø
        final order = [
          for (final k in PrayerKind.values) t[k],
        ];
        for (var i = 1; i < order.length; i++) {
          expect(order[i].isAfter(order[i - 1]), isTrue, reason: '$d #$i');
        }
      }
      expect(() => day(-78.0, 166.0, DateTime(2027, 6, 21)), returnsNormally);
    });

    test('high-latitude rule: auto = seventh above 48°, no effect near the equator',
        () {
      final d = DateTime(2027, 6, 21);
      final auto = day(51.5072, -0.1276, d); // لندن
      final middle = day(51.5072, -0.1276, d, hl: PrayerHighLat.middle);
      final seventh = day(51.5072, -0.1276, d, hl: PrayerHighLat.seventh);
      expect(auto[PrayerKind.isha], seventh[PrayerKind.isha]);
      expect(auto[PrayerKind.fajr], seventh[PrayerKind.fajr]);
      expect(auto[PrayerKind.isha].isBefore(middle[PrayerKind.isha]), isTrue);
      expect(auto[PrayerKind.fajr].isAfter(middle[PrayerKind.fajr]), isTrue);

      final a1 = day(18.22, 42.51, d);
      final a2 = day(18.22, 42.51, d, hl: PrayerHighLat.middle);
      for (final k in PrayerKind.values) {
        expect(a1[k], a2[k]);
      }
    });

    test('twilight-angle rule never throws, even for interval methods', () {
      expect(
          () => day(51.5, -0.12, DateTime(2027, 6, 21),
              method: PrayerMethod.ummAlQura, hl: PrayerHighLat.angle),
          returnsNormally);
      expect(
          () => day(51.5, -0.12, DateTime(2027, 6, 21), hl: PrayerHighLat.angle),
          returnsNormally);
    });

    test('Karachi-method regions default to the Hanafi Asr unless the user chose',
        () async {
      SharedPreferences.setMockInitialValues({});
      final svc = PrayerTimesService.instance..debugSet();
      PrayerCity byName(String n) => kPrayerCities.firstWhere((c) => c.name == n);
      expect(defaultMadhabFor(PrayerMethod.karachi), PrayerMadhab.hanafi);
      expect(defaultMadhabFor(PrayerMethod.ummAlQura), PrayerMadhab.shafi);

      await svc.setCity(byName('دلهي'));
      expect(svc.method, PrayerMethod.karachi);
      expect(svc.madhab, PrayerMadhab.hanafi);

      await svc.setMadhab(PrayerMadhab.shafi); // اختيار صريح
      await svc.setCity(byName('كراتشي'));
      expect(svc.madhab, PrayerMadhab.shafi);

      await svc.setCity(byName('الرياض')); // لا يتأثر
      expect(svc.method, isNot(PrayerMethod.karachi));
      svc.debugSet();
    });

    test('isFarFrom: only real relocations pass the 25 km bar', () {
      expect(isFarFrom(21.4225, 39.8262, 21.43, 39.83, 25), isFalse);
      expect(isFarFrom(24.7136, 46.6753, 21.4858, 39.1925, 25), isTrue);
    });
  });
}
