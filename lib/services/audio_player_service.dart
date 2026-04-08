import 'package:just_audio/just_audio.dart';
import '../main.dart';

class AudioPlayerService {
  AudioPlayerService._();
  static AudioPlayerService? _instance;
  static AudioPlayerService get instance {
    _instance ??= AudioPlayerService._();
    return _instance!;
  }

  AudioPlayer get player => appAudioPlayer;
}
