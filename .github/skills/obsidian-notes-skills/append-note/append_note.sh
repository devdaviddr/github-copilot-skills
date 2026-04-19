#!/usr/bin/env bash
set -euo pipefail

# append_note.sh: append text to an Obsidian note using POST /vault/{path}
# Usage: append_note.sh [--dry-run] "path/to/note.md" "Text to append"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HELPER="$ROOT_DIR/obsidian_api.sh"

usage(){
  cat <<USAGE
Usage: $0 [--dry-run] NOTE_PATH APPEND_TEXT
Example:
  $0 "notes/meeting.md" "- Action: follow up with team"
  $0 --dry-run "notes/meeting.md" "- Action: test"

POST /vault/{path} appends the given text to the note.
USAGE
}

DRY_RUN=0
if [ "$#" -lt 2 ]; then
  usage
  exit 1
fi

if [ "$1" = "--dry-run" ]; then
  DRY_RUN=1
  shift
fi

if [ "$#" -lt 2 ]; then
  usage
  exit 1
fi

NOTE_PATH="$1"
APPEND_TEXT="$2"

# URL-encode the path
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for URL encoding" >&2
  exit 2
fi
ENCODED_PATH=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1], safe='/'))" "$NOTE_PATH")

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN: would POST to /vault/$ENCODED_PATH with body:"
  echo "$APPEND_TEXT"
  exit 0
fi

# POST appends the body text to the note
"$HELPER" POST "/vault/$ENCODED_PATH" \
  -H "Content-Type: text/plain" \
  --data "$APPEND_TEXT"

echo "Appended to $NOTE_PATH"
