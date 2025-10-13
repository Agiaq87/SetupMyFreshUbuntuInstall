#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

ask_yes_no "Do you want to install cloud integration tools?" Y; then
    log INFO "Installing cloud integration tools"
    silent_run_with_spinner "Installing rclone" sudo nala install -y rclone
    silent_run_with_spinner "Installing Dropbox CLI" sudo nala install -y nautilus-dropbox
    silent_run_with_spinner "Installing Google Drive CLI" sudo nala install -y gnome-online-accounts gnome-control-center
    silent_run_with_spinner "Installing Nextcloud client" sudo nala install -y nextcloud-desktop
    silent_run_with_spinner "Installing Syncthing" sudo nala install -y syncthing syncthing-gtk
    ask_yes_no "Do you need isync for Microsoft OneDrive?" Y; then
        silent_run_with_spinner "Installing isync" sbash -c '
            wget -q https://cdn.insynchq.com/builds/linux/3.9.6.60027/insync_3.9.6.60027-noble_amd64.deb
            sudo dpkg -i insync_3.9.6.60027-noble_amd64.deb
            sudo apt-get install -f
            rm insync_3.9.6.60027-noble_amd64.deb
            '
    