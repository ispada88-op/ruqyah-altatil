import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roqia_altatil/services/adhkar_reminders.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';

/// بطاقة تذكير أذكار الصباح والمساء: مفتاح ووقت لكل منهما، بتوقيت الجهاز.
class AdhkarRemindersCard extends StatefulWidget {
  const AdhkarRemindersCard({super.key});

  @override
  State<AdhkarRemindersCard> createState() => _AdhkarRemindersCardState();
}

class _AdhkarRemindersCardState extends State<AdhkarRemindersCard> {
  final Map<AdhkarSlot, AdhkarReminderConfig> _cfg = {
    for (final s in AdhkarSlot.values)
      s: AdhkarReminderConfig(
          enabled: false, minutes: AdhkarRemindersStore.defaultMinutes(s)),
  };
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = {
      for (final s in AdhkarSlot.values) s: await AdhkarRemindersStore.load(s),
    };
    if (mounted) setState(() => _cfg.addAll(loaded));
  }

  Future<void> _toggle(AdhkarSlot slot, bool value) async {
    if (_busy) return;
    HapticFeedback.lightImpact();
    setState(() => _busy = true);
    try {
      if (value) {
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
      await NotificationService.instance.setAdhkarReminder(slot, enabled: value);
      final cfg = await AdhkarRemindersStore.load(slot);
      if (mounted) setState(() => _cfg[slot] = cfg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setByPrayer(AdhkarSlot slot, bool v) async {
    await NotificationService.instance.setAdhkarReminder(slot, byPrayer: v);
    final cfg = await AdhkarRemindersStore.load(slot);
    if (mounted) setState(() => _cfg[slot] = cfg);
  }

  Future<void> _setOffset(AdhkarSlot slot, int m) async {
    await NotificationService.instance.setAdhkarReminder(slot, offsetMin: m);
    final cfg = await AdhkarRemindersStore.load(slot);
    if (mounted) setState(() => _cfg[slot] = cfg);
  }

  Future<void> _pickTime(AdhkarSlot slot) async {
    final cur = _cfg[slot]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: cur.hour, minute: cur.minute),
      helpText: slot == AdhkarSlot.morning
          ? 'وقت تذكير أذكار الصباح'
          : 'وقت تذكير أذكار المساء',
    );
    if (picked == null || !mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    await NotificationService.instance.setAdhkarReminder(slot, minutes: minutes);
    final cfg = await AdhkarRemindersStore.load(slot);
    if (mounted) setState(() => _cfg[slot] = cfg);
  }

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.wb_twilight_rounded, color: accent, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تذكير أذكار الصباح والمساء',
                        style: AppTextStyles.subheader(color: textColor)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'يصلك إشعار يومي بوقتك المحلي وتفتح الأذكار بالضغط عليه',
                      style: AppTextStyles.caption(color: subColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final slot in AdhkarSlot.values) ...[
            const Divider(height: 1),
            _row(slot, accent, textColor, subColor),
          ],
        ],
      ),
    );
  }

  Widget _row(AdhkarSlot slot, Color accent, Color textColor, Color subColor) {
    final cfg = _cfg[slot]!;
    final morning = slot == AdhkarSlot.morning;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: cfg.hour, minute: cfg.minute),
    );
    final hasLoc = PrayerTimesService.instance.hasLocation;
    final byPrayer = cfg.byPrayer && hasLoc;
    final anchor = morning ? 'الفجر' : 'العصر';
    final fixedRow = Row(
      children: [
        Icon(morning ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
            size: 20, color: accent),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(morning ? 'أذكار الصباح' : 'أذكار المساء',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(color: textColor)
                  .copyWith(fontWeight: FontWeight.w500)),
        ),
        if (!byPrayer)
          TextButton(
            onPressed: () => _pickTime(slot),
            style: TextButton.styleFrom(foregroundColor: accent),
            child: Text(time),
          ),
        Switch.adaptive(
          value: cfg.enabled,
          onChanged: _busy ? null : (v) => _toggle(slot, v),
          activeThumbColor: accent,
        ),
      ],
    );
    if (!hasLoc) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: fixedRow,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fixedRow,
          Row(
            children: [
              Expanded(
                child: Text('حسب الصلاة (بعد $anchor)',
                    style: AppTextStyles.caption(color: subColor)),
              ),
              Switch.adaptive(
                value: byPrayer,
                onChanged: (_busy || !cfg.enabled)
                    ? null
                    : (v) => _setByPrayer(slot, v),
                activeThumbColor: accent,
              ),
            ],
          ),
          if (byPrayer)
            Wrap(
              spacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('بعد الصلاة بـ', style: AppTextStyles.caption(color: subColor)),
                for (final m in AdhkarRemindersStore.offsetChoices)
                  ChoiceChip(
                    label: Text('${arDigits(m)} د'),
                    selected: cfg.offsetMin == m,
                    onSelected: _busy ? null : (_) => _setOffset(slot, m),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
