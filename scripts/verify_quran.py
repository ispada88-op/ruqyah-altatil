#!/usr/bin/env python3
"""Verify every Quran string in the app against the bundled Tanzil text.

    python3 scripts/verify_quran.py          # exit 0 = all verified

Reference: assets/quran/quran-uthmani.txt (Tanzil Uthmani 1.1, verbatim; its
SHA-256 is pinned in test/quran_asset_test.dart). Cross-checked 2026-09-28:
all 6236 ayat identical to Quran.com (text_uthmani) letter-for-letter and
mark-for-mark, and letter-identical to the King Fahd Complex Hafs text.

Checked:
  lib/data/quran_data.dart      GENERATED — must be byte-identical to the asset
  lib/data/quran_extracts.dart  GENERATED — must be byte-identical to the asset
  lib/data/verified_quran.dart  hand-imported from Tanzil 1.0.2 — NFC-equal to
                                the asset, with exactly two representation
                                equivalences of 1.0.2 vs 1.1 (never letters):
                                  ـٰ  ≡  ٰ     (superscript alef on a kashida)
                                  ءَا ≡ ـَٔا   (hamza before alef, e.g. ٱلْءَاخِرَةِ)
  every basmala constant        must equal 1:1 (NFC)
  every other .dart file        must contain NO Uthmani-script text at all, so
                                no unverified ayah can hide anywhere in lib/.

Never "fix" a failure by editing this script — re-run scripts/gen_quran_data.py
or check a printed Madinah Mushaf and fix the text.
"""
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


def load_tanzil():
    t = {}
    for line in (ROOT / 'assets/quran/quran-uthmani.txt').read_text(encoding='utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        s, a, txt = line.split('|', 2)
        t[(int(s), int(a))] = txt
    head = [skeleton(w) for w in t[(1, 1)].split(' ')]
    for s in range(2, 115):
        words = t[(s, 1)].split(' ')
        has = [skeleton(w) for w in words[:len(head)]] == head and len(words) > len(head)
        if s == 9:
            assert not has
            continue
        assert has, f'surah {s}: basmala prefix not found'  # 95, 97 use «بِّسْمِ»
        t[(s, 1)] = ' '.join(words[len(head):])
    return t


def nfc(x):
    return unicodedata.normalize('NFC', x)


def equivalent_102(x):
    """Tanzil 1.0.2 -> 1.1 representation (see module docstring)."""
    x = nfc(x).replace('ـٰ', 'ٰ')
    x = x.replace('ءَا', 'ـَٔا')
    return nfc(x)


def split_marker(v, expected):
    m = re.fullmatch(r'(.*) ﴿([٠-٩]+)﴾', v, re.S)
    if not m:
        return v, 'missing ayah marker'
    if m.group(2) != str(expected).translate(AR_DIGITS):
        return m.group(1), f'ayah marker ﴿{m.group(2)}﴾ != {expected}'
    return m.group(1), None


def main():
    t = load_tanzil()
    assert len(t) == 6236, len(t)
    counts = {}
    for s, a in t:
        counts[s] = max(counts.get(s, 0), a)
    checked = failures = equivalences = 0

    def fail(msg):
        nonlocal failures
        failures += 1
        print('FAIL', msg)

    # 1) verified_quran.dart
    src = (ROOT / 'lib/data/verified_quran.dart').read_text(encoding='utf-8')
    for block in re.split(r'\nconst \w+ = SurahVerses\(', src)[1:]:
        s = int(re.search(r'surahNumber:\s*(\d+)', block).group(1))
        for n, parts in re.findall(r"Verse\((\d+),\s*((?:'[^']*'\s*)+)\)", block):
            text = ''.join(re.findall(r"'([^']*)'", parts))
            checked += 1
            ref = t[(s, int(n))]
            if nfc(text) == nfc(ref):
                continue
            if equivalent_102(text) == equivalent_102(ref):
                equivalences += 1
                continue
            fail(f'verified_quran.dart {s}:{n}\n  app: {text}\n  ref: {ref}')

    # 2) generated files: byte-identical, complete, correctly numbered
    src = (ROOT / 'lib/data/quran_data.dart').read_text(encoding='utf-8')
    for name, s in [('anfalVerses', 8), ('dukhanVerses', 44), ('saffatVerses', 37), ('haqqaVerses', 69)]:
        body = re.search(r'const List<String> ' + name + r' = \[(.*?)\n\];', src, re.S).group(1)
        verses = re.findall(r"'([^']*)'", body)
        if len(verses) != counts[s]:
            fail(f'quran_data.dart {name}: {len(verses)} ayat, surah {s} has {counts[s]}')
        for i, v in enumerate(verses, 1):
            checked += 1
            text, err = split_marker(v, i)
            if err:
                fail(f'quran_data.dart {s}:{i} {err}')
            elif text != t[(s, i)]:
                fail(f'quran_data.dart {s}:{i} not byte-identical — re-run gen_quran_data.py')

    src = (ROOT / 'lib/data/quran_extracts.dart').read_text(encoding='utf-8')
    extracts = re.findall(r'QuranExtract\((\d+), (\d+), (\d+), \[(.*?)\]\);', src, re.S)
    if not extracts:
        fail('quran_extracts.dart: no extracts parsed')
    for s, a, b, body in extracts:
        verses = re.findall(r"'([^']*)'", body)
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
            checked += 1
            if nfc(lit) != nfc(basmala_ref):
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

    print(f'verify_quran: {checked} strings checked, {failures} failures, '
          f'{equivalences} verses via the two 1.0.2 representation equivalences')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
