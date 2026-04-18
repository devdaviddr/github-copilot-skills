#!/usr/bin/env bash
set -euo pipefail

# append_note.sh: read an Obsidian note, append text, and write it back using obsidian_api.sh
# Supports --dry-run to avoid making changes.
# Usage: append_note.sh [--dry-run] "path/to/note.md" "Text to append\n"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HELPER="$ROOT_DIR/obsidian_api.sh"

usage(){
  cat <<USAGE
Usage: $0 [--dry-run] NOTE_PATH APPEND_TEXT
Example:
  $0 "notes/meeting.md" "\n- Action: follow up with team"
  $0 --dry-run "notes/meeting.md" "\n- Action: test"

This script URL-encodes the path, GETs the file, extracts content when JSON is returned,
concatenates the append text, then POSTs the updated content back to the API unless --dry-run is set.
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

# URL-encode the path using python3 (safe and portable)
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for URL encoding and JSON handling" >&2
  exit 2
fi
ENCODED_PATH=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1], safe=''))" "$NOTE_PATH")

# Read the file via helper
RAW=$("$HELPER" GET "/files/$ENCODED_PATH")

# Extract content if JSON with common keys, otherwise use raw body
CURRENT_CONTENT=$(python3 - <<PY
import sys, json
s = sys.stdin.read()
try:
    obj = json.loads(s)
    if isinstance(obj, dict):
        for k in ('content','text','body'):
            if k in obj:
                print(obj[k], end='')
                raise SystemExit(0)
    # if it's a plain string
    if isinstance(obj, str):
        print(obj, end='')
        raise SystemExit(0)
    # fallback: pretty-print JSON
    print(json.dumps(obj))
except Exception:
    # not JSON, print raw
    sys.stdout.write(s)
PY
<<<"$RAW")

# Build new content
NEW_CONTENT="$CURRENT_CONTENT$APPEND_TEXT"

# Build JSON payload safely using python
JSON_BODY=$(python3 - <<PY
import json,sys
payload = {"path": sys.argv[1], "content": sys.stdin.read()}
print(json.dumps(payload))
PY
"$NOTE_PATH" <<<"$NEW_CONTENT")

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN: would POST the following payload to /files:"
  echo
  python3 -m json.tool <<<"$JSON_BODY" || echo "$JSON_BODY"
  exit 0
fi

# POST updated content
"$HELPER" POST /files --data "$JSON_BODY"

echo "Appended to $NOTE_PATH"
