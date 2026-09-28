import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

/// تذكير يكتبه المستخدم بنفسه ويختار وقته (يتكرر يومياً).
class CustomReminder {
  final String id;
  final String text;
  final int hour;
  final int minute;
  final bool enabled;

  const CustomReminder({
    required this.id,
    required this.text,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  CustomReminder copyWith(
          {String? text, int? hour, int? minute, bool? enabled}) =>
      CustomReminder(
        id: id,
        text: text ?? this.text,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'h': hour, 'm': minute, 'on': enabled};

  static CustomReminder? fromJson(Object? j) {
    if (j is! Map) return null;
    final text = (j['text'] as String?)?.trim() ?? '';
    final h = j['h'], m = j['m'];
    if (text.isEmpty || h is! int || m is! int) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return CustomReminder(
      id: (j['id'] as String?) ?? '$h:$m:${text.hashCode}',
      text: text,
      hour: h,
      minute: m,
      enabled: j['on'] != false,
    );
  }
}

/// تخزين التذكيرات المخصصة. الحد [maxCount] يحمي ميزانية iOS (64 إشعاراً).
class CustomRemindersStore {
  CustomRemindersStore._();

  static const _kKey = 'custom_reminders_v1';
  static const int maxCount = 10;
  static const int maxTextLength = 200;

  static Future<List<CustomReminder>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return decode(prefs.getString(_kKey));
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'CustomReminders.load');
      return [];
    }
  }

  static Future<void> save(List<CustomReminder> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encode(items));
  }

  static String encode(List<CustomReminder> items) =>
      jsonEncode(items.take(maxCount).map((r) => r.toJson()).toList());

  static List<CustomReminder> decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list
          .map(CustomReminder.fromJson)
          .whereType<CustomReminder>()
          .take(maxCount)
          .toList();
    } catch (_) {
      return []; // corrupted value — start clean rather than crash
    }
  }

  /// قص النص وتنظيفه قبل الحفظ.
  static String sanitize(String text) {
    final t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t.length > maxTextLength ? t.substring(0, maxTextLength) : t;
  }
}
