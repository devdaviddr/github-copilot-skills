#!/bin/bash
# Server health checkup script
# Credentials can be overridden via environment variables:
#   SERVER_HOST, SERVER_USER, SERVER_PASS
#
# WARNING: Storing passwords in scripts is only appropriate for local/private use.
# Prefer SSH key-based auth for shared or production environments.

# Load local .env if present (kept out of git via .gitignore)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

SERVER_HOST="${SERVER_HOST:-}"
SERVER_USER="${SERVER_USER:-}"
SERVER_PASS="${SERVER_PASS:-}"

if [ -z "$SERVER_HOST" ] || [ -z "$SERVER_USER" ] || [ -z "$SERVER_PASS" ]; then
  echo "ERROR: SERVER_HOST, SERVER_USER, and SERVER_PASS must be set. Create .github/skills/server-checkup/.env or export them before running."
  exit 1
fi

# Parse flags
CHECK_DOCKER=0
for arg in "$@"; do
  case "$arg" in
    --docker) CHECK_DOCKER=1 ;;
  esac
done

# Check for sshpass
if ! command -v sshpass &>/dev/null; then
  echo "ERROR: sshpass is not installed."
  echo "Install it with:  brew install hudochenkov/sshpass/sshpass"
  exit 1
fi

# Determine output path (local machine, not remote)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || pwd)/outputs/server-checkup"
mkdir -p "$OUTPUT_DIR"
RAW_OUTPUT_FILE="${OUTPUT_DIR}/${TIMESTAMP}_raw.txt"
REPORT_FILE="${OUTPUT_DIR}/${TIMESTAMP}_checkup.md"

echo "Connecting to ${SERVER_USER}@${SERVER_HOST} ..."
echo ""

# WARNING: StrictHostKeyChecking=no disables host verification and MITM protection.
# This is only appropriate on trusted networks for local/private use.
sshpass -p "$SERVER_PASS" ssh \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=10 \
  -o BatchMode=no \
  "${SERVER_USER}@${SERVER_HOST}" bash -s -- "$CHECK_DOCKER" << 'REMOTE' | tee "$RAW_OUTPUT_FILE"
CHECK_DOCKER="$1"

echo "=== UPTIME & LOAD ==="
uptime

echo ""
echo "=== MEMORY USAGE ==="
if command -v free &>/dev/null; then
  free -h
else
  # macOS fallback
  vm_stat | perl -ne '/page size of (\d+)/ and $pgsize=$1; /Pages\s+(\w[\w ]+):\s+(\d+)/ and printf("%-25s %s\n",$1,$2*$pgsize/1048576 ." MB")'
fi

echo ""
echo "=== DISK USAGE ==="
df -h

echo ""
echo "=== CPU INFO ==="
if command -v top &>/dev/null; then
  # Linux: non-interactive single snapshot
  top -bn1 2>/dev/null | grep -E "^(%Cpu|Cpu|top)" | head -5 || true
fi
if command -v mpstat &>/dev/null; then
  mpstat 1 1 2>/dev/null | tail -4
fi
# Fallback: /proc/loadavg
if [ -f /proc/loadavg ]; then
  echo "Load averages: $(cat /proc/loadavg)"
fi
# Number of CPUs
if [ -f /proc/cpuinfo ]; then
  echo "CPU count: $(grep -c ^processor /proc/cpuinfo)"
fi

echo ""
echo "=== FAILED SERVICES ==="
if command -v systemctl &>/dev/null; then
  FAILED=$(systemctl list-units --state=failed --no-legend 2>/dev/null)
  if [ -z "$FAILED" ]; then
    echo "All services running normally."
  else
    echo "$FAILED"
  fi
else
  echo "systemd not available on this host."
fi

echo ""
echo "=== NETWORK INTERFACES ==="
if command -v ip &>/dev/null; then
  ip -brief addr show
else
  ifconfig 2>/dev/null | grep -E "^[a-z]|inet " || echo "Network info unavailable."
fi

echo ""
echo "=== RECENT LOGINS ==="
last -n 5 2>/dev/null || echo "last command not available."

if [ "$CHECK_DOCKER" = "1" ]; then
  echo ""
  echo "=== DOCKER CONTAINERS ==="
  if command -v docker &>/dev/null; then
    echo "--- Running containers ---"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Could not list containers (permission denied?)"
    echo ""
    echo "--- Container resource usage ---"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null || echo "Could not get stats."
    echo ""
    echo "--- Exited / unhealthy containers ---"
    STOPPED=$(docker ps -a --filter status=exited --filter status=dead --format "{{.Names}} [{{.Status}}]" 2>/dev/null)
    if [ -z "$STOPPED" ]; then
      echo "No stopped or dead containers."
    else
      echo "$STOPPED"
    fi
  else
    echo "Docker is not installed on this host."
  fi
fi

REMOTE

echo ""
echo "RAW_OUTPUT_FILE=${RAW_OUTPUT_FILE}"
echo "REPORT_FILE=${REPORT_FILE}"
echo "RECS_FILE=${OUTPUT_DIR}/${TIMESTAMP}_recommendations.md"
