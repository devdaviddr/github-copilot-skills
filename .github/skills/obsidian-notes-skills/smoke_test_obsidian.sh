#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$ROOT/obsidian_api.sh"

if [ -z "${OBSIDIAN_API_TOKEN:-}" ]; then
  echo "OBSIDIAN_API_TOKEN is not set. Export it before running smoke tests." >&2
  exit 2
fi

echo "Checking /active/ endpoint..."
"$HELPER" GET /active/ || { echo "GET /active/ failed" >&2; exit 1; }

echo "Searching for term 'test'..."
"$HELPER" GET /search --data-urlencode "q=test" || { echo "GET /search failed" >&2; exit 1; }

# Dry-run of append (safe)
if [ -x "$ROOT/append-note/run" ]; then
  echo "Running append-note dry-run on notes/test-smoke.md"
  "$ROOT/append-note/run" --dry-run "notes/test-smoke.md" "\n- smoke test entry" || { echo "append dry-run failed" >&2; exit 1; }
else
  echo "append-note/run not found or not executable; skipping append dry-run"
fi

echo "Smoke tests completed successfully."
