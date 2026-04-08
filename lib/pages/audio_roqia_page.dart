import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/main.dart';

class ReciterModel {
  final String name;
  final String localAsset;
  const ReciterModel({
    required this.name,
    required this.localAsset,
  });
}

class AudioRoqiaPage extends StatefulWidget {
  const AudioRoqiaPage({super.key});
  @override
  State<AudioRoqiaPage> createState() => _AudioRoqiaPageState();
}

class _AudioRoqiaPageState extends State<AudioRoqiaPage> {
  final AudioPlayer _audioPlayer = appAudioPlayer;
  String _selectedSheikh = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  bool _isSwitching = false;
  double _playbackSpeed = 1.0;
  String? _errorMessage;

  final List<ReciterModel> _reciters = const [
    ReciterModel(
      name: 'الشيخ ماهر المعيقلي',
      localAsset: 'assets/audio/maher_almuaiqly.mp3',
    ),
    ReciterModel(
      name: 'الشيخ سعد الغامدي',
      localAsset: 'assets/audio/saad_alghamdi.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSheikh = _reciters[0].name;
    debugPrint('🟡 AudioRoqiaPage.initState');

    // Configure audio session for background playback
    _initAudioSession();

    _audioPlayer.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => _position = Duration.zero);
      }
      if (mounted) setState(() {});
    });
    _audioPlayer.playingStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    debugPrint('✅ AudioSession configured');
  }

  Future<void> _loadAudio(ReciterModel reciter) async {
    debugPrint('🟡 _loadAudio ENTERED: ${reciter.name}');

    if (_isSwitching) {
      debugPrint('🔴 _loadAudio SKIPPED - _isSwitching=true');
      return;
    }

    setState(() {
      _isSwitching = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🟡 _loadAudio: loading ${reciter.localAsset}');
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(AudioSource.asset(reciter.localAsset));
      await _audioPlayer.play();
      await WakelockPlus.enable();
      debugPrint('🟢 _loadAudio SUCCESS for ${reciter.name}');
    } catch (e, stack) {
      debugPrint('🔴 _loadAudio FAILED: $e');
      debugPrint('🔴 STACK: $stack');
      if (mounted) {
        setState(() => _errorMessage = 'خطأ: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSwitching = false;
        });
      }
    }
  }

  Future<void> _playPause() async {
    debugPrint('🟢 _playPause ENTERED');

    if (_isLoading || _isSwitching) {
      debugPrint('🔴 _playPause BLOCKED');
      return;
    }

    if (!mounted) return;

    HapticFeedback.lightImpact();

    if (_audioPlayer.processingState == ProcessingState.idle ||
        _audioPlayer.processingState == ProcessingState.completed) {
      debugPrint('🟡 _playPause: State idle/completed - loading audio');
      final reciter = _reciters.firstWhere((r) => r.name == _selectedSheikh);
      await _loadAudio(reciter);
    } else if (_audioPlayer.playing) {
      debugPrint('🟡 _playPause: Pausing...');
      await _audioPlayer.pause();
      if (mounted) setState(() {});
    } else {
      debugPrint('🟡 _playPause: Resuming...');
      await _audioPlayer.play();
      if (mounted) setState(() {});
    }

    debugPrint('🟢 _playPause FINISHED');
  }

  Future<void> _stopAudio() async {
    debugPrint('🟡 _stopAudio ENTERED');
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    try {
      await _audioPlayer.stop();
      await WakelockPlus.disable();
      debugPrint('🟢 _stopAudio SUCCESS');
    } catch (e) {
      debugPrint('🔴 _stopAudio ERROR: $e');
    }
    if (!mounted) return;
    setState(() => _position = Duration.zero);
  }

  void _seekForward() {
    final n = _position + const Duration(seconds: 10);
    _audioPlayer.seek(n > _duration ? _duration : n);
  }

  void _seekBackward() {
    final n = _position - const Duration(seconds: 10);
    _audioPlayer.seek(n < Duration.zero ? Duration.zero : n);
  }

  void _seekTo(double value) => _audioPlayer.seek(Duration(seconds: value.toInt()));

  void _changeSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _audioPlayer.setSpeed(speed);
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
    }
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Widget _buildPlayButton() {
    final isPlaying = _audioPlayer.playing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('🟢 PLAY BUTTON TAPPED!');
        _playPause();
      },
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
        child: _isLoading
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
      onTap: () {
        debugPrint('🟢 STOP BUTTON TAPPED!');
        _stopAudio();
      },
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
      onTap: () {
        debugPrint('🟢 REWIND BUTTON TAPPED!');
        _seekBackward();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSecondary : Colors.white).withValues(alpha: 0.8),
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
      onTap: () {
        debugPrint('🟢 FORWARD BUTTON TAPPED!');
        _seekForward();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSecondary : Colors.white).withValues(alpha: 0.8),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          _audioPlayer.playing ? Icons.music_note : Icons.play_circle_outline,
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
                _selectedSheikh,
                style: AppTextStyles.subheader(
                  color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              // Error message
              if (_errorMessage != null) ...[
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
                          _errorMessage!,
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
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      activeTrackColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                      inactiveTrackColor:
                          (isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary)
                              .withValues(alpha: 0.3),
                      thumbColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      min: 0,
                      max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
                      onChanged: _seekTo,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: AppTextStyles.caption(
                            color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: AppTextStyles.caption(
                            color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
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
                  _buildRewindButton(),
                  const SizedBox(width: AppSpacing.md),
                  _buildPlayButton(),
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
                  color: (isDark ? AppColors.darkSecondary : Colors.white).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Text(
                      'سرعة التشغيل',
                      style: AppTextStyles.caption(
                        color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
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
                                    : (isDark ? AppColors.textOnDark : AppColors.textPrimary),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                            backgroundColor:
                                isDark ? AppColors.darkSurface : AppColors.backgroundCream,
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
                  color: (isDark ? AppColors.darkSecondary : Colors.white).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر القارئ',
                      style: AppTextStyles.subheader(
                        color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._reciters.map((reciter) {
                      final isSelected = reciter.name == _selectedSheikh;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          debugPrint('🟢 RECITER TAPPED: ${reciter.name}');
                          if (reciter.name != _selectedSheikh) {
                            setState(() => _selectedSheikh = reciter.name);
                            await _loadAudio(reciter);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.darkTeal : AppColors.primaryTeal).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                                  : (isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary)
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                              child: Text(
                                reciter.name.substring(0, 1),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              reciter.name,
                              style: AppTextStyles.body(color: isDark ? AppColors.textOnDark : AppColors.textPrimary),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: isDark ? AppColors.darkTeal : AppColors.primaryTeal)
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
