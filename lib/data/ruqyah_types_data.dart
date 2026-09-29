// ═══════════════════════════════════════════════════════════════════════════
// «رقى حسب الحالة» — آيات وأدعية مأثورة من القرآن والسنة
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ محتوى شرعي — يراجعه صاحب التطبيق قبل كل إصدار. لا تُضف نصاً من الذاكرة.
//
// المصادر:
//   • الآيات: `verified_quran.dart` + `quran_extracts.dart` (مولَّد من نص مجمع الملك فهد hafsData_v18.json).
//   • الأدعية: «حصن المسلم» الأبواب ٣٤ (الهم والحزن) و٣٥ (الكرب) و٤٨ (ما يعوذ
//     به الأولاد) — نصها يُفحص حرفاً بحرف بـ scripts/verify_adhkar.py.
//   • رقية جبريل: صحيح مسلم (كتاب السلام) — مُدرجة يدوياً ومستثناة من الفحص الآلي.
//   • آيات السحر: مما ذكره الشيخ عبدالعزيز بن باز رحمه الله في علاج السحر.
//
// رقية «الكشف» الخاصة بالشيخ فهد القرني غير مضمَّنة: تحتاج نصها من مصدر الشيخ.
// ═══════════════════════════════════════════════════════════════════════════

import 'general_ruqyah_data.dart';
import 'quran_extracts.dart';
import 'verified_quran.dart';

class RuqyahType {
  final String id;
  final String title;
  final String subtitle;
  final String intro;
  final List<GeneralRuqyahItem> Function() items;

  const RuqyahType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.items,
  });
}

String _arNum(int n) =>
    n.toString().split('').map((d) => '٠١٢٣٤٥٦٧٨٩'[int.parse(d)]).join();

List<String> _extractLines(QuranExtract e) => [
      for (var i = 0; i < e.verses.length; i++)
        Verse(e.from + i, e.verses[i]).withMarker,
    ];

String _range(String surah, QuranExtract e) =>
    '$surah (${_arNum(e.from)}-${_arNum(e.to)})';

GeneralRuqyahItem _fatiha() => GeneralRuqyahItem(
      title: 'سورة الفاتحة',
      repeat: 1,
      isQuran: true,
      source: 'الرقية بالفاتحة — متفق عليه',
      blocks: [RuqyahBlock(lines: verseLines(surahAlFatiha))],
    );

GeneralRuqyahItem _kursi() => GeneralRuqyahItem(
      title: 'آية الكرسي',
      subtitle: 'البقرة (٢٥٥)',
      repeat: 1,
      isQuran: true,
      blocks: [RuqyahBlock(lines: verseLines(ayatAlKursi))],
    );

GeneralRuqyahItem _muawwidhat({int repeat = 1, String? source, String? note}) =>
    GeneralRuqyahItem(
      title: 'المعوذات',
      subtitle: 'الإخلاص والفلق والناس',
      repeat: repeat,
      isQuran: true,
      source: source,
      note: note,
      blocks: muawwidhatBlocks,
    );

GeneralRuqyahItem _dua(String title, String text, String source,
        {int repeat = 1, String? note}) =>
    GeneralRuqyahItem(
      title: title,
      repeat: repeat,
      source: source,
      note: note,
      blocks: [
        RuqyahBlock(lines: [text])
      ],
    );

final List<RuqyahType> kRuqyahTypes = [
  RuqyahType(
    id: 'sihr',
    title: 'رقية السحر',
    subtitle: 'آيات إبطال السحر والمعوذات',
    // النصان بين «» منقولان حرفياً من binbaz.org.sa/articles/88 (تحقق 2026-09-28).
    intro: 'ذكر الشيخ عبدالعزيز بن باز رحمه الله في رسالة «حكم السحر والكهانة وما '
        'يتعلق بها» من علاج السحر: «أن يأخذ سبع ورقات من السدر الأخضر فيدقها بحجر '
        'أو نحوه، ويجعلها في إناء ويصب عليه من الماء ما يكفيه للغسل»، ويقرأ فيه آية '
        'الكرسي وآيات السحر من الأعراف ويونس وطه، وسورة الكافرون والإخلاص '
        'والمعوذتين، «وبعد قراءة ما ذكر في الماء يشرب منه ثلاث مرات، ويغتسل '
        'بالباقي، وبذلك يزول الداء إن شاء الله».',
    items: () => [
      _kursi(),
      GeneralRuqyahItem(
        title: 'آيات من سورة الأعراف',
        subtitle: _range('الأعراف', arafSihr),
        repeat: 1,
        isQuran: true,
        blocks: [RuqyahBlock(lines: _extractLines(arafSihr))],
      ),
      GeneralRuqyahItem(
        title: 'آيات من سورة يونس',
        subtitle: _range('يونس', yunusSihr),
        repeat: 1,
        isQuran: true,
        blocks: [RuqyahBlock(lines: _extractLines(yunusSihr))],
      ),
      GeneralRuqyahItem(
        title: 'آيات من سورة طه',
        subtitle: _range('طه', tahaSihr),
        repeat: 1,
        isQuran: true,
        blocks: [RuqyahBlock(lines: _extractLines(tahaSihr))],
      ),
      GeneralRuqyahItem(
        title: 'سورة الكافرون',
        repeat: 1,
        isQuran: true,
        blocks: [
          RuqyahBlock(lines: [basmalaUthmani, ...verseLines(surahAlKafirun)]),
        ],
      ),
      _muawwidhat(),
    ],
  ),
  RuqyahType(
    id: 'ayn',
    title: 'رقية العين والحسد',
    subtitle: 'الفاتحة والمعوذات ورقية جبريل عليه السلام',
    intro: 'ومن الوقاية قوله ﷺ: «إِذَا رَأَى أَحَدُكُمْ مِنْ أَخِيهِ، أَوْ مِنْ '
        'نَفْسِهِ، أَوْ مِنْ مَالِهِ مَا يُعْجِبُهُ فَلْيَدْعُ لَهُ بِالْبَرَكَةِ، '
        'فَإِنَّ الْعَيْنَ حَقٌّ» (رواه أحمد وابن ماجه).',
    items: () => [
      _fatiha(),
      _kursi(),
      _muawwidhat(
        repeat: 3,
        source: 'رواه الترمذي',
        note: 'كان ﷺ يتعوّذ من الجانّ وعين الإنسان، فلما نزلت المعوذتان أخذ بهما.',
      ),
      _dua(
        'رقية جبريل عليه السلام',
        'بِاسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِاسْمِ اللَّهِ أَرْقِيكَ',
        'رواه مسلم',
        note: 'رقى بها جبريلُ النبيَّ ﷺ، ويرقي بها المسلم غيره.',
      ),
      _dua(
        'التعويذ النبوي',
        'أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
        'رواه أبو داود والترمذي، وأصله في البخاري',
        note: 'كان النبي ﷺ يعوّذ بها الحسن والحسين رضي الله عنهما.',
      ),
    ],
  ),
  RuqyahType(
    id: 'hamm',
    title: 'رقية الهم والحزن والقلق',
    subtitle: 'أدعية تفريج الهم والكرب',
    intro: 'أدعية مأثورة لتفريج الهم والكرب. ومع الرقية والدعاء لا تتردد في '
        'مراجعة طبيب أو مختص نفسي عند الحاجة؛ فطلب العلاج من الأخذ بالأسباب.',
    items: () => [
      _fatiha(),
      _dua(
        'دعاء الهم والحزن',
        'اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ، سَمَّيْتَ بِهِ نَفْسَكَ، أَوْ أَنْزَلْتَهُ فِي كِتَابِكَ، أَوْ عَلَّمْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوِ اسْتَأْثَرْتَ بِهِ فِي عِلْمِ الْغَيْبِ عِنْدَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجَلَاءَ حُزْنِي، وَذَهَابَ هَمِّي',
        'رواه أحمد',
      ),
      _dua(
        'الاستعاذة من الهم والحزن',
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
        'رواه البخاري',
      ),
      _dua(
        'دعاء الكرب',
        'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
        'متفق عليه',
      ),
      _dua(
        'رحمتك أرجو',
        'اللَّهُمَّ رَحْمَتَكَ أَرْجُو، فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لَا إِلَهَ إِلَّا أَنْتَ',
        'رواه أبو داود',
      ),
      _dua(
        'دعوة ذي النون',
        'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
        'رواه الترمذي',
      ),
      _dua(
        'الله ربي',
        'اللَّهُ اللَّهُ رَبِّي لَا أُشْرِكُ بِهِ شَيْئًا',
        'رواه أبو داود',
      ),
    ],
  ),
];

RuqyahType? ruqyahTypeById(String id) {
  for (final t in kRuqyahTypes) {
    if (t.id == id) return t;
  }
  return null;
}
