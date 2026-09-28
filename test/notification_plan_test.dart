import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

bool quiet(int h) => h >= 22 || h < 7;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final zone in ['Asia/Riyadh', 'Europe/London', 'America/New_York']) {
    group(zone, () {
      late tz.Location loc;
      setUp(() => loc = tz.getLocation(zone));

      test(
          '3h interval: 5 slots/day, all in the future, local wall-clock hours',
          () {
        final now = tz.TZDateTime(loc, 2026, 9, 28, 10, 30);
        final times = NotificationPlan.dhikrTimes(
          now: now,
          slots: NotificationPlan.slotsFor(3),
          budget: NotificationService.maxPending - 1,
          isQuietHour: quiet,
        );
        expect(times.length, NotificationService.maxPending - 1);
        expect(times.every((t) => t.isAfter(now)), isTrue);
        expect(times.map((t) => t.hour).toSet(), {9, 12, 15, 18, 21});
        expect(times.first, tz.TZDateTime(loc, 2026, 9, 28, 12));
        // strictly increasing → no duplicates
        for (var i = 1; i < times.length; i++) {
          expect(times[i].isAfter(times[i - 1]), isTrue);
        }
      });

      test('5h interval covers more days within the same budget', () {
        final now = tz.TZDateTime(loc, 2026, 9, 28, 23);
        final times = NotificationPlan.dhikrTimes(
          now: now,
          slots: NotificationPlan.slotsFor(5),
          budget: 59,
          isQuietHour: quiet,
        );
        expect(times.length, 59); // budget-capped: day 0 all past, then 3/day
        expect(times.first, tz.TZDateTime(loc, 2026, 9, 29, 9));
      });
    });
  }

  test('quiet hours are never scheduled', () {
    final loc = tz.getLocation('Asia/Riyadh');
    final times = NotificationPlan.dhikrTimes(
      now: tz.TZDateTime(loc, 2026, 1, 1),
      slots: const [6, 9, 22, 23],
      budget: 100,
      isQuietHour: quiet,
      maxDays: 3,
    );
    expect(times.map((t) => t.hour).toSet(), {9});
  });

  test('nextAt: today if still ahead, otherwise tomorrow', () {
    final loc = tz.getLocation('Asia/Riyadh');
    expect(NotificationPlan.nextAt(tz.TZDateTime(loc, 2026, 9, 28, 19, 59), 20),
        tz.TZDateTime(loc, 2026, 9, 28, 20));
    expect(NotificationPlan.nextAt(tz.TZDateTime(loc, 2026, 9, 28, 20), 20),
        tz.TZDateTime(loc, 2026, 9, 29, 20));
    // month rollover
    expect(NotificationPlan.nextAt(tz.TZDateTime(loc, 2026, 9, 30, 21), 20),
        tz.TZDateTime(loc, 2026, 10, 1, 20));
  });
}
