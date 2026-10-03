import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/data/prayer_cities.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/prayer_reminders_card.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// «٢:١٥:٠٣» — الوقت المتبقي بالأرقام العربية.
String formatCountdown(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return arDigits('$h:${two(m)}:${two(sec)}');
}

/// اسم الوقت مع مراعاة الجمعة (الظهر يوم الجمعة = «الجمعة»).
String prayerLabelOn(PrayerKind k, DateTime day) =>
    k == PrayerKind.dhuhr && day.weekday == DateTime.friday ? 'الجمعة' : k.label;

/// مواقيت الصلاة: حساب فلكي داخل الجهاز (بدون إنترنت) + القبلة + تنبيهات.
class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final _svc = PrayerTimesService.instance;
  Timer? _tick;
  bool _gpsBusy = false;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onChanged);
    if (!_svc.isLoaded) _svc.load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _svc.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _afterChange() async {
    // المواقيت تغيّرت ⇒ أعد جدولة التنبيهات المرتبطة بها.
    try {
      await NotificationService.instance.reschedule();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerTimesPage.reschedule');
    }
  }

  Future<void> _useGps() async {
    if (_gpsBusy) return;
    setState(() => _gpsBusy = true);
    final outcome = await _svc.useGps();
    if (!mounted) return;
    setState(() => _gpsBusy = false);
    if (outcome == GpsOutcome.ok) {
      await _afterChange();
      return;
    }
    final msg = switch (outcome) {
      GpsOutcome.serviceOff => 'خدمة الموقع مغلقة في جهازك. فعّلها أو اختر مدينتك.',
      GpsOutcome.denied => 'لم يُمنح إذن الموقع. يمكنك اختيار مدينتك بدلاً منه.',
      GpsOutcome.deniedForever =>
        'إذن الموقع مرفوض من إعدادات النظام. فعّله من هناك أو اختر مدينتك.',
      _ => 'تعذّر تحديد موقعك الآن. اختر مدينتك أو أعد المحاولة.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.warning,
      duration: const Duration(seconds: 6),
    ));
  }

  Future<void> _pickCity() async {
    final city = await showModalBottomSheet<PrayerCity>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CityPickerSheet(),
    );
    if (city == null) return;
    await _svc.setCity(city);
    await _afterChange();
  }

  Future<void> _openSettings() async {
    Haptic.light();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SettingsSheet(
        onUseGps: _useGps,
        onPickCity: _pickCity,
        onChanged: _afterChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SectionBackBar(title: 'مواقيت الصلاة', fallbackRoute: AppRoutes.home),
        Expanded(
          child: Scaffold(
            body: !_svc.isLoaded
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      if (!_svc.hasLocation)
                        _SetupCard(
                            busy: _gpsBusy, onGps: _useGps, onCity: _pickCity)
                      else ...[
                        _NextPrayerHero(now: DateTime.now()),
                        const SizedBox(height: AppSpacing.md),
                        _TimesCard(now: DateTime.now()),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Haptic.light();
                                  context.push(AppRoutes.qibla);
                                },
                                icon: const Icon(Icons.explore_outlined),
                                label: const Text('اتجاه القبلة'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openSettings,
                                icon: const Icon(Icons.tune),
                                label: const Text('الموقع والطريقة'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const PrayerRemindersCard(),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'تُحسب المواقيت داخل جهازك بلا إنترنت، ولا يُرسل موقعك لأي جهة. '
                          'قد تختلف بدقائق عن التقويم المعتمد في بلدك؛ فإن اختلفت فاعتمد '
                          'تقويم بلدك الرسمي.',
                          style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.textOnDarkSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.busy, required this.onGps, required this.onCity});
  final bool busy;
  final VoidCallback onGps;
  final VoidCallback onCity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.location_on_outlined, size: 44, color: teal),
          const SizedBox(height: AppSpacing.sm),
          Text('حدّد موقعك لحساب المواقيت',
              textAlign: TextAlign.center,
              style: AppTextStyles.subheader(
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'يُحسب الوقت داخل جهازك فقط ولا يُرسل موقعك لأحد. '
            'يمكنك استخدام موقعك الحالي أو اختيار مدينتك بدون أي إذن.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: busy ? null : onGps,
            style: FilledButton.styleFrom(
                backgroundColor: teal,
                foregroundColor:
                    isDark ? const Color(0xFF0B1F1F) : Colors.white),
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.my_location),
            label: const Text('استخدم موقعي'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onCity,
            icon: const Icon(Icons.location_city),
            label: const Text('اختر مدينتي'),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerHero extends StatelessWidget {
  const _NextPrayerHero({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final svc = PrayerTimesService.instance;
    final next = svc.nextPrayer(now);
    if (next == null) return const SizedBox.shrink();
    final left = next.time.difference(now);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryTeal, AppColors.primaryTealDark], // تباين الذهبي والأبيض ≥ ٤٫٥ على كامل التدرج
        ),
      ),
      child: Column(
        children: [
          Text('الصلاة القادمة',
              style: AppTextStyles.caption(color: Colors.white70)),
          const SizedBox(height: 2),
          Text(prayerLabelOn(next.kind, next.time),
              style: AppTextStyles.header(color: Colors.white)
                  .copyWith(fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(formatTimeAr(next.time.hour, next.time.minute),
              style: AppTextStyles.subheader(color: AppColors.accentGoldLight)),
          const SizedBox(height: AppSpacing.sm),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(formatCountdown(left),
                style: AppTextStyles.header(color: Colors.white)
                    .copyWith(fontSize: 26, letterSpacing: 2)),
          ),
          const SizedBox(height: 2),
          Text('متبقٍ على الأذان',
              style: AppTextStyles.caption(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _TimesCard extends StatelessWidget {
  const _TimesCard({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final svc = PrayerTimesService.instance;
    final day = svc.dayFor(now);
    if (day == null) return const SizedBox.shrink();
    final next = svc.nextPrayer(now);
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(formatDateAr(now),
                      style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textSecondary)),
                ),
                Flexible(
                  child: Text(
                    svc.label.isEmpty ? '' : svc.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: teal)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          for (final k in PrayerKind.values)
            _TimeRow(
              label: prayerLabelOn(k, now),
              time: day[k],
              isNext: next != null &&
                  next.kind == k &&
                  next.time.day == day[k].day,
              passed: day[k].isBefore(now),
              dim: !k.isPrayer,
            ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.isNext,
    required this.passed,
    required this.dim,
  });
  final String label;
  final DateTime time;
  final bool isNext;
  final bool passed;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    final base = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final color = isNext
        ? teal
        // 0.72 يحفظ تبايناً ≥ 4.5:1 على الأبيض والكحلي (0.55 كان ≈ 3.6:1).
        : (passed || dim ? base.withValues(alpha: 0.72) : base);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isNext ? teal.withValues(alpha: 0.12) : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          if (isNext)
            Icon(Icons.notifications_active_outlined, size: 18, color: teal)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: AppTextStyles.body(color: color).copyWith(
                    // لا مائل للعربية (مائل اصطناعي يشوّه الحروف): الشروق أخفّ وزناً.
                    fontWeight: isNext
                        ? FontWeight.w800
                        : (dim ? FontWeight.w400 : FontWeight.w500))),
          ),
          Text(formatTimeAr(time.hour, time.minute),
              style: AppTextStyles.subheader(color: color)
                  .copyWith(fontWeight: isNext ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet(
      {required this.onUseGps, required this.onPickCity, required this.onChanged});
  final Future<void> Function() onUseGps;
  final Future<void> Function() onPickCity;
  final Future<void> Function() onChanged;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  final _svc = PrayerTimesService.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 4, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('الموقع', style: AppTextStyles.subheader(color: null)),
            const SizedBox(height: 4),
            Text(
              _svc.hasLocation
                  ? '${_svc.label} — ${_svc.source == PrayerLocationSource.gps ? 'من جهازك' : 'مدينة مختارة'}'
                  : 'غير محدد',
              style: AppTextStyles.caption(color: sub),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await widget.onUseGps();
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('موقعي'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await widget.onPickCity();
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.location_city),
                    label: const Text('مدينة'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('طريقة الحساب', style: AppTextStyles.subheader(color: null)),
            const SizedBox(height: 4),
            DropdownButtonFormField<PrayerMethod>(
              initialValue: _svc.method,
              isExpanded: true,
              items: [
                for (final m in PrayerMethod.values)
                  DropdownMenuItem(value: m, child: Text(m.label)),
              ],
              onChanged: (m) async {
                if (m == null) return;
                await _svc.setMethod(m);
                await widget.onChanged();
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('وقت العصر', style: AppTextStyles.subheader(color: null)),
            const SizedBox(height: 4),
            RadioGroup<PrayerMadhab>(
              groupValue: _svc.madhab,
              onChanged: (m) async {
                if (m == null) return;
                await _svc.setMadhab(m);
                await widget.onChanged();
                if (mounted) setState(() {});
              },
              child: Column(
                children: [
                  for (final m in PrayerMadhab.values)
                    RadioListTile<PrayerMadhab>(
                      value: m,
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.label, style: AppTextStyles.body(color: null)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet();

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final cities = [
      for (final c in kPrayerCities)
        if (_q.isEmpty || c.name.contains(_q) || c.country.contains(_q)) c,
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ابحث عن مدينة أو دولة',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _q = v.trim()),
                ),
              ),
              Expanded(
                child: cities.isEmpty
                    ? const Center(child: Text('لا نتائج'))
                    : ListView.builder(
                        itemCount: cities.length,
                        itemBuilder: (_, i) {
                          final c = cities[i];
                          return ListTile(
                            title: Text(c.name),
                            subtitle: Text(c.country),
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
