import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime(2026, 11, 1, 10);
  DateTime day(int n) => t0.add(Duration(days: n));

  group('ReviewPolicy', () {
    bool ask({
      required int age,
      required int active,
      int prompts = 0,
      int? lastAgo,
      bool positive = true,
    }) =>
        ReviewPolicy.shouldAsk(
          now: day(age),
          firstLaunch: t0,
          activeDays: active,
          promptsShown: prompts,
          lastPrompt: lastAgo == null ? null : day(age - lastAgo),
          positiveMoment: positive,
        );

    test('never asks a new user', () {
      expect(ask(age: 0, active: 1), isFalse);
      expect(ask(age: 6, active: 6), isFalse); // أقل من أسبوع
      expect(ask(age: 10, active: 4), isFalse); // أيام نشاط قليلة
    });

    test('asks at a positive moment once it is a habit', () {
      expect(ask(age: 7, active: 5), isTrue);
    });

    test('without a positive moment it waits longer', () {
      expect(ask(age: 10, active: 9, positive: false), isFalse);
      expect(ask(age: 14, active: 7, positive: false), isFalse);
      expect(ask(age: 14, active: 8, positive: false), isTrue);
    });

    test('spaces prompts by 90 days and caps at 3', () {
      expect(ask(age: 100, active: 30, prompts: 1, lastAgo: 89), isFalse);
      expect(ask(age: 100, active: 30, prompts: 1, lastAgo: 90), isTrue);
      expect(ask(age: 400, active: 90, prompts: 3, lastAgo: 200), isFalse);
    });
  });

  group('ReviewService', () {
    late int requests;
    late ReviewService svc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      requests = 0;
      svc = ReviewService.instance
        ..resetForTest()
        ..settle = Duration.zero
        ..requester = () async {
          requests++;
          return true;
        };
    });

    Future<int> prefInt(String k) async =>
        (await SharedPreferences.getInstance()).getInt(k) ?? 0;

    test('daily use for a week then a finished wird → one request', () async {
      for (var d = 0; d <= 7; d++) {
        await svc.markSessionStart(now: day(d));
      }
      expect(requests, 0); // الفتح وحده لا يسأل قبل أسبوعين
      await svc.onPositiveMoment(now: day(7));
      expect(requests, 1);
      expect(await prefInt('review_prompts'), 1);

      // نفس الجلسة: لا تكرار.
      await svc.onPositiveMoment(now: day(7));
      expect(requests, 1);
    });

    test('several sessions in one day count as one active day', () async {
      for (var i = 0; i < 10; i++) {
        await svc.markSessionStart(now: day(0).add(Duration(minutes: i)));
      }
      expect(await prefInt('review_active_days'), 1);
    });

    test('a user who never finishes a wird is asked after two weeks', () async {
      for (var d = 0; d <= 13; d++) {
        await svc.markSessionStart(now: day(d));
      }
      expect(requests, 0);
      await svc.markSessionStart(now: day(14));
      expect(requests, 1);
    });

    test('a new app session after 30 days does not ask again; after 90 it can',
        () async {
      for (var d = 0; d <= 7; d++) {
        await svc.markSessionStart(now: day(d));
      }
      await svc.onPositiveMoment(now: day(7));
      expect(requests, 1);

      svc.resetForTest();
      svc
        ..settle = Duration.zero
        ..requester = () async {
          requests++;
          return true;
        };
      await svc.markSessionStart(now: day(37));
      await svc.onPositiveMoment(now: day(37));
      expect(requests, 1);

      svc.resetForTest();
      svc
        ..settle = Duration.zero
        ..requester = () async {
          requests++;
          return true;
        };
      await svc.markSessionStart(now: day(100));
      await svc.onPositiveMoment(now: day(100));
      expect(requests, 2); // مضى ٩٣ يوماً على الطلب الأول (≥ ٩٠)
    });

    test('a request that was not shown is not counted', () async {
      svc.requester = () async => false;
      for (var d = 0; d <= 7; d++) {
        await svc.markSessionStart(now: day(d));
      }
      await svc.onPositiveMoment(now: day(7));
      expect(await prefInt('review_prompts'), 0);
    });

    test('legacy session-count users are migrated as already asked', () async {
      SharedPreferences.setMockInitialValues({
        'review_session_count': 12,
        'review_asked_at': 10,
      });
      await svc.markSessionStart(now: day(0));
      expect(await prefInt('review_prompts'), 1);
      expect(requests, 0);
      await svc.onPositiveMoment(now: day(30)); // داخل مهلة الـ٩٠
      expect(requests, 0);
    });
  });

  group('review card', () {
    bool card({
      required int age,
      required int active,
      bool rated = false,
      int dismissals = 0,
      int? lastAgo,
    }) =>
        ReviewPolicy.shouldShowCard(
          now: day(age),
          firstLaunch: t0,
          activeDays: active,
          rated: rated,
          dismissals: dismissals,
          lastDismissed: lastAgo == null ? null : day(age - lastAgo),
        );

    test('policy: habit first, then calm, then gone', () {
      expect(card(age: 9, active: 9), isFalse); // مبكر
      expect(card(age: 12, active: 5), isFalse); // نشاط قليل
      expect(card(age: 10, active: 6), isTrue);
      expect(card(age: 40, active: 20, rated: true), isFalse);
      expect(card(age: 40, active: 20, dismissals: 1, lastAgo: 29), isFalse);
      expect(card(age: 40, active: 20, dismissals: 1, lastAgo: 30), isTrue);
      expect(card(age: 90, active: 40, dismissals: 2, lastAgo: 60), isFalse);
    });

    test('service: shows after a habit, dismiss hides 30 days, two dismissals end it',
        () async {
      SharedPreferences.setMockInitialValues({});
      final svc = ReviewService.instance
        ..resetForTest()
        ..settle = Duration.zero
        ..requester = () async => false;
      for (var d = 0; d <= 10; d++) {
        await svc.markSessionStart(now: day(d));
      }
      expect(svc.cardVisible.value, isTrue);

      await svc.dismissCard(now: day(10));
      expect(svc.cardVisible.value, isFalse);
      await svc.refreshCard(now: day(39));
      expect(svc.cardVisible.value, isFalse);
      await svc.refreshCard(now: day(40));
      expect(svc.cardVisible.value, isTrue);

      await svc.dismissCard(now: day(40));
      await svc.refreshCard(now: day(400));
      expect(svc.cardVisible.value, isFalse);
    });

    test('service: opening the write-review page ends the card for good', () async {
      SharedPreferences.setMockInitialValues({});
      final svc = ReviewService.instance
        ..resetForTest()
        ..settle = Duration.zero
        ..requester = () async => false;
      for (var d = 0; d <= 10; d++) {
        await svc.markSessionStart(now: day(d));
      }
      expect(svc.cardVisible.value, isTrue);
      await svc.openWriteReview();
      expect(svc.cardVisible.value, isFalse);
      await svc.refreshCard(now: day(500));
      expect(svc.cardVisible.value, isFalse);
    });
  });

  test('KhatmaService fires onTodayCompleted once when the wird is done',
      () async {
    SharedPreferences.setMockInitialValues({});
    final k = KhatmaService.test();
    var fired = 0;
    k.onTodayCompleted = () => fired++;
    final now = DateTime(2026, 1, 1, 12);
    await k.start(30, now: now);
    for (var p = k.nextPage; p <= k.todayEndPage; p++) {
      await k.onPageViewed(p, now: now);
    }
    expect(k.todayDone, isTrue);
    expect(fired, 1);
    // قراءة صفحة إضافية لا تعيد الإطلاق.
    await k.onPageViewed(k.nextPage, now: now);
    expect(fired, 1);
  });
}
