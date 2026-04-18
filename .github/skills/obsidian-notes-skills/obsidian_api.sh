#!/usr/bin/env bash
set -euo pipefail

API_HOST="${OBSIDIAN_API_HOST:-https://127.0.0.1:27124}"
TOKEN="${OBSIDIAN_API_TOKEN:-}"

usage() {
  cat <<-USAGE
Usage: $0 METHOD PATH [DATA_JSON]
Examples:
  $0 GET /active/
  $0 GET /search --data-urlencode "q=term"
  $0 POST /files --data '{"path":"notes/foo.md","content":"# Title\nbody"}'

Environment variables:
  OBSIDIAN_API_HOST  default: https://127.0.0.1:27124
  OBSIDIAN_API_TOKEN Bearer token (required for authenticated endpoints)
USAGE
}

if [ "$#" -lt 2 ]; then
  usage
  exit 1
fi

METHOD="$1"
PATH="$2"
shift 2

CURL_OPTS=( -sS -k -H "Accept: application/json" )
if [ -n "$TOKEN" ]; then
  CURL_OPTS+=( -H "Authorization: Bearer $TOKEN" )
fi

# Allow passing arbitrary curl flags (e.g., --data, --data-urlencode)
if command -v curl >/dev/null 2>&1; then
  curl "${CURL_OPTS[@]}" -X "$METHOD" "${API_HOST%/}$PATH" "$@"
else
  # curl not available; try Python 3 fallback using urllib.request
  URL="${API_HOST%/}$PATH"
  # Extract common --data/--data-urlencode arguments if passed
  DATA=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --data=*) DATA="${1#--data=}"; shift ;;
      --data) shift; DATA="$1"; shift ;;
      --data-urlencode=*) DATA="${1#--data-urlencode=}"; shift ;;
      --data-urlencode) shift; DATA="$1"; shift ;;
      *) shift ;; 
    esac
  done
  python3 - "$METHOD" "$URL" "$DATA" <<'PY'
import sys, urllib.request, ssl, os
method, url, data = sys.argv[1], sys.argv[2], sys.argv[3]
req = urllib.request.Request(url, data=(data.encode('utf-8') if data else None), method=method)
req.add_header('Accept','application/json')
token = os.environ.get('OBSIDIAN_API_TOKEN','')
if token:
    req.add_header('Authorization','Bearer ' + token)
ctx = ssl._create_unverified_context()
with urllib.request.urlopen(req, context=ctx) as resp:
    sys.stdout.buffer.write(resp.read())
PY
fi

echo
