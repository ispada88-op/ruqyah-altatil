---
name: verify-quran
description: Verify Quranic verses in the codebase against the pinned King Fahd Complex (Madinah Mushaf) text. Use whenever the user mentions adding, editing, or auditing Quran text in the app.
---

# Verify Quran Text

Quran text is sacred — never trust manual edits.

## Source of truth

`assets/quran/hafsData_v18.json` — King Fahd Glorious Quran Printing Complex
(KFGQPC, Madinah) Hafs v0.18, verbatim, SHA-256 pinned (`test/quran_asset_test.dart`,
`scripts/verify_quran.py`). It is shown with the byte-identical font
`assets/fonts/kfgqpc/hafs.18.ttf` (EULA: never modify/convert/sell — see CLAUDE.md).

## Workflow

1. Never type an ayah. Add ranges to `EXTRACTS` / `VERIFIED` in
   `scripts/gen_quran_data.py`, then run it — it writes `lib/data/*quran*.dart` from the JSON.
2. Run `python3 scripts/verify_quran.py` — **byte equality only**, no normalisation,
   no allowlist. Any failure = fix the source/generator, never the script.
3. `python3 scripts/crosscheck_quran.py` compares the letters with the Tanzil reference
   (`scripts/ref/quran-uthmani-tanzil.txt`); only 2:72 is a known difference.
4. Imla'i quotes outside the Mushaf must be whole words of the cited ayah in
   `scripts/ref/quran-simple.txt`.

## Don'ts

- NEVER edit a verse based on hearing or memory, and never "fix" spelling to match another edition.
- NEVER apply autocorrect / linters / formatters to verse strings.
- NEVER change a letter or mark between the data and the screen (no substitutions, no
  font weight — use `AppTextStyles.mushaf` / `QuranText`).
- The ayah-number tail (NBSP + Arabic-Indic digits) is part of the KFGQPC format: the
  font draws it as the end-of-ayah sign; for copy/share use `quranForSharing`.
