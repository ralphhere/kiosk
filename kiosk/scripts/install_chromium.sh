#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install_chromium.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

export DEBIAN_FRONTEND=noninteractive

if ! command -v chromium >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends chromium chromium-sandbox
fi

mkdir -p /etc/chromium.d
cat > /etc/chromium.d/00-kiosk-flags <<'EOF'
CHROMIUM_FLAGS="--kiosk --no-first-run --no-default-browser-check --no-crash-dialog --no-session-restore --no-translate --disable-infobars --autoplay-policy=no-user-gesture-required --ozone-platform=wayland --enable-features=UseOzonePlatform"
EOF
chmod 644 /etc/chromium.d/00-kiosk-flags

printf '\n[chromium] installed and configured.\n'
