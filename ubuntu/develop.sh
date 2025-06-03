#!/bin/bash
#set -x
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

if ask_yes_no "Do you want to install github desktop?" Y; then
    silent_run_with_spinner "Setup for GitHub desktop" bash -c '
    wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'
    '
    log INFO "Update system" 
    sudo apt update
    silent_run_with_spinner "Installing GitHub desktop" sudo apt install -y github-desktop
else
    log INFO "Skipping GitHub desktop installation"
fi