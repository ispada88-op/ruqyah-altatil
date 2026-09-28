import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/data/ruqyah_types_data.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// «رقى حسب الحالة» — قائمة الأنواع.
class RuqyahTypesPage extends StatelessWidget {
  const RuqyahTypesPage({super.key});

  static const _icons = {
    'sihr': Icons.auto_fix_off_rounded,
    'ayn': Icons.visibility_off_outlined,
    'hamm': Icons.spa_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;

    return Scaffold(
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Text(
            'رقى حسب الحالة',
            textAlign: TextAlign.center,
            style: AppTextStyles.header(color: teal),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'آيات وأدعية مأثورة من القرآن والسنة بمصادرها',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(
              color: isDark
                  ? AppColors.textOnDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final t in kRuqyahTypes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Material(
                color: isDark ? AppColors.darkSecondary : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () {
                    Haptic.light();
                    context.push(AppRoutes.ruqyahType(t.id));
                  },
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: teal.withValues(alpha: 0.12),
                          child:
                              Icon(_icons[t.id] ?? Icons.healing, color: teal),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: AppTextStyles.subheader(
                                  color: isDark
                                      ? AppColors.textOnDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.subtitle,
                                style: AppTextStyles.caption(
                                  color: isDark
                                      ? AppColors.textOnDarkSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: teal),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'الشفاء بيد الله وحده، والرقية سبب. هذه الأقسام من القرآن والسنة '
            'عامة، وليست رقية خاصة بالشيخ فهد القرني.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(
              color: isDark
                  ? AppColors.textOnDarkSecondary
                  : AppColors.textTertiary,
            ).copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

/// صفحة نوع واحد — تعيد استخدام صفحة القراءة بعدّاد.
class RuqyahTypePage extends StatelessWidget {
  const RuqyahTypePage({super.key, required this.typeId});

  final String typeId;

  @override
  Widget build(BuildContext context) {
    final type = ruqyahTypeById(typeId) ?? kRuqyahTypes.first;
    return Column(
      children: [
        SectionBackBar(title: type.title, fallbackRoute: AppRoutes.ruqyahTypes),
        Expanded(
          child: GeneralRuqyahPage(
            key: ValueKey(type.id),
            items: type.items(),
            title: type.title,
            subtitle: type.subtitle,
            emblem: 'رقية',
            intro: type.intro,
            footer:
                'آيات القرآن من مصحف المدينة (مشروع تنزيل) — الأدعية من حصن المسلم وصحيح مسلم',
          ),
        ),
      ],
    );
  }
}
