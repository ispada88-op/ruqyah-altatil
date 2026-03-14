import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// [title] and [artist] are shown on lock screen and in notification (background playback).
Future<void> switchReciterAudio({
  required AudioPlayer player,
  required String audioPath,
  bool autoPlay = true,
  Duration timeout = const Duration(seconds: 30),
  String? title,
  String? artist,
}) async {
  try {
    await player.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    final mediaItem = MediaItem(
      id: audioPath,
      title: title ?? 'رقية التعطيل والسحر — الشيخ فهد القرني',
      artist: artist ?? '',
    );

    AudioSource source;
    if (audioPath.startsWith('http')) {
      source = AudioSource.uri(Uri.parse(audioPath), tag: mediaItem);
    } else {
      source = AudioSource.asset(audioPath, tag: mediaItem);
    }

    await player.setAudioSource(source, preload: true).timeout(
      timeout,
      onTimeout: () {
        throw Exception('تأخر التحميل - تأكد من اتصالك بالإنترنت');
      },
    );
    
    if (autoPlay) {
      await player.play();
    }
    
    if (kDebugMode) debugPrint('✅ Audio switched successfully: $audioPath');
  } on PlayerException catch (e) {
    if (kDebugMode) debugPrint('❌ Audio Player Error: ${e.message}');
    rethrow;
  } catch (e) {
    if (kDebugMode) debugPrint('❌ Unexpected Error in switchReciterAudio: $e');
    rethrow;
  }
}
