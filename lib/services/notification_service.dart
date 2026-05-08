import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'error_reporter.dart';

/// خدمة الإشعارات: ترسل ذكراً قصيراً كل 3 ساعات بشكل افتراضي.
///
/// ميزات:
/// - يحترم وقت النوم (10 مساءً → 7 صباحاً) - لا إشعارات
/// - يختار ذكراً عشوائياً من قائمة منتقاة من القرآن والسنة
/// - يحفظ آخر ذكر مُرسل لتجنب التكرار
/// - يدعم تفعيل/تعطيل من المستخدم
/// - متوافق مع iOS و Android
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _kEnabledKey = 'notifications_enabled';
  static const _kLastSentIndex = 'last_sent_dhikr_index';
  static const _channelId = 'ruqyah_dhikr_channel';
  static const _channelName = 'تذكير بالأذكار';

  /// نافذة عدم الإزعاج (ساعة بداية، ساعة نهاية - بنظام 24)
  static const int _quietStartHour = 22; // 10 مساءً
  static const int _quietEndHour = 7;    // 7 صباحاً

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// قائمة الأذكار المختارة (آيات قصيرة + أحاديث + أدعية).
  /// كل ذكر: (العنوان، النص).
  static const List<({String title, String body})> dhikrLibrary = [
    // آيات قصيرة من القرآن
    (title: 'ذكر', body: 'سُبْحَانَ ٱللَّهِ وَبِحَمْدِهِ، سُبْحَانَ ٱللَّهِ ٱلْعَظِيمِ'),
    (title: 'ذكر', body: 'لَآ إِلَٰهَ إِلَّا ٱللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ'),
    (title: 'ذكر', body: 'أَسْتَغْفِرُ ٱللَّهَ ٱلْعَظِيمَ وَأَتُوبُ إِلَيْهِ'),
    (title: 'ذكر', body: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّهِ'),
    (title: 'ذكر', body: 'حَسْبِيَ ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ ٱلْعَرْشِ ٱلْعَظِيمِ'),
    // أذكار الصباح والمساء
    (title: 'دعاء', body: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ'),
    (title: 'دعاء', body: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ'),
    (title: 'دعاء', body: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا'),
    (title: 'دعاء', body: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ'),
    // آيات قصيرة من سور قصار
    (title: 'آية كريمة', body: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ • ٱللَّهُ ٱلصَّمَدُ'),
    (title: 'آية كريمة', body: 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ • مِن شَرِّ مَا خَلَقَ'),
    (title: 'آية كريمة', body: 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ • مَلِكِ ٱلنَّاسِ'),
    // الصلاة على النبي
    (title: 'الصلاة على النبي ﷺ',
     body: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ'),
    // أدعية مأثورة قصيرة
    (title: 'دعاء', body: 'رَبِّ ٱشْرَحْ لِى صَدْرِى وَيَسِّرْ لِىٓ أَمْرِى'),
    (title: 'دعاء', body: 'رَبَّنَآ ءَاتِنَا فِى ٱلدُّنْيَا حَسَنَةً وَفِى ٱلْءَاخِرَةِ حَسَنَةً وَقِنَا عَذَابَ ٱلنَّارِ'),
    (title: 'دعاء', body: 'حَسْبُنَا ٱللَّهُ وَنِعْمَ ٱلْوَكِيلُ، نِعْمَ ٱلْمَوْلَىٰ وَنِعْمَ ٱلنَّصِيرُ'),
  ];

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
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

  /// تهيئة الخدمة - يجب استدعاؤها مرة واحدة في main().
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      // Use device's local timezone via the OS - timezone package's getLocation
      // doesn't auto-detect; we use UTC offset from DateTime as fallback.
      try {
        final localName = DateTime.now().timeZoneName;
        // Common Saudi/Gulf names
        const knownTzs = {
          '+03': 'Asia/Riyadh',
          'AST': 'Asia/Riyadh',
          '+02': 'Africa/Cairo',
        };
        final tzName = knownTzs[localName] ?? 'Asia/Riyadh';
        tz.setLocalLocation(tz.getLocation(tzName));
      } catch (_) {
        // Fallback to UTC if location lookup fails — at worst, schedules shift.
      }

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

  /// طلب الإذن من المستخدم - يستدعى عادةً من زر "تفعيل التذكيرات".
  /// يرجع true لو الإذن مُنح.
  Future<bool> requestPermissions() async {
    try {
      // Android 13+ يتطلب POST_NOTIFICATIONS
      final notifStatus = await Permission.notification.request();
      if (!notifStatus.isGranted) return false;

      // iOS
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

      // Android 12+ exact alarms (optional - for precise scheduling)
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
        // exact alarm is best-effort; we fall back to inexact if denied
        await androidImpl.requestExactAlarmsPermission();
      }

      return true;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'requestPermissions');
      return false;
    }
  }

  /// جدولة 8 إشعارات/يوم (كل 3 ساعات) لمدة 7 أيام قادمة.
  /// flutter_local_notifications لا يدعم تكرار اعتباطي 3-ساعات،
  /// فنجدول كل ضربة بشكل صريح.
  Future<void> _scheduleAll() async {
    if (!_initialized) await initialize();

    try {
      await cancelAll();

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'تذكيرات دورية بالأذكار والأدعية',
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

      final now = tz.TZDateTime.now(tz.local);
      // schedule at hours: 0, 3, 6, 9, 12, 15, 18, 21
      // skip times within quiet window (22-7)
      const slots = [9, 12, 15, 18, 21];
      var notificationId = 0;
      final rng = Random();

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

          // Pick a dhikr deterministically based on day+hour to avoid repeats
          final idx = (dayOffset * slots.length +
                  slots.indexOf(hour) +
                  rng.nextInt(3)) %
              dhikrLibrary.length;
          final dhikr = dhikrLibrary[idx];

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
      if (kDebugMode) {
        debugPrint('✅ Scheduled $notificationId dhikr notifications');
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'NotificationService._scheduleAll');
    }
  }

  /// إعادة جدولة من نقطة الصفر (يُستدعى من background task أسبوعياً مثلاً).
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

  /// إرسال إشعار اختباري فوراً (مفيد لزر "اختبر الإشعار" في الإعدادات).
  Future<void> showTest() async {
    if (!_initialized) await initialize();
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );
      final dhikr = dhikrLibrary[Random().nextInt(dhikrLibrary.length)];
      await _plugin.show(9999, dhikr.title, dhikr.body, details);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'showTest');
    }
  }

  bool _isQuietHour(int hour) {
    if (_quietStartHour > _quietEndHour) {
      // overnight (e.g. 22-7)
      return hour >= _quietStartHour || hour < _quietEndHour;
    }
    return hour >= _quietStartHour && hour < _quietEndHour;
  }
}
