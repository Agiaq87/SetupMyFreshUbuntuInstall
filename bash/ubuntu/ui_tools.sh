#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "UI utility section"
if ask_yes_no "Do you want to install Figma?" Y; then
    if ask_yes_no "Do you want to install snap package?" Y; then
        ask_to_install "Figma" sudo snap install figma-linux
    else
        silent_run_with_spinner "Installing Figma from deb package"  bash -c '
            wget https://github.com/Figma-Linux/figma-linux/releases/download/v0.11.5/figma-linux_0.11.5_linux_amd64.deb
            sudo dpkg -i figma-linux*.deb
            sudo apt-get install -f
        '
        silent_run_with_spinner "Update system and resolve troubleshooting" bash -c '
            sudo nala install libffmpeg-extra
            sudo apt install -f
        '
        silent_run_with_spinner "Remove Figma deb package" rm figma-linux*.deb
    fi
fi