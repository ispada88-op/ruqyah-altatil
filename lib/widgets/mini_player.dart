import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roqia_altatil/services/audio_player_service.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/theme.dart';

/// شريط مصغّر يظهر فوق الـ bottom navigation عند تشغيل الصوت.
/// يسمح بالتحكم في التشغيل من أي صفحة.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, _) {
        // اخفاء إذا ما فيه صوت محمّل
        if (!audio.isLoaded && !audio.isLoading) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final progress = audio.duration.inMilliseconds == 0
            ? 0.0
            : audio.position.inMilliseconds / audio.duration.inMilliseconds;

        return Material(
          elevation: 8,
          color: isDark ? AppColors.darkSecondary : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط تقدم رفيع
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 2,
                backgroundColor: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                    .withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    // أيقونة
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkTeal, AppColors.accentGold]
                              : [AppColors.primaryTeal, AppColors.accentGold],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.headphones,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // اسم القارئ + الموضع
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audio.currentReciter.name,
                            style: AppTextStyles.caption(
                              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                            ).copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_format(audio.position)} / ${_format(audio.duration)}'
                            '${audio.sleepRemaining != null ? "  •  ⏰ ${_format(audio.sleepRemaining!)}" : ""}',
                            style: AppTextStyles.caption(
                              color: isDark
                                  ? AppColors.textOnDarkSecondary
                                  : AppColors.textSecondary,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // زر -10s
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () { Haptic.select(); audio.skipBackward(); },
                      iconSize: 22,
                      color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                      visualDensity: VisualDensity.compact,
                    ),
                    // زر تشغيل/إيقاف
                    IconButton(
                      icon: Icon(
                        audio.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      onPressed: audio.isLoading
                          ? null
                          : () { Haptic.medium(); audio.isPlaying ? audio.pause() : audio.play(); },
                      iconSize: 36,
                      color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                    ),
                    // زر +30s
                    IconButton(
                      icon: const Icon(Icons.forward_30),
                      onPressed: () { Haptic.select(); audio.skipForward(); },
                      iconSize: 22,
                      color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
