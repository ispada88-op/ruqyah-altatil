import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'error_reporter.dart';

/// نوع السطر في صفحة المصحف.
enum MushafLineKind { body, suraName, basmala }

/// سطر واحد: كل حرف في [glyphs] = كلمة واحدة مرسومة من خط الصفحة [font].
class MushafLine {
  final MushafLineKind kind;
  final String font; // اسم العائلة، مثل QCF4_Hafs_05_W
  final String glyphs;
  const MushafLine(this.kind, this.font, this.glyphs);

  /// عدد الكلمات (رموز الخط) في السطر.
  int get length => glyphs.runes.length;
}

/// صفحة من مصحف المدينة (١٥ سطراً؛ الصفحتان ١ و٢ ثمانية).
class MushafPage {
  final int number; // 1..604
  final int surah; // سورة أول الصفحة
  final int juz;
  final List<MushafLine> lines;

  /// نهايات الآيات في هذه الصفحة: (سورة، آية).
  final List<(int, int)> verseEnds;
  const MushafPage(this.number, this.surah, this.juz, this.lines, this.verseEnds);

  Set<String> get fonts => {for (final l in lines) l.font};
}

class MushafLayout {
  final List<MushafPage> pages;
  const MushafLayout(this.pages);

  static const int pageCount = 604;
  static const int firstSuraNameGlyph = 0xF100; // سورة ١ في QCF4_QBSML

  MushafPage page(int n) => pages[n.clamp(1, pageCount) - 1];

  /// أول صفحة للسورة [surah] (1..114) — من سطر اسم السورة نفسه.
  int pageOfSurah(int surah) {
    final code = firstSuraNameGlyph + surah - 1;
    for (final p in pages) {
      for (final l in p.lines) {
        if (l.kind == MushafLineKind.suraName && l.glyphs.runes.first == code) {
          return p.number;
        }
      }
    }
    return 1;
  }

  /// أول صفحة للجزء [juz] (1..30).
  int pageOfJuz(int juz) =>
      pages.firstWhere((p) => p.juz == juz, orElse: () => pages.first).number;

  /// الصفحة التي تنتهي فيها الآية ([surah]:[ayah]).
  int pageOfAyah(int surah, int ayah) {
    for (final p in pages) {
      if (p.verseEnds.contains((surah, ayah))) return p.number;
    }
    return pageOfSurah(surah);
  }
}

/// يحلل `assets/quran/mushaf_pages.json` (من `scripts/gen_mushaf_pages.py`).
/// يرمي [FormatException] لأي شذوذ في البنية.
MushafLayout parseMushafPages(String raw) {
  final doc = jsonDecode(raw);
  if (doc is! Map) throw const FormatException('mushaf pages: expected object');
  final fonts = (doc['fonts'] as List).cast<String>();
  final list = doc['pages'] as List;
  if (list.length != MushafLayout.pageCount) {
    throw FormatException('mushaf pages: ${list.length} pages, expected 604');
  }
  final pages = <MushafPage>[];
  for (var i = 0; i < list.length; i++) {
    final p = list[i] as Map;
    final lines = <MushafLine>[
      for (final l in (p['l'] as List))
        MushafLine(MushafLineKind.values[l[0] as int], fonts[l[1] as int], l[2] as String),
    ];
    final ends = <(int, int)>[
      for (final v in (p['v'] as List)) ((v[0] as int), (v[1] as int)),
    ];
    pages.add(MushafPage(i + 1, p['s'] as int, p['j'] as int, lines, ends));
  }
  return MushafLayout(pages);
}

/// تخطيط صفحات مصحف المدينة + تحميل خطوط الصفحات عند الحاجة.
///
/// كل صفحة تُرسم بخط من ٤٧ خطاً (`assets/fonts/qcf4/QCF4_Hafs_NN_W.ttf`) يضم
/// كل كلمة فيها كرمز واحد — فيُرسم النص بإملاء المجمع وتشكيله كما في المطبوع.
/// الخطوط ليست مسجّلة في pubspec (لا تُحمَّل كلها عند الإقلاع): تُحمَّل
/// بـ [FontLoader] عند أول صفحة تحتاجها. ملفات الخط تُضمَّن بايتاً ببايت.
class MushafPagesRepository {
  MushafPagesRepository._();
  static final MushafPagesRepository instance = MushafPagesRepository._();

  static const String assetPath = 'assets/quran/mushaf_pages.json';
  static const String fontsDir = 'assets/fonts/qcf4';

  Future<MushafLayout>? _layout;
  final Map<String, Future<void>> _fonts = {};

  Future<MushafLayout> layout() => _layout ??= () async {
        try {
          final raw = await rootBundle.loadString(assetPath);
          return await compute(parseMushafPages, raw);
        } catch (e, st) {
          ErrorReporter.report(e, st, context: 'MushafPages.load');
          _layout = null; // أعد المحاولة عند الطلب التالي
          rethrow;
        }
      }();

  /// يحمّل خط [family] (مرة واحدة).
  Future<void> ensureFont(String family) => _fonts[family] ??= () async {
        try {
          final loader = FontLoader(family)
            ..addFont(rootBundle.load('$fontsDir/$family.ttf'));
          await loader.load();
        } catch (e, st) {
          ErrorReporter.report(e, st, context: 'MushafPages.font $family');
          _fonts.remove(family);
          rethrow;
        }
      }();

  Future<void> ensureFonts(Iterable<String> families) =>
      Future.wait([for (final f in families) ensureFont(f)]);
}
