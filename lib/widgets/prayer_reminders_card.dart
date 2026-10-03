import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/prayer_reminders.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/theme.dart';

/// تنبيهات مرتبطة بأوقات الصلاة: تنبيه الأذان، أذكار بعد الصلاة، الكهف يوم
/// الجمعة، أذكار النوم. كلها معطّلة افتراضياً وتحتاج موقعاً محفوظاً.
class PrayerRemindersCard extends StatefulWidget {
  const PrayerRemindersCard({super.key});

  @override
  State<PrayerRemindersCard> createState() => _PrayerRemindersCardState();
}

class _PrayerRemindersCardState extends State<PrayerRemindersCard> {
  PrayerReminderConfig _cfg = const PrayerReminderConfig();
  bool _busy = false;

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
    _load();
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
              backgroundColor: AppColors.warning,
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
              Icon(Icons.notifications_active_outlined, color: accent, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تنبيهات الصلاة',
                        style: AppTextStyles.subheader(color: textColor)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'تُجدَّد التنبيهات كلما فتحت التطبيق (أسبوع قادم) — افتحه مرة '
                      'كل بضعة أيام ليستمر وصولها.',
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
              icon: Icons.volume_up_outlined,
              title: 'أذان ${k.label}',
              value: _cfg.alerts.contains(k),
              onChanged: (v) => _toggleAlert(k, v),
              accent: accent,
              textColor: textColor,
            ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
    );
  }
}
