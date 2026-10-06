#!/usr/bin/env python3
"""Letter-by-letter check of lib/data/adhkar_data.dart against Hisn al-Muslim.

Usage: python3 scripts/verify_adhkar.py DIR
       DIR holds hisn_27.json hisn_34.json hisn_35.json hisn_48.json downloaded from
       https://www.hisnmuslim.com/api/ar/<N>.json

Also checks the duas in lib/data/ruqyah_types_data.dart against chapters 34/35/48
(the one hadith not in those chapters — رقية جبريل, Sahih Muslim — is allowlisted).

Compares the consonant skeleton (diacritics, punctuation and bracketed notes
removed) of every morning dhikr with the book text, and every evening dhikr
with the book's «وإذا أمسى قال» wording (or the morning text with the book's
own morning→evening substitutions). Any mismatch prints both skeletons and
exits 1 — fix the Dart text, never the checker.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIAC = re.compile('[ؐ-ًؚ-ٰٟۖ-ۭـ]')


def skeleton(t: str) -> str:
    t = t.replace('ﷺ', 'صلى الله عليه وسلم')
    t = DIAC.sub('', t)
    t = re.sub(r'\[[^\]]*\]', ' ', t)            # [وإذا أمسى قال: ...]
    # count / timing notes such as (ثلاث مرات) (مائة مرة) (إذا أصبح) — not dhikr text
    t = t.replace('((', ' ').replace('))', ' ')   # the book wraps each dhikr in (( ))
    t = re.sub(r'\((?=[^()]{0,40}\))(?:[^()]*مر[ةا]ت?[^()]*|[^()]*أصبح[^()]*|[^()]*أمسى[^()]*|[^()]*الكسل[^()]*)\)', ' ', t)
    t = re.sub(r'،?\s*أو\s*$', ' ', t.strip())      # dangling «أو» before a removed note
    t = t.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا').replace('ٱ', 'ا')
    t = re.sub(r'[^ء-ي ]', ' ', t)
    return ' '.join(t.split())


def dart_strings(kind: str):
    src = (ROOT / 'lib/data/adhkar_data.dart').read_text(encoding='utf-8')
    return [m.group(1) for m in re.finditer(kind + r":\s*\n?\s*'([^']+)'", src)]


EVENING_SUBS = [
    ('امسينا', 'اصبحنا'), ('وامسى', 'واصبح'), ('امسيت', 'اصبحت'), ('ما امسى بي', 'ما اصبح بي'),
    ('هذه الليلة', 'هذا اليوم'), ('ما بعدها', 'ما بعده'), ('فتحها', 'فتحه'), ('ونصرها', 'ونصره'),
    ('ونورها', 'ونوره'), ('وبركتها', 'وبركته'), ('وهداها', 'وهداه'), ('ما فيها', 'ما فيه'),
]


def load_book(path):
    items = json.load(open(path, encoding='utf-8-sig'))
    return [it['ARABIC_TEXT'] for it in list(items.values())[0]]


MANUAL_DUAS = {'رقية جبريل عليه السلام'}  # Sahih Muslim, not in the fetched chapters


def check_duas(d):
    book = [skeleton(b) for i in (34, 35, 48) for b in load_book(Path(d) / f'hisn_{i}.json')]
    src = (ROOT / 'lib/data/ruqyah_types_data.dart').read_text(encoding='utf-8')
    ok = bad = 0
    for title, text in re.findall(r"_dua\(\s*'([^']+)',\s*'([^']+)'", src):
        if title in MANUAL_DUAS:
            continue
        sk = skeleton(text)
        # exact, or the full dua inside the book's narration («كان ﷺ يعوذ … ((النص))»)
        if sk in book or any(len(sk) > 30 and sk in b for b in book):
            ok += 1
        else:
            bad += 1
            print('DUA MISMATCH:', title, '|', sk)
    print(f'ruqyah duas check: {ok} ok, {bad} mismatch')
    return bad


def main(d):
    book = load_book(Path(d) / 'hisn_27.json')
    book_sk = [skeleton(b) for b in book]
    evening_in_book = [skeleton(m) for b in book for m in re.findall(r'أمسى قال: ([^\]]+)\]', b)]
    ok = bad = 0
    for text in dart_strings('morning'):
        if skeleton(text) in book_sk:
            ok += 1
        else:
            bad += 1
            print('MORNING MISMATCH:', skeleton(text))
    for text in dart_strings('evening'):
        sk = skeleton(text)
        back = sk
        for ev, mo in EVENING_SUBS:
            back = back.replace(ev, mo)
        if back in book_sk or sk in evening_in_book:
            ok += 1
        else:
            bad += 1
            print('EVENING MISMATCH:', sk, '\n   back->', back)
    print(f'adhkar check: {ok} ok, {bad} mismatch')
    bad += check_duas(d)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
