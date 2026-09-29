#!/usr/bin/env python3
"""Verify every Quran string in the app against the bundled KFGQPC (Madinah) text.

    python3 scripts/verify_quran.py          # exit 0 = all verified

Reference: assets/quran/hafsData_v18.json — King Fahd Glorious Quran Printing
Complex «Hafs Uthmanic Script» data v0.18, verbatim (SHA-256 pinned in
test/quran_asset_test.dart), shown with the bundled font hafs.18.ttf.
Each record's aya_text is «body NBSP number»; the body is what is compared.

Checked (no allowlist, no equivalences — byte equality only):
  lib/data/quran_data.dart      GENERATED — byte-identical to the asset (body + tail)
  lib/data/quran_extracts.dart  GENERATED — byte-identical to the asset
  lib/data/verified_quran.dart  GENERATED — byte-identical to the asset
  every basmala constant        byte-identical to 1:1
  every other .dart file        must contain NO Uthmani-script text at all, so
                                no unverified ayah can hide anywhere in lib/.
  imla'i Quran quotes           (category 'ayah' adhkar, lib/data/quran_quotes.dart,
                                any ﴿…﴾ quote) must be whole words of the cited
                                (or, for ﴿…﴾, of some) ayah in Tanzil "simple"
                                text, scripts/ref/quran-simple.txt (SHA-256 pinned).

Never "fix" a failure by editing this script — re-run scripts/gen_quran_data.py
or check a printed Madinah Mushaf and fix the text.
"""
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AR_DIGITS = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')
QURAN_FILES = {'quran_data.dart', 'quran_extracts.dart', 'verified_quran.dart'}
# Uthmani-only characters (alef wasla, Quranic annotation marks, open tanween).
UTHMANI = re.compile('[ٱۖ-ࣰۭ-ࣲ]')


def skeleton(word):
    out = []
    for ch in word:
        o = ord(ch)
        if (0x0610 <= o <= 0x061A or 0x064B <= o <= 0x065F or o == 0x0670
                or 0x06D6 <= o <= 0x06ED or 0x08D3 <= o <= 0x08FF or o == 0x0640):
            continue
        out.append('ا' if o == 0x0671 else ch)
    return ''.join(out)


KF_JSON = ROOT / 'assets/quran/hafsData_v18.json'
KF_SHA256 = '5d8bb91726e482839d0057633cb1973031e4d706fa9604eea5e08892f20ba140'
NBSP = '\N{NO-BREAK SPACE}'


def load_kf():
    """-> ({(surah, ayah): body}, {(surah, ayah): aya_text})"""
    raw = KF_JSON.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == KF_SHA256, 'hafsData_v18.json changed'
    body, full = {}, {}
    for r in json.loads(raw.decode('utf-8')):
        m = re.fullmatch(r'(.*)' + NBSP + r'([٠-٩]+)', r['aya_text'], re.S)
        assert m and m.group(2).translate(AR_TO_INT) == str(r['aya_no']), (r['sora'], r['aya_no'])
        body[(r['sora'], r['aya_no'])] = m.group(1)
        full[(r['sora'], r['aya_no'])] = r['aya_text']
    return body, full


def dart_unescape(lit):
    """Inverse of gen_quran_data.dart_str for the escapes it emits."""
    return re.sub(r'\\(u00A0|.)', lambda m: NBSP if m.group(1) == 'u00A0' else m.group(1), lit)


def nfc(x):
    return unicodedata.normalize('NFC', x)


SIMPLE = ROOT / 'scripts/ref/quran-simple.txt'
SIMPLE_SHA256 = 'f3268cfe7a400add8a8024fe23368d66f58cc8baa51773fe94e323625c66344b'
AR_TO_INT = str.maketrans('٠١٢٣٤٥٦٧٨٩', '0123456789')


def load_simple():
    import hashlib
    raw = SIMPLE.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == SIMPLE_SHA256, 'quran-simple.txt changed'
    t = {}
    for line in raw.decode('utf-8').splitlines():
        if line and not line.startswith('#'):
            s, a, x = line.split('|', 2)
            t[(int(s), int(a))] = x
    b = t[(1, 1)] + ' '
    for s in range(2, 115):
        if s != 9 and t[(s, 1)].startswith(b):
            t[(s, 1)] = t[(s, 1)][len(b):]
    return t


def whole_words_of(quote, ayah):
    return f' {quote} ' in f' {ayah} '


def split_tail(v, expected):
    m = re.fullmatch(r'(.*)' + NBSP + r'([٠-٩]+)', v, re.S)
    if not m:
        return v, 'missing ayah-number tail'
    if m.group(2) != str(expected).translate(AR_DIGITS):
        return m.group(1), f'ayah number {m.group(2)} != {expected}'
    return m.group(1), None


def main():
    t, full = load_kf()
    assert len(t) == 6236, len(t)
    counts = {}
    for s, a in t:
        counts[s] = max(counts.get(s, 0), a)
    checked = failures = 0

    def fail(msg):
        nonlocal failures
        failures += 1
        print('FAIL', msg)

    # 1) verified_quran.dart
    src = (ROOT / 'lib/data/verified_quran.dart').read_text(encoding='utf-8')
    for block in re.split(r'\nconst \w+ = SurahVerses\(', src)[1:]:
        s = int(re.search(r'surahNumber:\s*(\d+)', block).group(1))
        for n, parts in re.findall(r"Verse\((\d+),\s*((?:'[^']*'\s*)+)\)", block):
            text = dart_unescape(''.join(re.findall(r"'([^']*)'", parts)))
            checked += 1
            ref = t[(s, int(n))]
            if text != ref:
                fail(f'verified_quran.dart {s}:{n} not byte-identical — re-run gen_quran_data.py'
                     f'\n  app: {text}\n  ref: {ref}')

    # 2) generated files: byte-identical, complete, correctly numbered
    src = (ROOT / 'lib/data/quran_data.dart').read_text(encoding='utf-8')
    for name, s in [('anfalVerses', 8), ('dukhanVerses', 44), ('saffatVerses', 37), ('haqqaVerses', 69)]:
        body = re.search(r'const List<String> ' + name + r' = \[(.*?)\n\];', src, re.S).group(1)
        verses = [dart_unescape(x) for x in re.findall(r"'([^']*)'", body)]
        if len(verses) != counts[s]:
            fail(f'quran_data.dart {name}: {len(verses)} ayat, surah {s} has {counts[s]}')
        for i, v in enumerate(verses, 1):
            checked += 1
            text, err = split_tail(v, i)
            if err:
                fail(f'quran_data.dart {s}:{i} {err}')
            elif v != full[(s, i)] or text != t[(s, i)]:
                fail(f'quran_data.dart {s}:{i} not byte-identical — re-run gen_quran_data.py')

    src = (ROOT / 'lib/data/quran_extracts.dart').read_text(encoding='utf-8')
    extracts = re.findall(r'QuranExtract\((\d+), (\d+), (\d+), \[(.*?)\]\);', src, re.S)
    if not extracts:
        fail('quran_extracts.dart: no extracts parsed')
    for s, a, b, body in extracts:
        verses = [dart_unescape(x) for x in re.findall(r"'([^']*)'", body)]
        if len(verses) != int(b) - int(a) + 1:
            fail(f'quran_extracts.dart {s}:{a}-{b}: {len(verses)} verses')
        for i, v in enumerate(verses):
            checked += 1
            if v != t[(int(s), int(a) + i)]:
                fail(f'quran_extracts.dart {s}:{int(a) + i} not byte-identical')

    # 3) every basmala constant
    basmala_ref = t[(1, 1)]
    for f in ('lib/data/quran_data.dart', 'lib/data/verified_quran.dart',
              'lib/services/quran_repository.dart'):
        for lit in re.findall(r"basmala\w*\s*[=:]\s*'([^']*)'", (ROOT / f).read_text(encoding='utf-8')):
            lit = dart_unescape(lit)
            checked += 1
            if lit != basmala_ref:
                fail(f'{f}: basmala literal differs from 1:1\n  app: {lit}\n  ref: {basmala_ref}')

    # 4) no Uthmani text anywhere else in lib/
    for p in sorted((ROOT / 'lib').rglob('*.dart')):
        if p.name in QURAN_FILES:
            continue
        code = p.read_text(encoding='utf-8')
        if p.name == 'quran_repository.dart':  # its basmala default is checked in (3)
            code = re.sub(r"String basmala = '[^']*';", '', code)
        for m in UTHMANI.finditer(code):
            line = code.count('\n', 0, m.start()) + 1
            fail(f'{p.relative_to(ROOT)}:{line} Uthmani text outside the verified Quran files')
            break

    # 5) imla'i Quran quotes outside the Uthmani files
    simple = load_simple()
    names = {name: int(n) for n, name in re.findall(
        r"SurahInfo\((\d+), '([^']+)'", (ROOT / 'lib/data/quran_index.dart').read_text(encoding='utf-8'))}
    hisn = (ROOT / 'lib/data/hisn_almuslim_dhikr.dart').read_text(encoding='utf-8')
    ayah_entries = re.findall(r"category: 'ayah', title: '([^']*)',\s*body: '([^']*)'", hisn)
    if len(ayah_entries) != hisn.count("category: 'ayah'"):
        fail("hisn_almuslim_dhikr.dart: an 'ayah' entry could not be parsed")
    for title, body in ayah_entries:
        checked += 1
        m = re.fullmatch(r'آية — (.+) ([٠-٩]+)', title)
        if not m or m.group(1) not in names:
            fail(f"hisn_almuslim_dhikr.dart: 'ayah' title must be «آية — السورة رقم»: {title}")
            continue
        key = (names[m.group(1)], int(m.group(2).translate(AR_TO_INT)))
        if key not in simple or not whole_words_of(body, simple[key]):
            fail(f'hisn_almuslim_dhikr.dart {title}: not whole words of the ayah'
                 f'\n  app: {body}\n  ref: {simple.get(key)}')
    quotes = re.findall(r"QuranQuote\((\d+), (\d+), '([^']*)'\)",
                        (ROOT / 'lib/data/quran_quotes.dart').read_text(encoding='utf-8'))
    if not quotes:
        fail('quran_quotes.dart: no quotes parsed')
    for s, a, text in quotes:
        checked += 1
        if not whole_words_of(text, simple.get((int(s), int(a)), '')):
            fail(f'quran_quotes.dart {s}:{a} not whole words of the ayah\n  app: {text}')
    for p in sorted((ROOT / 'lib').rglob('*.dart')):
        if p.name in QURAN_FILES:
            continue
        for q in re.findall(r'﴿([^﴾$]*[ء-ي][^﴾$]*)﴾', p.read_text(encoding='utf-8')):
            checked += 1
            if not any(whole_words_of(q, x) for x in simple.values()):
                fail(f'{p.relative_to(ROOT)}: ﴿{q}﴾ is not whole words of any ayah')

    print(f'verify_quran: {checked} strings checked, {failures} failures')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
