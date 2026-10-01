import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

/// تذكير أذكار الصباح أو المساء.
enum AdhkarSlot { morning, evening }

/// إعداد تذكير واحد: مفعّل أم لا، والوقت بالدقائق منذ منتصف الليل (بتوقيت الجهاز).
class AdhkarReminderConfig {
  final bool enabled;
  final int minutes;

  const AdhkarReminderConfig({required this.enabled, required this.minutes});

  int get hour => minutes ~/ 60;
  int get minute => minutes % 60;
}

/// تخزين تذكيري أذكار الصباح والمساء.
///
/// الوقت يُحفظ كساعة ودقيقة «على ساعة الجدار» لا كلحظة مطلقة، والجدولة تتم
/// بمنطقة الجهاز الزمنية (انظر `NotificationService._initTimeZone`) — فيصل
/// الإشعار في الوقت نفسه عند كل مستخدم أينما كان، لا بتوقيت الرياض.
class AdhkarRemindersStore {
  AdhkarRemindersStore._();

  /// الافتراضي: ٦:٠٠ صباحاً و٥:٠٠ مساءً (قبل غروب الشمس في أغلب الأوقات).
  static const int defaultMorningMinutes = 6 * 60;
  static const int defaultEveningMinutes = 17 * 60;

  static int defaultMinutes(AdhkarSlot s) => s == AdhkarSlot.morning
      ? defaultMorningMinutes
      : defaultEveningMinutes;

  static String _onKey(AdhkarSlot s) => 'adhkar_reminder_${s.name}_on';
  static String _minKey(AdhkarSlot s) => 'adhkar_reminder_${s.name}_min';

  /// قيمة صالحة (0..1439) أو [fallback].
  static int sanitizeMinutes(Object? v, int fallback) =>
      v is int && v >= 0 && v < 24 * 60 ? v : fallback;

  static Future<AdhkarReminderConfig> load(AdhkarSlot s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final on = prefs.get(_onKey(s));
      return AdhkarReminderConfig(
        enabled: on == true,
        minutes: sanitizeMinutes(prefs.get(_minKey(s)), defaultMinutes(s)),
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'AdhkarRemindersStore.load');
      return AdhkarReminderConfig(enabled: false, minutes: defaultMinutes(s));
    }
  }

  static Future<void> save(AdhkarSlot s, {bool? enabled, int? minutes}) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled != null) await prefs.setBool(_onKey(s), enabled);
    if (minutes != null) {
      await prefs.setInt(_minKey(s), sanitizeMinutes(minutes, defaultMinutes(s)));
    }
  }

  /// عنوان الإشعار ونصه.
  static (String, String) message(AdhkarSlot s) => s == AdhkarSlot.morning
      ? ('أذكار الصباح 🌅', 'حان وقت أذكار الصباح — اضغط لتقرأها الآن.')
      : ('أذكار المساء 🌙', 'حان وقت أذكار المساء — اضغط لتقرأها الآن.');

  /// حمولة الإشعار: تُستعمل لفتح صفحة الأذكار على الوقت الصحيح عند الضغط.
  static String payload(AdhkarSlot s) => 'adhkar:${s.name}';
}
