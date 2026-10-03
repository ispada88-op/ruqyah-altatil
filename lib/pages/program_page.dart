import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/data/adhkar_data.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/services/program_service.dart';
import 'package:roqia_altatil/services/ruqyah_log_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// برنامج المداومة: قائمة يومية قصيرة نحو هدف ٧ أو ٢١ أو ٤٠ يوماً متتالية.
class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  final _program = ProgramService.instance;
  final _log = RuqyahLogService.instance;
  final _khatma = KhatmaService.instance;
  late final Listenable _all = Listenable.merge([_program, _log, _khatma]);

  @override
  void initState() {
    super.initState();
    () async {
      await Future.wait([_program.ensureLoaded(), _khatma.ensureLoaded()]);
      if (!_log.isLoaded) await _log.load();
      // ورد الختمة قد يكتمل بالقراءة خارج هذه الصفحة.
      await _program.syncLog();
    }();
  }

  ({String title, String? sub, String route, IconData icon}) _meta(ProgramItem i) {
    switch (i) {
      case ProgramItem.morning:
        return (
          title: 'أذكار الصباح',
          sub: null,
          route: AppRoutes.adhkarAt(AdhkarTime.morning),
          icon: Icons.wb_sunny_outlined
        );
      case ProgramItem.ruqyah:
        return (
          title: 'الرقية',
          sub: 'استماع أو قراءة',
          route: AppRoutes.audioRoqia,
          icon: Icons.headphones_outlined
        );
      case ProgramItem.wird:
        final k = _khatma;
        return k.active
            ? (
                title: 'وردك من القرآن',
                sub:
                    'من صفحة ${arDigits(k.todayStartPage)} إلى ${arDigits(k.todayEndPage)}',
                route: AppRoutes.mushafPage(k.nextPage),
                icon: Icons.menu_book_rounded
              )
            : (
                title: 'وردك من القرآن',
                sub: 'ولو صفحة واحدة',
                route: AppRoutes.mushaf,
                icon: Icons.menu_book_rounded
              );
      case ProgramItem.evening:
        return (
          title: 'أذكار المساء',
          sub: null,
          route: AppRoutes.adhkarAt(AdhkarTime.evening),
          icon: Icons.nights_stay_outlined
        );
      case ProgramItem.sleep:
        return (
          title: 'أذكار النوم والتحصين',
          sub: null,
          route: AppRoutes.tahseen,
          icon: Icons.bedtime_outlined
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const SectionBackBar(title: 'برنامج المداومة', fallbackRoute: AppRoutes.home),
          Expanded(
            child: ListenableBuilder(
              listenable: _all,
              builder: (context, _) {
                final now = DateTime.now();
                final done = _program.effectiveDone(now);
                final complete = isProgramDayComplete(done);
                final streak = _log.streak(now);
                final goal = _log.goal;
                return ListView(
                  padding: AppSpacing.paddingMd,
                  children: [
                    AppCard(
                      padding: AppSpacing.paddingLg,
                      child: Column(children: [
                        Text('المداومة على الرقية والأذكار',
                            style: AppTextStyles.subheader(color: c.ink)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('أنجز بنود اليوم كلها فيُسجَّل يومك ويزيد تتابعك',
                            style: AppTextStyles.caption(color: c.sub),
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: 112,
                          height: 112,
                          child: Semantics(
                            label: 'أيام التتابع ${arDigits(streak)} من ${arDigits(goal)}',
                            excludeSemantics: true,
                            child: Stack(alignment: Alignment.center, children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: (streak / goal).clamp(0.0, 1.0),
                                strokeWidth: 9,
                                color: c.gold,
                                backgroundColor: c.gold.withValues(alpha: 0.18),
                              ),
                            ),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(arDigits(streak),
                                  style: AppTextStyles.header(color: c.ink)
                                      .copyWith(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1)),
                              Text('من ${arDigits(goal)} يوماً',
                                  style: AppTextStyles.caption(color: c.sub)),
                            ]),
                          ])),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            for (final g in RuqyahLogService.goals)
                              ChoiceChip(
                                label: Text('${arDigits(g)} يوماً'),
                                selected: goal == g,
                                onSelected: (_) {
                                  Haptic.select();
                                  _log.setGoal(g);
                                },
                              ),
                          ],
                        ),
                        if (streak >= goal)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text('بلغت هدفك — تقبّل الله منك وثبّتك',
                                style: AppTextStyles.body(color: AppColors.success)),
                          ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('مهام اليوم', style: AppTextStyles.subheader(color: c.ink)),
                    const SizedBox(height: AppSpacing.sm),
                    for (final item in ProgramItem.values) ...[
                      _row(item, done.contains(item), c),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (complete)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success),
                            const SizedBox(width: AppSpacing.sm),
                            Text('أتممت برنامج اليوم — ولله الحمد',
                                style: AppTextStyles.body(color: AppColors.success)),
                          ],
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.tracker),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('سجل الأيام'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(ProgramItem item, bool done, PageColors c) {
    final m = _meta(item);
    // بند الورد المحتسب تلقائياً من الختمة لا يُبدَّل يدوياً.
    final auto = item == ProgramItem.wird && _program.wirdFromKhatma();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      onTap: () {
        Haptic.light();
        context.push(m.route);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(children: [
          Checkbox(
            value: done,
            activeColor: AppColors.success,
            onChanged: auto
                ? null
                : (_) {
                    Haptic.select();
                    _program.toggle(item);
                  },
          ),
          Icon(m.icon, color: c.gold, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.title,
                    style: AppTextStyles.body(color: c.ink).copyWith(
                        decoration: done ? TextDecoration.lineThrough : null)),
                if (m.sub != null)
                  Text(m.sub!, style: AppTextStyles.caption(color: c.sub)),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: c.sub),
        ]),
      ),
    );
  }
}
