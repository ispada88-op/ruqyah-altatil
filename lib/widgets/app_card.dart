import 'package:flutter/material.dart';

import 'package:roqia_altatil/theme.dart';

/// بطاقة قياسية (خلفية بيضاء/داكنة، ظل خفيف) لصفحات التطبيق الجديدة.
class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = AppSpacing.paddingMd,
      this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.lg);
    return Material(
      color: isDark ? AppColors.darkSecondary : Colors.white,
      borderRadius: radius,
      elevation: isDark ? 0 : 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// ألوان الصفحات: (خلفية، حبر، ثانوي، تمييز تيل، ذهبي).
class PageColors {
  PageColors(BuildContext context)
      : isDark = Theme.of(context).brightness == Brightness.dark;

  final bool isDark;
  Color get bg => isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7);
  Color get ink => isDark ? AppColors.textOnDark : AppColors.textPrimary;
  Color get sub =>
      isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
  Color get teal => isDark ? AppColors.darkTeal : AppColors.primaryTeal;
  Color get gold => isDark ? AppColors.accentGold : AppColors.accentGoldDark;

  /// ذهبي للنصوص (الأيقونات تكفيها [gold]): تباين مقروء في الوضعين.
  Color get goldText => isDark ? AppColors.accentGold : AppColors.goldText;

  /// أخضر/أحمر للنص والأيقونات الدلالية بتباين صحيح فوق الخلفية الداكنة.
  Color get success => isDark ? const Color(0xFF66BB6A) : AppColors.success;
  Color get error => isDark ? const Color(0xFFEF9A9A) : AppColors.error;

  /// نص فوق خلفية التيل: أبيض في الفاتح، حبر داكن في الليلي
  /// (الأبيض على #4DA6A6 تباينه ≈ 2.9:1؛ الداكن ≈ 6:1).
  Color get onTeal => isDark ? const Color(0xFF0B1F1F) : Colors.white;

  /// نمط زر مملوء موحّد بتباين صحيح في الوضعين.
  ButtonStyle get filled =>
      FilledButton.styleFrom(backgroundColor: teal, foregroundColor: onTeal);
}

/// شارة أيقونة موحّدة لصفوف التنقّل (٤٤×٤٤، تيل بشفافية ١٢٪).
class AppIconBadge extends StatelessWidget {
  const AppIconBadge(this.icon, {super.key, this.color, this.size = 44});

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? PageColors(context).teal;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: c, size: size * 0.55),
    );
  }
}
