import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';
import 'prayer_times_service.dart';

/// تنبيهات مرتبطة بأوقات الصلاة (كلها اختيارية ومعطّلة افتراضياً).
class PrayerReminderConfig {
  /// صلوات يصل عند أذانها تنبيه «حان وقت الصلاة».
  final Set<PrayerKind> alerts;

  /// تنبيه «أذكار بعد الصلاة» بعد كل فريضة.
  final bool afterPrayer;

  /// تذكير بسورة الكهف يوم الجمعة.
  final bool kahfFriday;

  /// تذكير بأذكار النوم بعد العشاء.
  final bool sleep;

  const PrayerReminderConfig({
    this.alerts = const {},
    this.afterPrayer = false,
    this.kahfFriday = false,
    this.sleep = false,
  });

  bool get anyEnabled => alerts.isNotEmpty || afterPrayer || kahfFriday || sleep;

  PrayerReminderConfig copyWith({
    Set<PrayerKind>? alerts,
    bool? afterPrayer,
    bool? kahfFriday,
    bool? sleep,
  }) =>
      PrayerReminderConfig(
        alerts: alerts ?? this.alerts,
        afterPrayer: afterPrayer ?? this.afterPrayer,
        kahfFriday: kahfFriday ?? this.kahfFriday,
        sleep: sleep ?? this.sleep,
      );
}

class PrayerRemindersStore {
  PrayerRemindersStore._();

  static const _kAlerts = 'prayer_alerts'; // قائمة أسماء PrayerKind
  static const _kAfter = 'prayer_after_adhkar';
  static const _kKahf = 'prayer_kahf_friday';
  static const _kSleep = 'prayer_sleep_adhkar';

  /// الشروق ليس صلاة فلا ينفع للتنبيه.
  static bool _valid(PrayerKind k) => k.isPrayer;

  static Future<PrayerReminderConfig> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.get(_kAlerts);
      final names = raw is List ? raw.whereType<String>().toSet() : <String>{};
      return PrayerReminderConfig(
        alerts: {
          for (final k in PrayerKind.values)
            if (_valid(k) && names.contains(k.name)) k,
        },
        afterPrayer: p.get(_kAfter) == true,
        kahfFriday: p.get(_kKahf) == true,
        sleep: p.get(_kSleep) == true,
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerRemindersStore.load');
      return const PrayerReminderConfig();
    }
  }

  static Future<void> save(PrayerReminderConfig c) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kAlerts, [for (final k in c.alerts) if (_valid(k)) k.name]);
    await p.setBool(_kAfter, c.afterPrayer);
    await p.setBool(_kKahf, c.kahfFriday);
    await p.setBool(_kSleep, c.sleep);
  }
}
