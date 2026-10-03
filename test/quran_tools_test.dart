import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/bookmarks_service.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/utils/arabic_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tanzilSha = 'f3268cfe7a400add8a8024fe23368d66f58cc8baa51773fe94e323625c66344b';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('search asset', () {
    final file = File('assets/quran/quran-simple-tanzil.txt');

    test('is the verbatim, pinned Tanzil simple text (terms say: no changes)', () {
      expect(sha256.convert(file.readAsBytesSync()).toString(), _tanzilSha);
      expect(file.readAsBytesSync(),
          File('scripts/ref/quran-simple.txt').readAsBytesSync());
      expect(file.readAsStringSync(), contains('tanzil.net'));
    });

    test('parses to 6236 ayat in order', () {
      final v = parseTanzilForSearch(file.readAsStringSync());
      expect(v.length, 6236);
      expect((v.first.surah, v.first.ayah), (1, 1));
      expect((v.last.surah, v.last.ayah), (114, 6));
    });
  });

  group('normalizeArabic', () {
    test('strips diacritics and folds letter variants', () {
      expect(normalizeArabic('الصَّلَاةَ'), 'الصلاه');
      expect(normalizeArabic('الصلاة'), 'الصلاه');
      expect(normalizeArabic('إِلَٰهَ'), 'اله');
      expect(normalizeArabic('ٱللَّهُ'), 'الله');
      expect(normalizeArabic('مُؤْمِنِينَ'), 'مومنين');
      expect(normalizeArabic('سَأَلَ'), 'سال');
      expect(normalizeArabic('الْهُدَىٰ'), 'الهدي');
      expect(normalizeArabic('  كَلَّا  وَ  '), 'كلا و');
    });

    test('digits, punctuation and Quranic signs are dropped', () {
      expect(normalizeArabic('۩ قُلْ ١٢٣ abc!'), 'قل');
    });
  });

  group('searchVerses', () {
    final verses =
        parseTanzilForSearch(File('assets/quran/quran-simple-tanzil.txt').readAsStringSync());
    List<(int, int)> ids(SearchResults r) =>
        [for (final v in r.shown) (v.surah, v.ayah)];

    test('Ayat al-Kursi opening is found in 2:255 and 3:2, in Mushaf order', () {
      final r = searchVerses(verses, 'لا اله الا هو الحي القيوم');
      expect(ids(r).first, (2, 255));
      expect(ids(r), contains((3, 2)));
    });

    test('spelling variants find the same ayat', () {
      final a = searchVerses(verses, 'الصلاة', limit: 2000);
      final b = searchVerses(verses, 'الصَّلَاةَ', limit: 2000);
      final c = searchVerses(verses, 'الصلاه', limit: 2000);
      expect(a.total, greaterThan(20));
      expect(ids(a), ids(b));
      expect(ids(a), ids(c));
    });

    test('phrase matches rank first, then the rest in Mushaf order', () {
      final r = searchVerses(verses, 'الرحمن الرحيم', limit: 3000);
      expect(ids(r).first, (1, 1));
      expect(r.total, r.shown.length);
    });

    test('limit caps the list but reports the full count', () {
      final r = searchVerses(verses, 'الله', limit: 50);
      expect(r.shown.length, 50);
      expect(r.total, greaterThan(500));
    });

    test('one-letter, blank and unmatched queries are empty', () {
      expect(searchVerses(verses, 'ا').total, 0);
      expect(searchVerses(verses, '   ').total, 0);
      expect(searchVerses(verses, 'zzz').total, 0);
    });
  });

  group('khatma plan', () {
    test('daily target rounds up and spreads the remainder', () {
      expect(khatmaDailyTarget(nextPage: 1, daysLeft: 30), 21);
      expect(khatmaDailyTarget(nextPage: 1, daysLeft: 7), 87);
      expect(khatmaDailyTarget(nextPage: 1, daysLeft: 1), 604);
      expect(khatmaDailyTarget(nextPage: 1, daysLeft: 0), 604); // never divides by 0
      expect(khatmaDailyTarget(nextPage: 604, daysLeft: 5), 1);
      expect(khatmaDailyTarget(nextPage: 605, daysLeft: 5), 0);
      // تأخّر: بعد ١٥ يوماً من ٣٠ وصفحة ٥٠ فقط → الورد يكبر.
      expect(khatmaDailyTarget(nextPage: 50, daysLeft: 15), 37);
    });

    test('calendar days ignore time of day and DST', () {
      expect(calendarDaysBetween(DateTime(2026, 3, 28, 23, 59), DateTime(2026, 3, 30, 0, 1)), 2);
      expect(khatmaDayKey(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('KhatmaService', () {
    test('start → today target; sequential pages advance; skipping does not', () async {
      final k = KhatmaService.test();
      await k.start(30, now: DateTime(2026, 10, 3, 9));
      expect(k.active, isTrue);
      expect((k.todayStartPage, k.todayEndPage, k.todayTarget), (1, 21, 21));
      await k.onPageViewed(5); // قفز
      expect(k.nextPage, 1);
      await k.onPageViewed(1);
      await k.onPageViewed(2);
      expect(k.nextPage, 3);
      expect(k.todayRead, 2);
      expect(k.todayDone, isFalse);
      await k.onPageViewed(2); // رجوع لصفحة سبقت
      expect(k.nextPage, 3);
    });

    test('completeToday finishes the day wird', () async {
      final k = KhatmaService.test();
      await k.start(30, now: DateTime(2026, 10, 3));
      await k.completeToday(now: DateTime(2026, 10, 3));
      expect(k.nextPage, 22);
      expect(k.todayDone, isTrue);
    });

    test('finishing page 604 completes a khatma and deactivates', () async {
      final k = KhatmaService.test();
      await k.start(7, fromPage: 604, now: DateTime(2026, 10, 3));
      await k.onPageViewed(604);
      expect(k.active, isFalse);
      expect(k.completedCount, 1);
    });

    test('state survives a reload; a new day recomputes from where you are', () async {
      final a = KhatmaService.test();
      await a.start(30, now: DateTime(2026, 10, 3));
      for (var p = 1; p <= 10; p++) {
        await a.onPageViewed(p);
      }
      final b = KhatmaService.test();
      await b.ensureLoaded();
      expect((b.active, b.nextPage, b.days), (true, 11, 30));
      // اليوم التالي: ٢٩ يوماً متبقية (٣٠ − يوم واحد)، المتبقي ٥٩٤ صفحة.
      b.refresh(DateTime(2026, 10, 4, 6));
      expect(b.todayStartPage, 11);
      expect(b.todayTarget, khatmaDailyTarget(nextPage: 11, daysLeft: 29));
    });

    test('corrupt stored values fall back safely', () async {
      SharedPreferences.setMockInitialValues({
        'khatma_active': true,
        'khatma_start': 'garbage',
        'khatma_days': -4,
        'khatma_next': 'x',
        'khatma_day_target': 99999,
      });
      final k = KhatmaService.test();
      await k.ensureLoaded();
      expect(k.nextPage, inInclusiveRange(1, 604));
      expect(k.days, 30);
      expect(k.todayTarget, lessThanOrEqualTo(604));
    });
  });

  group('BookmarksService', () {
    test('toggle adds then removes; newest first; persisted', () async {
      final b = BookmarksService.test();
      expect(await b.toggle(10, now: DateTime(2026, 1, 1)), isTrue);
      expect(await b.toggle(300, now: DateTime(2026, 1, 2)), isTrue);
      expect([for (final x in b.items) x.page], [300, 10]);
      expect(b.contains(10), isTrue);

      final again = BookmarksService.test();
      await again.ensureLoaded();
      expect([for (final x in again.items) x.page], [300, 10]);

      expect(await again.toggle(10), isFalse);
      expect(again.contains(10), isFalse);
      await again.remove(300);
      expect(again.items, isEmpty);
    });

    test('out-of-range pages are ignored; corrupt entries skipped', () async {
      SharedPreferences.setMockInitialValues({
        'mushaf_bookmarks': ['5:100', 'x', '999:1', '5:200', '7:abc', '9'],
      });
      final b = BookmarksService.test();
      await b.ensureLoaded();
      expect([for (final x in b.items) x.page], [5]); // التكرار يُهمَل
      await b.toggle(0);
      await b.toggle(605);
      expect(b.items.length, 1);
    });
  });

  test('new routes are canonical', () {
    for (final r in [AppRoutes.khatma, AppRoutes.bookmarks, AppRoutes.quranSearch]) {
      expect(AppRoutes.normalize(r), isNull);
    }
    expect(AppRoutes.normalize('/khatma/'), '/khatma');
  });
}
