#!/usr/bin/env bash
set -euo pipefail

# Load helper to populate OBSIDIAN_API_TOKEN from keychain, XDG config, or .env
if [ -f ".github/skills/obsidian-notes-skills/obsidian_api_env.sh" ]; then
  # shellcheck source=/dev/null
  . ".github/skills/obsidian-notes-skills/obsidian_api_env.sh"
fi

# Load .env files (repo root .env first, then skill-local .env) if OBSIDIAN_API_TOKEN not already set.
# This reads simple KEY=VALUE lines and exports them. It avoids executing arbitrary shell by parsing lines only.
for ENVFILE in .env .github/skills/obsidian-notes-skills/.env; do
  if [ -f "$ENVFILE" ]; then
    while IFS='=' read -r key val; do
      # skip comments and empty lines
      case "$key" in
        ''|\#*) continue ;;
      esac
      key="$(echo "$key" | tr -d '[:space:]')"
      # strip surrounding quotes from value
      val="$(echo "$val" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"
      export "$key"="$val"
    done < "$ENVFILE"
  fi
done

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
  # curl not available; try Python 3 fallback using urllib.request if python3 exists
  if command -v python3 >/dev/null 2>&1; then
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
  else
    echo "Error: neither curl nor python3 are available to make the HTTP request." >&2
    exit 2
  fi
fi

echo
