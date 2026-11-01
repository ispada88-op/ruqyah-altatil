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

  test('full-adhan segments exist, fit the iOS 30 s limit and match segmentSecs', () {
    for (final v in AdhanVoice.values) {
      if (v == AdhanVoice.none) {
        expect(v.segmentCount, 0);
        continue;
      }
      expect(v.segmentCount, greaterThan(3), reason: v.id);
      var total = 0.0;
      for (var n = 1; n <= v.segmentCount; n++) {
        final f = File(v.segmentAsset(n));
        expect(f.existsSync(), isTrue, reason: v.segmentAsset(n));
        final b = f.readAsBytesSync();
        expect(String.fromCharCodes(b.sublist(0, 4)), 'RIFF');
        final byteRate = b[28] | (b[29] << 8) | (b[30] << 16) | (b[31] << 24);
        final sec = (b.length - 44) / byteRate;
        expect(sec, lessThanOrEqualTo(29), reason: '${v.id}#$n iOS limit');
        expect(sec, closeTo(v.segmentSecs[n - 1], 0.1), reason: '${v.id}#$n');
        total += sec;
      }
      // مجموع المقاطع ≈ الأذان الكامل (الـmp3 أطول من ٣٠ث بكثير).
      expect(total, greaterThan(100), reason: v.id);
    }
  });

  test('Fajr chain fits the pending-notification budget', () {
    for (final v in AdhanVoice.values) {
      if (v == AdhanVoice.none) continue;
      expect((v.segmentCount - 1) * kAdhanChainDays, lessThanOrEqualTo(24));
    }
    // IDs السلسلة فوق آخر ID لتنبيهات الصلاة (١٠٠٠ + ٧ أيام × ١٦ خانة).
    expect(kAdhanChainIdBase, greaterThan(1000 + 7 * 16));
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
