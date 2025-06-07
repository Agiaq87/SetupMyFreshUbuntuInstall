#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

silent_run_with_spinner "Update system" bash -c '
sudo apt update
sudo apt upgrade
sudo apt install unattended-upgrades -y'

silent_run_with_spinner "Installing nala" sudo apt install -y nala

silent_run_with_spinner "Installing utils" sudo nala install -y gdebi synaptic flatpak htop neofetch bpytop samba-common-bin exfat-fuse \
unzip zip unrar wget curl linux-headers-$(uname -r) linux-headers-generic gstreamer1.0-vaapi \
ntfs-3g p7zip ubuntu-restricted-extras libfuse2 libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils tar

silent_run_with_spinner "Setup Flatpak" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo