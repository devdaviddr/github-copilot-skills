#!/usr/bin/env bash
set -euo pipefail

# setup_env.sh: interactive helper to create a .env file for the obsidian skills
# Usage: ./setup_env.sh [--save-keychain]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE="$SCRIPT_DIR/.env.example"
DEST="$SCRIPT_DIR/.env"

if [ ! -f "$EXAMPLE" ]; then
  echo ".env.example not found in $SCRIPT_DIR" >&2
  exit 1
fi

read -rp "Obsidian API host (default: https://127.0.0.1:27124): " HOST
HOST=${HOST:-https://127.0.0.1:27124}

# read token silently
read -rsp "Enter OBSIDIAN_API_TOKEN (input hidden): " TOKEN
echo

# write .env (overwrite)
cat > "$DEST" <<EOF
OBSIDIAN_API_TOKEN=$TOKEN
OBSIDIAN_API_HOST=$HOST
EOF

echo "Wrote $DEST"

echo "IMPORTANT: Add $DEST to your .gitignore to avoid committing secrets."

# Offer to save to macOS Keychain for convenience
if command -v security >/dev/null 2>&1; then
  read -rp "Save token to macOS Keychain (service 'obsidian-token')? [y/N]: " save
  if [[ "$save" =~ ^[Yy]$ ]]; then
    security add-generic-password -s obsidian-token -a "$USER" -w "$TOKEN" -U >/dev/null 2>&1 || true
    echo "Saved token to Keychain under service 'obsidian-token'. Use: export OBSIDIAN_API_TOKEN=\"\$(security find-generic-password -s obsidian-token -w)\""
  fi
fi

echo "Done. To use in this shell: export \\$(sed -n '1p' $DEST)"
