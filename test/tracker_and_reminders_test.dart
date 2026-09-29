import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/pages/ruqyah_tracker_page.dart';
import 'package:roqia_altatil/services/custom_reminders.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/ruqyah_log_service.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ruqyah streak', () {
    final today = DateTime(2026, 9, 28);
    Set<String> days(List<int> daysAgo) =>
        {for (final d in daysAgo) dayKey(DateTime(2026, 9, 28 - d))};

    test('counts consecutive days ending today', () {
      expect(currentStreak(days([0, 1, 2]), today), 3);
    });
    test('today not logged yet → streak ending yesterday still counts', () {
      expect(currentStreak(days([1, 2, 3, 4]), today), 4);
    });
    test('a gap breaks the streak', () {
      expect(currentStreak(days([0, 1, 3, 4]), today), 2);
      expect(currentStreak(days([2, 3]), today), 0);
    });
    test('month boundary', () {
      final d = {
        dayKey(DateTime(2026, 10, 1)),
        dayKey(DateTime(2026, 9, 30)),
        dayKey(DateTime(2026, 9, 29))
      };
      expect(currentStreak(d, DateTime(2026, 10, 1)), 3);
    });
    test('toggle persists and reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final log = RuqyahLogService.instance;
      await log.load();
      await log.toggle(today);
      expect(log.isDone(today), isTrue);
      await log.load();
      expect(log.isDone(today), isTrue);
      await log.toggle(today);
      await log.load();
      expect(log.isDone(today), isFalse);
    });
  });

  group('custom reminders', () {
    test('json round-trip keeps text, time and state', () {
      const r = CustomReminder(
          id: 'a', text: 'سبحان الله', hour: 21, minute: 5, enabled: false);
      final back =
          CustomRemindersStore.decode(CustomRemindersStore.encode([r]));
      expect(back.single.text, 'سبحان الله');
      expect((back.single.hour, back.single.minute, back.single.enabled),
          (21, 5, false));
    });

    test('corrupt / invalid entries are dropped, never crash', () {
      expect(CustomRemindersStore.decode('not json'), isEmpty);
      expect(
          CustomRemindersStore.decode(
              '[{"text":"","h":1,"m":1},{"text":"x","h":25,"m":0}]'),
          isEmpty);
    });

    test('one wrongly-typed entry does not wipe the valid ones', () {
      final out = CustomRemindersStore.decode(
          '[{"text":123,"h":1,"m":1},{"text":"ok","h":7,"m":30,"id":"a"},{"id":5,"text":"y","h":8,"m":0}]');
      expect(out.map((r) => r.text), ['ok']);
    });

    test('capped at maxCount and text sanitised', () {
      final many = [
        for (var i = 0; i < 15; i++)
          CustomReminder(id: '$i', text: 't$i', hour: 9, minute: 0),
      ];
      expect(
          CustomRemindersStore.decode(CustomRemindersStore.encode(many)).length,
          CustomRemindersStore.maxCount);
      expect(CustomRemindersStore.sanitize('  a   b  '), 'a b');
      expect(CustomRemindersStore.sanitize('x' * 500).length,
          CustomRemindersStore.maxTextLength);
    });

    test('iOS 64-pending budget shrinks with custom reminders', () {
      expect(NotificationPlan.dhikrBudget(customCount: 0), 59);
      expect(
          NotificationPlan.dhikrBudget(
              customCount: CustomRemindersStore.maxCount),
          49);
      expect(
        NotificationPlan.dhikrBudget(
                customCount: CustomRemindersStore.maxCount) +
            CustomRemindersStore.maxCount +
            1,
        lessThanOrEqualTo(NotificationService.maxPending),
      );
    });

    test('nextAt honours minutes', () {
      tz_data.initializeTimeZones();
      final loc = tz.getLocation('Asia/Riyadh');
      final now = tz.TZDateTime(loc, 2026, 9, 28, 21, 4);
      expect(NotificationPlan.nextAt(now, 21, minute: 5),
          tz.TZDateTime(loc, 2026, 9, 28, 21, 5));
      expect(NotificationPlan.nextAt(now, 21, minute: 4),
          tz.TZDateTime(loc, 2026, 9, 29, 21, 4));
    });
  });

  group('arabic format', () {
    test('digits, time, date', () {
      expect(arDigits(2026), '٢٠٢٦');
      expect(formatTimeAr(0, 5), '١٢:٠٥ ص');
      expect(formatTimeAr(20, 30), '٨:٣٠ م');
      expect(formatDateAr(DateTime(2026, 9, 28)), 'الإثنين ٢٨ سبتمبر ٢٠٢٦');
      expect(daysLabel(1), 'يوم واحد');
      expect(daysLabel(2), 'يومان');
      expect(daysLabel(7), '٧ أيام');
      expect(daysLabel(21), '٢١ يوماً');
    });
  });

  testWidgets('tracker page records today', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await RuqyahLogService.instance.load();
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
          textDirection: TextDirection.rtl, child: RuqyahTrackerPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('قرأت الرقية اليوم'), findsOneWidget);
    await tester.tap(find.text('قرأت الرقية اليوم'));
    await tester.pumpAndSettle();
    expect(find.text('تم تسجيل قراءة اليوم ✓'), findsOneWidget);
  });
}
