import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/prayer_times_page.dart' show prayerLabelOn;
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';

export 'package:roqia_altatil/utils/arabic_format.dart' show shortLeftAr;
import 'package:roqia_altatil/widgets/app_card.dart';

/// شريط الرئيسية: الصلاة القادمة + ورد الختمة اليوم.
class TodayStrip extends StatefulWidget {
  const TodayStrip({super.key});

  @override
  State<TodayStrip> createState() => _TodayStripState();
}

class _TodayStripState extends State<TodayStrip> {
  Timer? _tick;
  final _prayer = PrayerTimesService.instance;
  final _khatma = KhatmaService.instance;
  late final Listenable _all = Listenable.merge([_prayer, _khatma]);

  @override
  void initState() {
    super.initState();
    _khatma.ensureLoaded();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      _khatma.refresh(); // بعد منتصف الليل
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return ListenableBuilder(
      listenable: _all,
      builder: (context, _) {
        final now = DateTime.now();
        final next = _prayer.hasLocation ? _prayer.nextPrayer(now) : null;
        final prev = _prayer.hasLocation ? _prayer.previousPrayer(now) : null;
        final k = _khatma;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tile(
              c,
              icon: Icons.mosque_outlined,
              title: next == null
                  ? 'حدّد موقعك لمواقيت الصلاة'
                  : 'الصلاة القادمة: ${prayerLabelOn(next.kind, next.time)}',
              sub: next == null
                  ? 'تُحسب داخل جهازك بلا إنترنت'
                  : '${formatTimeAr(next.time.hour, next.time.minute)}، بعد ${shortLeftAr(next.time.difference(now))}'
                      '${prev == null ? '' : '\nمضى ${shortLeftAr(now.difference(prev.time))} على أذان ${prayerLabelOn(prev.kind, prev.time)}'}',
              onTap: () => context.go(AppRoutes.prayerTimes),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (k.active)
              _tile(
                c,
                icon: k.todayDone
                    ? Icons.check_circle
                    : Icons.auto_stories_outlined,
                iconColor: k.todayDone ? c.success : null,
                title:
                    k.todayDone ? 'أتممت وردك اليوم' : 'وردك اليوم من القرآن',
                sub: k.todayDone
                    ? 'تقبّل الله منك — صفحة ${arDigits(k.nextPage)} غداً بإذن الله'
                    : 'صفحة ${arDigits(k.todayStartPage)} إلى ${arDigits(k.todayEndPage)}، قرأت ${arDigits(k.todayRead)} من ${arDigits(k.todayTarget)}',
                onTap: () => context.go(AppRoutes.mushafPage(k.nextPage)),
              )
            else
              _tile(
                c,
                icon: Icons.flag_outlined,
                title: 'ابدأ ختمة القرآن',
                sub: 'ورد يومي يتقدّم بقراءتك في المصحف',
                onTap: () => context.go(AppRoutes.khatma),
              ),
          ],
        );
      },
    );
  }

  Widget _tile(
    PageColors c, {
    required IconData icon,
    Color? iconColor,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            AppIconBadge(icon, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: AppTextStyles.body(color: c.ink)
                          .copyWith(fontWeight: FontWeight.w700)),
                  Text(sub, style: AppTextStyles.caption(color: c.sub)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 24, color: c.teal.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}
