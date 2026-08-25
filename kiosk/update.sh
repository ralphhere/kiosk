#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
UPDATE_LOG="$LOG_DIR/update.log"
: > "$UPDATE_LOG"
exec > >(tee -a "$UPDATE_LOG") 2>&1

if [[ -d .git ]]; then
  echo "[update] Pulling latest repository changes..."
  git pull --ff-only || { echo "[update] git pull failed"; exit 1; }
else
  echo "[update] No git repository detected in current directory; skipping git pull."
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload || true
  systemctl restart kiosk.service || true
  systemctl restart labwc-session.service || true
fi

find "$LOG_DIR" -type f -maxdepth 1 -name '*.log' -exec truncate -s 0 {} + 2>/dev/null || true

printf '\n[update] Manual kiosk update finished.\n'
