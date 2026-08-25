#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/create_services.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

TARGET_DIR="/etc/systemd/system"
mkdir -p "$TARGET_DIR"

cat > "$TARGET_DIR/kiosk.service" <<'EOF'
[Unit]
Description=Kiosk bootstrap service
After=graphical.target
Wants=graphical.target

[Service]
Type=oneshot
User=pi
Group=pi
Environment=HOME=/home/pi
Environment=XDG_RUNTIME_DIR=/run/user/1000
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=wayland-1
Environment=XDG_SESSION_TYPE=wayland
ExecStart=/usr/bin/systemctl --no-block start labwc-session.service
RemainAfterExit=yes
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

cat > "$TARGET_DIR/labwc-session.service" <<'EOF'
[Unit]
Description=Labwc Wayland compositor session
After=graphical.target
Wants=graphical.target

[Service]
Type=simple
User=pi
Group=pi
Environment=HOME=/home/pi
Environment=XDG_RUNTIME_DIR=/run/user/1000
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=wayland-1
Environment=XDG_SESSION_TYPE=wayland
WorkingDirectory=/home/pi
ExecStart=/usr/bin/labwc -C /etc/xdg/labwc
ExecStop=/usr/bin/killall -TERM labwc
Restart=always
RestartSec=2
KillSignal=SIGTERM
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "$TARGET_DIR/kiosk.service" "$TARGET_DIR/labwc-session.service"

systemctl daemon-reload || true

printf '\n[services] systemd services created.\n'
