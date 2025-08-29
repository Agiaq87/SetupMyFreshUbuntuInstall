#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "GParted section"
ask_yes_no "Do you want to install GParted?" Y; then
    silent_run_with_spinner "Installing GParted" sudo apt install -y gparted
    silent_run_with_spinner "Install DOS/WIN filesystem utility" sudo nala install -y dosfstools ntfs-3g exfat-fuse exfat-utils
    silent_run_with_spinner "Install Linux filesystem utility" bash -c '
        sudo nala install -y btrfs-progs xfsprogs xfsdump reiserfsprogs reiser4progs nilfs-tools lvm2 cryptsetup dmsetup jfsutils
        '
    silent_run_with_spinner "Install APPLE filesystem utility" sudo nala install -y hfsprogs hfsutils

log INFO "Disk utility section"
ask_yes_no "Do you want to install Disk utility? [Testdisk]" Y; then
    silent_run_with_spinner "Installing Disk utility" sudo nala install -y testdisk

        
