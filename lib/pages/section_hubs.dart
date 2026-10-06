import 'package:flutter/material.dart';

import 'package:roqia_altatil/config/app_identity.dart';
import 'package:roqia_altatil/data/ruqyah_types_data.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/ruqyah_types_page.dart'
    show RuqyahTypesPage;
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/adhkar_reminders_card.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/menu_group.dart';
import 'package:roqia_altatil/widgets/notifications_settings_card.dart';

/// هيكل قائمة قسم (الرقية، الأذكار): ترويسة بأيقونة وعنوان ثم مجموعات صفوف.
/// الهدف: كل قسم في مكان واحد واضح بدل صفوف كثيرة مبعثرة في الرئيسية.
class SectionHubPage extends StatelessWidget {
  const SectionHubPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.groups,
    this.footer = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> groups;

  /// ودجتات أسفل المجموعات (بطاقات إعدادات مثلاً).
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: c.isDark
                ? [AppColors.darkPrimary, AppColors.darkSurface]
                : [AppColors.backgroundCreamLight, AppColors.backgroundCream],
          ),
        ),
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            Row(
              children: [
                AppIconBadge(icon, size: 56),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.header(color: c.teal)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(subtitle,
                          style: AppTextStyles.caption(color: c.sub)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final g in groups) ...[
              g,
              const SizedBox(height: AppSpacing.md),
            ],
            for (final f in footer) ...[
              f,
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

/// قائمة «الرقية»: رقية التعطيل (صوتية ومكتوبة)، ثم باقي الرقى بأقسامها، ثم
/// المتابعة والضوابط.
class RuqyahHubPage extends StatelessWidget {
  const RuqyahHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionHubPage(
      icon: Icons.healing_outlined,
      title: 'الرقية',
      subtitle: 'رقية التعطيل وباقي الرقى الشرعية بأقسامها',
      groups: [
        const MenuGroup(
          title: AppIdentity.taTil,
          caption: AppIdentity.taTilOwner,
          rows: [
            MenuRow(
              title: 'صوتية',
              subtitle: 'بأصوات مشايخ مختارين، وتعمل في الخلفية',
              icon: Icons.headphones_outlined,
              route: AppRoutes.audioRoqia,
            ),
            MenuRow(
              title: 'مكتوبة',
              subtitle: 'اقرأها بالرسم العثماني وخط واضح',
              icon: Icons.text_snippet_outlined,
              route: AppRoutes.writtenRoqia,
            ),
          ],
        ),
        MenuGroup(
          title: 'رقى أخرى',
          rows: [
            const MenuRow(
              title: 'الرقية المستقلة',
              subtitle: 'الفاتحة والمعوذات وآيات وأدعية بعدد التكرار',
              iconWidget: RuqyahBadge(),
              route: AppRoutes.generalRuqyah,
            ),
            for (final t in kRuqyahTypes)
              MenuRow(
                title: t.title,
                subtitle: t.subtitle,
                icon: RuqyahTypesPage.iconFor(t.id),
                route: AppRoutes.ruqyahType(t.id),
              ),
          ],
        ),
        const MenuGroup(
          title: 'المتابعة والضوابط',
          rows: [
            MenuRow(
              title: 'برنامج المداومة',
              subtitle: 'مهام يومية نحو ٧ أو ٢١ أو ٤٠ يوماً',
              icon: Icons.checklist_outlined,
              route: AppRoutes.program,
            ),
            MenuRow(
              title: 'متابعة أيام الرقية',
              subtitle: 'سجّل قراءتك اليومية وتابع استمرارك',
              icon: Icons.calendar_month_outlined,
              route: AppRoutes.tracker,
            ),
            MenuRow(
              title: 'ضوابط الرقية الشرعية',
              subtitle: 'الشروط والأدلة وما يُحذَّر منه',
              icon: Icons.rule_outlined,
              route: AppRoutes.ruqyahRules,
            ),
          ],
        ),
      ],
    );
  }
}

/// قائمة «الأذكار»: حصن المسلم (الصباح والمساء وبعد الصلاة)، ثم التحصين
/// والتسبيح، ثم التذكيرات.
class AdhkarHubPage extends StatelessWidget {
  const AdhkarHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionHubPage(
      icon: Icons.wb_twilight_outlined,
      title: 'الأذكار',
      subtitle: 'حصن المسلم والتحصين والتسبيح في مكان واحد',
      groups: [
        MenuGroup(
          title: 'حصن المسلم',
          rows: [
            MenuRow(
              title: 'أذكار الصباح والمساء',
              subtitle: 'كاملة من حصن المسلم بعدّاد لكل ذكر',
              icon: Icons.wb_twilight_outlined,
              route: AppRoutes.adhkar,
            ),
            MenuRow(
              title: 'أذكار بعد الصلاة',
              subtitle: 'بعد السلام من كل فريضة من حصن المسلم',
              icon: Icons.menu_book_outlined,
              route: AppRoutes.afterPrayer,
            ),
          ],
        ),
        MenuGroup(
          title: 'التحصين والتسبيح',
          rows: [
            MenuRow(
              title: 'أذكار التحصين',
              subtitle: 'أذكار مأثورة بمصادرها للحفظ بإذن الله',
              icon: Icons.shield_moon_outlined,
              route: AppRoutes.tahseen,
            ),
            MenuRow(
              title: 'عدّاد التسبيح والأدعية',
              subtitle: 'عدّاد ذكي وأدعية مأثورة',
              icon: Icons.touch_app_outlined,
              route: AppRoutes.dhikr,
            ),
          ],
        ),
      ],
      footer: [
        AdhkarRemindersCard(),
        NotificationsSettingsCard(),
      ],
    );
  }
}
