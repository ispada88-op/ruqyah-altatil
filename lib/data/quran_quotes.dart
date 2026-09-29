// Short Quran quotes shown outside the Mushaf pages, in imla'i spelling.
//
// Each text is copied verbatim from Tanzil "simple" text
// (scripts/ref/quran-simple.txt) and must be whole words of the cited ayah —
// scripts/verify_quran.py enforces it. Never type an ayah from memory.

class QuranQuote {
  final int surah;
  final int ayah;
  final String text;
  const QuranQuote(this.surah, this.ayah, this.text);
}

// (The home header basmala is the verified KFGQPC basmala, `basmalaUthmani`.)

/// Home footer — An-Nas 1.
const kHomeFooterAyah = QuranQuote(114, 1, 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ');
