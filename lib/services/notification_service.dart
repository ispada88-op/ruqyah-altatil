import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'error_reporter.dart';
import '../data/hisn_almuslim_dhikr.dart';

/// خدمة الإشعارات: ترسل ذكراً قصيراً كل 3 أو 5 ساعات (يختاره المستخدم)
/// + تذكيراً يومياً واحداً بقراءة الرقية الساعة 8 مساءً.
///
/// ميزات:
/// - يحترم وقت النوم (10 مساءً → 7 صباحاً)
/// - يختار ذكراً عشوائياً من 70+ ذكر من حصن المسلم
/// - يحفظ آخر ذكر مُرسل لتجنب التكرار المباشر
/// - يدعم تفعيل/تعطيل + تغيير الفترة
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _kEnabledKey = 'notifications_enabled';
  static const _kIntervalKey = 'notifications_interval_hours'; // 3 or 5
  static const _kLastIdxKey = 'last_dhikr_index';
  static const _channelId = 'ruqyah_dhikr_channel';
  static const _channelName = 'تذكير بالأذكار';

  /// التذكير اليومي بالرقية: الساعة 8م (لا يتعارض مع مواعيد الأذكار 9/12/15/18/21 أو 9/14/19).
  static const int _ruqyahReminderHour = 20;

  /// IDs التذكير اليومي تبدأ من 500 حتى لا تتداخل مع إشعارات الأذكار (0..34).
  static const int _ruqyahIdBase = 500;

  static const List<(String, String)> _ruqyahReminders = [
    ('تذكير بالرقية 🕊', 'لا تنسَ قراءة رقية التعطيل اليوم — جعلها الله شفاءً وعافيةً لك.'),
    ('وقت الرقية 📖', 'خصّص دقائق الآن لقراءة الرقية الشرعية أو الاستماع لها.'),
    ('لا تنسَ رقيتك اليوم', 'المداومة على الرقية سبب للشفاء بإذن الله — اقرأها الآن.'),
  ];

  /// نافذة عدم الإزعاج (10م → 7ص)
  static const int _quietStartHour = 22;
  static const int _quietEndHour = 7;

  /// iOS يحتفظ فقط بأقرب 64 إشعاراً مجدولاً ويتجاهل الباقي بصمت.
  /// نترك هامشاً (60) ونقسم الميزانية: 1 للتذكير اليومي المتكرر + الباقي للأذكار.
  static const int maxPending = 60;

  /// المنطقة الزمنية المستخدمة فعلياً (للتشخيص وللاختبارات).
  String get timeZoneName => _timeZoneName;
  String _timeZoneName = 'UTC';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  Future<int> get intervalHours async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kIntervalKey) ?? 3;
  }

  Future<void> setIntervalHours(int hours) async {
    if (![3, 5].contains(hours)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kIntervalKey, hours);
    if (await isEnabled) await _scheduleAll();
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
    if (value) {
      await _scheduleAll();
    } else {
      await cancelAll();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _initTimeZone();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      _initialized = true;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'NotificationService.initialize');
    }
  }

  /// إصلاح 2026-09-28: كانت المنطقة مثبتة على Asia/Riyadh، فمستخدم في مصر أو
  /// أوروبا أو أمريكا يستلم «أذكار 9 صباحاً» في وقت خاطئ (حتى منتصف الليل)
  /// ونافذة عدم الإزعاج تصبح بلا معنى. الآن: منطقة الجهاز، ثم الرياض كاحتياط.
  Future<void> _initTimeZone() async {
    tz_data.initializeTimeZones();
    String? deviceZone;
    try {
      deviceZone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'NotificationService.deviceTimeZone');
    }
    for (final name in [deviceZone, 'Asia/Riyadh']) {
      if (name == null || name.isEmpty) continue;
      try {
        tz.setLocalLocation(tz.getLocation(name));
        _timeZoneName = name;
        return;
      } catch (_) {/* unknown id on this tz database — try the next one */}
    }
  }

  /// طلب الإذن من المستخدم.
  ///
  /// إصلاح 2026-07-10: كان الطلب يمر عبر permission_handler
  /// (`Permission.notification.request()`) وهو مسار هش على iOS — في حالات
  /// معروفة يرجع denied فوراً بدون إظهار نافذة النظام، فيرتد مفتاح التنبيهات
  /// إلى الإيقاف ويبدو «لا يستجيب». الآن نطلب الإذن مباشرة عبر
  /// flutter_local_notifications نفسها على كلا النظامين (مسار واحد موثوق).
  Future<bool> requestPermissions() async {
    try {
      if (!_initialized) await initialize();

      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        // ملاحظة: لا نطلب exact alarms — الجدولة inexact والـ manifest
        // لا يتضمن SCHEDULE_EXACT_ALARM.
        final granted = await androidImpl.requestNotificationsPermission();
        // null = أندرويد أقدم من 13 حيث لا يوجد إذن تشغيلي → مسموح.
        return granted ?? true;
      }
      return true;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'requestPermissions');
      return false;
    }
  }

  /// فتح إعدادات التطبيق في النظام — للمستخدم الذي رفض الإذن سابقاً
  /// (النظام لا يعيد إظهار نافذة الإذن بعد الرفض، فلا حل إلا الإعدادات).
  Future<void> openSystemSettings() async {
    try {
      await openAppSettings();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'openSystemSettings');
    }
  }

  /// جدولة الإشعارات بناءً على الـ interval المحفوظ: أذكار لأيام قادمة ضمن
  /// ميزانية [maxPending] + تذكير رقية يومي متكرر لا ينتهي.
  Future<void> _scheduleAll() async {
    if (!_initialized) await initialize();

    try {
      await cancelAll();

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'تذكيرات دورية بالأذكار من حصن المسلم',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      );
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      final hours = await intervalHours;
      final now = tz.TZDateTime.now(tz.local);
      final prefs = await SharedPreferences.getInstance();
      var lastIdx = prefs.getInt(_kLastIdxKey) ?? -1;
      final rng = Random();
      var notificationId = 0;

      // ─── أذكار دورية: مواعيد لعدة أيام قادمة ضمن ميزانية iOS ───
      final times = NotificationPlan.dhikrTimes(
        now: now,
        slots: NotificationPlan.slotsFor(hours),
        budget: maxPending - 1,
        isQuietHour: _isQuietHour,
      );
      for (final scheduledDate in times) {
        // اختيار ذكر بدون تكرار مباشر
        int idx;
        do {
          idx = rng.nextInt(hisnAlmuslimDhikr.length);
        } while (idx == lastIdx && hisnAlmuslimDhikr.length > 1);
        lastIdx = idx;

        final dhikr = hisnAlmuslimDhikr[idx];
        await _plugin.zonedSchedule(
          notificationId++,
          dhikr.title,
          dhikr.body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // ignore: deprecated_member_use
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      await prefs.setInt(_kLastIdxKey, lastIdx);

      // ─── التذكير اليومي بالرقية (8م) ───
      // إصلاح 2026-09-28: كان 7 إشعارات منفردة تنتهي بعد أسبوع إن لم يُفتح
      // التطبيق. الآن إشعار واحد متكرر يومياً (matchDateTimeComponents.time)
      // فلا ينقطع أبداً — أهم تذكير في التطبيق.
      final (title, body) = _ruqyahReminders[now.day % _ruqyahReminders.length];
      await _plugin.zonedSchedule(
        _ruqyahIdBase,
        title,
        body,
        NotificationPlan.nextAt(now, _ruqyahReminderHour),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        // ignore: deprecated_member_use
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      const ruqyahCount = 1;

      if (kDebugMode) {
        debugPrint('✅ Scheduled $notificationId dhikr + $ruqyahCount daily ruqyah '
            'notifications (every $hours hrs, tz=$_timeZoneName)');
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'NotificationService._scheduleAll');
    }
  }

  /// إعادة جدولة (يُستدعى عند تغيير الإعدادات).
  Future<void> reschedule() => _scheduleAll();

  /// إعادة الجدولة عند فتح التطبيق إن كانت الإشعارات مفعّلة.
  /// ضروري لأن الجدولة تغطي 7 أيام فقط وتتوقف بدونها.
  Future<void> rescheduleIfEnabled() async {
    if (await isEnabled) await _scheduleAll();
  }

  /// إلغاء كل الإشعارات.
  Future<void> cancelAll() async {
    if (!_initialized) await initialize();
    try {
      await _plugin.cancelAll();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'cancelAll');
    }
  }

  /// إرسال إشعار اختباري فوراً.
  Future<void> showTest() async {
    if (!_initialized) await initialize();
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      );
      final dhikr = hisnAlmuslimDhikr[Random().nextInt(hisnAlmuslimDhikr.length)];
      await _plugin.show(9999, dhikr.title, dhikr.body, details);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'showTest');
    }
  }

  bool _isQuietHour(int hour) {
    if (_quietStartHour > _quietEndHour) {
      return hour >= _quietStartHour || hour < _quietEndHour;
    }
    return hour >= _quietStartHour && hour < _quietEndHour;
  }
}


/// حسابات الجدولة كدوال نقية — قابلة للاختبار بدون المكوّن الأصلي.
class NotificationPlan {
  NotificationPlan._();

  /// مواعيد الأذكار حسب الفترة المختارة:
  ///   3 ساعات → 9, 12, 15, 18, 21 (5/يوم) — 5 ساعات → 9, 14, 19 (3/يوم)
  static List<int> slotsFor(int intervalHours) =>
      intervalHours == 3 ? const [9, 12, 15, 18, 21] : const [9, 14, 19];

  /// كل مواعيد الأذكار القادمة (بعد [now]) بالترتيب، بحد أقصى [budget] موعداً
  /// و[maxDays] يوماً، مع استبعاد ساعات الهدوء.
  static List<tz.TZDateTime> dhikrTimes({
    required tz.TZDateTime now,
    required List<int> slots,
    required int budget,
    required bool Function(int hour) isQuietHour,
    int maxDays = 21,
  }) {
    final out = <tz.TZDateTime>[];
    for (var day = 0; day < maxDays && out.length < budget; day++) {
      for (final hour in slots) {
        if (isQuietHour(hour)) continue;
        final t = tz.TZDateTime(now.location, now.year, now.month, now.day + day, hour);
        if (!t.isAfter(now)) continue;
        out.add(t);
        if (out.length >= budget) break;
      }
    }
    return out;
  }

  /// أقرب وقت قادم للساعة [hour] (اليوم إن لم تمضِ، وإلا غداً).
  static tz.TZDateTime nextAt(tz.TZDateTime now, int hour) {
    var t = tz.TZDateTime(now.location, now.year, now.month, now.day, hour);
    if (!t.isAfter(now)) {
      t = tz.TZDateTime(now.location, now.year, now.month, now.day + 1, hour);
    }
    return t;
  }
}
