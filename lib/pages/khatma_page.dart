import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// ختمة القرآن: اختيار المدة ثم ورد يومي يتقدّم بقراءة المصحف.
class KhatmaPage extends StatefulWidget {
  const KhatmaPage({super.key});

  @override
  State<KhatmaPage> createState() => _KhatmaPageState();
}

class _KhatmaPageState extends State<KhatmaPage> {
  final _svc = KhatmaService.instance;
  int _choice = 30;

  @override
  void initState() {
    super.initState();
    _svc.ensureLoaded().then((_) {
      if (mounted) _svc.refresh();
    });
  }

  static String _daysLabel(int d) => switch (d) {
        7 => 'أسبوع',
        14 => 'أسبوعان',
        30 => 'شهر (٣٠ يوماً)',
        60 => 'شهران',
        90 => '٣ أشهر',
        180 => '٦ أشهر',
        _ => '${arDigits(d)} يوماً',
      };

  Future<void> _confirmStop() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إنهاء الختمة؟'),
          content:
              const Text('سيتوقف الورد اليومي، ويمكنك بدء ختمة جديدة بعدها.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('إنهاء')),
          ],
        ),
      ),
    );
    if (ok == true) await _svc.stop();
  }

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const SectionBackBar(
              title: 'ختمة القرآن', fallbackRoute: AppRoutes.mushaf),
          Expanded(
            child: ListenableBuilder(
              listenable: _svc,
              builder: (context, _) => ListView(
                padding: AppSpacing.paddingMd,
                children: _svc.active ? _activeView(c) : _setupView(c),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _setupView(PageColors c) {
    return [
      if (_svc.completedCount > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            child: Row(children: [
              Icon(Icons.emoji_events_outlined, color: c.gold),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                    'أتممت ${arDigits(_svc.completedCount)} ختمة — تقبّل الله منك',
                    style: AppTextStyles.body(color: c.ink)),
              ),
            ]),
          ),
        ),
      Text('اختر مدة الختمة', style: AppTextStyles.subheader(color: c.ink)),
      const SizedBox(height: AppSpacing.xs),
      Text(
          'يُقسَّم المصحف (٦٠٤ صفحات) على أيام المدة، وتتقدّم الختمة بقراءتك في المصحف.',
          style: AppTextStyles.caption(color: c.sub)),
      const SizedBox(height: AppSpacing.md),
      RadioGroup<int>(
        groupValue: _choice,
        onChanged: (v) {
          if (v != null) setState(() => _choice = v);
        },
        child: Column(
          children: [
            for (final d in KhatmaService.durations)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  onTap: () {
                    Haptic.select();
                    setState(() => _choice = d);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Row(children: [
                      Radio<int>(value: d, activeColor: c.teal),
                      Expanded(
                        child: Text(_daysLabel(d),
                            style: AppTextStyles.body(color: c.ink)),
                      ),
                      Text(
                        '${pagesLabel(khatmaDailyTarget(nextPage: 1, daysLeft: d))} يومياً',
                        style: AppTextStyles.caption(color: c.sub),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      FilledButton.icon(
        style: c.filled,
        icon: const Icon(Icons.flag_outlined),
        label: const Text('ابدأ الختمة'),
        onPressed: () async {
          Haptic.medium();
          await _svc.start(_choice);
        },
      ),
    ];
  }

  List<Widget> _activeView(PageColors c) {
    final s = _svc;
    final left = s.daysLeftAfterToday(DateTime.now());
    final pct = (s.progress * 100).floor();
    return [
      AppCard(
        padding: AppSpacing.paddingLg,
        child: Column(children: [
          SizedBox(
            width: 128,
            height: 128,
            child: Semantics(
                label: 'تقدّم الختمة ${arDigits(pct)} بالمئة',
                excludeSemantics: true,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: s.progress,
                      strokeWidth: 10,
                      color: c.teal,
                      backgroundColor: c.teal.withValues(alpha: 0.15),
                    ),
                  ),
                  Text('${arDigits(pct)}٪',
                      style: AppTextStyles.header(color: c.ink)
                          .copyWith(fontSize: 30, fontWeight: FontWeight.w800)),
                ])),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'قرأت ${arDigits(s.nextPage - 1)} من ${pagesLabel(kMushafPages)}',
            style: AppTextStyles.body(color: c.ink),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            left >= 0
                ? 'بقي ${pagesLabel(s.pagesLeft)} في ${daysLabel(left + 1)} (بما فيها اليوم)'
                : 'تجاوزت المدة المحددة — أكمل بما تيسّر',
            style: AppTextStyles.caption(color: c.sub),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
      const SizedBox(height: AppSpacing.md),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(s.todayDone ? Icons.check_circle : Icons.auto_stories_outlined,
                color: s.todayDone ? c.success : c.gold),
            const SizedBox(width: AppSpacing.sm),
            Text('وردك اليوم', style: AppTextStyles.subheader(color: c.ink)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(
            s.todayTarget == 0
                ? '—'
                : 'من صفحة ${arDigits(s.todayStartPage)} إلى صفحة ${arDigits(s.todayEndPage)} (${pagesLabel(s.todayTarget)})',
            style: AppTextStyles.body(color: c.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: s.todayTarget == 0 ? 0 : s.todayRead / s.todayTarget,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            color: s.todayDone ? c.success : c.teal,
            backgroundColor: c.teal.withValues(alpha: 0.15),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            s.todayDone
                ? 'أتممت وردك اليوم — تقبّل الله منك'
                : 'قرأت ${arDigits(s.todayRead)} من ${arDigits(s.todayTarget)}',
            style: AppTextStyles.caption(color: c.sub),
          ),
        ]),
      ),
      const SizedBox(height: AppSpacing.md),
      FilledButton.icon(
        style: c.filled,
        icon: const Icon(Icons.auto_stories_outlined),
        label: Text('تابع القراءة من صفحة ${arDigits(s.nextPage)}'),
        onPressed: () {
          Haptic.light();
          context.push(AppRoutes.mushafPage(s.nextPage));
        },
      ),
      const SizedBox(height: AppSpacing.sm),
      if (!s.todayDone)
        OutlinedButton.icon(
          icon: const Icon(Icons.done_all),
          label: const Text('قرأت وردي من مصحف آخر'),
          onPressed: () {
            Haptic.medium();
            s.completeToday();
          },
        ),
      TextButton(
        onPressed: _confirmStop,
        child: Text('إنهاء الختمة', style: TextStyle(color: c.error)),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'تتقدّم الختمة حين تفتح الصفحة التالية لما قرأت بالتسلسل؛ القفز بين الصفحات لا يُحتسب.',
        style: AppTextStyles.caption(color: c.sub),
        textAlign: TextAlign.center,
      ),
    ];
  }
}
