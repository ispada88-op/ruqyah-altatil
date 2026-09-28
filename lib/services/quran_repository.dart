import 'package:flutter/services.dart';

import 'error_reporter.dart';

/// النص القرآني الكامل (مشروع تنزيل — عثماني 1.1) من
/// `assets/quran/quran-uthmani.txt`. يُحمَّل مرة واحدة عند أول استخدام.
///
/// الملف نسخة حرفية من tanzil.net ولا يُعدَّل أبداً (اختبار
/// `quran_asset_test.dart` يثبّت بصمته). البسملة الملصقة بأول آية في السور
/// (عدا الفاتحة والتوبة) تُفصل هنا للعرض فقط لتظهر كعنوان مستقل.
class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  static const String assetPath = 'assets/quran/quran-uthmani.txt';

  Map<int, List<String>>? _surahs;
  Future<Map<int, List<String>>>? _loading;

  /// البسملة كما في النص (آية الفاتحة الأولى).
  String basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  Future<Map<int, List<String>>> _load() {
    return _loading ??= () async {
      try {
        final raw = await rootBundle.loadString(assetPath);
        final parsed = parseTanzil(raw);
        basmala = parsed.basmala;
        _surahs = parsed.surahs;
        return parsed.surahs;
      } catch (e, st) {
        ErrorReporter.report(e, st, context: 'QuranRepository.load');
        _loading = null; // allow a retry on the next call
        rethrow;
      }
    }();
  }

  /// آيات سورة [number] (1..114) بدون البسملة الملصقة.
  Future<List<String>> surah(int number) async {
    final all = _surahs ?? await _load();
    return all[number] ?? const [];
  }
}

class ParsedQuran {
  final Map<int, List<String>> surahs;
  final String basmala;
  const ParsedQuran(this.surahs, this.basmala);

  int get totalAyat => surahs.values.fold(0, (a, s) => a + s.length);
}

/// يحلل صيغة تنزيل txt-2 (`سورة|آية|نص`) ويتجاهل أسطر الحقوق (#).
ParsedQuran parseTanzil(String raw) {
  final surahs = <int, List<String>>{};
  for (final line in raw.split('\n')) {
    final l = line.endsWith('\r') ? line.substring(0, line.length - 1) : line;
    if (l.isEmpty || l.startsWith('#')) continue;
    final first = l.indexOf('|');
    final second = l.indexOf('|', first + 1);
    if (first < 0 || second < 0) continue;
    final s = int.parse(l.substring(0, first));
    surahs.putIfAbsent(s, () => []).add(l.substring(second + 1));
  }
  final basmala = surahs[1]!.first;
  final basmalaWords = basmala.split(' ').map(quranSkeleton).toList();
  for (var s = 2; s <= 114; s++) {
    final ayat = surahs[s];
    if (ayat == null || ayat.isEmpty) {
      throw FormatException('Quran text: surah $s is missing');
    }
    final words = ayat.first.split(' ');
    final head = words.take(basmalaWords.length).map(quranSkeleton).toList();
    final hasBasmala = words.length > basmalaWords.length &&
        _sameWords(head, basmalaWords);
    if (s == 9) {
      if (hasBasmala) {
        throw const FormatException('Quran text: At-Tawbah must not carry a basmala');
      }
      continue;
    }
    // Tanzil writes the basmala of At-Tin (95) and Al-Qadr (97) as «بِّسْمِ»
    // (with shaddah), so match by letters, never by exact string.
    if (!hasBasmala) {
      throw FormatException('Quran text: surah $s ayah 1 lacks the basmala prefix');
    }
    ayat[0] = words.skip(basmalaWords.length).join(' ');
  }
  return ParsedQuran(surahs, basmala);
}

bool _sameWords(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Letters only: drops harakat, Quranic annotation marks and tatweel, and
/// reads alef wasla as alef. Used to recognise words regardless of marks —
/// never to display text.
String quranSkeleton(String word) {
  final sb = StringBuffer();
  for (final r in word.runes) {
    final isMark = (r >= 0x0610 && r <= 0x061A) ||
        (r >= 0x064B && r <= 0x065F) ||
        r == 0x0670 ||
        (r >= 0x06D6 && r <= 0x06ED) ||
        (r >= 0x08D3 && r <= 0x08FF) ||
        r == 0x0640;
    if (isMark) continue;
    sb.writeCharCode(r == 0x0671 ? 0x0627 : r);
  }
  return sb.toString();
}
