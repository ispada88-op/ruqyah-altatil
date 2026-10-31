// مطابقة تقويم أم القرى الرسمي (ummulqura.org.sa) بإحداثياته الرسمية للمدن
// (assets/data/cities.json في الموقع). الجداول منقولة من الموقع كما تُعرض.
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';

const _rows = <(String, double, double, String, String)>[
  // (المدينة، العرض، الطول، التاريخ، الفجر الشروق الظهر العصر المغرب العشاء)
  ('مكة المكرمة', 21.426666, 39.831666, '2026-11-01', '05:07 06:23 12:05 15:20 17:45 19:15'),
  ('المدينة المنورة', 24.54, 39.63, '2026-11-01', '05:10 06:28 12:06 15:18 17:42 19:12'),
  ('الرياض', 24.67, 46.69, '2026-11-01', '04:42 06:00 11:37 14:50 17:14 18:44'),
  ('بريدة', 26.35, 43.96, '2026-11-01', '04:54 06:13 11:48 14:59 17:23 18:53'),
  ('الدمام', 26.44, 50.1, '2026-11-01', '04:29 05:48 11:24 14:34 16:58 18:28'),
  ('أبها', 18.22, 42.51, '2026-11-01', '04:54 06:09 11:54 15:12 17:38 19:08'),
  ('تبوك', 28.4, 36.58, '2026-11-01', '05:24 06:45 12:18 15:26 17:49 19:19'),
  ('حائل', 27.52, 41.7, '2026-11-01', '05:03 06:23 11:57 15:07 17:30 19:00'),
  ('عرعر', 30.99, 41.02, '2026-11-01', '05:08 06:30 12:00 15:05 17:28 18:58'),
  ('جازان', 16.89, 42.54, '2026-11-01', '04:53 06:07 11:54 15:12 17:39 19:09'),
  ('نجران', 17.52, 44.2, '2026-11-01', '04:47 06:01 11:47 15:05 17:32 19:02'),
  ('الباحة', 20.01, 41.47, '2026-11-01', '04:59 06:15 11:58 15:15 17:40 19:10'),
  ('سكاكا', 29.97, 40.2, '2026-11-01', '05:11 06:32 12:03 15:10 17:33 19:03'),
  ('العارضة', 17.04, 43.09, '2026-11-01', '04:51 06:05 11:52 15:10 17:37 19:07'),
  ('أبها', 18.22, 42.51, '2026-10-31', '04:54 06:08 11:54 15:12 17:39 19:09'),
  ('جازان', 16.89, 42.54, '2026-10-31', '04:53 06:07 11:54 15:13 17:40 19:10'),
];

void main() {
  test('Umm al-Qura times match the official calendar minute for minute', () {
    var exact = 0, total = 0;
    final misses = <String>[];
    for (final r in _rows) {
      final day = computePrayerDay(
        lat: r.$2,
        lon: r.$3,
        date: DateTime.parse(r.$4),
        method: PrayerMethod.ummAlQura,
        madhab: PrayerMadhab.shafi,
      );
      final want = r.$5.split(' ');
      for (var i = 0; i < 6; i++) {
        final t = day[PrayerKind.values[i]]
            .toUtc()
            .add(const Duration(hours: 3)); // السعودية UTC+3
        final hm = want[i].split(':');
        final diff = t.hour * 60 +
            t.minute -
            (int.parse(hm[0]) * 60 + int.parse(hm[1]));
        total++;
        if (diff == 0) {
          exact++;
        } else {
          misses.add('${r.$1} ${r.$4} ${PrayerKind.values[i].name} $diff');
        }
        expect(diff.abs(), lessThanOrEqualTo(1),
            reason: '${r.$1} ${r.$4} ${PrayerKind.values[i].name}');
      }
    }
    // ignore: avoid_print
    print('Umm al-Qura parity: $exact/$total exact; $misses');
    expect(exact, greaterThanOrEqualTo(total - 2));
  });
}
