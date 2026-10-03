import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/adhkar_reminders.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/prayer_notification_plan.dart';
import 'package:roqia_altatil/services/prayer_reminders.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz_data.initializeTimeZones();
  final riyadh = tz.getLocation('Asia/Riyadh');
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PrayerDay dayFor(DateTime d) => computePrayerDay(
      lat: 21.4225,
      lon: 39.8262,
      date: d,
      method: PrayerMethod.ummAlQura,
      madhab: PrayerMadhab.shafi);

  const off = AdhkarReminderConfig(enabled: false, minutes: 360);
  const all = PrayerReminderConfig(
      alerts: {
        PrayerKind.fajr,
        PrayerKind.dhuhr,
        PrayerKind.asr,
        PrayerKind.maghrib,
        PrayerKind.isha
      },
      afterPrayer: true,
      kahfFriday: true,
      sleep: true);

  List<PlannedNotification> plan(
          {required tz.TZDateTime now,
          PrayerReminderConfig cfg = all,
          AdhkarReminderConfig morning = off,
          AdhkarReminderConfig evening = off,
          int budget = 1000}) =>
      planPrayerNotifications(
          now: now,
          dayFor: dayFor,
          cfg: cfg,
          morning: morning,
          evening: evening,
          budget: budget);

  // الجمعة ٢ أكتوبر ٢٠٢٦ — بداية الأسبوع المخطَّط.
  final friday = tz.TZDateTime(riyadh, 2026, 10, 2, 0, 5);

  test('nothing enabled → empty plan', () {
    expect(plan(now: friday, cfg: const PrayerReminderConfig()), isEmpty);
  });

  test('budget 0 or negative → empty; budget caps and keeps the earliest', () {
    expect(plan(now: friday, budget: 0), isEmpty);
    expect(plan(now: friday, budget: -3), isEmpty);
    final full = plan(now: friday);
    final cut = plan(now: friday, budget: 10);
    expect(cut.length, 10);
    expect([for (final n in cut) n.id], [for (final n in full.take(10)) n.id]);
  });

  test('sorted, all in the future, unique ids, inside the id range', () {
    final p = plan(now: friday);
    for (var i = 1; i < p.length; i++) {
      expect(p[i].when.isBefore(p[i - 1].when), isFalse);
    }
    expect(p.every((n) => n.when.isAfter(friday)), isTrue);
    expect(p.map((n) => n.id).toSet().length, p.length);
    expect(p.every((n) => n.id >= kPrayerIdBase && n.id < kPrayerIdBase + 7 * 16),
        isTrue);
  });

  test('past times are dropped (now = after Dhuhr)', () {
    final noon = dayFor(DateTime(2026, 10, 2))[PrayerKind.dhuhr];
    final now = tz.TZDateTime.fromMillisecondsSinceEpoch(
        riyadh, noon.add(const Duration(minutes: 1)).millisecondsSinceEpoch);
    final p = plan(now: now, cfg: const PrayerReminderConfig(
        alerts: {PrayerKind.fajr, PrayerKind.dhuhr}));
    expect(p.first.when.isAfter(now), isTrue);
    expect(p.where((n) => n.when.day == 2 && n.title.contains('الفجر')), isEmpty);
  });

  test('Friday: Dhuhr alert is named الجمعة; Kahf only on Fridays', () {
    final p = plan(now: friday);
    expect(p.where((n) => n.kind == PlannedKind.kahf).length, 1); // جمعة واحدة
    final kahf = p.firstWhere((n) => n.kind == PlannedKind.kahf);
    expect(kahf.when.weekday, DateTime.friday);
    expect(kahf.payload, 'kahf');
    final fri = p.firstWhere((n) =>
        n.kind == PlannedKind.prayerAlert && n.when.weekday == DateTime.friday &&
        n.title.contains('الجمعة'));
    expect(fri.title, 'حان وقت صلاة الجمعة');
    final sat = p.firstWhere((n) =>
        n.kind == PlannedKind.prayerAlert && n.when.weekday == DateTime.saturday &&
        n.title.contains('الظهر'));
    expect(sat.title, 'حان وقت صلاة الظهر');
  });

  test('after-prayer fires 30 min after each of the five prayers', () {
    final p = plan(
        now: friday,
        cfg: const PrayerReminderConfig(afterPrayer: true));
    final d = dayFor(DateTime(2026, 10, 2));
    final firstDay = p.where((n) => n.when.day == 2).toList();
    expect(firstDay.length, 5);
    expect(firstDay.every((n) => n.payload == 'afterprayer'), isTrue);
    expect(
        firstDay.first.when.millisecondsSinceEpoch,
        d[PrayerKind.fajr]
            .add(const Duration(minutes: kAfterPrayerOffsetMin))
            .millisecondsSinceEpoch);
  });

  test('by-prayer adhkar: after Fajr / Asr, clamped before Sunrise / Maghrib', () {
    final d = dayFor(DateTime(2026, 10, 3));
    const huge = AdhkarReminderConfig(
        enabled: true, minutes: 360, byPrayer: true, offsetMin: 180);
    final p = plan(
        now: friday,
        cfg: const PrayerReminderConfig(),
        morning: huge,
        evening: huge);
    final m = p.firstWhere(
        (n) => n.kind == PlannedKind.morningAdhkar && n.when.day == 3);
    final e = p.firstWhere(
        (n) => n.kind == PlannedKind.eveningAdhkar && n.when.day == 3);
    expect(m.when.millisecondsSinceEpoch,
        d[PrayerKind.sunrise].subtract(const Duration(minutes: 5)).millisecondsSinceEpoch);
    expect(e.when.millisecondsSinceEpoch,
        d[PrayerKind.maghrib].subtract(const Duration(minutes: 5)).millisecondsSinceEpoch);
    expect(m.payload, 'adhkar:morning');
    expect(e.payload, 'adhkar:evening');
  });

  test('by-prayer is ignored while the slot is disabled or not by-prayer', () {
    const fixed = AdhkarReminderConfig(enabled: true, minutes: 360);
    const disabled =
        AdhkarReminderConfig(enabled: false, minutes: 360, byPrayer: true);
    final p = plan(
        now: friday,
        cfg: const PrayerReminderConfig(),
        morning: fixed,
        evening: disabled);
    expect(p, isEmpty);
  });

  group('PrayerRemindersStore', () {
    test('defaults off; round trip; Sunrise is never stored as an alert',
        () async {
      var c = await PrayerRemindersStore.load();
      expect(c.anyEnabled, isFalse);
      await PrayerRemindersStore.save(const PrayerReminderConfig(
          alerts: {PrayerKind.fajr, PrayerKind.sunrise},
          sleep: true,
          afterPrayer: true));
      c = await PrayerRemindersStore.load();
      expect(c.alerts, {PrayerKind.fajr});
      expect((c.sleep, c.afterPrayer, c.kahfFriday), (true, true, false));
    });

    test('corrupt values do not throw', () async {
      SharedPreferences.setMockInitialValues({
        'prayer_alerts': 'fajr',
        'prayer_after_adhkar': 'yes',
        'prayer_sleep_adhkar': 3,
      });
      final c = await PrayerRemindersStore.load();
      expect(c.anyEnabled, isFalse);
    });
  });

  group('AdhkarRemindersStore by-prayer fields', () {
    test('defaults and round trip; offset sanitised', () async {
      var m = await AdhkarRemindersStore.load(AdhkarSlot.morning);
      expect(m.byPrayer, isFalse);
      expect(m.offsetMin, AdhkarRemindersStore.defaultOffsetMinutes);
      await AdhkarRemindersStore.save(AdhkarSlot.morning,
          enabled: true, byPrayer: true, offsetMin: 60);
      m = await AdhkarRemindersStore.load(AdhkarSlot.morning);
      expect((m.enabled, m.byPrayer, m.offsetMin), (true, true, 60));
      SharedPreferences.setMockInitialValues(
          {'adhkar_reminder_morning_offset': 9999});
      m = await AdhkarRemindersStore.load(AdhkarSlot.morning);
      expect(m.offsetMin, AdhkarRemindersStore.defaultOffsetMinutes);
    });
  });

  test('dhikrBudget subtracts prayer notifications and never goes negative', () {
    expect(NotificationPlan.dhikrBudget(customCount: 0), NotificationService.maxPending - 1);
    expect(
        NotificationPlan.dhikrBudget(customCount: 2, adhkarCount: 14, prayerCount: 20),
        NotificationService.maxPending - 1 - 2 - 14 - 20);
    expect(NotificationPlan.dhikrBudget(customCount: 0, prayerCount: 500), 0);
  });

  test('notification payloads route to the right pages', () {
    expect(AppRoutes.fromNotificationPayload('prayer'), '/prayer-times');
    expect(AppRoutes.fromNotificationPayload('afterprayer'), '/after-prayer');
    expect(AppRoutes.fromNotificationPayload('sleep'), '/tahseen');
    expect(AppRoutes.fromNotificationPayload('kahf'),
        '/mushaf/page/${AppRoutes.kKahfPage}');
    expect(AppRoutes.fromNotificationPayload('nope'), isNull);
    expect(AppRoutes.fromNotificationPayload(null), isNull);
  });
}
