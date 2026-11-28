#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN="$HOME/.local/bin"
TARGET_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/pi-monitor"
USER_SYSTEMD="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

mkdir -p "$TARGET_BIN" "$TARGET_CFG" "$USER_SYSTEMD"

case "$MODE" in
  --pi)
    install -m 755 "$SCRIPT_DIR/bin/pi-monitor" "$TARGET_BIN/pi-monitor"
    echo "Installed $TARGET_BIN/pi-monitor"

    # Install user service for Moonlight
    if [[ -f "$SCRIPT_DIR/systemd/pi-monitor-moonlight.service" ]]; then
      install -m 644 "$SCRIPT_DIR/systemd/pi-monitor-moonlight.service" "$USER_SYSTEMD/pi-monitor-moonlight.service"
      systemctl --user daemon-reload
      echo "Installed $USER_SYSTEMD/pi-monitor-moonlight.service"
    fi

    # Install labwc compositor service if running on Pi with systemd
    if [[ -f "$SCRIPT_DIR/systemd/labwc-desktop.service" ]] && command -v sudo >/dev/null 2>&1; then
      sed "s/CURRENT_USER/$USER/g" "$SCRIPT_DIR/systemd/labwc-desktop.service" | sudo tee /etc/systemd/system/labwc-desktop.service >/dev/null
      sudo systemctl daemon-reload
      sudo systemctl enable labwc-desktop.service
      echo "Installed & enabled /etc/systemd/system/labwc-desktop.service"
    fi
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
