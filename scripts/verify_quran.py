#!/usr/bin/env python3
"""Verify every Quran string in the app against the bundled Tanzil text.

    python3 scripts/verify_quran.py          # exit 0 = all verified

Reference: assets/quran/quran-uthmani.txt (Tanzil Uthmani 1.1, verbatim).
Checked files:
  lib/data/verified_quran.dart   (short surahs / ruqyah verses)
  lib/data/quran_data.dart       (Anfal, Dukhan, Saffat, Haqqa — from quran.com)
  lib/data/quran_extracts.dart   (generated ranges)

Allowed normalizations (typesetting only — never letters):
  * Unicode NFC (order of combining marks)
  * trailing ayah marker ﴿N﴾
  * tatweel before superscript alef (ـٰ ≡ ٰ) and hamza-on-tatweel (ـٔ ≡ ء)
    — Tanzil 1.0.2 vs 1.1 representation of the same glyphs
KNOWN_DIFFS lists reviewed differences that are not letter changes; anything
else fails. Never "fix" a failure by editing this script — check a printed
Madinah Mushaf and fix the text.
"""
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# (file, surah, ayah): reason — reviewed 2026-09-28, both are mark-level only
KNOWN_DIFFS = {
    ('quran_data.dart', 8, 23): 'extra sukun on و in «لَتَوَلَّوْا۟» (quran.com); Tanzil «لَتَوَلَّوا۟»',
    ('quran_data.dart', 69, 28): 'missing saktah sign ۜ after «مَالِيَهْ» (stripped on screen anyway)',
}


def load_tanzil():
    t = {}
    for line in (ROOT / 'assets/quran/quran-uthmani.txt').read_text(encoding='utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        s, a, txt = line.split('|', 2)
        t[(int(s), int(a))] = txt
    b = t[(1, 1)] + ' '
    for (s, a), txt in list(t.items()):
        if a == 1 and s not in (1, 9) and txt.startswith(b):
            t[(s, a)] = txt[len(b):]
    return t


def norm(x: str) -> str:
    x = unicodedata.normalize('NFC', x)
    x = re.sub(r'\s*﴿[٠-٩]+﴾\s*$', '', x).strip()
    x = x.replace('ـٰ', 'ٰ')
    x = x.replace('ءَ', 'ـَٔ')
    x = unicodedata.normalize('NFC', x.replace('ـ', ''))
    return x


def main():
    t = load_tanzil()
    assert len(t) == 6236, len(t)
    checked = failures = 0

    def check(fname, s, a, text):
        nonlocal checked, failures
        checked += 1
        if norm(text) == norm(t[(s, a)]):
            return
        if (fname, s, a) in KNOWN_DIFFS:
            return
        failures += 1
        print(f'DIFF {fname} {s}:{a}\n  app: {text}\n  ref: {t[(s, a)]}')

    src = (ROOT / 'lib/data/verified_quran.dart').read_text(encoding='utf-8')
    for block in re.split(r'\nconst \w+ = SurahVerses\(', src)[1:]:
        s = int(re.search(r'surahNumber:\s*(\d+)', block).group(1))
        for n, parts in re.findall(r"Verse\((\d+),\s*((?:'[^']*'\s*)+)\)", block):
            check('verified_quran.dart', s, int(n), ''.join(re.findall(r"'([^']*)'", parts)))

    src = (ROOT / 'lib/data/quran_data.dart').read_text(encoding='utf-8')
    for name, s in [('anfalVerses', 8), ('dukhanVerses', 44), ('saffatVerses', 37), ('haqqaVerses', 69)]:
        body = re.search(r'const List<String> ' + name + r' = \[(.*?)\n\];', src, re.S).group(1)
        verses = re.findall(r"'([^']*)'", body)
        for i, v in enumerate(verses, 1):
            check('quran_data.dart', s, i, v)

    src = (ROOT / 'lib/data/quran_extracts.dart').read_text(encoding='utf-8')
    for s, a, body in re.findall(r'QuranExtract\((\d+), (\d+), \d+, \[(.*?)\]\);', src, re.S):
        for i, v in enumerate(re.findall(r"'([^']*)'", body)):
            check('quran_extracts.dart', int(s), int(a) + i, v)

    print(f'verify_quran: {checked} verses checked, {failures} unexpected differences, '
          f'{len(KNOWN_DIFFS)} known mark-level differences')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
