import 'package:flutter/material.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/theme.dart';

/// بطاقة إعدادات الإشعارات - تُستخدم في home_page أو في صفحة الأذكار.
class NotificationsSettingsCard extends StatefulWidget {
  const NotificationsSettingsCard({super.key});

  @override
  State<NotificationsSettingsCard> createState() => _NotificationsSettingsCardState();
}

class _NotificationsSettingsCardState extends State<NotificationsSettingsCard> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final enabled = await NotificationService.instance.isEnabled;
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      // طلب الإذن أولاً
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
              ? 'تم تفعيل تذكيرات الأذكار كل 3 ساعات ✅'
              : 'تم إيقاف التذكيرات'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
      child: Row(
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
                  'إشعار كل 3 ساعات بذكر أو دعاء (يُحترم وقت النوم)',
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
    );
  }
}
