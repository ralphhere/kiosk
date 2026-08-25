#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cleanup_os.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

export DEBIAN_FRONTEND=noninteractive

for service in \
  bluetooth \
  avahi-daemon \
  cups \
  triggerhappy \
  speech-dispatcher \
  gnome-keyring-daemon \
  wpa_supplicant \
  rsyslog \
  pipewire \
  pipewire-pulse \
  pulseaudio; do
  systemctl disable --now "$service" 2>/dev/null || true
  systemctl mask "$service" 2>/dev/null || true
done

systemctl daemon-reload || true

mkdir -p /etc/systemd/system.conf.d
cat > /etc/systemd/system.conf.d/kiosk.conf <<'EOF'
[Manager]
HandleLidSwitch=ignore
HandlePowerKey=ignore
RuntimeDirectorySize=128M
EOF
chmod 644 /etc/systemd/system.conf.d/kiosk.conf

mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/10-disable-power-management.conf <<'EOF'
Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection
EOF
chmod 644 /etc/X11/xorg.conf.d/10-disable-power-management.conf

mkdir -p /etc/profile.d
cat > /etc/profile.d/kiosk-no-sleep.sh <<'EOF'
#!/usr/bin/env bash
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-1
export XDG_SESSION_TYPE=wayland
export XDG_RUNTIME_DIR=/run/user/1000
EOF
chmod 755 /etc/profile.d/kiosk-no-sleep.sh

apt-get purge -y xscreensaver light-locker 2>/dev/null || true

printf '\n[cleanup] OS cleanup completed.\n'
