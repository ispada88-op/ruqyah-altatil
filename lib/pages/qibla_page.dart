import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// فرق الزاويتين بين −١٨٠ و١٨٠ (للمحاذاة مع القبلة).
double angleDelta(double a, double b) {
  var d = (a - b) % 360;
  if (d > 180) d -= 360;
  if (d < -180) d += 360;
  return d;
}

/// اتجاه القبلة: بوصلة الجهاز + الدرجة من الشمال. تحتاج موقعاً محفوظاً.
class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    final svc = PrayerTimesService.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qibla = svc.qibla;
    return Column(
      children: [
        const SectionBackBar(title: 'اتجاه القبلة', fallbackRoute: AppRoutes.prayerTimes),
        Expanded(
          child: Scaffold(
            body: qibla == null
                ? Center(
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('حدّد موقعك أولاً لحساب اتجاه القبلة.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(color: null)),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton(
                            onPressed: () => context.go(AppRoutes.prayerTimes),
                            child: const Text('تحديد الموقع'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _body(context, qibla, isDark),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, double qibla, bool isDark) {
    final stream = FlutterCompass.events;
    final sub = isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    return StreamBuilder<CompassEvent>(
      stream: stream,
      builder: (context, snap) {
        final heading = snap.data?.heading; // null = لا بوصلة أو لم تصل قراءة
        final hasCompass = heading != null;
        final delta = hasCompass ? angleDelta(qibla, heading) : null;
        final aligned = delta != null && delta.abs() <= 3;
        if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
        _wasAligned = aligned;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'القبلة ${arDigits(qibla.round())}° من الشمال (مع عقارب الساعة)',
              textAlign: TextAlign.center,
              style: AppTextStyles.subheader(
                  color: isDark ? AppColors.textOnDark : AppColors.primaryTeal),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: _Dial(
                heading: heading ?? 0,
                qibla: qibla,
                aligned: aligned,
                hasCompass: hasCompass,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              !hasCompass
                  ? (snap.connectionState == ConnectionState.waiting
                      ? 'جارٍ قراءة البوصلة…'
                      : 'لا تتوفر بوصلة في هذا الجهاز. وجّه نفسك نحو ${arDigits(qibla.round())}° من الشمال.')
                  : aligned
                      ? 'أنت باتجاه القبلة ✓'
                      : 'أدر الجهاز حتى يطابق السهم الذهبي أعلى الدائرة',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                  color: aligned ? AppColors.success : sub)
                  .copyWith(fontWeight: aligned ? FontWeight.w800 : FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'ضع الجهاز أفقياً مسطّحاً وابتعد عن المعادن والمغناطيس. '
              'إن بدت القراءة غير دقيقة فحرّك الجهاز بشكل رقم ٨ لمعايرة البوصلة. '
              'البوصلة وسيلة مساعدة؛ وإن توفّر لك اتجاه المحراب في المسجد فهو المعتمد.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: sub),
            ),
          ],
        );
      },
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.heading,
    required this.qibla,
    required this.aligned,
    required this.hasCompass,
  });
  final double heading;
  final double qibla;
  final bool aligned;
  final bool hasCompass;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ring = aligned
        ? AppColors.success
        : (isDark ? AppColors.darkTeal : AppColors.primaryTeal);
    final size = math.min(MediaQuery.of(context).size.width - 56, 320.0);
    // القرص كله يدور بعكس اتجاه الجهاز فيبقى الشمال حقيقياً؛ والكعبة على القرص
    // عند زاوية القبلة. السهم الثابت أعلى الدائرة = اتجاه رأس الجهاز.
    final turns = -heading * math.pi / 180;
    return SizedBox(
      width: size,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSecondary : Colors.white,
                border: Border.all(color: ring, width: 5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Transform.rotate(
                angle: turns,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الشمال
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('ش',
                            style: AppTextStyles.subheader(color: AppColors.error)),
                      ),
                    ),
                    // الكعبة عند زاوية القبلة
                    Transform.rotate(
                      angle: qibla * math.pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 34),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.accentGold, width: 2),
                                ),
                                child: const Icon(Icons.mosque, size: 20, color: AppColors.accentGold),
                              ),
                              Container(width: 2, height: size / 2 - 90, color: ring.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // سهم اتجاه الجهاز (ثابت)
          const Positioned(
            top: 0,
            child: Icon(Icons.arrow_drop_down, size: 44, color: AppColors.accentGold),
          ),
        ],
      ),
    );
  }
}
