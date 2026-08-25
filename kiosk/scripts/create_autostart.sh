#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/create_autostart.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

AUTOSTART_DIR="/home/pi/.config/labwc"
mkdir -p "$AUTOSTART_DIR"
chmod 700 /home/pi/.config
chmod 700 "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/autostart" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

export HOME=/home/pi
export XDG_RUNTIME_DIR=/run/user/1000
export WAYLAND_DISPLAY=wayland-1
export DISPLAY=:0
export XDG_SESSION_TYPE=wayland
mkdir -p /kiosk/logs

while true; do
  /usr/bin/chromium \
    --user-data-dir=/home/pi/.config/chromium-kiosk \
    --kiosk \
    --no-first-run \
    --no-default-browser-check \
    --no-crash-dialog \
    --no-session-restore \
    --no-translate \
    --disable-infobars \
    --autoplay-policy=no-user-gesture-required \
    --ozone-platform=wayland \
    --enable-features=UseOzonePlatform \
    --enable-logging=stderr \
    --v=1 \
    "https://www.bestvooruit.nl/tv?utm_source=copilot.com" \
    >> /kiosk/logs/chromium.log 2>&1

  echo "[autostart] Chromium exited; restarting in 3s" >> /kiosk/logs/chromium.log
  sleep 3
done
EOF
chmod 755 "$AUTOSTART_DIR/autostart"

printf '\n[autostart] labwc autostart configured.\n'
