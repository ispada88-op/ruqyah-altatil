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
    final ok =
        (s == lastSurah && a == lastAyah + 1) || (s == lastSurah + 1 && a == 1);
    if (!ok) throw FormatException('tanzil: $s:$a out of order');
    lastSurah = s;
    lastAyah = a;
    out.add(SearchVerse(s, a, normalizeArabic(parts[2])));
  }
  if (out.length != 6236 || lastSurah != 114) {
    throw FormatException(
        'tanzil: ${out.length} verses, last surah $lastSurah');
  }
  return out;
}

class SearchResults {
  final List<SearchVerse> shown;
  final int total;
  const SearchResults(this.shown, this.total);
}

/// كلمات لا تُبحث: من كتب «آية الكرسي» يقصد «الكرسي» لا كلمة «آية».
const Set<String> _stopTokens = {'ايه', 'ايات', 'سوره'};

/// «الكرسي» → «كرسي» (كلمات الآيات تأتي بلواحق: «كرسيه»).
String _stripAl(String t) =>
    t.length > 3 && t.startsWith('ال') ? t.substring(2) : t;

/// صيغة متسامحة: بلا ألفات، وبواو/ياء واحدة بدل المكرّرة. تُطابق «داود»
/// بـ«داوود» (الرسم القرآني)، و«الرحمان» بـ«الرحمن»، و«السموات» بـ«السماوات».
String looseArabic(String n) => n
    .replaceAll('ا', '')
    .replaceAll(RegExp('و+'), 'و')
    .replaceAll(RegExp('ي+'), 'ي');

final Expando<String> _looseCache = Expando<String>('looseVerse');
String _looseOf(SearchVerse v) => _looseCache[v] ??= looseArabic(v.norm);

/// يبحث عن الآيات التي تحوي كل كلمات [query] (كجزء من كلمة). من تطابقت
/// عبارته كما كُتبت تأتي أولاً، ثم الباقي بترتيب المصحف. يُرجع أول [limit] فقط
/// مع العدد الكلي. استعلام أقصر من حرفين بعد التطبيع لا يعيد شيئاً.
///
/// البحث الحرفي أولاً؛ إن لم يجد شيئاً يُعاد بصيغة متسامحة ([looseArabic] مع
/// حذف «ال» التعريف من أول كل كلمة) فلا يُخيّب مَن كتب الإملاء المعتاد.
SearchResults searchVerses(List<SearchVerse> verses, String query,
    {int limit = 100}) {
  final q = normalizeArabic(query);
  if (q.replaceAll(' ', '').length < 2) return const SearchResults([], 0);
  final tokens = [
    for (final t in q.split(' '))
      if (!_stopTokens.contains(t)) t
  ];
  if (tokens.isEmpty) return const SearchResults([], 0);

  var all =
      _run(verses, tokens, (v) => v.norm, (t) => RegExp(RegExp.escape(t)));
  if (all.isEmpty) {
    final loose = [
      for (final t in tokens) looseArabic(_stripAl(t)),
    ].where((t) => t.length >= 2).toList();
    // المتسامح يُثبَّت عند بداية الكلمة (مع سوابقها: و ف ب ك ل / «ال»)، وإلا
    // طابقت «داود» كلمة «حدود».
    if (loose.isNotEmpty) {
      all = _run(verses, loose, _looseOf,
          (t) => RegExp('(?:^| )[وفبكل]{0,2}${RegExp.escape(t)}'));
    }
  }
  return SearchResults(
      all.length > limit ? all.sublist(0, limit) : all, all.length);
}

List<SearchVerse> _run(List<SearchVerse> verses, List<String> tokens,
    String Function(SearchVerse) textOf, RegExp Function(String) matcher) {
  final phrase = tokens.join(' ');
  final patterns = [for (final t in tokens) matcher(t)];
  final first = <SearchVerse>[];
  final rest = <SearchVerse>[];
  for (final v in verses) {
    final text = textOf(v);
    if (!patterns.every((p) => p.hasMatch(text))) continue;
    (tokens.length > 1 && text.contains(phrase) ? first : rest).add(v);
  }
  return [...first, ...rest];
}
