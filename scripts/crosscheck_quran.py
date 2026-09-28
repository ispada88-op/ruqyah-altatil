#!/usr/bin/env python3
"""Cross-check the bundled Tanzil text against two independent sources.

Run before changing assets/quran/quran-uthmani.txt (or once per release):

  1) Quran.com v4 Uthmani (mark-for-mark):
       curl -o qc.json "https://api.quran.com/api/v4/quran/verses/uthmani"
  2) King Fahd Complex (KFGQPC) Uthmani Hafs v13 (letter-for-letter):
       curl -o kf.json "https://raw.githubusercontent.com/fawazahmed0/quran-api/1/editions/ara-quranuthmanihaf.json"

  python3 scripts/crosscheck_quran.py qc.json kf.json      # exit 0 = clean

Result on 2026-09-28: Quran.com 6236/6236 identical (letters and every mark);
KFGQPC 6236/6236 identical letters. Known, reading-neutral differences with
KFGQPC: word joins in 15:7, 27:20, 36:22 (Tanzil and Quran.com write them
apart), encoding of hamza/tanween/sukun, and edition-specific waqf signs.
"""
import json
import sys
import unicodedata as ud
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_asset():
    t = {}
    for line in (ROOT / 'assets/quran/quran-uthmani.txt').read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            s, a, x = line.split('|', 2)
            t[(int(s), int(a))] = x
    head = letters(t[(1, 1)]).split()
    for s in range(2, 115):
        if s == 9:
            continue
        w = t[(s, 1)].split(' ')
        assert letters(' '.join(w[:4])).split() == head, s
        t[(s, 1)] = ' '.join(w[4:])
    return t


def letters(x, unify_yeh=False):
    out = []
    for ch in ud.normalize('NFD', x):
        if ch == ' ':
            out.append(ch)
            continue
        if ud.category(ch) != 'Lo' or ch in 'ۥۦ':
            continue  # marks, tatweel, RLM, rub-el-hizb, sajdah, small waw/yeh
        ch = 'ا' if ch == 'ٱ' else ch
        if unify_yeh and ch == 'ى':
            ch = 'ي'  # KFGQPC encodes dotless yeh as U+064A
        out.append(ch)
    return ''.join(out)


def marks_equal(a, b):
    def n(x):
        x = x.replace('۞ ', '').strip()          # Quran.com rub-el-hizb token
        x = x.replace('ـٰ', 'ٰ')        # kashida + superscript alef
        return ud.normalize('NFC', x)
    return n(a) == n(b)


def main(qc_path, kf_path):
    t = load_asset()
    qc = {tuple(map(int, v['verse_key'].split(':'))): v['text_uthmani']
          for v in json.load(open(qc_path, encoding='utf-8'))['verses']}
    kf = {(v['chapter'], v['verse']): v['text']
          for v in json.load(open(kf_path, encoding='utf-8'))['quran']}
    assert len(t) == len(qc) == len(kf) == 6236
    bad = 0
    for k in sorted(t):
        if not marks_equal(t[k], qc[k]):
            bad += 1
            print('QURAN.COM DIFF', k, '\n  asset:', t[k], '\n  qc:   ', qc[k])
        a = letters(t[k], True)
        b = letters(kf[k], True)
        if a.replace(' ', '') != b.replace(' ', ''):
            bad += 1
            print('KFGQPC LETTER DIFF', k, '\n  asset:', a, '\n  kf:   ', b)
    print(f'crosscheck: 6236 ayat, {bad} differences')
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(*sys.argv[1:3]))
