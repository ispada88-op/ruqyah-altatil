import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/prayer_reminders.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/app_card.dart';

/// تنبيهات مرتبطة بأوقات الصلاة: تنبيه الأذان، أذكار بعد الصلاة، الكهف يوم
/// الجمعة، أذكار النوم. كلها معطّلة افتراضياً وتحتاج موقعاً محفوظاً.
class PrayerRemindersCard extends StatefulWidget {
  const PrayerRemindersCard({super.key});

  @override
  State<PrayerRemindersCard> createState() => _PrayerRemindersCardState();
}

class _PrayerRemindersCardState extends State<PrayerRemindersCard>
    with WidgetsBindingObserver {
  PrayerReminderConfig _cfg = const PrayerReminderConfig();
  bool _busy = false;

  /// أندرويد ١٤+: التنبيه الدقيق يحتاج إذناً من المستخدم؛ بدونه قد يتأخر
  /// تنبيه دخول الوقت حتى ساعة. true افتراضياً (iOS/أقدم) حتى يثبت العكس.
  bool _exactOk = true;

  static const _prayers = [
    PrayerKind.fajr,
    PrayerKind.dhuhr,
    PrayerKind.asr,
    PrayerKind.maghrib,
    PrayerKind.isha,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _checkExact();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // عودة من صفحة إعدادات النظام بعد منح/سحب الإذن.
    if (state == AppLifecycleState.resumed) _checkExact();
  }

  Future<void> _checkExact() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final ok = await NotificationService.instance.exactAlarmsAllowed();
    if (mounted && ok != _exactOk) {
      setState(() => _exactOk = ok);
      // صار الإذن ممنوحاً: أعد الجدولة لتصير التنبيهات دقيقة فوراً.
      if (ok && _cfg.alerts.isNotEmpty) {
        NotificationService.instance.reschedule();
      }
    }
  }

  Future<void> _load() async {
    final c = await PrayerRemindersStore.load();
    if (mounted) setState(() => _cfg = c);
  }

  Future<void> _apply(PrayerReminderConfig next) async {
    if (_busy) return;
    HapticFeedback.lightImpact();
    setState(() => _busy = true);
    try {
      if (next.anyEnabled && !_cfg.anyEnabled) {
        final granted = await NotificationService.instance.requestPermissions();
        if (!granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('إذن الإشعارات مرفوض من النظام'),
              backgroundColor: AppColors.warningStrong,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'فتح الإعدادات',
                textColor: Colors.white,
                onPressed: NotificationService.instance.openSystemSettings,
              ),
            ),
          );
          return;
        }
      }
      await NotificationService.instance.setPrayerReminders(next);
      if (mounted) setState(() => _cfg = next);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerRemindersCard._apply');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleAlert(PrayerKind k, bool on) {
    final s = {..._cfg.alerts};
    on ? s.add(k) : s.remove(k);
    _apply(_cfg.copyWith(alerts: s));
  }

  @override
  Widget build(BuildContext context) {
    final svc = PrayerTimesService.instance;
    if (!svc.hasLocation) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final subColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIconBadge(Icons.notifications_active_outlined,
                  color: accent, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تذكيرات الصلاة',
                        style: AppTextStyles.subheader(color: textColor)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'تُجدَّد التذكيرات كلما فتحت التطبيق (أسبوعاً قادماً)، '
                      'فافتحه مرة كل بضعة أيام ليستمر وصولها.',
                      style: AppTextStyles.caption(color: subColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          for (final k in _prayers)
            _row(
              icon: Icons.notifications_none_outlined,
              title: 'تنبيه دخول وقت ${k.label}',
              value: _cfg.alerts.contains(k),
              onChanged: (v) => _toggleAlert(k, v),
              accent: accent,
              textColor: textColor,
            ),
          if (!_exactOk && _cfg.alerts.isNotEmpty)
            _exactHint(accent, textColor, subColor),
          const Divider(height: 1),
          _row(
            icon: Icons.menu_book_outlined,
            title: 'أذكار بعد الصلاة',
            subtitle: 'بعد كل فريضة بنحو ٣٠ دقيقة',
            value: _cfg.afterPrayer,
            onChanged: (v) => _apply(_cfg.copyWith(afterPrayer: v)),
            accent: accent,
            textColor: textColor,
            subColor: subColor,
          ),
          _row(
            icon: Icons.auto_stories_outlined,
            title: 'سورة الكهف يوم الجمعة',
            subtitle: 'صباح الجمعة، بعد الشروق بنحو ٢٠ دقيقة',
            value: _cfg.kahfFriday,
            onChanged: (v) => _apply(_cfg.copyWith(kahfFriday: v)),
            accent: accent,
            textColor: textColor,
            subColor: subColor,
          ),
          _row(
            icon: Icons.bedtime_outlined,
            title: 'أذكار النوم',
            subtitle: 'بعد العشاء بنحو ٤٥ دقيقة',
            value: _cfg.sleep,
            onChanged: (v) => _apply(_cfg.copyWith(sleep: v)),
            accent: accent,
            textColor: textColor,
            subColor: subColor,
          ),
        ],
      ),
    );
  }

  Widget _exactHint(Color accent, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لتصل التنبيهات في دقيقة دخول الوقت، اسمح للتطبيق بـ«التنبيهات '
            'والتذكيرات» في إعدادات النظام. بدونه قد يتأخر التنبيه حتى ساعة.',
            style: AppTextStyles.caption(color: subColor),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () =>
                  NotificationService.instance.requestExactAlarms().then((ok) {
                if (mounted) setState(() => _exactOk = ok);
              }),
              icon: const Icon(Icons.alarm_on_outlined),
              label: const Text('السماح بالتنبيه في الدقيقة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accent,
    required Color textColor,
    Color? subColor,
  }) {
    return MergeSemantics(
        child: InkWell(
            // الصف كله يبدّل المفتاح، لا المفتاح وحده فقط (هدف لمس أكبر).
            excludeFromSemantics: true,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: _busy ? null : () => onChanged(!value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: AppTextStyles.body(color: textColor)
                                  .copyWith(fontWeight: FontWeight.w500)),
                          if (subtitle != null)
                            Text(subtitle,
                                style: AppTextStyles.caption(color: subColor)),
                        ],
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: value,
                    onChanged: _busy ? null : onChanged,
                    activeThumbColor: accent,
                  ),
                ],
              ),
            )));
  }
}
