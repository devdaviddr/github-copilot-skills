#!/bin/bash
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

echo "📥 Downloading audio..."
yt-dlp -x --audio-format mp3 -o "$OUTPUT_DIR/audio.%(ext)s" "$URL"

echo "🎙️ Transcribing with Whisper..."
whisper "$OUTPUT_DIR/audio.mp3" \
  --model small \
  --output_format txt \
  --output_dir "$OUTPUT_DIR"

if [[ ! -f "$OUTPUT_DIR/audio.txt" ]]; then
  echo "Error: Transcription output not found."
  exit 1
fi

# Save original transcript in target file
cp "$OUTPUT_DIR/audio.txt" "$TARGET_FILE"

# Append summary section
cat >> "$TARGET_FILE" <<EOF

---
Summary:
EOF

python3 - <<PY >> "$TARGET_FILE"
from pathlib import Path
path = Path("$OUTPUT_DIR/audio.txt")
text = path.read_text(encoding='utf-8', errors='ignore').strip()
if not text:
    print('No transcript text available.')
    raise SystemExit(0)

# Naive summary: first 4 non-empty lines as sentences
lines = [l.strip() for l in text.splitlines() if l.strip()]
summary = ' '.join(lines[:4])
print(summary)
PY

echo "Saved transcript with summary to: $TARGET_FILE"
cat "$TARGET_FILE"
