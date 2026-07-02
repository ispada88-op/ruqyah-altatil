import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/theme.dart';
import 'error_reporter.dart';

/// تنبيه "الجديد في هذا الإصدار": يظهر مرة واحدة بعد كل تحديث
/// (يقارن رقم النسخة المحفوظ مع الحالي).
class WhatsNewService {
  WhatsNewService._();

  static const _kLastSeenKey = 'whats_new_last_seen_version';

  /// مزايا الإصدار الحالي المعروضة في التنبيه.
  static const List<(IconData, String)> _highlights = [
    (Icons.shield_moon_outlined,
        'شاشة أذكار التحصين: أذكار مأثورة بمصادرها وأدعية جامعة'),
    (Icons.notifications_active_outlined,
        'تذكير يومي بقراءة الرقية الساعة 8 مساءً'),
    (Icons.share_rounded, 'شارك التطبيق مع من تحب — الدال على الخير كفاعله'),
    (Icons.auto_awesome, 'أيقونة جديدة وتحسينات في الاستقرار والوضع الليلي'),
  ];

  /// يخزّن النسخة الحالية بدون عرض (يُستدعى عند إكمال الترحيب لمستخدم جديد).
  static Future<void> markCurrentSeen() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastSeenKey, info.version);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'WhatsNew.markCurrentSeen');
    }
  }

  /// يعرض التنبيه إذا تغيّرت النسخة منذ آخر مشاهدة.
  static Future<void> maybeShow(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final prefs = await SharedPreferences.getInstance();
      final lastSeen = prefs.getString(_kLastSeenKey);
      if (lastSeen == info.version) return;
      await prefs.setString(_kLastSeenKey, info.version);
      if (!context.mounted) return;
      await _showSheet(context, info.version);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'WhatsNew.maybeShow');
    }
  }

  static Future<void> _showSheet(BuildContext context, String version) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSecondary : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Icon(Icons.celebration_outlined, size: 40, color: AppColors.accentGold),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'الجديد في الإصدار $version',
                style: AppTextStyles.subheader(
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._highlights.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(h.$1, size: 22, color: teal),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          h.$2,
                          style: AppTextStyles.body(
                            color: isDark
                                ? AppColors.textOnDark
                                : AppColors.textPrimary,
                          ).copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.shield_moon_outlined, size: 20),
              label: const Text('استكشف أذكار التحصين'),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go(AppRoutes.tahseen);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('لاحقاً',
                  style: TextStyle(
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
