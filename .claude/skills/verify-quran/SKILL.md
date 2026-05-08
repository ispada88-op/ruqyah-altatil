---
name: verify-quran
description: Verify Quranic verses in the codebase against the Tanzil Uthmani reference text. Use whenever the user mentions adding, editing, or auditing Quran text in the app.
---

# Verify Quran Text

Quran text is sacred — never trust manual edits. Whenever the user wants to
add or change verses in `lib/data/verified_quran.dart` or `lib/data/quran_data.dart`:

## Workflow

1. **Source of truth**: Tanzil.net Uthmani XML (matches Madinah Mushaf KFGQPC).
2. **Method**: Compare character-by-character after Unicode NFC normalization.
3. **Acceptable normalizations**:
   - Remove waqf marks (ۖ ۗ ۘ ۙ ۚ ۛ ۜ) before compare — they're typesetting.
   - Treat `ـٰ` (tatweel + superscript alef) as equivalent to `ٰ` alone.
   - Different Unicode orderings of combining marks count as equivalent.
4. **Real differences** — flag immediately. Do not assume they're typos.
   Show the user diff and ask for confirmation against an authoritative source.

## Reference command

```bash
python3 scripts/verify_quran.py lib/data/verified_quran.dart
```

(If the script doesn't exist, point the user to:
`https://github.com/risan/quran-json` or pyquran package for the reference text.)

## Don'ts

- NEVER edit a verse based on hearing or memory.
- NEVER apply autocorrect / linters to verse strings.
- NEVER remove the ﴿N﴾ ayah markers — they're part of the display.
- If Tanzil and Madinah Mushaf differ on a specific verse, prefer Madinah Mushaf
  (KFGQPC) — that's our reference.
