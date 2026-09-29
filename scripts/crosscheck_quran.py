#!/usr/bin/env python3
"""Cross-check the bundled KFGQPC (Madinah) text against an independent source.

The app's Quran text is assets/quran/hafsData_v18.json (King Fahd Complex,
Hafs v0.18). This script compares its LETTERS with the Tanzil Uthmani 1.1 text
kept for reference in scripts/ref/quran-uthmani-tanzil.txt (Quran.com-identical),
ignoring every mark, so a corrupted or truncated asset is caught by a second,
unrelated encoding of the same Mushaf.

  python3 scripts/crosscheck_quran.py       # exit 0 = only the known differences

Known difference (2026-09-29): 2:72 «فَٱدَّٰرَٰٔتُمۡ» — King Fahd writes the hamza as
a full letter (ء with sukun) where Tanzil uses a hamza mark. Yeh is unified (ى = ي) before comparing because the
Madinah print writes «فِي / ٱلَّذِي / شَيۡءٍ» with two dots where Tanzil writes
dotless «فِى / ٱلَّذِى / شَىْءٍ» (~2300 ayat) — the app follows the Madinah print.
Everything else is letter-identical.
"""
import json
import sys
import unicodedata as ud
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NBSP = '\N{NO-BREAK SPACE}'
KNOWN = {(2, 72)}


def letters(x):
    out = []
    for ch in ud.normalize('NFD', x):
        if ud.category(ch) != 'Lo':
            continue  # marks, tatweel, small letters, signs
        out.append({'ٱ': 'ا', 'ى': 'ي', 'ٲ': 'ا'}.get(ch, ch))
    return ''.join(out)


def load_kf():
    return {(r['sora'], r['aya_no']): r['aya_text'].rsplit(NBSP, 1)[0]
            for r in json.loads((ROOT / 'assets/quran/hafsData_v18.json').read_text(encoding='utf-8'))}


def load_tanzil():
    t = {}
    for line in (ROOT / 'scripts/ref/quran-uthmani-tanzil.txt').read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            s, a, x = line.split('|', 2)
            t[(int(s), int(a))] = x
    head = letters(t[(1, 1)])
    for s in range(2, 115):
        if s != 9:  # Tanzil glues the basmala to ayah 1 of every surah but 1 and 9
            L = letters(t[(s, 1)])
            assert L.startswith(head), s
            t[(s, 1)] = L[len(head):]
    return t


def main():
    kf, tz = load_kf(), load_tanzil()
    assert len(kf) == len(tz) == 6236
    diff = {k for k in kf if letters(kf[k]) != letters(tz[k])}
    for k in sorted(diff - KNOWN):
        print('UNEXPECTED DIFF', k, '\n  kf:', letters(kf[k]), '\n  tz:', letters(tz[k]))
    for k in sorted(KNOWN - diff):
        print('known diff no longer differs', k)
    print(f'crosscheck: 6236 ayat, {len(diff)} letter differences ({len(diff & KNOWN)} known)')
    return 1 if diff != KNOWN else 0


if __name__ == '__main__':
    sys.exit(main())
