#!/usr/bin/env bash
# Tiny wrapper to run ytd-list scripts. Chooses API-based script if YT_API_KEY or --api-key is provided, else uses yt-dlp.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_SCRIPT="$SCRIPT_DIR/fetch_videos.py"
YTDLP_SCRIPT="$SCRIPT_DIR/fetch_videos_yt_dlp.py"

show_help(){
  cat <<EOF
Usage: $(basename "$0") [--api-key KEY] [--channel-id ID | --channel-url URL] [--out PATH] [--full]

Examples:
  # Use API (if you have a key):
  YT_API_KEY=KEY $(basename "$0") --channel-id UC... --out videos.csv

  # No-key mode (yt-dlp):
  $(basename "$0") --channel-url "https://www.youtube.com/channel/UC..." --out videos.csv

Options:
  --api-key KEY       Pass API key (overrides YT_API_KEY env var)
  --channel-id ID     Channel ID (UC...); script will use API-mode when key present
  --channel-url URL   Channel page URL (for yt-dlp mode)
  --out PATH          Output CSV path (default: videos.csv)
  --full              Fetch full metadata (slower; for yt-dlp mode)
  -h, --help          Show this help
EOF
}

# Parse args
ARGS=()
API_KEY=""
CHANNEL_ID=""
CHANNEL_URL=""
OUT="videos.csv"
FULL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-key) API_KEY="$2"; shift 2;;
    --channel-id) CHANNEL_ID="$2"; shift 2;;
    --channel-url) CHANNEL_URL="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --full) FULL="--full"; shift;;
    -h|--help) show_help; exit 0;;
    --) shift; break;;
    *) ARGS+=("$1"); shift;;
  esac
done

# Decide which script to run
if [[ -n "${API_KEY}" ]]; then
  export YT_API_KEY="$API_KEY"
fi

if [[ -n "${YT_API_KEY:-}" || -n "$API_KEY" ]]; then
  # prefer API script
  if [[ -z "$CHANNEL_ID" && -z "$CHANNEL_URL" ]]; then
    echo "Error: --channel-id or --channel-url required for API mode" >&2
    show_help
    exit 2
  fi
  # If channel-url provided, try to extract channel id if looks like /channel/UC...
  if [[ -z "$CHANNEL_ID" && -n "$CHANNEL_URL" ]]; then
    if [[ "$CHANNEL_URL" =~ /channel/([^/?#]+) ]]; then
      CHANNEL_ID="${BASH_REMATCH[1]}"
    fi
  fi
  # Run API script
  python "$API_SCRIPT" --channel-id "$CHANNEL_ID" --api-key "${YT_API_KEY:-}" --out "$OUT"
else
  # Use yt-dlp script
  if [[ -n "$CHANNEL_ID" && -z "$CHANNEL_URL" ]]; then
    CHANNEL_URL="https://www.youtube.com/channel/$CHANNEL_ID"
  fi
  if [[ -z "$CHANNEL_URL" ]]; then
    echo "Error: --channel-url or --channel-id required for yt-dlp mode" >&2
    show_help
    exit 2
  fi
  # Ensure yt-dlp is installed
  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "yt-dlp not found. Install it with: pip install --user yt-dlp" >&2
    exit 3
  fi
  if [[ -n "$FULL" ]]; then
    python "$YTDLP_SCRIPT" --channel-url "$CHANNEL_URL" --out "$OUT" --full
  else
    python "$YTDLP_SCRIPT" --channel-url "$CHANNEL_URL" --out "$OUT"
  fi
fi
