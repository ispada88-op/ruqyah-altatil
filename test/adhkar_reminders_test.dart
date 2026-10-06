import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/adhkar_data.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/adhkar_reminders.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AdhkarRemindersStore', () {
    test('defaults: off, 06:00 morning, 17:00 evening', () async {
      final m = await AdhkarRemindersStore.load(AdhkarSlot.morning);
      final e = await AdhkarRemindersStore.load(AdhkarSlot.evening);
      expect((m.enabled, m.hour, m.minute), (false, 6, 0));
      expect((e.enabled, e.hour, e.minute), (false, 17, 0));
    });

    test('save/load round trip, slots are independent', () async {
      await AdhkarRemindersStore.save(AdhkarSlot.morning,
          enabled: true, minutes: 5 * 60 + 45);
      final m = await AdhkarRemindersStore.load(AdhkarSlot.morning);
      final e = await AdhkarRemindersStore.load(AdhkarSlot.evening);
      expect((m.enabled, m.hour, m.minute), (true, 5, 45));
      expect(e.enabled, false);
      expect(e.minutes, AdhkarRemindersStore.defaultEveningMinutes);
    });

    test('corrupt stored values fall back to defaults instead of throwing',
        () async {
      SharedPreferences.setMockInitialValues({
        'adhkar_reminder_morning_on': 'yes',
        'adhkar_reminder_morning_min': 99999,
        'adhkar_reminder_evening_min': 'x',
      });
      final m = await AdhkarRemindersStore.load(AdhkarSlot.morning);
      final e = await AdhkarRemindersStore.load(AdhkarSlot.evening);
      expect(m.enabled, false);
      expect(m.minutes, AdhkarRemindersStore.defaultMorningMinutes);
      expect(e.minutes, AdhkarRemindersStore.defaultEveningMinutes);
    });

    test('sanitizeMinutes bounds', () {
      expect(AdhkarRemindersStore.sanitizeMinutes(0, 9), 0);
      expect(AdhkarRemindersStore.sanitizeMinutes(1439, 9), 1439);
      expect(AdhkarRemindersStore.sanitizeMinutes(1440, 9), 9);
      expect(AdhkarRemindersStore.sanitizeMinutes(-1, 9), 9);
      expect(AdhkarRemindersStore.sanitizeMinutes(null, 9), 9);
    });
  });

  group('fires at local wall-clock time in the device zone', () {
    for (final zone in ['Asia/Riyadh', 'Africa/Cairo', 'Europe/London', 'America/New_York']) {
      test(zone, () {
        final loc = tz.getLocation(zone);
        final now = tz.TZDateTime(loc, 2026, 9, 28, 7, 0); // after 06:00
        final morning = NotificationPlan.nextAt(now, 6, minute: 0);
        final evening = NotificationPlan.nextAt(now, 17, minute: 0);
        expect(morning, tz.TZDateTime(loc, 2026, 9, 29, 6));
        expect(evening, tz.TZDateTime(loc, 2026, 9, 28, 17));
        expect(morning.location.name, zone);
      });
    }
  });

  test('payload ↔ route', () {
    expect(AdhkarRemindersStore.payload(AdhkarSlot.morning), 'adhkar:morning');
    expect(AppRoutes.fromNotificationPayload('adhkar:morning'),
        '/adhkar?time=morning');
    expect(AppRoutes.fromNotificationPayload('adhkar:evening'),
        AppRoutes.adhkarAt(AdhkarTime.evening));
    expect(AppRoutes.fromNotificationPayload(null), isNull);
    expect(AppRoutes.fromNotificationPayload('whatever'), isNull);
    // the query string must survive router normalisation
    expect(AppRoutes.normalize(Uri.parse('/adhkar?time=evening').path), isNull);
  });

  test('iOS budget accounts for the two adhkar reminders', () {
    expect(NotificationPlan.dhikrBudget(customCount: 0, adhkarCount: 2), 57);
    final worst = NotificationPlan.dhikrBudget(customCount: 10, adhkarCount: 2) +
        10 + 2 + 1; // dhikr + custom + adhkar + ruqyah
    expect(worst, lessThan(64));
  });
}
