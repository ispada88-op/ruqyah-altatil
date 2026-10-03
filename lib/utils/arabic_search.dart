/// تطبيع النص العربي للبحث: يُطبَّق على نص الآيات وعلى ما يكتبه المستخدم بالدالة
/// نفسها فيتطابقان مهما اختلف التشكيل أو شكل الألف والهمزة والياء والتاء المربوطة.
library;

/// علامات التشكيل والوقف القرآنية والتطويل (تُحذف).
final RegExp _marks = RegExp(
    '[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u08D3-\u08FF]');
final RegExp _notLetters = RegExp('[^ء-ي ]');

String normalizeArabic(String s) {
  var t = s.replaceAll(_marks, '');
  t = t
      .replaceAll('أ', 'ا') // أ
      .replaceAll('إ', 'ا') // إ
      .replaceAll('آ', 'ا') // آ
      .replaceAll('\u0671', '\u0627') // alef wasla → alef
      .replaceAll('ى', 'ي') // ى → ي
      .replaceAll('ة', 'ه') // ة → ه
      .replaceAll('ؤ', 'و') // ؤ → و
      .replaceAll('ئ', 'ي') // ئ → ي
      .replaceAll('ء', ''); // ء
  t = t.replaceAll(_notLetters, ' ');
  return t.split(' ').where((w) => w.isNotEmpty).join(' ');
}

/// آية في فهرس البحث.
class SearchVerse {
  final int surah;
  final int ayah;
  final String norm;
  const SearchVerse(this.surah, this.ayah, this.norm);
}

/// يحلل ملف تنزيل («سورة|آية|نص» وتعليقات تبدأ بـ #).
/// يرمي [FormatException] إن لم تكن الآيات ٦٢٣٦ بترقيم متسلسل.
List<SearchVerse> parseTanzilForSearch(String raw) {
  final out = <SearchVerse>[];
  var lastSurah = 0, lastAyah = 0;
  for (final line in raw.split('\n')) {
    final l = line.trim();
    if (l.isEmpty || l.startsWith('#')) continue;
    final parts = l.split('|');
    if (parts.length != 3) throw FormatException('tanzil: bad line "$l"');
    final s = int.parse(parts[0]);
    final a = int.parse(parts[1]);
    final ok = (s == lastSurah && a == lastAyah + 1) ||
        (s == lastSurah + 1 && a == 1);
    if (!ok) throw FormatException('tanzil: $s:$a out of order');
    lastSurah = s;
    lastAyah = a;
    out.add(SearchVerse(s, a, normalizeArabic(parts[2])));
  }
  if (out.length != 6236 || lastSurah != 114) {
    throw FormatException('tanzil: ${out.length} verses, last surah $lastSurah');
  }
  return out;
}

class SearchResults {
  final List<SearchVerse> shown;
  final int total;
  const SearchResults(this.shown, this.total);
}

/// يبحث عن الآيات التي تحوي كل كلمات [query] (كجزء من كلمة). من تطابقت
/// عبارته كما كُتبت تأتي أولاً، ثم الباقي بترتيب المصحف. يُرجع أول [limit] فقط
/// مع العدد الكلي. استعلام أقصر من حرفين بعد التطبيع لا يعيد شيئاً.
SearchResults searchVerses(List<SearchVerse> verses, String query,
    {int limit = 100}) {
  final q = normalizeArabic(query);
  if (q.replaceAll(' ', '').length < 2) return const SearchResults([], 0);
  final tokens = q.split(' ');
  final phrase = <SearchVerse>[];
  final rest = <SearchVerse>[];
  for (final v in verses) {
    if (!tokens.every(v.norm.contains)) continue;
    (tokens.length > 1 && v.norm.contains(q) ? phrase : rest).add(v);
  }
  final all = [...phrase, ...rest];
  return SearchResults(all.length > limit ? all.sublist(0, limit) : all, all.length);
}
