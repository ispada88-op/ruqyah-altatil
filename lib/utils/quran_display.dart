/// Display form of Uthmani Quran text (Tanzil encoding) — the ONLY place
/// Quran text is changed between the verified data and the screen.
///
/// Exactly two display-only substitutions; letters and every other mark are
/// untouched, and [fromMushafDisplay] restores the source byte for byte
/// (test/quran_display_test.dart proves it for all 6236 ayat):
///
/// 1. Sukun U+0652 → U+06E1 (Quranic sukun, drawn as a jazm).
///    In the Madinah Mushaf a sukun is drawn as a jazm and a small ring means
///    «this letter is not pronounced» (U+06DF, e.g. the alef after the waw of
///    «كفروا» or the waw of «أولئك»).
///    Tanzil encodes sukun as U+0652, which Noto Naskh and Amiri draw as the
///    same ring as U+06DF — so «لَمْ» would look like a silent mim. U+06E1 is
///    the code point the King Fahd Complex uses for exactly this sukun.
/// 2. The space before a stand-alone pause sign (U+06D6–U+06DC) or the
///    sajdah sign (U+06E9) → no-break space. Tanzil writes these as separate
///    tokens; without this a line could break before the sign and start with
///    an orphan mark. Shaping is identical (the sign still sits in place).
///
/// Never use this for copy/share — those keep the standard encoding.
String mushafDisplay(String uthmani) => uthmani
    .replaceAll(_sukun, _jazm)
    .replaceAllMapped(_spaceBeforePause, (m) => '$_nbsp${m[1]}');

/// Exact inverse of [mushafDisplay] for text that came from the verified
/// sources (which contain neither U+06E1 nor U+00A0).
String fromMushafDisplay(String shown) => shown
    .replaceAll(_jazm, _sukun)
    .replaceAllMapped(_nbspBeforePause, (m) => ' ${m[1]}');

const String _sukun = '\u0652';
const String _jazm = '\u06E1';
const String _nbsp = '\u00A0';
final RegExp _spaceBeforePause = RegExp(' ([\u06D6-\u06DC\u06E9])');
final RegExp _nbspBeforePause = RegExp('\u00A0([\u06D6-\u06DC\u06E9])');
