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
  final prefix = '$basmala ';
  for (final entry in surahs.entries) {
    if (entry.key == 1 || entry.key == 9) continue;
    final first = entry.value.first;
    if (first.startsWith(prefix)) {
      entry.value[0] = first.substring(prefix.length);
    }
  }
  return ParsedQuran(surahs, basmala);
}
