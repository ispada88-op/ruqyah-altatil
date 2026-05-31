import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/services/audio_player_service.dart';

/// صفحة الرقية الصوتية — تستخدم [AudioPlayerService] المركزية
/// (تشغيل في الخلفية + lock screen + mini player + حفظ الموضع).
class AudioRoqiaPage extends StatefulWidget {
  const AudioRoqiaPage({super.key});
  @override
  State<AudioRoqiaPage> createState() => _AudioRoqiaPageState();
}

class _AudioRoqiaPageState extends State<AudioRoqiaPage> {
  double _playbackSpeed = 1.0;

  AudioPlayerService get _svc => context.read<AudioPlayerService>();

  Future<void> _playPause() async {
    HapticFeedback.lightImpact();
    final svc = _svc;
    if (svc.isPlaying) {
      await svc.pause();
    } else {
      await svc.play();
    }
  }

  Future<void> _stopAudio() async {
    HapticFeedback.mediumImpact();
    await _svc.stop();
  }

  void _seekForward() {
    HapticFeedback.selectionClick();
    _svc.skipForward(const Duration(seconds: 10));
  }

  void _seekBackward() {
    HapticFeedback.selectionClick();
    _svc.skipBackward(const Duration(seconds: 10));
  }

  void _seekTo(double value) => _svc.seek(Duration(seconds: value.toInt()));

  void _changeSpeed(double speed) {
    HapticFeedback.lightImpact();
    setState(() => _playbackSpeed = speed);
    _svc.setSpeed(speed);
  }

  Future<void> _selectReciter(Reciter reciter) async {
    HapticFeedback.selectionClick();
    await _svc.loadReciter(reciter);
    await _svc.play();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
    }
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Widget _buildPlayButton(AudioPlayerService svc) {
    final isPlaying = svc.isPlaying;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _playPause,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkTeal, AppColors.accentGold]
                : [AppColors.primaryTeal, AppColors.accentGold],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: svc.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
      ),
    );
  }

  Widget _buildStopButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _stopAudio,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stop_circle_outlined,
              color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'إيقاف',
              style: TextStyle(
                color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewindButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _seekBackward,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSecondary : Colors.white)
              .withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.replay_10,
          size: 28,
          color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildForwardButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _seekForward,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSecondary : Colors.white)
              .withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.forward_10,
          size: 28,
          color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildLoopButton(AudioPlayerService svc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = svc.isLooping;
    final accent = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        svc.toggleLoop();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: active
              ? accent
              : (isDark ? AppColors.darkSecondary : Colors.white)
                  .withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: active ? Border.all(color: accent, width: 2) : null,
        ),
        child: Icon(
          Icons.repeat_one,
          size: 26,
          color: active ? Colors.white : accent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AudioPlayerService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final position = svc.position;
    final duration = svc.duration;
    final selectedReciter = svc.currentReciter;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.darkPrimary, AppColors.darkSurface]
              : [AppColors.backgroundCreamLight, AppColors.backgroundCream],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Circle container
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkTeal, AppColors.primaryTealDark]
                        : [AppColors.primaryTeal, AppColors.accentGold],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                          .withValues(alpha: 0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: svc.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          svc.isPlaying
                              ? Icons.music_note
                              : Icons.play_circle_outline,
                          size: 80,
                          color: Colors.white,
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'رقية التعطيل والسحر',
                style: AppTextStyles.header(
                  color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Sheikh name
              Text(
                selectedReciter.name,
                style: AppTextStyles.subheader(
                  color: isDark
                      ? AppColors.textOnDarkSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              // Error message
              if (svc.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          svc.errorMessage!,
                          style: AppTextStyles.caption(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      activeTrackColor:
                          isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                      inactiveTrackColor: (isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textTertiary)
                          .withValues(alpha: 0.3),
                      thumbColor:
                          isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                    ),
                    child: Slider(
                      value: position.inSeconds
                          .clamp(0, duration.inSeconds > 0 ? duration.inSeconds : 1)
                          .toDouble(),
                      min: 0,
                      max: duration.inSeconds > 0
                          ? duration.inSeconds.toDouble()
                          : 1,
                      onChanged: _seekTo,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.textOnDarkSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.textOnDarkSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoopButton(svc),
                  const SizedBox(width: AppSpacing.md),
                  _buildRewindButton(),
                  const SizedBox(width: AppSpacing.md),
                  _buildPlayButton(svc),
                  const SizedBox(width: AppSpacing.md),
                  _buildForwardButton(),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Stop button
              _buildStopButton(),

              const SizedBox(height: AppSpacing.lg),

              // Speed control
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSecondary : Colors.white)
                      .withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Text(
                      'سرعة التشغيل',
                      style: AppTextStyles.caption(
                        color: isDark
                            ? AppColors.textOnDarkSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
                        final isSelected = _playbackSpeed == speed;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              '${speed}x',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textOnDark
                                        : AppColors.textPrimary),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor:
                                isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.backgroundCream,
                            onSelected: (_) => _changeSpeed(speed),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Reciters list
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSecondary : Colors.white)
                      .withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر القارئ',
                      style: AppTextStyles.subheader(
                        color:
                            isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...kReciters.map((reciter) {
                      final isSelected = reciter.id == selectedReciter.id;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _selectReciter(reciter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                        ? AppColors.darkTeal
                                        : AppColors.primaryTeal)
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.darkTeal
                                      : AppColors.primaryTeal)
                                  : (isDark
                                          ? AppColors.textOnDarkSecondary
                                          : AppColors.textTertiary)
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDark
                                  ? AppColors.darkTeal
                                  : AppColors.primaryTeal,
                              child: Text(
                                reciter.name.substring(0, 1),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              reciter.name,
                              style: AppTextStyles.body(
                                  color: isDark
                                      ? AppColors.textOnDark
                                      : AppColors.textPrimary),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: isDark
                                        ? AppColors.darkTeal
                                        : AppColors.primaryTeal)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
