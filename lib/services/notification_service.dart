import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'error_reporter.dart';
import '../data/hisn_almuslim_dhikr.dart';

/// خدمة الإشعارات: ترسل ذكراً قصيراً كل 3 أو 5 ساعات (يختاره المستخدم).
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

  /// نافذة عدم الإزعاج (10م → 7ص)
  static const int _quietStartHour = 22;
  static const int _quietEndHour = 7;

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
      tz_data.initializeTimeZones();
      try {
        const tzName = 'Asia/Riyadh';
        tz.setLocalLocation(tz.getLocation(tzName));
      } catch (_) {/* fallback to UTC */}

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

  /// طلب الإذن من المستخدم.
  Future<bool> requestPermissions() async {
    try {
      final notifStatus = await Permission.notification.request();
      if (!notifStatus.isGranted) return false;

      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted == false) return false;
      }

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
        await androidImpl.requestExactAlarmsPermission();
      }
      return true;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'requestPermissions');
      return false;
    }
  }

  /// جدولة الإشعارات للأسبوع القادم بناءً على الـ interval المحفوظ.
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
      // مواعيد محددة بناءً على الفترة:
      //   3 ساعات → 9, 12, 15, 18, 21 (5 إشعارات/يوم)
      //   5 ساعات → 9, 14, 19 (3 إشعارات/يوم)
      final slots = hours == 3 ? const [9, 12, 15, 18, 21] : const [9, 14, 19];

      final now = tz.TZDateTime.now(tz.local);
      final prefs = await SharedPreferences.getInstance();
      var lastIdx = prefs.getInt(_kLastIdxKey) ?? -1;
      final rng = Random();
      var notificationId = 0;

      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        for (final hour in slots) {
          if (_isQuietHour(hour)) continue;
          final scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + dayOffset,
            hour,
            0,
          );
          if (scheduledDate.isBefore(now)) continue;

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
      }
      await prefs.setInt(_kLastIdxKey, lastIdx);

      if (kDebugMode) {
        debugPrint('✅ Scheduled $notificationId dhikr notifications (every $hours hrs)');
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'NotificationService._scheduleAll');
    }
  }

  /// إعادة جدولة (يُستدعى عند تغيير الإعدادات).
  Future<void> reschedule() => _scheduleAll();

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
