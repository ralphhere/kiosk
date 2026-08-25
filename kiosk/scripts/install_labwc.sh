#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="/kiosk/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install_labwc.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends labwc xwayland

mkdir -p /etc/xdg/labwc
cat > /etc/xdg/labwc/rc.xml <<'EOF'
<?xml version="1.0"?>
<labwc>
  <core>
    <decoration>server</decoration>
    <reuse>no</reuse>
    <gap>0</gap>
  </core>
  <theme>
    <name>default</name>
    <cornerRadius>0</cornerRadius>
    <font size="12" />
  </theme>
  <cursor theme="none" size="0"/>
  <keyboard>
    <repeatRate>50</repeatRate>
    <repeatDelay>250</repeatDelay>
  </keyboard>
  <windowSwitcher show="no" />
</labwc>
EOF
chmod 644 /etc/xdg/labwc/rc.xml

printf '\n[labwc] installed and configured.\n'
