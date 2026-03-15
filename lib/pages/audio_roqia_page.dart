import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/custom_actions/switch_reciter_audio.dart';

class AudioRoqiaPage extends StatefulWidget {
  const AudioRoqiaPage({super.key});

  @override
  State<AudioRoqiaPage> createState() => _AudioRoqiaPageState();
}

class _AudioRoqiaPageState extends State<AudioRoqiaPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedSheikh = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  bool _isSwitching = false;
  double _playbackSpeed = 1.0;
  String? _errorMessage;

  final List<ReciterModel> _reciters = [
    ReciterModel(
      name: 'الشيخ ماهر المعيقلي',
      localAsset: 'assets/audio/maher_almuaiqly.mp3',
      fallbackUrl: 'https://server8.mp3quran.net/afs/001.mp3',
    ),
    ReciterModel(
      name: 'الشيخ سعد الغامدي',
      localAsset: 'assets/audio/saad_alghamdi.mp3',
      fallbackUrl: 'https://archive.org/download/SurahFatehaAbdulRahmanSudais/Sheikh_Saad_Al-Ghamdi_Ruqya.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSheikh = _reciters[0].name;

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) setState(() => _duration = duration ?? Duration.zero);
    });
    _audioPlayer.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _position = Duration.zero);
      }
    });

    // التطبيق مجاني — لا بوابة اشتراك
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Loads and optionally starts playback for the given reciter.
  /// Uses the switchReciterAudio Custom Action so one source of truth for stop/load/play and timeout.
  Future<void> _loadAudio(ReciterModel reciter) async {
    if (_isSwitching) return;

    setState(() {
      _isSwitching = true;
      _isLoading = true;
      _errorMessage = null;
    });

    // Prefer local asset; fall back to URL so switchReciterAudio gets a single path.
    final audioPath = reciter.localAsset.isNotEmpty
        ? reciter.localAsset
        : reciter.fallbackUrl;

    try {
      await switchReciterAudio(
        player: _audioPlayer,
        audioPath: audioPath,
        autoPlay: true,
        timeout: const Duration(seconds: 30),
        title: 'رقية التعطيل والسحر — الشيخ فهد القرني',
        artist: reciter.name,
      );
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ خطأ في تحميل الملف: $e');
      if (reciter.localAsset.isNotEmpty && reciter.fallbackUrl.isNotEmpty) {
        try {
          await switchReciterAudio(
            player: _audioPlayer,
            audioPath: reciter.fallbackUrl,
            autoPlay: true,
            timeout: const Duration(seconds: 30),
            title: 'رقية التعطيل والسحر — الشيخ فهد القرني',
            artist: reciter.name,
          );
          HapticFeedback.mediumImpact();
        } catch (e2) {
          if (kDebugMode) debugPrint('❌ خطأ في الرابط الاحتياطي: $e2');
          if (mounted) setState(() => _errorMessage = 'فشل تحميل الملف الصوتي. يرجى المحاولة مرة أخرى.');
          HapticFeedback.heavyImpact();
        }
      } else {
        if (mounted) setState(() => _errorMessage = 'فشل تحميل الملف الصوتي. يرجى المحاولة مرة أخرى.');
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
          _isLoading = false;
        });
      }
    }
  }

  void _playPause() async {
    if (_isLoading) return;
    
    HapticFeedback.lightImpact();
    
    if (_audioPlayer.processingState == ProcessingState.idle || 
        _audioPlayer.processingState == ProcessingState.completed) {
      final reciter = _reciters.firstWhere((r) => r.name == _selectedSheikh);
      await _loadAudio(reciter);
    } else if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      if (mounted) setState(() {});
    } else {
      await _audioPlayer.play();
      if (mounted) setState(() {});
    }
  }

  void _stopAudio() async {
    HapticFeedback.mediumImpact();
    await _audioPlayer.stop();
    if (mounted) setState(() => _position = Duration.zero);
  }

  void _seekForward() {
    HapticFeedback.selectionClick();
    final newPosition = _position + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
  }

  void _seekBackward() {
    HapticFeedback.selectionClick();
    final newPosition = _position - const Duration(seconds: 10);
    _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _seekTo(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  void _changeSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _audioPlayer.setSpeed(speed);
    HapticFeedback.selectionClick();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _duration.inSeconds > 0 ? _position.inSeconds / _duration.inSeconds : 0.0;
    
    return Scaffold(
      body: Container(
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
                
                // Album Art / Visualization
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated rings
                      if (_audioPlayer.playing) ...[
                        _PulseRing(delay: 0, isDark: isDark),
                        _PulseRing(delay: 500, isDark: isDark),
                        _PulseRing(delay: 1000, isDark: isDark),
                      ],
                      
                      // Center Icon
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isLoading
                              ? Icons.hourglass_empty
                              : _audioPlayer.playing
                                  ? Icons.music_note
                                  : Icons.play_circle_outline,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Title
                Text(
                  'رقية التعطيل والسحر — الشيخ فهد القرني',
                  style: AppTextStyles.header(
                    color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _selectedSheikh,
                  style: AppTextStyles.subheader(
                    color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Reciter Selection
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSecondary : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر القارئ:',
                        style: AppTextStyles.subheader(
                          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ..._reciters.map((reciter) => _ReciterTile(
                        reciter: reciter,
                        isSelected: _selectedSheikh == reciter.name,
                        // Changing reciter: stop current, update selection, then load new
                        // source and start playback via switchReciterAudio inside _loadAudio.
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (_selectedSheikh == reciter.name) return;
                          _audioPlayer.stop();
                          setState(() {
                            _selectedSheikh = reciter.name;
                            _position = Duration.zero;
                            _errorMessage = null;
                          });
                          _loadAudio(reciter);
                        },
                        isDark: isDark,
                      )),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: AppSpacing.paddingMd,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.body(color: AppColors.error),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final reciter = _reciters.firstWhere((r) => r.name == _selectedSheikh);
                            _loadAudio(reciter);
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                
                // Progress Bar
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSecondary : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Background track
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          // Progress track: FractionallySizedBox is not in Flutter SDK; use
                          // LayoutBuilder + SizedBox to size the fill by progress (same visual).
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final fillWidth = constraints.maxWidth * progress;
                              return SizedBox(
                                width: fillWidth,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [AppColors.darkTeal, AppColors.accentGold]
                                          : [AppColors.primaryTeal, AppColors.accentGold],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Slider (invisible but functional)
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: isDark ? AppColors.darkTeal : AppColors.accentGold,
                              overlayColor: (isDark ? AppColors.darkTeal : AppColors.accentGold)
                                  .withValues(alpha: 0.2),
                            ),
                            child: Slider(
                              value: _position.inSeconds.toDouble(),
                              max: _duration.inSeconds.toDouble() > 0
                                  ? _duration.inSeconds.toDouble()
                                  : 1,
                              onChanged: _seekTo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
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
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Playback Speed Control
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSecondary : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'السرعة:',
                        style: AppTextStyles.body(
                          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                        ),
                      ),
                      ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                        final isSelected = _playbackSpeed == speed;
                        return InkWell(
                          onTap: () => _changeSpeed(speed),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${speed}x',
                              style: AppTextStyles.caption(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlButton(
                      icon: Icons.replay_10,
                      onPressed: _seekBackward,
                      size: 56,
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _PlayButton(
                      isPlaying: _audioPlayer.playing,
                      isLoading: _isLoading,
                      onPressed: _playPause,
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _ControlButton(
                      icon: Icons.forward_10,
                      onPressed: _seekForward,
                      size: 56,
                      isDark: isDark,
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Stop Button
                TextButton.icon(
                  onPressed: _stopAudio,
                  icon: const Icon(Icons.stop),
                  label: const Text('إيقاف'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Application Instructions Section
                _ApplicationMethodCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Duas Section
                _DuasCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 900.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Source Attribution
                Container(
                  padding: AppSpacing.paddingSm,
                  child: Text(
                    'المصدر: الشيخ فهد القرني — رقية التعطيل',
                    style: AppTextStyles.caption(
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 1000.ms),
                
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Application Method Card
class _ApplicationMethodCard extends StatelessWidget {
  final bool isDark;

  const _ApplicationMethodCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF1E4D2B).withValues(alpha: 0.6),
                  const Color(0xFF2C5530).withValues(alpha: 0.4),
                ]
              : [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFF1F8E9),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.accentGold.withValues(alpha: 0.3)
              : const Color(0xFF81C784).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accentGold.withValues(alpha: 0.2)
                      : const Color(0xFF66BB6A).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  color: isDark ? AppColors.accentGold : const Color(0xFF388E3C),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '🌿 طريقة التطبيق',
                  style: AppTextStyles.subheader(
                    color: isDark ? AppColors.textOnDark : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildStepItem(
            '١- يجب أن يكون الشخص طاهراً',
            isDark,
          ),
          _buildStepItem(
            '٢- قراءة السور يومياً معاً بدون انقطاع (يمكن استبدال القراءة بالاستماع للمقاطع الصوتية أعلاه)',
            isDark,
          ),
          _buildStepItem(
            '٣- يمكن قراءة السور على كمية من الماء والنفث فيه',
            isDark,
          ),
          _buildStepItem(
            '٤- من ثم شرب الماء المقروء عليه والاغتسال به يومياً',
            isDark,
          ),
          _buildStepItem(
            '٥- الاغتسال كامل الجسد أو استخدام بخاخ يوضع به الماء ويُبخّ به الجسد بدءاً من منابت الشعر إلى الأقدام',
            isDark,
          ),
          _buildStepItem(
            '٦- لا مانع من زيادة الماء إذا نقص، واستمر في هذه الخطوات حتى حدوث الشفاء بإذن الله',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, left: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.accentGold : const Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body(
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

// Duas Card
class _DuasCard extends StatelessWidget {
  final bool isDark;

  const _DuasCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final duas = [
      'اللهم إني أعوذ بك من كل معطل، ومن كل مبطل، ومن كل ممانعة، ومن كل معصية، ومن كل ظلم، ومن كل بغي، ومن كل عدو، ومن كل كيد، ومن كل حسد، ومن كل عين حاسدة',
      'اللهم إني أعوذ بك من شر كل ذي شر، ومن شر كل ذي عين حاسدة، وشر كل لسان ناطق، وشر كل ذي بلغة ناطقة، وشر كل ذي مكر مكيد، وشر كل ذي قلب مريد، وشر كل ذي نية حاقدة، وشر كل ذي نفس ساخطة',
    ];

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  AppColors.accentGold.withValues(alpha: 0.15),
                  AppColors.darkTeal.withValues(alpha: 0.2),
                ]
              : [
                  const Color(0xFFFFF8E1),
                  const Color(0xFFFFF9C4).withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.accentGold.withValues(alpha: 0.4)
              : AppColors.accentGold.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: AppColors.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '🤲 أدعية إزالة التعطيل',
                  style: AppTextStyles.subheader(
                    color: isDark ? AppColors.textOnDark : AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...duas.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final dua = entry.value;
            return _DuaItem(
              number: index,
              text: dua,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }
}

// Individual Dua Item
class _DuaItem extends StatelessWidget {
  final int number;
  final String text;
  final bool isDark;

  const _DuaItem({
    required this.number,
    required this.text,
    required this.isDark,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ الدعاء'),
        duration: const Duration(seconds: 2),
        backgroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondary.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.accentGold : AppColors.accentGold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: AppTextStyles.caption(
                      color: isDark ? AppColors.darkPrimary : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'الدعاء $number',
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.accentGold : AppColors.accentGold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => _copyToClipboard(context),
                color: isDark ? AppColors.accentGold : AppColors.accentGold,
                tooltip: 'نسخ',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.body(
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

// Pulse ring animation for playing state
class _PulseRing extends StatelessWidget {
  final int delay;
  final bool isDark;
  
  const _PulseRing({required this.delay, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeOut(delay: delay.ms, duration: 2000.ms)
        .scale(delay: delay.ms, duration: 2000.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1));
  }
}

class _ReciterTile extends StatelessWidget {
  final ReciterModel reciter;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ReciterTile({
    required this.reciter,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? [AppColors.darkTeal, AppColors.primaryTealDark]
                        : [AppColors.primaryTeal, AppColors.primaryTealLight],
                  )
                : null,
            color: isSelected ? null : (isDark ? AppColors.darkSurface : AppColors.backgroundCream),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? AppColors.darkTeal : AppColors.primaryTeal).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTeal : AppColors.primaryTeal),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  reciter.name,
                  style: AppTextStyles.body(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textOnDark : AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isDark;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
        iconSize: 28,
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isDark;

  const _PlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: onPressed,
              color: Colors.white,
              iconSize: 40,
            ),
    );
  }
}

class ReciterModel {
  final String name;
  final String localAsset;
  final String fallbackUrl;

  ReciterModel({
    required this.name,
    required this.localAsset,
    required this.fallbackUrl,
  });
}
