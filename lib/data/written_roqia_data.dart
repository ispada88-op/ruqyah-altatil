// ═══════════════════════════════════════════════════════════════════════════
// بيانات صفحة الرقية المكتوبة - تستخدم النص العثماني الموثّق
// ═══════════════════════════════════════════════════════════════════════════
//
// هذا الملف يحوّل البيانات من `verified_quran.dart` إلى الصيغة المتوقعة
// من `_buildSurahCard()` (List<String> مع علامة الآية).
//
// هذا يضمن أن كل النصوص في الصفحة مطابقة لمصحف المدينة.
// ═══════════════════════════════════════════════════════════════════════════

import 'verified_quran.dart';
import 'quran_data.dart' show anfalVerses, dukhanVerses, saffatVerses, haqqaVerses, basmala;

/// تحويل قائمة Verse إلى `List<String>` بصيغة "النص ﴿N﴾".
List<String> _versesToStrings(List<Verse> verses) =>
    verses.map((v) => v.withMarker).toList();

/// تجميعة لكل سورة: (الاسم، عدد الآيات أو null للجزئية، البسملة، النصوص، subtitle)
class WrittenSurah {
  final String name;
  final int? totalAyat;
  final String? basmala;
  final List<String> verses;
  final String? subtitle;

  const WrittenSurah({
    required this.name,
    required this.verses,
    this.totalAyat,
    this.basmala,
    this.subtitle,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// قائمة السور بالنص العثماني الموثّق
// ═══════════════════════════════════════════════════════════════════════════

List<WrittenSurah> get writtenSurahs => [
      WrittenSurah(
        name: surahAlFatiha.name,
        totalAyat: 7,
        verses: _versesToStrings(surahAlFatiha.verses),
      ),
      WrittenSurah(
        name: 'سورة البقرة',
        basmala: basmalaUthmani,
        verses: _versesToStrings(surahAlBaqarahOpening.verses),
        subtitle: 'الآيات (١-٥)',
      ),
      WrittenSurah(
        name: 'آية الكرسي',
        verses: _versesToStrings(ayatAlKursi.verses),
        subtitle: 'البقرة (٢٥٥)',
      ),
      WrittenSurah(
        name: 'خواتيم البقرة',
        verses: _versesToStrings(surahAlBaqarahClosing.verses),
        subtitle: 'الآيات (٢٨٥-٢٨٦)',
      ),
      // السور الأربع الكبيرة - تبقى من quran_data.dart (مفحوصة وصحيحة)
      WrittenSurah(
        name: 'سورة الأنفال',
        totalAyat: 75,
        basmala: basmala,
        verses: anfalVerses,
      ),
      WrittenSurah(
        name: 'سورة الدخان',
        totalAyat: 59,
        basmala: basmala,
        verses: dukhanVerses,
      ),
      WrittenSurah(
        name: 'سورة الصافات',
        totalAyat: 182,
        basmala: basmala,
        verses: saffatVerses,
      ),
      WrittenSurah(
        name: 'سورة الحاقة',
        totalAyat: 52,
        basmala: basmala,
        verses: haqqaVerses,
      ),
      WrittenSurah(
        name: surahAzZalzalah.name,
        totalAyat: 8,
        basmala: surahAzZalzalah.basmala,
        verses: _versesToStrings(surahAzZalzalah.verses),
      ),
      WrittenSurah(
        name: surahAlQariah.name,
        totalAyat: 11,
        basmala: surahAlQariah.basmala,
        verses: _versesToStrings(surahAlQariah.verses),
      ),
      WrittenSurah(
        name: surahAlKafirun.name,
        totalAyat: 6,
        basmala: surahAlKafirun.basmala,
        verses: _versesToStrings(surahAlKafirun.verses),
      ),
      WrittenSurah(
        name: surahAlIkhlas.name,
        totalAyat: 4,
        basmala: surahAlIkhlas.basmala,
        verses: _versesToStrings(surahAlIkhlas.verses),
      ),
      WrittenSurah(
        name: surahAlFalaq.name,
        totalAyat: 5,
        basmala: surahAlFalaq.basmala,
        verses: _versesToStrings(surahAlFalaq.verses),
      ),
      WrittenSurah(
        name: surahAnNas.name,
        totalAyat: 6,
        basmala: surahAnNas.basmala,
        verses: _versesToStrings(surahAnNas.verses),
      ),
    ];
