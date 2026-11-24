#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN="$HOME/.local/bin"
TARGET_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pi-monitor"

mkdir -p "$TARGET_BIN" "$TARGET_CFG"

case "$MODE" in
  --pi)
    install -m 755 "$SCRIPT_DIR/bin/pi-monitor" "$TARGET_BIN/pi-monitor"
    echo "Installed $TARGET_BIN/pi-monitor"
    ;;
  --host)
    install -m 755 "$SCRIPT_DIR/bin/pi-monitor-host" "$TARGET_BIN/pi-monitor"
    echo "Installed $TARGET_BIN/pi-monitor (SSH wrapper -> Pi)"
    ;;
  *)
    echo "Usage: $0 {--pi|--host}" >&2
    exit 1
    ;;
esac

if [[ ! -f "$TARGET_CFG/config.env" ]]; then
  cp "$SCRIPT_DIR/config/config.env.example" "$TARGET_CFG/config.env"
  echo "Created $TARGET_CFG/config.env (edit it to match your IPs and monitor layout)"
else
  echo "Existing config preserved at $TARGET_CFG/config.env"
fi
