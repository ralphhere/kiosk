#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
SETUP_LOG="$LOG_DIR/setup.log"
: > "$SETUP_LOG"
exec > >(tee -a "$SETUP_LOG") 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ${EUID} -ne 0 ]]; then
  echo "[setup] Run with sudo: sudo ./setup.sh"
  exit 1
fi

mkdir -p /kiosk /kiosk/logs /kiosk/scripts
chmod 755 /kiosk /kiosk/logs /kiosk/scripts

for script in \
  "$SCRIPT_DIR/scripts/install_labwc.sh" \
  "$SCRIPT_DIR/scripts/install_chromium.sh" \
  "$SCRIPT_DIR/scripts/cleanup_os.sh" \
  "$SCRIPT_DIR/scripts/create_autostart.sh" \
  "$SCRIPT_DIR/scripts/create_services.sh"
do
  if [[ -f "$script" ]]; then
    chmod 755 "$script"
    echo "[setup] Running: $script"
    bash "$script"
  else
    echo "[setup] Required script missing: $script" >&2
    exit 1
  fi
done

cp -f "$SCRIPT_DIR/kiosk.service" /etc/systemd/system/kiosk.service
cp -f "$SCRIPT_DIR/labwc-session.service" /etc/systemd/system/labwc-session.service
systemctl daemon-reload
systemctl enable --now kiosk.service || true
systemctl enable --now labwc-session.service || true
systemctl restart kiosk.service || true

printf '\n[setup] Raspberry Pi kiosk setup completed successfully.\n'
