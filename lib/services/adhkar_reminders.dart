import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

/// تذكير أذكار الصباح أو المساء.
enum AdhkarSlot { morning, evening }

/// إعداد تذكير واحد: مفعّل أم لا، والوقت بالدقائق منذ منتصف الليل (بتوقيت الجهاز).
class AdhkarReminderConfig {
  final bool enabled;
  final int minutes;

  /// «حسب الصلاة»: الصباح بعد الفجر والمساء بعد العصر بـ [offsetMin] دقيقة
  /// (يتطلب موقعاً محدداً في صفحة المواقيت). وإلا فالوقت الثابت [minutes].
  final bool byPrayer;
  final int offsetMin;

  const AdhkarReminderConfig({
    required this.enabled,
    required this.minutes,
    this.byPrayer = false,
    this.offsetMin = AdhkarRemindersStore.defaultOffsetMinutes,
  });

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

  /// الإزاحة الافتراضية بعد صلاة الفجر/العصر: بعد أذكار ما بعد الصلاة وقبل
  /// الشروق/الغروب (يُقصّ في الجدولة عند الحاجة).
  static const int defaultOffsetMinutes = 40;
  static const List<int> offsetChoices = [20, 40, 60];

  static int sanitizeOffset(Object? v) =>
      v is int && v >= 0 && v <= 180 ? v : defaultOffsetMinutes;

  static String _byKey(AdhkarSlot s) => 'adhkar_reminder_${s.name}_by_prayer';
  static String _offKey(AdhkarSlot s) => 'adhkar_reminder_${s.name}_offset';
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
        byPrayer: prefs.get(_byKey(s)) == true,
        offsetMin: sanitizeOffset(prefs.get(_offKey(s))),
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'AdhkarRemindersStore.load');
      return AdhkarReminderConfig(enabled: false, minutes: defaultMinutes(s));
    }
  }

  static Future<void> save(AdhkarSlot s,
      {bool? enabled, int? minutes, bool? byPrayer, int? offsetMin}) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled != null) await prefs.setBool(_onKey(s), enabled);
    if (byPrayer != null) await prefs.setBool(_byKey(s), byPrayer);
    if (offsetMin != null) {
      await prefs.setInt(_offKey(s), sanitizeOffset(offsetMin));
    }
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
