#!/usr/bin/env bash
set -euo pipefail

# Open Sunshine streaming ports on the Host ONLY for the Raspberry Pi's IP.
# Usage: ./scripts/setup-ufw.sh <PI_IP> [INTERFACE]
# Example: ./scripts/setup-ufw.sh 192.168.10.2 eno1

PI_IP="${1:-}"
IFACE="${2:-}"

if [[ -z "$PI_IP" ]]; then
  echo "Usage: $0 <PI_IP> [INTERFACE]" >&2
  exit 1
fi

IFACE_ARG=()
if [[ -n "$IFACE" ]]; then
  IFACE_ARG=(in on "$IFACE")
fi

sudo ufw allow "${IFACE_ARG[@]}" from "$PI_IP" to any port 47984:47990 proto tcp comment 'Sunshine TCP'
sudo ufw allow "${IFACE_ARG[@]}" from "$PI_IP" to any port 48010 proto tcp comment 'Sunshine RTSP'
sudo ufw allow "${IFACE_ARG[@]}" from "$PI_IP" to any port 47998:48010 proto udp comment 'Sunshine UDP'

echo "UFW rules added for $PI_IP${IFACE:+ on $IFACE}."
