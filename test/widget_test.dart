import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/audio_player_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Reciter catalogue is non-empty and well-formed', () {
    expect(kReciters, isNotEmpty);
    for (final r in kReciters) {
      expect(r.id, isNotEmpty);
      expect(r.name, isNotEmpty);
      expect(r.localAsset.endsWith('.mp3'), isTrue);
    }
  });
}
