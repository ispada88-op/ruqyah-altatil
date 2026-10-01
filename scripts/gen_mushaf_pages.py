#!/usr/bin/env python3
"""Builds assets/quran/mushaf_pages.json — the page layout of the Madinah Mushaf
(604 pages, 15 lines) from the King Fahd Complex «Mushaf Publisher» database.

Source: Quran.mdb (embedded in Library.LibraryBLL.DLL of «Mushaf Publisher Win
Setup V3.16», qurancomplex.gov.sa), tables Hafs_Word and Hafs_Page, exported to
JSON (one list of row objects per table; see docs/MUSHAF_PAGES.md).

  python3 scripts/gen_mushaf_pages.py Hafs_Word.json Hafs_Page.json

Every word of the mushaf is ONE glyph (PUA code point `FontCode`) of the page
font `FontName` (QCF4_Hafs_NN_W.ttf) — the glyph is the word as printed, so the
orthography/shaping is the Complex's own. Nothing here is typed by hand.
"""
import json, sys, collections, os

KIND = {1: 0, 6: 0, 7: 0, 8: 0, 5: 1, 4: 2}  # body | sura name | basmala


def main(word_json, page_json, out):
    words = json.load(open(word_json, encoding='utf-8'))
    pages_tbl = {r['page_no']: r for r in json.load(open(page_json, encoding='utf-8'))}
    fonts = sorted({x['FontName'] for x in words})
    fidx = {f: i for i, f in enumerate(fonts)}
    by = collections.defaultdict(lambda: collections.defaultdict(list))
    for x in words:
        by[x['PageNo']][x['LineNo']].append(x)
    assert sorted(by) == list(range(1, 605)), 'pages'
    pages = []
    for p in range(1, 605):
        lines, verses = [], []
        first_sura = None
        for ln in sorted(by[p]):
            ws = sorted(by[p][ln], key=lambda z: z['ID'])
            kinds = {KIND[x['Type']] for x in ws}
            fnts = {x['FontName'] for x in ws}
            assert len(kinds) == 1 and len(fnts) == 1, (p, ln)
            lines.append([kinds.pop(), fidx[fnts.pop()], ''.join(chr(x['FontCode']) for x in ws)])
            for x in ws:
                if x['Type'] == 6:
                    verses.append([x['Sura'], x['Verse']])
            if first_sura is None:
                first_sura = ws[0]['Sura']
        pages.append({'s': first_sura, 'j': pages_tbl[p]['Part'], 'l': lines, 'v': verses})
    doc = {
        'source': 'KFGQPC Mushaf Publisher 3.16 — Hafs (QCF4) — Quran.mdb',
        'fonts': fonts,
        'pages': pages,
    }
    with open(out, 'w', encoding='ascii', newline='\n') as f:
        json.dump(doc, f, ensure_ascii=True, separators=(',', ':'))
        f.write('\n')
    print('pages', len(pages), 'lines', sum(len(p['l']) for p in pages), 'bytes', os.path.getsize(out))


if __name__ == '__main__':
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
    main(sys.argv[1], sys.argv[2], os.path.join(root, 'assets/quran/mushaf_pages.json'))
