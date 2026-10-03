import 'package:flutter/material.dart';

import 'package:roqia_altatil/theme.dart';

/// بطاقة قياسية (خلفية بيضاء/داكنة، ظل خفيف) لصفحات التطبيق الجديدة.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = AppSpacing.paddingMd, this.onTap});

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
  Color get sub => isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
  Color get teal => isDark ? AppColors.darkTeal : AppColors.primaryTeal;
  Color get gold => isDark ? AppColors.accentGold : AppColors.accentGoldDark;

  /// نص فوق خلفية التيل: أبيض في الفاتح، حبر داكن في الليلي
  /// (الأبيض على #4DA6A6 تباينه ≈ 2.9:1؛ الداكن ≈ 6:1).
  Color get onTeal => isDark ? const Color(0xFF0B1F1F) : Colors.white;

  /// نمط زر مملوء موحّد بتباين صحيح في الوضعين.
  ButtonStyle get filled =>
      FilledButton.styleFrom(backgroundColor: teal, foregroundColor: onTeal);
}
