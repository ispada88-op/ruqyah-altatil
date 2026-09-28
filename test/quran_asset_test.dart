import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/quran_data.dart' as long_surahs;
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
    // Letter-level check (an exact-prefix check missed 95 and 97, which Tanzil
    // writes «بِّسْمِ» with a shaddah).
    final bWords = parsed.basmala.split(' ').map(quranSkeleton).toList();
    for (var s = 2; s <= 114; s++) {
      final head =
          parsed.surahs[s]!.first.split(' ').take(4).map(quranSkeleton).toList();
      expect(head, isNot(equals(bWords)),
          reason: 'surah $s still carries the basmala');
    }
    expect(parsed.surahs[95]!.first, startsWith('وَٱلتِّينِ'));
    expect(parsed.surahs[97]!.first, startsWith('إِنَّآ أَنزَلْنَٰهُ'));
    // The basmala inside An-Naml 30 is part of the ayah and must stay.
    expect(parsed.surahs[27]![29].split(' ').map(quranSkeleton).join(' '),
        contains(bWords.join(' ')));
  });

  test('parser rejects a corrupted file instead of showing wrong text', () {
    final broken = raw.replaceFirst(RegExp(r'^95\|1\|\S+ ', multiLine: true), '95|1|');
    expect(() => parseTanzil(broken), throwsFormatException);
  });

  test('long surahs (quran_data.dart) equal the asset byte-for-byte', () {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String marker(int n) =>
        '﴿${n.toString().split('').map((d) => digits[int.parse(d)]).join()}﴾';
    final sets = {
      8: long_surahs.anfalVerses,
      44: long_surahs.dukhanVerses,
      37: long_surahs.saffatVerses,
      69: long_surahs.haqqaVerses,
    };
    for (final e in sets.entries) {
      final ref = parsed.surahs[e.key]!;
      expect(e.value.length, ref.length, reason: 'surah ${e.key}');
      for (var i = 0; i < ref.length; i++) {
        expect(e.value[i], '${ref[i]} ${marker(i + 1)}',
            reason: '${e.key}:${i + 1}');
      }
    }
    expect(long_surahs.basmala, parsed.basmala);
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
