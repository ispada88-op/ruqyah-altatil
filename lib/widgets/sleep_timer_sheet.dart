import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roqia_altatil/services/audio_player_service.dart';
import 'package:roqia_altatil/theme.dart';

/// Bottom sheet لاختيار Sleep timer.
///
/// Usage:
/// ```dart
/// showSleepTimerSheet(context);
/// ```
Future<void> showSleepTimerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SleepTimerSheet(),
  );
}

class _SleepTimerSheet extends StatelessWidget {
  const _SleepTimerSheet();

  static const _options = [
    (5, '5 دقائق'),
    (15, '15 دقيقة'),
    (30, '30 دقيقة'),
    (60, 'ساعة'),
    (90, 'ساعة ونصف'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audio = context.watch<AudioPlayerService>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Center(
            child: Icon(
              Icons.bedtime,
              size: 32,
              color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'إيقاف تلقائي',
              style: AppTextStyles.subheader(
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
          ),
          if (audio.hasSleepTimer && audio.sleepRemaining != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                'الوقت المتبقي: ${_format(audio.sleepRemaining!)}',
                style: AppTextStyles.body(
                  color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ..._options.map((opt) {
            final mins = opt.$1;
            final label = opt.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  audio.startSleepTimer(Duration(minutes: mins));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('سيتم الإيقاف بعد $label'),
                      backgroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.backgroundCreamLight,
                  foregroundColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  elevation: 0,
                  side: BorderSide(
                    color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            );
          }),
          if (audio.hasSleepTimer)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('إلغاء المؤقت'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () {
                  audio.cancelSleepTimer();
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
