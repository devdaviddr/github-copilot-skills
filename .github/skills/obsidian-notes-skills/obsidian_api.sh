#!/usr/bin/env bash
set -euo pipefail

# Resolve script location so .env loading works regardless of cwd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Load helper to populate OBSIDIAN_API_TOKEN from keychain, XDG config, or .env
if [ -f "$SCRIPT_DIR/obsidian_api_env.sh" ]; then
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/obsidian_api_env.sh"
fi

# Load .env files (repo root first, then skill-local) if OBSIDIAN_API_TOKEN not already set.
if [ -z "${OBSIDIAN_API_TOKEN:-}" ]; then
  for ENVFILE in "$REPO_ROOT/.env" "$SCRIPT_DIR/.env"; do
    if [ -f "$ENVFILE" ]; then
      while IFS='=' read -r key val; do
        case "$key" in
          ''|\#*) continue ;;
        esac
        key="$(echo "$key" | tr -d '[:space:]')"
        val="$(echo "$val" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"
        export "$key"="$val"
      done < "$ENVFILE"
    fi
  done
fi

API_HOST="${OBSIDIAN_API_HOST:-https://127.0.0.1:27124}"
TOKEN="${OBSIDIAN_API_TOKEN:-}"

usage() {
  cat <<-USAGE
Usage: $0 METHOD API_PATH [curl-flags...]
Examples:
  $0 GET /active/
  $0 GET /vault/notes/foo.md
  $0 PUT /vault/notes/foo.md --data-binary @file.md -H "Content-Type: text/markdown"
  $0 POST /search/simple/?query=term
  $0 POST /vault/notes/foo.md --data "text to append" -H "Content-Type: text/plain"

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
API_PATH="$2"
shift 2

CURL_OPTS=( -sS -k )
if [ -n "$TOKEN" ]; then
  CURL_OPTS+=( -H "Authorization: Bearer $TOKEN" )
fi

curl "${CURL_OPTS[@]}" -X "$METHOD" "${API_HOST%/}${API_PATH}" "$@"
echo
