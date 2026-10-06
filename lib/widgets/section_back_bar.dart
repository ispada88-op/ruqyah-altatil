import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/theme.dart';

/// شريط رجوع لصفحات فرعية داخل الـ shell (لا يوجد زر رجوع في شريط التطبيق).
class SectionBackBar extends StatelessWidget {
  const SectionBackBar(
      {super.key, required this.title, required this.fallbackRoute});

  final String title;

  /// المسار الذي نذهب إليه إن لم يوجد ما نرجع إليه في المكدس.
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.textOnDark : AppColors.primaryTeal;
    return Material(
      color: isDark ? AppColors.darkSecondary : Colors.white,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: [
            IconButton(
              tooltip: 'رجوع',
              icon: Icon(Icons.arrow_back, color: color),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(fallbackRoute);
                }
              },
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.subheader(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
