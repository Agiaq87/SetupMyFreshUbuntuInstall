#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "Install UFW"
nala install -y ufw nmap zenmap wireshark aircrack-ng

log INFO "Setup UFW"
systemctl enable ufw
systemctl start ufw
