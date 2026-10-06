import 'package:timezone/timezone.dart' as tz;

import 'adhkar_reminders.dart';
import 'prayer_reminders.dart';
import 'prayer_times_service.dart';

enum PlannedKind {
  morningAdhkar,
  eveningAdhkar,
  prayerAlert,
  afterPrayer,
  kahf,
  sleep
}

/// إشعار واحد مجدوَل بوقت محدد (لا يتكرر). يُبنى من [planPrayerNotifications].
class PlannedNotification {
  final int id;
  final tz.TZDateTime when;
  final String title;
  final String body;
  final String? payload;
  final PlannedKind kind;
  const PlannedNotification(
      {required this.id,
      required this.when,
      required this.title,
      required this.body,
      required this.kind,
      this.payload});
}

/// IDs تنبيهات الصلاة: ١٠٠٠ فما فوق، ١٦ خانة لكل يوم — لا تتداخل مع الأذكار
/// الدورية (0..58) ولا المتكررة (500، 600+، 700+).
const int kPrayerIdBase = 1000;
const int _slotsPerDay = 16;

/// بعد أذان كل فريضة بكم دقيقة نذكّر بأذكار ما بعد الصلاة (وصول الإمام + الصلاة).
const int kAfterPrayerOffsetMin = 30;

/// أذكار النوم بعد العشاء بكم دقيقة.
const int kSleepOffsetMin = 45;

/// تذكير الكهف الجمعة بعد الشروق بكم دقيقة.
const int kKahfOffsetMin = 20;

/// يبني تنبيهات الأيام القادمة المرتبطة بالصلاة، مقصوصةً إلى [budget] أقرب
/// موعد (iOS يحتفظ بـ٦٤ إشعاراً فقط). الأقرب زمناً له الأولوية.
///
/// دالة نقية: لا تقرأ ساعة الجهاز ولا تخزيناً — [now] و[dayFor] و[morning]
/// و[evening] و[cfg] كلها مُمرَّرة.
List<PlannedNotification> planPrayerNotifications({
  required tz.TZDateTime now,
  required PrayerDay Function(DateTime day) dayFor,
  required PrayerReminderConfig cfg,
  required AdhkarReminderConfig morning,
  required AdhkarReminderConfig evening,
  required int budget,
  int maxDays = 7,
}) {
  if (budget <= 0) return const [];
  final out = <PlannedNotification>[];

  tz.TZDateTime at(DateTime t) => tz.TZDateTime.fromMillisecondsSinceEpoch(
      now.location, t.millisecondsSinceEpoch);

  for (var d = 0; d < maxDays; d++) {
    final date = DateTime(now.year, now.month, now.day + d);
    final day = dayFor(date);
    var slot = 0;
    int idOf(int s) => kPrayerIdBase + d * _slotsPerDay + s;

    // الصباح بعد الفجر — مقصوص قبل الشروق بخمس دقائق.
    if (morning.enabled && morning.byPrayer) {
      var t = day[PrayerKind.fajr].add(Duration(minutes: morning.offsetMin));
      final limit =
          day[PrayerKind.sunrise].subtract(const Duration(minutes: 5));
      if (t.isAfter(limit)) t = limit;
      final (title, body) = AdhkarRemindersStore.message(AdhkarSlot.morning);
      out.add(PlannedNotification(
          id: idOf(0),
          when: at(t),
          title: title,
          body: body,
          payload: AdhkarRemindersStore.payload(AdhkarSlot.morning),
          kind: PlannedKind.morningAdhkar));
    }
    // المساء بعد العصر — مقصوص قبل المغرب بخمس دقائق.
    if (evening.enabled && evening.byPrayer) {
      var t = day[PrayerKind.asr].add(Duration(minutes: evening.offsetMin));
      final limit =
          day[PrayerKind.maghrib].subtract(const Duration(minutes: 5));
      if (t.isAfter(limit)) t = limit;
      final (title, body) = AdhkarRemindersStore.message(AdhkarSlot.evening);
      out.add(PlannedNotification(
          id: idOf(1),
          when: at(t),
          title: title,
          body: body,
          payload: AdhkarRemindersStore.payload(AdhkarSlot.evening),
          kind: PlannedKind.eveningAdhkar));
    }

    slot = 2;
    final prayers = [
      for (final k in PrayerKind.values)
        if (k.isPrayer) k
    ];
    for (var i = 0; i < prayers.length; i++) {
      final k = prayers[i];
      final name = _nameOn(k, date);
      if (cfg.alerts.contains(k)) {
        out.add(PlannedNotification(
            id: idOf(slot + i),
            when: at(day[k]),
            title: 'حان وقت صلاة $name',
            body: 'دخل وقت الصلاة حسب موقعك. تقبّل الله منك.',
            payload: 'prayer',
            kind: PlannedKind.prayerAlert));
      }
      if (cfg.afterPrayer) {
        out.add(PlannedNotification(
            id: idOf(slot + 5 + i),
            when:
                at(day[k].add(const Duration(minutes: kAfterPrayerOffsetMin))),
            title: 'أذكار بعد صلاة $name',
            body: 'لا تنسَ أذكار ما بعد الصلاة — اضغط لتقرأها.',
            payload: 'afterprayer',
            kind: PlannedKind.afterPrayer));
      }
    }

    if (cfg.kahfFriday && date.weekday == DateTime.friday) {
      out.add(PlannedNotification(
          id: idOf(12),
          when: at(day[PrayerKind.sunrise]
              .add(const Duration(minutes: kKahfOffsetMin))),
          title: 'سورة الكهف 📖',
          body: 'اليوم الجمعة — اضغط لقراءة سورة الكهف.',
          payload: 'kahf',
          kind: PlannedKind.kahf));
    }
    if (cfg.sleep) {
      out.add(PlannedNotification(
          id: idOf(13),
          when: at(day[PrayerKind.isha]
              .add(const Duration(minutes: kSleepOffsetMin))),
          title: 'أذكار النوم 🌙',
          body: 'قبل أن تنام: اضغط لقراءة أذكار التحصين.',
          payload: 'sleep',
          kind: PlannedKind.sleep));
    }
  }

  final future = out.where((n) => n.when.isAfter(now)).toList()
    ..sort((a, b) => a.when.compareTo(b.when));
  return future.length > budget ? future.sublist(0, budget) : future;
}

String _nameOn(PrayerKind k, DateTime date) =>
    k == PrayerKind.dhuhr && date.weekday == DateTime.friday
        ? 'الجمعة'
        : k.label;
