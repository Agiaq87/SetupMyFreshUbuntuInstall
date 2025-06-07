#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "Install VLC"
nala install -y vlc cheese

log INFO "Steam"
nala install -y steam

log INFO "Install bottles"
flatpak install flathub com.usebottles.bottles