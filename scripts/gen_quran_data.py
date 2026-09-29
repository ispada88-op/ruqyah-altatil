#!/usr/bin/env python3
"""Generate every Quran data file of the app from the ONE pinned official asset:
lib/data/quran_index.dart, quran_extracts.dart, quran_data.dart, verified_quran.dart.

Source (never edit by hand, SHA-256 pinned in test/quran_asset_test.dart):
  assets/quran/hafsData_v18.json  - King Fahd Glorious Quran Printing Complex
      (KFGQPC, Madinah) «Hafs Uthmanic Script» data, v0.18 — the text that goes
      with the bundled font assets/fonts/kfgqpc/hafs.18.ttf. Verbatim copy of
      https://qurancomplex.gov.sa/en/techquran/dev/ (hafsData_v18.json); the
      official site is unreachable from some networks, so the same file was
      taken from the GitHub mirror thetruetruth/quran-data-kfgqpc (hash equal).

Each record's aya_text is «<ayah body> NBSP <Arabic-Indic ayah number>»: the
font draws the number after the NBSP as the ornamental ayah end sign. The body
is used for verses; the full string (body + marker) for the long surahs.

Surah names / Meccan-Medinan flags below come from Tanzil metadata (tanzil.net,
CC BY 3.0) with four hamza fixes already applied (see NAME_FIXES history in
git). Ayah counts and juz starts are taken from the KFGQPC data itself.

Usage:  python3 scripts/gen_quran_data.py
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QURAN = ROOT / 'assets/quran/hafsData_v18.json'

AR_DIGITS = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')
NBSP = '\N{NO-BREAK SPACE}'
BS = chr(92)  # backslash, spelled out so tooling never rewrites the escapes below


def load_quran():
    """-> ({(surah, ayah): body}, {(surah, ayah): body + NBSP + digits}, [records], basmala)"""
    records = json.loads(QURAN.read_text(encoding='utf-8'))
    assert len(records) == 6236, len(records)
    body, full = {}, {}
    for i, r in enumerate(records, 1):
        assert r['id'] == i
        s, a, txt = r['sora'], r['aya_no'], r['aya_text']
        m = re.fullmatch(r'(.*)' + NBSP + r'([٠-٩]+)', txt, re.S)
        assert m, f'{s}:{a} has no NBSP+number tail'
        assert m.group(2) == str(a).translate(AR_DIGITS), f'{s}:{a} marker mismatch'
        assert (s, a) not in body
        body[(s, a)] = m.group(1)
        full[(s, a)] = txt
    basmala = body[(1, 1)]
    return body, full, records, basmala


def write_lf(path, text):
    """Always LF, on every OS (the repo pins byte-exact generated files)."""
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def dart_str(s: str) -> str:
    """Dart single-quoted literal; the only invisible character (NBSP) is escaped."""
    return "'" + (s.replace(BS, BS + BS).replace("'", BS + "'")
                  .replace(NBSP, BS + 'u00A0')) + "'"


# (number, name, Meccan) — Tanzil metadata + hamza fixes (إبراهيم، الإنسان بهمزة
# القطع؛ الانفطار، الانشقاق بهمزة الوصل).
SURAHS = [
    (1, 'الفاتحة', True),
    (2, 'البقرة', False),
    (3, 'آل عمران', False),
    (4, 'النساء', False),
    (5, 'المائدة', False),
    (6, 'الأنعام', True),
    (7, 'الأعراف', True),
    (8, 'الأنفال', False),
    (9, 'التوبة', False),
    (10, 'يونس', True),
    (11, 'هود', True),
    (12, 'يوسف', True),
    (13, 'الرعد', False),
    (14, 'إبراهيم', True),
    (15, 'الحجر', True),
    (16, 'النحل', True),
    (17, 'الإسراء', True),
    (18, 'الكهف', True),
    (19, 'مريم', True),
    (20, 'طه', True),
    (21, 'الأنبياء', True),
    (22, 'الحج', False),
    (23, 'المؤمنون', True),
    (24, 'النور', False),
    (25, 'الفرقان', True),
    (26, 'الشعراء', True),
    (27, 'النمل', True),
    (28, 'القصص', True),
    (29, 'العنكبوت', True),
    (30, 'الروم', True),
    (31, 'لقمان', True),
    (32, 'السجدة', True),
    (33, 'الأحزاب', False),
    (34, 'سبإ', True),
    (35, 'فاطر', True),
    (36, 'يس', True),
    (37, 'الصافات', True),
    (38, 'ص', True),
    (39, 'الزمر', True),
    (40, 'غافر', True),
    (41, 'فصلت', True),
    (42, 'الشورى', True),
    (43, 'الزخرف', True),
    (44, 'الدخان', True),
    (45, 'الجاثية', True),
    (46, 'الأحقاف', True),
    (47, 'محمد', False),
    (48, 'الفتح', False),
    (49, 'الحجرات', False),
    (50, 'ق', True),
    (51, 'الذاريات', True),
    (52, 'الطور', True),
    (53, 'النجم', True),
    (54, 'القمر', True),
    (55, 'الرحمن', False),
    (56, 'الواقعة', True),
    (57, 'الحديد', False),
    (58, 'المجادلة', False),
    (59, 'الحشر', False),
    (60, 'الممتحنة', False),
    (61, 'الصف', False),
    (62, 'الجمعة', False),
    (63, 'المنافقون', False),
    (64, 'التغابن', False),
    (65, 'الطلاق', False),
    (66, 'التحريم', False),
    (67, 'الملك', True),
    (68, 'القلم', True),
    (69, 'الحاقة', True),
    (70, 'المعارج', True),
    (71, 'نوح', True),
    (72, 'الجن', True),
    (73, 'المزمل', True),
    (74, 'المدثر', True),
    (75, 'القيامة', True),
    (76, 'الإنسان', False),
    (77, 'المرسلات', True),
    (78, 'النبإ', True),
    (79, 'النازعات', True),
    (80, 'عبس', True),
    (81, 'التكوير', True),
    (82, 'الانفطار', True),
    (83, 'المطففين', True),
    (84, 'الانشقاق', True),
    (85, 'البروج', True),
    (86, 'الطارق', True),
    (87, 'الأعلى', True),
    (88, 'الغاشية', True),
    (89, 'الفجر', True),
    (90, 'البلد', True),
    (91, 'الشمس', True),
    (92, 'الليل', True),
    (93, 'الضحى', True),
    (94, 'الشرح', True),
    (95, 'التين', True),
    (96, 'العلق', True),
    (97, 'القدر', True),
    (98, 'البينة', False),
    (99, 'الزلزلة', False),
    (100, 'العاديات', True),
    (101, 'القارعة', True),
    (102, 'التكاثر', True),
    (103, 'العصر', True),
    (104, 'الهمزة', True),
    (105, 'الفيل', True),
    (106, 'قريش', True),
    (107, 'الماعون', True),
    (108, 'الكوثر', True),
    (109, 'الكافرون', True),
    (110, 'النصر', False),
    (111, 'المسد', True),
    (112, 'الإخلاص', True),
    (113, 'الفلق', True),
    (114, 'الناس', True),
]


def gen_index(records):
    counts, juz = {}, {}
    for r in records:
        counts[r['sora']] = max(counts.get(r['sora'], 0), r['aya_no'])
        juz.setdefault(r['jozz'], (r['sora'], r['aya_no']))
    assert len(SURAHS) == 114 and sorted(counts) == list(range(1, 115))
    assert sorted(juz) == list(range(1, 31))
    out = [
        '// GENERATED by scripts/gen_quran_data.py from assets/quran/hafsData_v18.json — DO NOT EDIT.',
        '// Ayah counts and juz starts: King Fahd Glorious Quran Printing Complex (Madinah Mushaf).',
        '// Surah names / type: Tanzil Project (tanzil.net), CC BY 3.0, with hamza fixes.',
        '',
        'class SurahInfo {',
        '  final int number;',
        '  final String name;',
        '  final int ayahCount;',
        '  final bool meccan;',
        '  const SurahInfo(this.number, this.name, this.ayahCount, this.meccan);',
        '}',
        '',
        '/// (surah, ayah) where each of the 30 juz starts (Madinah Mushaf).',
        'class JuzStart {',
        '  final int juz;',
        '  final int surah;',
        '  final int ayah;',
        '  const JuzStart(this.juz, this.surah, this.ayah);',
        '}',
        '',
        'const List<SurahInfo> kSurahs = [',
    ]
    for n, name, meccan in SURAHS:
        out.append(f"  SurahInfo({n}, {dart_str(name)}, {counts[n]}, {'true' if meccan else 'false'}),")
    out += ['];', '', f'const int kTotalAyat = {sum(counts.values())};', '',
            'const List<JuzStart> kJuzStarts = [']
    for j in range(1, 31):
        out.append(f'  JuzStart({j}, {juz[j][0]}, {juz[j][1]}),')
    out.append('];')
    write_lf(ROOT / 'lib/data/quran_index.dart', '\n'.join(out) + '\n')
    assert sum(counts.values()) == 6236


# Verse ranges used by «رقى حسب الحالة» (see lib/data/ruqyah_types_data.dart).
EXTRACTS = {
    'arafSihr': (7, 117, 119),   # الأعراف ١١٧-١١٩
    'yunusSihr': (10, 79, 82),   # يونس ٧٩-٨٢
    'tahaSihr': (20, 65, 69),    # طه ٦٥-٦٩
}

SRC_LINE = '// GENERATED by scripts/gen_quran_data.py from assets/quran/hafsData_v18.json'
SRC_LINE2 = '// (KFGQPC Hafs v0.18, SHA-256 pinned in test/quran_asset_test.dart) — DO NOT EDIT.'


def gen_extracts(body):
    out = [
        SRC_LINE, SRC_LINE2,
        '// test/quran_asset_test.dart re-checks every line against the bundled asset.',
        '',
        '/// A contiguous verse range: ayah bodies exactly as in the KFGQPC asset',
        '/// (without the ayah-number tail).',
        'class QuranExtract {',
        '  final int surah;',
        '  final int from;',
        '  final int to;',
        '  final List<String> verses;',
        '  const QuranExtract(this.surah, this.from, this.to, this.verses);',
        '}',
        '',
    ]
    for name, (s, a, b) in EXTRACTS.items():
        out.append(f'const {name} = QuranExtract({s}, {a}, {b}, [')
        for i in range(a, b + 1):
            out.append(f'  {dart_str(body[(s, i)])},')
        out.append(']);')
        out.append('')
    write_lf(ROOT / 'lib/data/quran_extracts.dart', '\n'.join(out))


# Whole surahs used by the written ruqyah (lib/data/written_roqia_data.dart).
LONG_SURAHS = [
    ('anfalVerses', 8, 75, 'الأنفال'),
    ('dukhanVerses', 44, 59, 'الدخان'),
    ('saffatVerses', 37, 182, 'الصافات'),
    ('haqqaVerses', 69, 52, 'الحاقة'),
]


def gen_long_surahs(full, basmala):
    out = [
        SRC_LINE, SRC_LINE2,
        '// Each verse is the asset\'s aya_text verbatim (body + NBSP + Arabic-Indic',
        '// number, which the font draws as the ayah end sign).',
        '// ' + ' + '.join(f'{name} ({count})' for _, _, count, name in LONG_SURAHS),
        '',
        f'const String basmala = {dart_str(basmala)};',
    ]
    for const, s, count, _ in LONG_SURAHS:
        assert (s, count) in full and (s, count + 1) not in full, f'surah {s} ayah count'
        out.append('')
        out.append(f'const List<String> {const} = [')
        for a in range(1, count + 1):
            out.append(f'  {dart_str(full[(s, a)])},')
        out.append('];')
    write_lf(ROOT / 'lib/data/quran_data.dart', '\n'.join(out) + '\n')


# (const name, doc comment, SurahVerses.name, surah, first, last, show basmala)
VERIFIED = [
    ('surahAlFatiha', 'سورة الفاتحة - 7 آيات', 'سورة الفاتحة', 1, 1, 7, False),
    ('surahAlBaqarahOpening', 'أوائل سورة البقرة (1-5)', 'سورة البقرة (أول 5 آيات)', 2, 1, 5, True),
    ('ayatAlKursi', 'آية الكرسي (البقرة 255)', 'آية الكرسي', 2, 255, 255, False),
    ('surahAlBaqarahClosing', 'خواتيم سورة البقرة (285-286)', 'خواتيم سورة البقرة (285-286)', 2, 285, 286, False),
    ('surahAzZalzalah', 'سورة الزلزلة - 8 آيات', 'سورة الزلزلة', 99, 1, 8, True),
    ('surahAlQariah', 'سورة القارعة - 11 آية', 'سورة القارعة', 101, 1, 11, True),
    ('surahAlKafirun', 'سورة الكافرون - 6 آيات', 'سورة الكافرون', 109, 1, 6, True),
    ('surahAlIkhlas', 'سورة الإخلاص - 4 آيات', 'سورة الإخلاص', 112, 1, 4, True),
    ('surahAlFalaq', 'سورة الفلق - 5 آيات', 'سورة الفلق', 113, 1, 5, True),
    ('surahAnNas', 'سورة الناس - 6 آيات', 'سورة الناس', 114, 1, 6, True),
    ('taHaMountains', 'آيات من سورة طه (105-107)', 'آيات من سورة طه', 20, 105, 107, False),
    ('hudFloodVerse', 'آية من سورة هود (44)', 'آية من سورة هود', 11, 44, 44, False),
]

VERIFIED_CLASSES = """/// نموذج آية قرآنية واحدة.
class Verse {
  final int number;
  final String text;
  const Verse(this.number, this.text);

  /// النص متبوعاً بمسافة غير قاطعة ورقم الآية بالأرقام العربية الهندية —
  /// الصيغة نفسها في ملف مجمع الملك فهد، وخط المجمع يرسم الرقم علامةَ نهاية آية.
  String get withMarker {
    const map = {'0':'٠','1':'١','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩'};
    final arabicNum = number.toString().split('').map((d) => map[d] ?? d).join();
    return '$text\\u00A0$arabicNum';
  }
}

/// مجموعة آيات من سورة معينة.
class SurahVerses {
  final String name;
  final int surahNumber;
  final String? basmala; // null للسور التي لا تبدأ بالبسملة
  final List<Verse> verses;

  const SurahVerses({
    required this.name,
    required this.surahNumber,
    required this.verses,
    this.basmala,
  });
}
"""


def gen_verified(body, basmala):
    out = [
        SRC_LINE, SRC_LINE2,
        '// Every verse is the asset text byte for byte; scripts/verify_quran.py re-checks it.',
        '// To add verses: extend VERIFIED in the generator and re-run it.',
        '',
        VERIFIED_CLASSES,
        f'const String basmalaUthmani = {dart_str(basmala)};',
    ]
    for const, doc, name, s, a, b, show in VERIFIED:
        assert (s, b) in body
        out += ['', f'/// {doc}', f'const {const} = SurahVerses(',
                f'  name: {dart_str(name)},', f'  surahNumber: {s},']
        if show:
            out.append('  basmala: basmalaUthmani,')
        out.append('  verses: [')
        for n in range(a, b + 1):
            out.append(f'    Verse({n}, {dart_str(body[(s, n)])}),')
        out += ['  ],', ');']
    write_lf(ROOT / 'lib/data/verified_quran.dart', '\n'.join(out) + '\n')


if __name__ == '__main__':
    body, full, records, basmala = load_quran()
    assert len(body) == 6236
    gen_index(records)
    gen_extracts(body)
    gen_long_surahs(full, basmala)
    gen_verified(body, basmala)
    print('ok: 6236 ayat; extracts:', ', '.join(EXTRACTS),
          '; long surahs:', ', '.join(c for c, *_ in LONG_SURAHS))
