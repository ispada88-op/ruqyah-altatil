import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

/// سجل أيام قراءة الرقية (طلب مستخدمة: «صفحة لعدد يوم القراءة والتاريخ»).
///
/// يُحفظ كقائمة تواريخ محلية `yyyy-MM-dd` — لا شيء يغادر الجهاز.
class RuqyahLogService extends ChangeNotifier {
  RuqyahLogService._();
  static final RuqyahLogService instance = RuqyahLogService._();

  static const _kDaysKey = 'ruqyah_log_days';
  static const _kGoalKey = 'ruqyah_goal_days';
  static const List<int> goals = [7, 21, 40];

  final Set<String> _days = {};
  int _goal = 7;
  bool _loaded = false;

  Set<String> get days => Set.unmodifiable(_days);
  int get goal => _goal;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _days
        ..clear()
        ..addAll(prefs.getStringList(_kDaysKey) ?? const []);
      final g = prefs.getInt(_kGoalKey) ?? 7;
      _goal = goals.contains(g) ? g : 7;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'RuqyahLog.load');
    }
    _loaded = true;
    notifyListeners();
  }

  bool isDone(DateTime day) => _days.contains(dayKey(day));

  /// يبدّل حالة يوم [day] (افتراضياً اليوم): تسجيل ↔ إلغاء.
  Future<void> toggle([DateTime? day]) async {
    final key = dayKey(day ?? DateTime.now());
    if (!_days.remove(key)) _days.add(key);
    notifyListeners();
    await _persist();
  }

  Future<void> setGoal(int value) async {
    if (!goals.contains(value)) return;
    _goal = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kGoalKey, value);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'RuqyahLog.setGoal');
    }
  }

  int streak([DateTime? today]) =>
      currentStreak(_days, today ?? DateTime.now());

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sorted = _days.toList()..sort();
      await prefs.setStringList(_kDaysKey, sorted);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'RuqyahLog.persist');
    }
  }
}

/// `yyyy-MM-dd` بالتقويم المحلي.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// عدد الأيام المتتالية حتى اليوم. إن لم يُسجَّل اليوم بعد، تُحسب السلسلة
/// المنتهية أمس (فلا تنكسر السلسلة صباحاً قبل أن يقرأ المستخدم).
int currentStreak(Set<String> days, DateTime today) {
  var d = DateTime(today.year, today.month, today.day);
  if (!days.contains(dayKey(d))) {
    d = DateTime(d.year, d.month, d.day - 1); // لا subtract(24h): خطأ عند تغيّر التوقيت الصيفي
  }
  var n = 0;
  while (days.contains(dayKey(d))) {
    n++;
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return n;
}
