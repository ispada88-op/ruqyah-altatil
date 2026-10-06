import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/verified_quran.dart' show basmalaUthmani;
import 'error_reporter.dart';

/// النص القرآني الكامل — مصحف المدينة (مجمع الملك فهد لطباعة المصحف الشريف،
/// «الخط العثماني حفص» الإصدار 0.18) من `assets/quran/hafsData_v18.json`.
/// يُحمَّل مرة واحدة عند أول استخدام.
///
/// الملف نسخة حرفية من الموقع الرسمي للمجمع ولا يُعدَّل أبداً (اختبار
/// `quran_asset_test.dart` يثبّت بصمته)، ويُعرض بخط المجمع نفسه
/// (`assets/fonts/kfgqpc/hafs.18.ttf`، عائلة `kQuranFontFamily` في theme.dart).
class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  static const String assetPath = 'assets/quran/hafsData_v18.json';

  Map<int, List<String>>? _surahs;
  Future<Map<int, List<String>>>? _loading;

  /// البسملة كما في النص (آية الفاتحة الأولى) — تُعرض عنواناً لكل سورة عدا
  /// الفاتحة والتوبة. الحرف الأول من كل سورة بعدها ليس بسملة: ملف المجمع لا
  /// يلصق البسملة بالآية الأولى، فلا حاجة لفصلها.
  String basmala = basmalaUthmani;  // generated constant, verified = 1:1

  Future<Map<int, List<String>>> _load() {
    return _loading ??= () async {
      try {
        final raw = await rootBundle.loadString(assetPath);
        // ‎3.5MB JSON: يُحلَّل في isolate حتى لا يتجمّد أول فتح للمصحف.
        final parsed = await compute(parseHafsJson, raw);
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

  /// يبدأ التحميل في الخلفية (فهرس المصحف يستدعيه) فيكون النص جاهزاً حين يفتح
  /// القارئ سورة. الخطأ يُسجَّل في [ErrorReporter] وتُعاد المحاولة عند أول قراءة.
  void preload() {
    if (_surahs != null) return;
    _load().then<void>((_) {}, onError: (Object _) {});
  }

  /// آيات سورة [number] (1..114) — نص الآية بدون رقمها.
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

const String _nbsp = '\xA0';

/// يحلل `hafsData_v18.json`: قائمة سجلات `{sora, aya_no, aya_text, ...}` حيث
/// `aya_text` = نص الآية + مسافة غير قاطعة + رقمها بالأرقام العربية الهندية.
/// يُرجع نص الآية بدون الذيل (الرقم يُضاف عند العرض بـ [withAyahNumber]).
/// يرمي [FormatException] لأي شذوذ (ترقيم، ذيل، عدد).
ParsedQuran parseHafsJson(String raw) {
  final list = jsonDecode(raw);
  if (list is! List) {
    throw const FormatException('Quran text: expected a JSON list');
  }
  final surahs = <int, List<String>>{};
  var total = 0;
  for (final rec in list) {
    final r = rec as Map<String, dynamic>;
    final s = r['sora'] as int;
    final a = r['aya_no'] as int;
    final text = r['aya_text'] as String;
    final ayat = surahs.putIfAbsent(s, () => []);
    if (a != ayat.length + 1) {
      throw FormatException('Quran text: $s:$a out of order');
    }
    final cut = text.lastIndexOf(_nbsp);
    if (cut < 0 || text.substring(cut + 1) != arabicIndicDigits(a)) {
      throw FormatException('Quran text: $s:$a has a wrong ayah-number tail');
    }
    ayat.add(text.substring(0, cut));
    total++;
  }
  if (total != 6236 || surahs.length != 114) {
    throw FormatException('Quran text: $total ayat / ${surahs.length} surahs');
  }
  final basmala = surahs[1]!.first;
  return ParsedQuran(surahs, basmala);
}

/// رقم بالأرقام العربية الهندية (٠-٩).
String arabicIndicDigits(int n) {
  const d = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

/// نص قرآني للنسخ/المشاركة خارج التطبيق: ذيل «مسافة + رقم» (الذي يرسمه خط
/// المجمع علامةً مزخرفة) يصير ﴿N﴾ حتى يُقرأ سليماً في أي خط. الحروف والحركات
/// لا تتغير. إن لم يكن في السطر ذيل رقم (بسملة، عنوان) يعود كما هو.
String quranForSharing(String line) => line.replaceFirstMapped(
    RegExp('$_nbsp([٠-٩]+)\$'), (m) => ' ﴿${m[1]}﴾');

/// نص آية مع رقمها كما في ملف المجمع: نص + مسافة غير قاطعة + رقم — يرسمه
/// خط المجمع علامةَ نهاية آية مزخرفة.
String withAyahNumber(String ayahBody, int number) =>
    '$ayahBody$_nbsp${arabicIndicDigits(number)}';
