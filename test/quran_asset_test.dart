import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/quran_extracts.dart';
import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/services/quran_repository.dart';

/// The bundled Quran is a verbatim Tanzil download. Any byte change (an editor
/// "fixing" whitespace, a bad merge, a re-encode) must fail CI.
/// Full orthography check: scripts/verify_quran.py (also run in CI).
void main() {
  final file = File(QuranRepository.assetPath);
  final raw = file.readAsStringSync();
  final parsed = parseTanzil(raw);

  test('asset is the pinned Tanzil Uthmani 1.1 file (SHA-256)', () {
    expect(
      sha256.convert(file.readAsBytesSync()).toString(),
      '18c719bb3ba26d32ef457f40dad77cd28c4c5a34156833e26a8e5fcfdd246fb1',
      reason: 'Quran text changed — re-download from tanzil.net, never edit',
    );
  });

  test('Tanzil copyright block is kept (licence requirement)', () {
    expect(raw, contains('Tanzil Quran Text (Uthmani, Version 1.1)'));
    expect(raw, contains('CHANGING IT IS NOT ALLOWED'));
  });

  test('114 surahs / 6236 ayat, each count matches the index', () {
    expect(parsed.surahs.length, 114);
    expect(parsed.totalAyat, 6236);
    expect(kSurahs.length, 114);
    expect(kTotalAyat, 6236);
    for (final s in kSurahs) {
      expect(parsed.surahs[s.number]!.length, s.ayahCount, reason: s.name);
    }
    expect(kJuzStarts.length, 30);
  });

  test('basmala is split from the first ayah except Al-Fatiha and At-Tawbah',
      () {
    expect(parsed.surahs[1]!.first, parsed.basmala);
    expect(parsed.surahs[2]!.first, 'الٓمٓ');
    // Tanzil writes «بَرَآءَةٌ» with a decomposed alef + maddah (U+0627 U+0653),
    // so compare only the first letters.
    expect(parsed.surahs[9]!.first.startsWith('بَرَ'), isTrue);
    expect(parsed.surahs[112]!.first.startsWith('قُلْ هُوَ'), isTrue);
    for (var s = 2; s <= 114; s++) {
      expect(parsed.surahs[s]!.first.startsWith(parsed.basmala), isFalse,
          reason: 'surah $s still carries the basmala');
    }
  });

  test('no empty ayah anywhere', () {
    for (final e in parsed.surahs.entries) {
      for (final v in e.value) {
        expect(v.trim(), isNotEmpty, reason: 'surah ${e.key}');
      }
    }
  });

  test('generated extracts equal the asset verse by verse', () {
    for (final e in [arafSihr, yunusSihr, tahaSihr]) {
      expect(e.verses.length, e.to - e.from + 1);
      for (var i = 0; i < e.verses.length; i++) {
        expect(e.verses[i], parsed.surahs[e.surah]![e.from + i - 1],
            reason: '${e.surah}:${e.from + i}');
      }
    }
  });
}
