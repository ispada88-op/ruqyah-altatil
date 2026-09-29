// ═══════════════════════════════════════════════════════════════════════════
// بيانات «الرقية المستقلة» — رقية مستقلة عن رقية التعطيل
// ═══════════════════════════════════════════════════════════════════════════
//
// المكوّنات (بترتيب القراءة وعدد التكرار):
//   1. سورة الفاتحة ................................ ٧ مرات
//   2. المعوذات (الإخلاص والفلق والناس) ............ ٧ مرات
//   3. آيات من سورة طه (١٠٥-١٠٧) ................... ٧ مرات
//   4. آية من سورة هود (٤٤) ........................ ٧ مرات
//   5. بسم الله .................................... ٣ مرات
//   6. أعوذ بعزة الله وقدرته من شر ما أجد وأحاذر ... ٧ مرات
//   7. أسأل الله العظيم رب العرش العظيم أن يشفيني .. ٧ مرات
//
// النص القرآني من `verified_quran.dart` (عثماني موثّق) حصراً.
// الأذكار مضبوطة بالشكل ومصادرها مثبتة.
// ═══════════════════════════════════════════════════════════════════════════

import 'verified_quran.dart';

/// كتلة نصية داخل فقرة رقية: عنوان اختياري (اسم سورة/بسملة) + أسطر النص.
class RuqyahBlock {
  final String? heading;
  final List<String> lines;
  const RuqyahBlock({this.heading, required this.lines});
}

/// فقرة واحدة من الرقية المستقلة.
class GeneralRuqyahItem {
  final String title;
  final String? subtitle; // موضع الآيات مثل: طه (١٠٥-١٠٧)
  final int repeat; // عدد مرات القراءة
  final String? source; // تخريج الحديث للأذكار
  final String? note; // ملاحظة عملية من السنة
  final bool isQuran; // لاختيار خط المصحف في العرض
  final List<RuqyahBlock> blocks;

  const GeneralRuqyahItem({
    required this.title,
    required this.repeat,
    required this.blocks,
    this.subtitle,
    this.source,
    this.note,
    this.isQuran = false,
  });

  /// نص كامل للنسخ/المشاركة (مع اسم السورة وموضع الآيات للنص القرآني).
  String get plainText {
    final sb = StringBuffer();
    if (isQuran) sb.writeln(subtitle != null ? '$title — $subtitle' : title);
    for (final b in blocks) {
      if (b.heading != null) sb.writeln(b.heading);
      for (final l in b.lines) {
        sb.writeln(l);
      }
    }
    sb.write('(يُقرأ $repeatLabel)');
    return sb.toString();
  }

  /// «مرة واحدة» / «مرتان» / «٧ مرات» / «١٠٠ مرة» بالأرقام العربية.
  String get repeatLabel => repeatLabelFor(repeat);
}

/// صيغة العدد الصحيحة عربياً مع الأرقام العربية.
String repeatLabelFor(int n) {
  if (n == 1) return 'مرة واحدة';
  if (n == 2) return 'مرتان';
  final digits = n.toString().split('').map((d) => '٠١٢٣٤٥٦٧٨٩'[int.parse(d)]).join();
  return n <= 10 ? '$digits مرات' : '$digits مرة';
}

/// أسطر الآيات مع علامة رقم الآية ﴿N﴾.
List<String> verseLines(SurahVerses s) =>
    s.verses.map((v) => v.withMarker).toList(growable: false);

/// المعوذات الثلاث (الإخلاص والفلق والناس) مع البسملة — تُستخدم في أكثر من قسم.
List<RuqyahBlock> get muawwidhatBlocks => [
      RuqyahBlock(
        heading: 'سورة الإخلاص',
        lines: [basmalaUthmani, ...verseLines(surahAlIkhlas)],
      ),
      RuqyahBlock(
        heading: 'سورة الفلق',
        lines: [basmalaUthmani, ...verseLines(surahAlFalaq)],
      ),
      RuqyahBlock(
        heading: 'سورة الناس',
        lines: [basmalaUthmani, ...verseLines(surahAnNas)],
      ),
    ];

/// فقرات الرقية المستقلة بترتيب القراءة.
List<GeneralRuqyahItem> get generalRuqyahItems => [
      GeneralRuqyahItem(
        title: 'سورة الفاتحة',
        repeat: 7,
        isQuran: true,
        blocks: [RuqyahBlock(lines: verseLines(surahAlFatiha))],
      ),
      GeneralRuqyahItem(
        title: 'المعوذات',
        subtitle: 'الإخلاص والفلق والناس',
        repeat: 7,
        isQuran: true,
        blocks: muawwidhatBlocks,
      ),
      GeneralRuqyahItem(
        title: 'آيات من سورة طه',
        subtitle: 'طه (١٠٥-١٠٧)',
        repeat: 7,
        isQuran: true,
        blocks: [RuqyahBlock(lines: verseLines(taHaMountains))],
      ),
      GeneralRuqyahItem(
        title: 'آية من سورة هود',
        subtitle: 'هود (٤٤)',
        repeat: 7,
        isQuran: true,
        blocks: [RuqyahBlock(lines: verseLines(hudFloodVerse))],
      ),
      const GeneralRuqyahItem(
        title: 'بسم الله',
        repeat: 3,
        source: 'رواه مسلم (٢٢٠٢)',
        note: 'من السنة: تضع يدك على موضع الألم ثم تقول: بسم الله (ثلاثاً).',
        blocks: [
          RuqyahBlock(lines: ['بِسْمِ اللهِ، بِسْمِ اللهِ، بِسْمِ اللهِ']),
        ],
      ),
      const GeneralRuqyahItem(
        title: 'التعوّذ بعزة الله',
        repeat: 7,
        source: 'رواه ابن ماجه، وأصله في صحيح مسلم (٢٢٠٢)',
        blocks: [
          RuqyahBlock(lines: [
            'أَعُوذُ بِعِزَّةِ اللهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
          ]),
        ],
      ),
      const GeneralRuqyahItem(
        title: 'سؤال الله الشفاء',
        repeat: 7,
        source: 'رواه أبو داود والترمذي',
        note: 'وإذا رقيتَ غيرك فقل: «أَنْ يَشْفِيَكَ».',
        blocks: [
          RuqyahBlock(lines: [
            'أَسْأَلُ اللهَ الْعَظِيمَ، رَبَّ الْعَرْشِ الْعَظِيمِ، أَنْ يَشْفِيَنِي',
          ]),
        ],
      ),
    ];
