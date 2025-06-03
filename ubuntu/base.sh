#!/bin/bash
set -x
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

silent_run_with_spinner "Update system" bash -c '
sudo apt update
sudo apt upgrade
sudo apt install unattended-upgrades -y'

silent_run_with_spinner "Installing nala" sudo apt install -y nala

silent_run_with_spinner sudo nala install -y gdebi synaptic flatpak htop neofetch bpytop samba-common-bin exfat-fuse \
unzip zip unrar wget curl linux-headers-$(uname -r) linux-headers-generic gstreamer1.0-vaapi \
ntfs-3g p7zip ubuntu-restricted-extras libfuse2 libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils tar "Installing utils"

silent_run_with_spinner "Setup Flatpak" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

if [[ "$desktop" == "GNOME" ]]; then
    log INFO "GNOME detected"
    if ask_yes_no "Do you want to install gnome tweaks?" Y; then
        silent_run_with_spinner "Install gnome tweaks" sudo nala install gnome-tweaks 

    if ask_yes_no "Do you want to install gnome tweaks?" Y; then
        silent_run_with_spinner "Install gnome tweaks" sudo nala install gnome-shell-extension-manager 
fi


silent_run_with_spinner "Install base development" sudo nala install -y git build-essential libgl1-mesa-dev libclang-dev cmake ninja-build adb fastboot \
openjdk-17-jdk lib32z1 lib32ncurses6 lib32stdc++6 clang cargo libc6-i386 libc6-x32 libu2f-udev \
bzip2 tar gcc


