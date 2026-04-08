import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

Future<void> switchReciterAudio({
  required AudioPlayer player,
  required String audioPath,
  bool autoPlay = true,
  String? title,
  String? artist,
}) async {
  try {
    var key = audioPath.trim();
    if (key.startsWith('asset:///')) key = key.substring('asset:///'.length);
    if (key.startsWith('/')) key = key.substring(1);

    await player.stop();
    await player.setAudioSource(AudioSource.asset(key));
    
    if (autoPlay) await player.play();

    debugPrint('✅ Audio switched: $key');
  } catch (e) {
    debugPrint('❌ switchReciterAudio error: $e');
    rethrow;
  }
}
