#!/bin/bash
set -euo pipefail

URL="$1"
OUTPUT_DIR="/tmp/yt-summarise"
TRANSCRIPT_DIR="$(pwd)/transcripts"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TRANSCRIPT_DIR"

VIDEO_ID=$(yt-dlp --get-id "$URL")
VIDEO_TITLE=$(yt-dlp --get-title "$URL" 2>/dev/null || echo "unknown")
VIDEO_CHANNEL=$(yt-dlp --print "%(channel)s" "$URL" 2>/dev/null || echo "unknown")
SAFE_TITLE=$(echo "$VIDEO_TITLE" | tr ' /' '__' | tr -cd '[:alnum:]_\-')
if [[ -z "$SAFE_TITLE" ]]; then
  SAFE_TITLE="unknown"
fi
TARGET_FILE="$TRANSCRIPT_DIR/${VIDEO_ID}_${SAFE_TITLE}.md"

echo "Video ID: $VIDEO_ID"
echo "Title: $VIDEO_TITLE"
echo "Output file: $TARGET_FILE"

rm -f "$OUTPUT_DIR/audio.mp3" "$OUTPUT_DIR/audio.txt" "$OUTPUT_DIR/audio.vtt" "$OUTPUT_DIR/audio.md" "$TARGET_FILE"

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
import re
from pathlib import Path

path = Path("$VTT_FILE")
text = path.read_text(encoding='utf-8', errors='ignore')

def clean_line(line):
    line = re.sub(r'<\d{2}:\d{2}:\d{2}\.\d+>', '', line)  # remove inline timestamps
    line = re.sub(r'</?c>', '', line)                        # remove <c> tags
    line = re.sub(r'<[^>]+>', '', line)                      # remove any remaining tags
    return line.strip()

lines = []
for block in re.split(r'\n\n+', text.strip()):
    for raw in block.splitlines():
        raw = raw.strip()
        if (not raw
                or raw.startswith('WEBVTT')
                or raw.startswith('Kind:')
                or raw.startswith('Language:')
                or '-->' in raw
                or re.match(r'^\d+$', raw)):
            continue
        cleaned = clean_line(raw)
        if cleaned:
            lines.append(cleaned)

# Deduplicate consecutive identical lines (YouTube rolling captions repeat)
deduped = []
prev = None
for line in lines:
    if line != prev:
        deduped.append(line)
        prev = line

# Drop lines that are a leading substring of the next (rolling window artefact)
final = []
for i, line in enumerate(deduped):
    if i + 1 < len(deduped) and deduped[i + 1].startswith(line):
        continue
    final.append(line)

# Join short caption fragments into full-width paragraphs.
# Split on sentence-ending punctuation to form natural paragraph breaks.
words = ' '.join(final)
words = re.sub(r'\s+', ' ', words).strip()
sentences = re.split(r'(?<=[.!?])\s+', words)

# Group into paragraphs of ~5 sentences each for readability
para_size = 5
paragraphs = []
for i in range(0, len(sentences), para_size):
    paragraphs.append(' '.join(sentences[i:i + para_size]))

print('\n\n'.join(paragraphs))
PY
fi

cp "$TRANSCRIPT_SOURCE" "$TARGET_FILE"

# Prepend markdown header with video metadata
HEADER="# ${VIDEO_TITLE}

**Channel:** ${VIDEO_CHANNEL}
**URL:** ${URL}

---

## Transcript

"
echo -e "${HEADER}$(cat "$TARGET_FILE")" > "$TARGET_FILE"

echo "✅ Saved transcript to: $TARGET_FILE"
cat "$TARGET_FILE"
