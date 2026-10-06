import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/share_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/app_card.dart';

/// مجموعة صفوف بعنوان صغير: حاوية واحدة بخلفية موحّدة وفواصل رفيعة.
/// تُستعمل في الرئيسية وفي قوائم الأقسام (الرقية، الأذكار).
class MenuGroup extends StatelessWidget {
  const MenuGroup({
    super.key,
    this.title,
    this.caption,
    required this.rows,
  });

  final String? title;

  /// سطر صغير تحت العنوان (مثل نسبة «رقية التعطيل» للشيخ).
  final String? caption;
  final List<MenuRow> rows;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
                4, 0, 4, caption == null ? AppSpacing.sm : AppSpacing.xs),
            child: Text(
              title!,
              style: AppTextStyles.subheader(color: teal)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
            child: Text(
              caption!,
              style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSecondary : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.08),
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// صف واحد: أيقونة، عنوان، سطر وصف، سهم. يفتح [route] أو يشارك التطبيق.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    this.route,
    this.shareApp = false,
  }) : assert(icon != null || iconWidget != null);

  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final String? route;
  final bool shareApp;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return InkWell(
      onTap: () {
        Haptic.light();
        if (shareApp) {
          ShareService.shareApp(context);
        } else if (route != null) {
          context.go(route!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (iconWidget != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: teal),
                    child: iconWidget!,
                  ),
                ),
              )
            else
              AppIconBadge(icon!),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(
                      color:
                          isDark ? AppColors.textOnDark : AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // «التالي» في الواجهة العربية يتجه يساراً؛ chevron_right يعكسه الإطار
            // تلقائياً في RTL (arrow_back_ios_new كان يشير لليمين = للخلف).
            Icon(Icons.chevron_right,
                size: 24, color: teal.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

/// شارة قسم «الرقية المستقلة»: أيقونة مكتوب فيها «رقية» بخط أميري.
class RuqyahBadge extends StatelessWidget {
  const RuqyahBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    return Center(
      child: Text(
        'رقية',
        style: GoogleFonts.amiri(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.1,
        ),
      ),
    );
  }
}
