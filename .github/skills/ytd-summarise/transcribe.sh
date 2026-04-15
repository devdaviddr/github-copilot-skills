#!/bin/bash
set -euo pipefail

URL="$1"
OUTPUT_DIR="/tmp/yt-summarise"
TRANSCRIPT_DIR="$(pwd)/transcripts"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TRANSCRIPT_DIR"

VIDEO_ID=$(yt-dlp --get-id "$URL")
VIDEO_TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null || echo "unknown")
SAFE_TITLE=$(echo "$VIDEO_TITLE" | tr ' /' '__' | tr -cd '[:alnum:]_\-')
if [[ -z "$SAFE_TITLE" ]]; then
  SAFE_TITLE="unknown"
fi
TARGET_FILE="$TRANSCRIPT_DIR/${VIDEO_ID}_${SAFE_TITLE}.txt"

echo "Video ID: $VIDEO_ID"
echo "Title: $VIDEO_TITLE"
echo "Output file: $TARGET_FILE"

rm -f "$OUTPUT_DIR/audio.mp3" "$OUTPUT_DIR/audio.txt" "$OUTPUT_DIR/audio.vtt" "$TARGET_FILE"

echo "📥 Downloading audio..."
yt-dlp -x --audio-format mp3 -o "$OUTPUT_DIR/audio.%(ext)s" "$URL"

TRANSCRIPT_SOURCE="$OUTPUT_DIR/audio.txt"
if command -v whisper >/dev/null 2>&1; then
  echo "🎙️ Transcribing with Whisper..."
  whisper "$OUTPUT_DIR/audio.mp3" --model small --output_format txt --output_dir "$OUTPUT_DIR"
  if [[ ! -f "$TRANSCRIPT_SOURCE" ]]; then
    echo "Error: Whisper output not found."
    exit 1
  fi
else
  echo "⚠️ Whisper not installed; falling back to YouTube auto subtitles."
  yt-dlp --write-auto-sub --sub-lang en --skip-download -o "$OUTPUT_DIR/audio.%(ext)s" "$URL"
  VTT_FILE=$(ls "$OUTPUT_DIR"/audio*.vtt 2>/dev/null | head -n 1 || true)
  if [[ -z "$VTT_FILE" ]]; then
    echo "Error: fallback subtitles not found. Install whisper or provide subtitles."
    exit 1
  fi
  python3 - <<PY > "$TRANSCRIPT_SOURCE"
from pathlib import Path
import re
path = Path("$VTT_FILE")
text = path.read_text(encoding='utf-8', errors='ignore')
lines = []
for block in text.strip().split('\n\n'):
    sub_lines = [l.strip() for l in block.splitlines() if l.strip() and '-->' not in l and not l.strip().isdigit()]
    if sub_lines:
        lines.append(' '.join(sub_lines))
print('\n'.join(lines))
PY
fi

cp "$TRANSCRIPT_SOURCE" "$TARGET_FILE"

cat >> "$TARGET_FILE" <<EOF

---
Summary:
EOF

python3 - <<PY >> "$TARGET_FILE"
from pathlib import Path
path = Path("$TRANSCRIPT_SOURCE")
text = path.read_text(encoding='utf-8', errors='ignore').strip()
if not text:
    print('No transcript text available.')
    raise SystemExit(0)
lines = [l.strip() for l in text.splitlines() if l.strip()]
summary = ' '.join(lines[:4])
print(summary)
PY

echo "Saved transcript with summary to: $TARGET_FILE"
cat "$TARGET_FILE"
