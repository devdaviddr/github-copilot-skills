#!/usr/bin/env bash
# obsidian_api_env.sh - helper to load OBSIDIAN_API_TOKEN from multiple sources.
# Order: 1) macOS Keychain (service 'obsidian-token'), 2) XDG config (~/.config/obsidian-api), 3) repo .env, 4) skill-local .env
# Exits silently if no token found; callers should check OBSIDIAN_API_TOKEN.

_OBSENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_OBSENV_REPO="$(cd "$_OBSENV_DIR/../../.." && pwd)"

# Try macOS Keychain
if command -v security >/dev/null 2>&1; then
  if _token=$(security find-generic-password -s obsidian-token -w 2>/dev/null); then
    export OBSIDIAN_API_TOKEN="$_token"
  fi
fi

# Try XDG config file (~/.config/obsidian-api)
_XDG_CONF="$HOME/.config/obsidian-api"
if [ -z "${OBSIDIAN_API_TOKEN:-}" ] && [ -f "$_XDG_CONF" ]; then
  while IFS='=' read -r k v; do
    case "$k" in
      OBSIDIAN_API_TOKEN) v="${v%\"}"; v="${v#\"}"; export OBSIDIAN_API_TOKEN="$v"; break ;;
    esac
  done < "$_XDG_CONF"
fi

# Fall back to .env files (repo root then skill-local) using absolute paths
if [ -z "${OBSIDIAN_API_TOKEN:-}" ]; then
  for _ENVFILE in "$_OBSENV_REPO/.env" "$_OBSENV_DIR/.env"; do
    if [ -f "$_ENVFILE" ]; then
      while IFS='=' read -r key val; do
        case "$key" in
          ''|\#*) continue ;;
        esac
        key="$(echo "$key" | tr -d '[:space:]')"
        val="$(echo "$val" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"
        if [ "$key" = "OBSIDIAN_API_TOKEN" ] && [ -n "$val" ]; then
          export OBSIDIAN_API_TOKEN="$val"
          break 2
        fi
        if [ "$key" = "OBSIDIAN_API_HOST" ] && [ -n "$val" ]; then
          export OBSIDIAN_API_HOST="$val"
        fi
      done < "$_ENVFILE"
    fi
  done
fi

# If still not set, do nothing — caller should warn if needed.
