#!/bin/bash
set -euo pipefail

###############################################
#   EVMPAPA — Sunshine + Cloudflared Setup    #
###############################################

# ============ COLORS =============
CYAN='\033[0;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
RESET='\033[0m'
BOLD='\033[1m'

# ============ BANNER =============
clear
echo -e "${PURPLE}${BOLD}"
cat <<'EOF'
  _____   ___ __ ___  _ __   __ _ _ __   __ _
 / _ \ \ / / '_ ` _ \| '_ \ / _` | '_ \ / _` |
|  __/\ V /| | | | | | |_) | (_| | |_) | (_| |
 \___| \_/ |_| |_| |_| .__/ \__,_| .__/ \__,_|
                     | |         | |
                     |_|         |_|

                 :: Powered by EVMPAPA ::
EOF
echo -e "${RESET}"

# ============ HELPERS =============
log() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

error() {
    echo -e "${RED}[✗] ERROR:${RESET} $1"
}

kill_if_running() {
    local name="$1"
    if pgrep "$name" &>/dev/null; then
        warn "Killing existing process: $name"
        pkill -9 "$name" || true
    fi
}

# ============ 1. INSTALL DEPENDENCIES ============
log "Updating package list..."
sudo apt update -y

log "Installing required packages..."
sudo apt install -y \
    xserver-xorg-video-dummy \
    lxde-core lxde-common lxsession \
    screen curl unzip wget ufw

# ============ 2. KILL EXISTING PROCESSES ============
log "Cleaning up old sessions..."

for svc in sunshine cloudflared lxsession lxpanel openbox Xorg; do
    kill_if_running "$svc"
done

if screen -ls | grep -q sunshine; then
    warn "Removing sunshine screen sessions..."
    screen -ls | grep sunshine | awk '{print $1}' | xargs -r -n 1 screen -S {} -X quit
fi

log "All previous processes terminated."

# ============ 3. INSTALL SUNSHINE ============
if ! command -v sunshine &>/dev/null; then
    log "Installing Sunshine..."
    wget -O /tmp/sunshine.deb \
      https://github.com/LizardByte/Sunshine/releases/download/v0.23.1/sunshine-ubuntu-22.04-amd64.deb
    sudo apt install -y /tmp/sunshine.deb
    rm /tmp/sunshine.deb
else
    warn "Sunshine already installed."
fi

# Firewall
log "Configuring UFW firewall..."
sudo ufw allow ssh
sudo ufw allow 47984/tcp
sudo ufw allow 47989/tcp
sudo ufw allow 48010/tcp
sudo ufw allow 47990/tcp
sudo ufw allow 47998:48002/udp
sudo ufw --force enable

# ============ 4. INSTALL CLOUDFLARED ============
if ! command -v cloudflared &>/dev/null; then
    log "Installing Cloudflared..."
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo apt install -y ./cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
else
    warn "Cloudflared already installed."
fi

# ============ 5. CONFIGURE DUMMY XORG ============
log "Configuring dummy Xorg..."

sudo mkdir -p /etc/X11/xorg.conf.d

# Mouse & Keyboard
sudo tee /etc/X11/xorg.conf.d/10-evdev.conf >/dev/null <<EOF
Section "InputDevice"
    Identifier "Dummy Mouse"
    Driver "evdev"
EndSection
Section "InputDevice"
    Identifier "Dummy Keyboard"
    Driver "evdev"
EndSection
EOF

# Dummy GPU
sudo tee /etc/X11/xorg.conf.d/10-dummy.conf >/dev/null <<EOF
Section "Device"
    Identifier  "DummyDevice"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Monitor"
    Identifier  "DummyMonitor"
EndSection

Section "Screen"
    Identifier  "DummyScreen"
    Device      "DummyDevice"
    Monitor     "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Depth   24
        Modes   "1920x1080"
    EndSubSection
EndSection
EOF

# ============ 6. START XORG + LXDE ============
log "Starting Dummy Xorg..."
sudo Xorg :0 -configdir /etc/X11/xorg.conf.d vt7 &
sleep 4

export DISPLAY=:0

log "Starting LXDE..."
lxsession &
sleep 4

# ============ 7. START SUNSHINE & CLOUDFLARED ============
log "Launching Sunshine..."
screen -dmS sunshine bash -c 'DISPLAY=:0 sunshine'

log "Starting Cloudflared tunnel..."
screen -dmS cloudflared bash -c 'cloudflared tunnel --no-tls-verify --url https://localhost:47990 > /tmp/cloudflared.log 2>&1'

sleep 4

TUNNEL_URL=$(grep -o 'https://[^ ]*\.trycloudflare\.com' /tmp/cloudflared.log | head -n 1)

log "======================================="
log " ✔ Sunshine is running"
log " ✔ Cloudflared Tunnel Active"
log "Tunnel URL:"
echo -e "${CYAN}${BOLD}$TUNNEL_URL${RESET}"
log "======================================="

exit 0
