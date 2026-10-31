import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/bookmarks_service.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final jan1 = DateTime(2026, 1, 1, 12);

  Future<void> readTo(KhatmaService k, int lastPage, DateTime now) async {
    for (var p = k.nextPage; p <= lastPage; p++) {
      await k.onPageViewed(p, now: now);
    }
  }

  group('overdue plan', () {
    test('after the planned days the wird is capped at the plan pace',
        () async {
      final k = KhatmaService.test();
      await k.start(30, now: jan1);
      await readTo(k, 404, jan1);
      final later = DateTime(2026, 2, 20, 12); // ٥٠ يوماً — الخطة ٣٠
      k.refresh(later);
      expect(k.pagesLeft, 200);
      expect(k.todayTarget, 21); // لا ٢٠٠ في يوم واحد
      expect(k.isBehind(later), isTrue);
    });

    test('a few pages left after the deadline is not "behind"', () async {
      final k = KhatmaService.test();
      await k.start(30, now: jan1);
      await readTo(k, 599, jan1);
      final later = DateTime(2026, 2, 20, 12);
      k.refresh(later);
      expect(k.pagesLeft, 5); // قُرئت حتى ٥٩٩ فبقيت ٦٠٠–٦٠٤
      expect(k.todayTarget, 5);
      expect(k.isBehind(later), isFalse);
    });

    test('steady reading at the plan pace is never "behind"', () async {
      final k = KhatmaService.test();
      await k.start(30, now: jan1);
      for (var d = 0; d < 12; d++) {
        final now = DateTime(2026, 1, 1 + d, 12);
        k.refresh(now);
        expect(k.isBehind(now), isFalse, reason: 'day $d');
        expect(k.todayTarget, lessThanOrEqualTo(21), reason: 'day $d');
        await readTo(k, k.todayEndPage, now);
        expect(k.todayDone, isTrue, reason: 'day $d');
      }
    });
  });

  group('extend to pace', () {
    test('falling far behind offers an extension that restores the pace',
        () async {
      final k = KhatmaService.test();
      await k.start(7, now: jan1);
      expect(k.planPace, 87);
      final d6 = DateTime(2026, 1, 6, 12); // ٥ أيام بلا قراءة
      k.refresh(d6);
      expect(k.todayTarget, 302);
      expect(k.isBehind(d6), isTrue);

      await k.extendToPace(now: d6);
      expect(k.days, 12);
      expect(k.todayTarget, 87);
      expect(k.planPace, 87); // الوتيرة الأصلية لا تتغيّر
      expect(k.isBehind(d6), isFalse); // لا يعود العرض بعد قبوله
      expect(k.daysLeftAfterToday(d6), greaterThanOrEqualTo(0));
    });

    test('extension keeps today\'s progress', () async {
      final k = KhatmaService.test();
      await k.start(7, now: jan1);
      final d6 = DateTime(2026, 1, 6, 12);
      k.refresh(d6);
      await readTo(k, 40, d6);
      await k.extendToPace(now: d6);
      expect(k.todayStartPage, 1);
      expect(k.todayRead, 40);
      expect(k.nextPage, 41);
    });
  });

  group('start from a page', () {
    test('daily target and pace count only the remaining pages', () async {
      final k = KhatmaService.test();
      await k.start(30, fromPage: 301, now: jan1);
      expect(k.startPage, 301);
      expect(k.nextPage, 301);
      expect(k.todayTarget, 11); // ٣٠٤ صفحة ÷ ٣٠
      expect(k.planPace, 11);
    });

    test('start page and pace survive a reload', () async {
      final a = KhatmaService.test();
      await a.start(30, fromPage: 301, now: jan1);
      final b = KhatmaService.test();
      await b.ensureLoaded();
      expect(b.startPage, 301);
      expect(b.planPace, 11);
      expect(b.nextPage, 301);
    });

    test('a plan saved before this version still loads (pace derived)',
        () async {
      SharedPreferences.setMockInitialValues({
        'khatma_active': true,
        'khatma_start': '2026-01-01',
        'khatma_days': 30,
        'khatma_next': 5,
      });
      final k = KhatmaService.test();
      await k.ensureLoaded();
      expect(k.startPage, 1);
      expect(k.planPace, 21);
    });
  });

  testWidgets('dwell timer counts only pages that stay on screen',
      (t) async {
    final read = <int>[];
    final d = PageDwellTimer(read.add, dwell: const Duration(seconds: 10));
    d.show(1);
    await t.pump(const Duration(seconds: 3));
    d.show(2); // قلّب بسرعة
    await t.pump(const Duration(seconds: 3));
    d.show(3);
    await t.pump(const Duration(seconds: 11));
    expect(read, [3]);

    d.show(4);
    await t.pump(const Duration(seconds: 5));
    d.pause(); // التطبيق إلى الخلفية
    await t.pump(const Duration(seconds: 30));
    expect(read, [3]);

    d.show(5);
    d.dispose(); // خرج من القارئ
    await t.pump(const Duration(seconds: 30));
    expect(read, [3]);
  });

  group('bookmarks', () {
    test('undoing a delete restores the bookmark to its place and date',
        () async {
      final b = BookmarksService.test();
      await b.toggle(10, now: DateTime(2026, 1, 1));
      await b.toggle(20, now: DateTime(2026, 1, 2));
      await b.toggle(30, now: DateTime(2026, 1, 3));
      expect([for (final x in b.items) x.page], [30, 20, 10]);
      await b.remove(20);
      expect([for (final x in b.items) x.page], [30, 10]);
      await b.toggle(20, now: DateTime(2026, 1, 2)); // تراجع بتاريخها الأصلي
      expect([for (final x in b.items) x.page], [30, 20, 10]);
      expect(b.items[1].added, DateTime(2026, 1, 2));
    });

    test('same-instant bookmarks: the newest is first', () async {
      final b = BookmarksService.test();
      final t = DateTime(2026, 1, 1);
      await b.toggle(1, now: t);
      await b.toggle(2, now: t);
      expect([for (final x in b.items) x.page], [2, 1]);
    });
  });

  test('parseArabicInt accepts Arabic-Indic, Persian and Latin digits', () {
    expect(parseArabicInt('٢٠'), 20);
    expect(parseArabicInt('١٢٣'), 123);
    expect(parseArabicInt('۱۲'), 12);
    expect(parseArabicInt(' 604 '), 604);
    expect(parseArabicInt(''), isNull);
    expect(parseArabicInt('س'), isNull);
    expect(parseArabicInt('١٢س'), isNull);
  });
}
