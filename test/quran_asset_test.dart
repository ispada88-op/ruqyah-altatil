import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/quran_data.dart' as long_surahs;
import 'package:roqia_altatil/data/quran_extracts.dart';
import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/services/quran_repository.dart';

/// The bundled Quran is the verbatim King Fahd Complex (Madinah) data and font.
/// Any byte change (an editor "fixing" whitespace, a bad merge, a re-encode, a
/// font subset/convert — forbidden by the KFGQPC licence) must fail CI.
/// Full orthography check: scripts/verify_quran.py (also run in CI).
const _jsonSha = '5d8bb91726e482839d0057633cb1973031e4d706fa9604eea5e08892f20ba140';
const _fontSha = 'a0636e68e375af9552470d67773936f54d536e6586ce2608311b2fe7f9cbec3a';

void main() {
  final file = File(QuranRepository.assetPath);
  final raw = file.readAsStringSync();
  final parsed = parseHafsJson(raw);

  test('text asset is the pinned KFGQPC hafsData_v18.json (SHA-256)', () {
    expect(sha256.convert(file.readAsBytesSync()).toString(), _jsonSha,
        reason: 'Quran text changed — re-download from qurancomplex.gov.sa, never edit');
  });

  test('font is the byte-identical official hafs.18.ttf (SHA-256)', () {
    expect(
      sha256.convert(File('assets/fonts/kfgqpc/hafs.18.ttf').readAsBytesSync()).toString(),
      _fontSha,
      reason: 'KFGQPC licence forbids modifying/converting the font',
    );
  });

  test('font EULA ships with the font and is declared in pubspec', () {
    final eula = File('assets/fonts/kfgqpc/KFGQPC-EULA.txt').readAsStringSync();
    expect(eula, contains('ELECTRONIC END-USER LICENSE AGREEMENT'));
    expect(eula, contains('King Fahd Glorious Quran Printing Complex'));
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: KFGQPCHafs'));
    expect(pubspec, contains('asset: assets/fonts/kfgqpc/hafs.18.ttf'));
    expect(pubspec, contains('assets/fonts/kfgqpc/KFGQPC-EULA.txt'));
    expect(File('lib/main.dart').readAsStringSync(), contains('KFGQPC-EULA.txt'));
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

  test('juz starts follow the Madinah Mushaf (3:92 and 9:94, not Tanzil 3:93/9:93)', () {
    expect((kJuzStarts[3].surah, kJuzStarts[3].ayah), (3, 92));
    expect((kJuzStarts[10].surah, kJuzStarts[10].ayah), (9, 94));
    expect((kJuzStarts[29].surah, kJuzStarts[29].ayah), (78, 1));
  });

  // Letters only (no harakat / Quranic marks): hand-typed literals differ from
  // the asset in combining-mark order, so exact-string literals must never be
  // used for Quran text in tests.
  String letters(String x) => x.runes
      .where((r) => (r >= 0x0621 && r <= 0x064A) || r == 0x0671)
      .map((r) => r == 0x0671 ? 'ا' : String.fromCharCode(r))
      .join();

  test('basmala is ayah 1:1; no other surah starts with it (KFGQPC keeps it apart)', () {
    expect(parsed.surahs[1]!.first, parsed.basmala);
    expect(letters(parsed.basmala), 'بسماللهالرحمنالرحيم');
    expect(letters(parsed.surahs[2]!.first), 'الم');
    expect(letters(parsed.surahs[95]!.first), startsWith('والتين'));
    expect(letters(parsed.surahs[97]!.first), startsWith('إناأنزلنه'));
    expect(letters(parsed.surahs[112]!.first), startsWith('قلهوالله'));
    for (var s = 2; s <= 114; s++) {
      expect(letters(parsed.surahs[s]!.first), isNot(startsWith('بسمالله')),
          reason: 'surah $s');
    }
    // The basmala inside An-Naml 30 is part of the ayah.
    expect(parsed.surahs[27]![29], contains(parsed.basmala));
  });

  test('parser rejects a corrupted file instead of showing wrong text', () {
    // wrong ayah-number tail
    expect(() => parseHafsJson(raw.replaceFirst('\xA0١"', '\xA0٢"')),
        throwsFormatException);
    // a missing record
    expect(() => parseHafsJson(raw.replaceFirst('"aya_no" : 2,', '"aya_no" : 3,')),
        throwsFormatException);
    expect(() => parseHafsJson('{}'), throwsFormatException);
  });

  test('every ayah body has no ayah-number tail left and no stray NBSP at its end', () {
    for (final e in parsed.surahs.entries) {
      for (final v in e.value) {
        expect(v.trim(), isNotEmpty, reason: 'surah ${e.key}');
        expect(v.endsWith('\xA0'), isFalse, reason: 'surah ${e.key}');
        expect(RegExp('[٠-٩]').hasMatch(v), isFalse, reason: 'surah ${e.key}');
      }
    }
  });

  test('long surahs (quran_data.dart) equal aya_text verbatim', () {
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
        expect(e.value[i], withAyahNumber(ref[i], i + 1),
            reason: '${e.key}:${i + 1}');
      }
    }
    expect(long_surahs.basmala, parsed.basmala);
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

  test('withAyahNumber / quranForSharing round trip', () {
    expect(withAyahNumber('س', 12), 'س\xA0١٢');
    expect(quranForSharing('س\xA0١٢'), 'س ﴿١٢﴾');
    expect(quranForSharing(parsed.basmala), parsed.basmala);
    for (final e in parsed.surahs.entries) {
      for (var i = 0; i < e.value.length; i++) {
        final shared = quranForSharing(withAyahNumber(e.value[i], i + 1));
        expect(shared, '${e.value[i]} ﴿${arabicIndicDigits(i + 1)}﴾');
      }
    }
  });
}
