import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/theme.dart';

/// بطاقة إعدادات الإشعارات - مع خيار الفترة (3 أو 5 ساعات).
class NotificationsSettingsCard extends StatefulWidget {
  const NotificationsSettingsCard({super.key});

  @override
  State<NotificationsSettingsCard> createState() => _NotificationsSettingsCardState();
}

class _NotificationsSettingsCardState extends State<NotificationsSettingsCard> {
  bool _enabled = false;
  int _intervalHours = 3;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final enabled = await NotificationService.instance.isEnabled;
    final interval = await NotificationService.instance.intervalHours;
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _intervalHours = interval;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    HapticFeedback.lightImpact();
    if (value) {
      setState(() => _loading = true);
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم منح إذن الإشعارات. تأكد من إعدادات الجهاز.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }
    }

    await NotificationService.instance.setEnabled(value);
    if (mounted) {
      setState(() {
        _enabled = value;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'تم تفعيل تذكيرات الأذكار كل $_intervalHours ساعات ✅'
              : 'تم إيقاف التذكيرات'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changeInterval(int hours) async {
    if (hours == _intervalHours) return;
    HapticFeedback.selectionClick();
    setState(() => _intervalHours = hours);
    await NotificationService.instance.setIntervalHours(hours);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkTeal, AppColors.accentGold]
                        : [AppColors.primaryTeal, AppColors.accentGold],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكير الأذكار',
                      style: AppTextStyles.subheader(
                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'أذكار من حصن المسلم + تذكير يومي بالرقية (8م)',
                      style: AppTextStyles.caption(
                        color: isDark
                            ? AppColors.textOnDarkSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: _enabled,
                  onChanged: _toggle,
                  activeThumbColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                ),
            ],
          ),
          // اختيار الفترة - يظهر فقط لو مُفعّل
          if (_enabled) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'الفترة بين كل تذكير:',
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('كل 3 ساعات')),
                ButtonSegment(value: 5, label: Text('كل 5 ساعات')),
              ],
              selected: {_intervalHours},
              onSelectionChanged: (set) => _changeInterval(set.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _intervalHours == 3
                  ? '5 تذكيرات/يوم • وقت النوم محترم (10م-7ص)'
                  : '3 تذكيرات/يوم • وقت النوم محترم (10م-7ص)',
              style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.textTertiary,
              ).copyWith(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            // زر اختبار
            TextButton.icon(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await NotificationService.instance.showTest();
              },
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('اختبار الإشعار الآن'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
