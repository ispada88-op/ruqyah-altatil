#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# Compresses audio assets to reduce APK/AAB size.
# Original size:  ~133 MB (75 MB + 58 MB)
# After compress: ~25-30 MB combined
# Quality: voice-grade, transparent for spoken Quran recitation.
# ─────────────────────────────────────────────────────────────────────
# Requires: ffmpeg (https://ffmpeg.org)
# Run from project root:    bash scripts/compress_audio.sh
# ─────────────────────────────────────────────────────────────────────

set -e

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg not installed. Install from https://ffmpeg.org/download.html"
    echo "   Windows: choco install ffmpeg   (or scoop install ffmpeg)"
    echo "   macOS:   brew install ffmpeg"
    exit 1
fi

mkdir -p assets/audio/_original_backup

for f in assets/audio/*.mp3; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    # Skip if already compressed (check by size < 20MB)
    size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
    if [ "$size" -lt 20000000 ]; then
        echo "⏭️  Skip (already small): $name"
        continue
    fi

    echo "🎵 Compressing: $name ($(($size / 1024 / 1024)) MB)"
    cp "$f" "assets/audio/_original_backup/$name"

    # 64 kbps mono — transparent for voice recordings, ~75% smaller
    ffmpeg -y -i "assets/audio/_original_backup/$name" \
           -ac 1 -ar 22050 -b:a 64k \
           -map_metadata -1 \
           "$f" 2>/dev/null

    new_size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
    echo "   ✅ $(($new_size / 1024 / 1024)) MB (saved $((($size - $new_size) / 1024 / 1024)) MB)"
done

echo ""
echo "✅ Done. Originals kept in assets/audio/_original_backup/"
echo "   Test the app, then delete the backup folder before committing."
