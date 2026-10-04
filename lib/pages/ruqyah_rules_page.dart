import 'package:flutter/material.dart';

import 'package:roqia_altatil/data/ruqyah_rules_data.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// ضوابط الرقية الشرعية: الشروط والأدلة وما يُحذَّر منه — بنسبة كل نص لمخرِّجه.
class RuqyahRulesPage extends StatelessWidget {
  const RuqyahRulesPage({super.key});

  static IconData _icon(String k) => switch (k) {
        'rule' => Icons.rule_outlined,
        'book' => Icons.menu_book_outlined,
        'health' => Icons.health_and_safety_outlined,
        'warning' => Icons.warning_amber_outlined,
        'people' => Icons.groups_2_outlined,
        _ => Icons.info_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const SectionBackBar(
              title: 'ضوابط الرقية الشرعية', fallbackRoute: AppRoutes.home),
          Expanded(
            child: ListView(
              padding: AppSpacing.paddingMd,
              children: [
                Text(kRuqyahRulesIntro,
                    style: AppTextStyles.body(color: c.sub)),
                const SizedBox(height: AppSpacing.md),
                for (final sec in kRuqyahRules) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Icon(_icon(sec.icon),
                              color: sec.icon == 'warning'
                                  ? AppColors.warning
                                  : c.gold),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(sec.title,
                                style: AppTextStyles.subheader(color: c.ink)),
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.sm),
                        for (final p in sec.points) _point(p, c),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(kRuqyahRulesDisclaimer,
                    style: AppTextStyles.caption(color: c.sub),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _point(RulePoint p, PageColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.text,
                style: AppTextStyles.body(color: c.ink).copyWith(height: 1.7)),
            if (p.hadith != null)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: c.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: BorderDirectional(
                      start: BorderSide(color: c.gold, width: 3)),
                ),
                child: Text('«${p.hadith}»',
                    style: AppTextStyles.dhikr(color: c.ink, fontSize: 18)
                        .copyWith(height: 1.9)),
              ),
            if (p.source != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child:
                    Text(p.source!, style: AppTextStyles.caption(color: c.sub)),
              ),
          ],
        ),
      ),
    );
  }
}
