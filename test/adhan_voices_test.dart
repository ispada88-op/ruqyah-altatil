// أصوات الأذان: ملفاتها موجودة بالأسماء التي يطلبها الإشعار، ومقطع iOS ≤ ٣٠ث،
// والاختيار يُحفظ ويُستعاد.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/adhan_voices.dart';
import 'package:roqia_altatil/services/prayer_reminders.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every voice ships its iOS clip and Android raw sound', () {
    for (final v in AdhanVoice.values) {
      if (v == AdhanVoice.none) continue;
      final clip = File(v.clipAsset);
      expect(clip.existsSync(), isTrue, reason: v.clipAsset);
      expect(File(v.fullAsset).existsSync(), isTrue, reason: v.fullAsset);
      final raw = File('android/app/src/main/res/raw/${v.androidRaw}.mp3');
      expect(raw.existsSync(), isTrue, reason: raw.path);
      // wav PCM: ‏byteRate عند الإزاحة ٢٨؛ المدة = (الحجم − ٤٤) / byteRate.
      final b = clip.readAsBytesSync();
      expect(String.fromCharCodes(b.sublist(0, 4)), 'RIFF');
      final byteRate =
          b[28] | (b[29] << 8) | (b[30] << 16) | (b[31] << 24);
      final seconds = (b.length - 44) / byteRate;
      expect(seconds, lessThanOrEqualTo(30), reason: '${v.id} iOS limit');
      expect(seconds, greaterThan(10), reason: '${v.id} too short');
    }
  });

  test('ids are stable and unknown ids fall back to none', () {
    expect(AdhanVoice.byId('qassas'), AdhanVoice.qassas);
    expect(AdhanVoice.byId('gone'), AdhanVoice.none);
    expect(AdhanVoice.byId(null), AdhanVoice.none);
  });

  test('selected voice persists', () async {
    SharedPreferences.setMockInitialValues({});
    await PrayerRemindersStore.save(
        const PrayerReminderConfig(adhanVoice: AdhanVoice.qassas));
    expect((await PrayerRemindersStore.load()).adhanVoice, AdhanVoice.qassas);
    expect(const PrayerReminderConfig().adhanVoice, AdhanVoice.none);
  });
}
