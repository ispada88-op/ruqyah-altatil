import 'package:flutter/services.dart';

/// Haptic feedback مركزي - استخدمه في كل مكان لتجربة Premium.
///
/// متى تستخدم أيهم:
/// - `Haptic.light()`    → عند tap على بطاقة، زر عادي
/// - `Haptic.select()`   → عند تغيير tab، toggle، اختيار من قائمة
/// - `Haptic.medium()`   → عند start/stop للصوت، إكمال action مهم
/// - `Haptic.heavy()`    → عند حدث كبير (إكمال ختمة، blocking error)
class Haptic {
  Haptic._();

  static Future<void> light() => HapticFeedback.lightImpact();
  static Future<void> medium() => HapticFeedback.mediumImpact();
  static Future<void> heavy() => HapticFeedback.heavyImpact();
  static Future<void> select() => HapticFeedback.selectionClick();
  static Future<void> vibrate() => HapticFeedback.vibrate();
}
