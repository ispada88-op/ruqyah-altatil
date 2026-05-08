import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

/// نموذج القارئ.
class Reciter {
  final String id;
  final String name;
  final String localAsset;
  const Reciter({required this.id, required this.name, required this.localAsset});
}

const List<Reciter> kReciters = [
  Reciter(
    id: 'maher',
    name: 'الشيخ ماهر المعيقلي',
    localAsset: 'assets/audio/maher_almuaiqly.mp3',
  ),
  Reciter(
    id: 'saad',
    name: 'الشيخ سعد الغامدي',
    localAsset: 'assets/audio/saad_alghamdi.mp3',
  ),
];

/// خدمة تشغيل الصوت — يستخدمها الـ UI كاملاً.
///
/// مميزات:
/// - تشغيل في الخلفية (lock screen + notification controls)
/// - حفظ آخر موضع تلقائياً
/// - Sleep timer
/// - يصرّح عن الحالة عبر `ChangeNotifier` للـ UI
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  static const _kLastReciterKey = 'audio_last_reciter_id';
  static const _kLastPositionKey = 'audio_last_position_sec';

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Reciter _currentReciter = kReciters.first;
  Reciter get currentReciter => _currentReciter;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _errorMessage;

  Duration get duration => _duration;
  Duration get position => _position;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  bool get isPlaying => _player.playing;
  String? get errorMessage => _errorMessage;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // ─────────── Sleep timer ───────────
  Timer? _sleepTimer;
  Duration? _sleepRemaining;
  Duration? get sleepRemaining => _sleepRemaining;
  bool get hasSleepTimer => _sleepTimer != null;

  // ─────────── Initialization ───────────
  bool _initialized = false;
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });
    _player.positionStream.listen((p) {
      _position = p;
      // persist every 5 seconds
      if (p.inSeconds % 5 == 0) _persistPosition();
      notifyListeners();
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _position = Duration.zero;
        _persistPosition();
      }
      notifyListeners();
    });

    // Auto-restore last reciter
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString(_kLastReciterKey);
      if (lastId != null) {
        _currentReciter = kReciters.firstWhere(
          (r) => r.id == lastId,
          orElse: () => kReciters.first,
        );
      }
    } catch (_) {/* fallback to default */}
  }

  // ─────────── Loading ───────────
  Future<void> loadReciter(Reciter reciter, {bool restorePosition = true}) async {
    _isLoading = true;
    _isLoaded = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await _player.stop();
      _currentReciter = reciter;

      // MediaItem makes the player surface in lock-screen / notification.
      await _player.setAudioSource(
        AudioSource.asset(
          reciter.localAsset,
          tag: MediaItem(
            id: reciter.id,
            album: 'رقية التعطيل',
            title: 'الرقية الشرعية',
            artist: reciter.name,
          ),
        ),
      );

      // Restore last position if available and < 90% of duration.
      if (restorePosition) {
        final prefs = await SharedPreferences.getInstance();
        final lastPos = prefs.getInt('${_kLastPositionKey}_${reciter.id}');
        if (lastPos != null && lastPos > 5) {
          final dur = _player.duration ?? Duration.zero;
          if (dur.inSeconds == 0 || lastPos < dur.inSeconds * 0.9) {
            await _player.seek(Duration(seconds: lastPos));
          }
        }
      }

      // Persist current reciter
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastReciterKey, reciter.id);

      _isLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'AudioPlayerService.loadReciter');
      _errorMessage = 'تعذّر تحميل الصوت. تأكد من وجود الملف وأعد المحاولة.';
      _isLoading = false;
      _isLoaded = false;
      notifyListeners();
    }
  }

  // ─────────── Controls ───────────
  Future<void> play() async {
    try {
      if (!_isLoaded) await loadReciter(_currentReciter);
      await _player.play();
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'play');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _persistPosition();
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'pause');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _position = Duration.zero;
      _isLoaded = false;
      _persistPosition();
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'stop');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      _persistPosition();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'seek');
    }
  }

  Future<void> skipForward([Duration delta = const Duration(seconds: 30)]) async {
    final target = _position + delta;
    final maxDur = _duration;
    await seek(target < maxDur ? target : maxDur);
  }

  Future<void> skipBackward([Duration delta = const Duration(seconds: 10)]) async {
    final target = _position - delta;
    await seek(target > Duration.zero ? target : Duration.zero);
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed.clamp(0.5, 2.0));
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'setSpeed');
    }
  }

  // ─────────── Sleep timer ───────────
  void startSleepTimer(Duration duration) {
    cancelSleepTimer();
    _sleepRemaining = duration;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepRemaining == null) {
        timer.cancel();
        return;
      }
      _sleepRemaining = _sleepRemaining! - const Duration(seconds: 1);
      if (_sleepRemaining! <= Duration.zero) {
        timer.cancel();
        _sleepTimer = null;
        _sleepRemaining = null;
        pause();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepRemaining = null;
    notifyListeners();
  }

  // ─────────── Persistence ───────────
  Future<void> _persistPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        '${_kLastPositionKey}_${_currentReciter.id}',
        _position.inSeconds,
      );
    } catch (_) {/* best-effort */}
  }

  @override
  void dispose() {
    cancelSleepTimer();
    _player.dispose();
    super.dispose();
  }
}
