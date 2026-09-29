import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/quran_data.dart';
import 'package:roqia_altatil/data/verified_quran.dart';
import 'package:roqia_altatil/services/quran_repository.dart';

/// Structural integrity checks for the Quran text used in the app.
/// These guard against missing/duplicated/empty verses (a content-safety
/// regression guard). Orthography itself is sourced from the KFGQPC Hafs text.
void main() {
  group('Long surahs (quran_data.dart) — exact ayah counts', () {
    test('Al-Anfal has 75 verses', () => expect(anfalVerses.length, 75));
    test('Ad-Dukhan has 59 verses', () => expect(dukhanVerses.length, 59));
    test('As-Saffat has 182 verses', () => expect(saffatVerses.length, 182));
    test('Al-Haqqah has 52 verses', () => expect(haqqaVerses.length, 52));

    test('No empty verses', () {
      for (final list in [anfalVerses, dukhanVerses, saffatVerses, haqqaVerses]) {
        for (final v in list) {
          expect(v.trim(), isNotEmpty);
        }
      }
    });
  });

  group('Verified short surahs (verified_quran.dart) — Uthmani', () {
    test('Al-Fatiha has 7 verses', () => expect(surahAlFatiha.verses.length, 7));
    test('Al-Ikhlas has 4 verses', () => expect(surahAlIkhlas.verses.length, 4));
    test('Al-Falaq has 5 verses', () => expect(surahAlFalaq.verses.length, 5));
    test('An-Nas has 6 verses', () => expect(surahAnNas.verses.length, 6));
    test('Al-Kafirun has 6 verses',
        () => expect(surahAlKafirun.verses.length, 6));
    test('Az-Zalzalah has 8 verses',
        () => expect(surahAzZalzalah.verses.length, 8));
    test('Al-Qariah has 11 verses',
        () => expect(surahAlQariah.verses.length, 11));

    test('Verses are sequentially numbered from 1', () {
      for (final s in [
        surahAlFatiha,
        surahAlIkhlas,
        surahAlFalaq,
        surahAnNas,
        surahAlKafirun,
        surahAzZalzalah,
        surahAlQariah,
      ]) {
        for (var i = 0; i < s.verses.length; i++) {
          expect(s.verses[i].number, i + 1,
              reason: '${s.name} verse index $i');
          expect(s.verses[i].text.trim(), isNotEmpty);
        }
      }
    });
  });

  group('General ruqyah verses (verified_quran.dart) — Uthmani', () {
    test('TaHa mountains passage is verses 105-107', () {
      expect(taHaMountains.surahNumber, 20);
      expect(taHaMountains.verses.map((v) => v.number).toList(),
          [105, 106, 107]);
      for (final v in taHaMountains.verses) {
        expect(v.text.trim(), isNotEmpty);
      }
    });

    test('Hud flood verse is verse 44', () {
      expect(hudFloodVerse.surahNumber, 11);
      expect(hudFloodVerse.verses.single.number, 44);
    });

    // Byte-exact pin against the SHA-256-pinned KFGQPC asset (the single source
    // of truth) — not against hand-typed literals, whose combining-mark order
    // silently differs (e.g. U+0622 vs U+0627 U+0653, shadda/kasra order).
    final parsed = parseHafsJson(File(QuranRepository.assetPath).readAsStringSync());
    String asset(int s, int a) => parsed.surahs[s]![a - 1];

    test('TaHa 105-107 byte-identical to the KFGQPC asset', () {
      for (final v in taHaMountains.verses) {
        expect(v.text, asset(20, v.number), reason: 'TaHa ${v.number}');
      }
    });

    test('Hud 44 byte-identical to the KFGQPC asset', () {
      expect(hudFloodVerse.verses.single.text, asset(11, 44));
    });
  });

  test('Verse.withMarker = body + NBSP + Arabic-Indic number (KFGQPC aya_text form)', () {
    final v = surahAlFatiha.verses[1];
    expect(v.withMarker, '${v.text}\xA0٢');
    expect(surahAlFatiha.verses.last.withMarker.endsWith('\xA0٧'), isTrue);
    expect(taHaMountains.verses.first.withMarker.endsWith('\xA0١٠٥'), isTrue);
  });
}
