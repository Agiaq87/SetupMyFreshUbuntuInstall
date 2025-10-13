#!/bin/bash
set -e 

#Find current directory where script it's located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"

#check_root

if [ -f /etc/lsb-release ]; then
    log "Found an Ubuntu installation"
    ./common/setup_bash.sh
    ./ubuntu/base.sh
    ./ubuntu/gnome.sh
    ./ubuntu/develop.sh
    ./ubuntu/latex.sh
    ./ubuntu/virtualization.sh
    ./ubuntu/ui_tools.sh
    ./ubuntu/network.sh
    ./ubuntu/mobile.sh
    ./ubuntu/synology.sh
    ./ubuntu/config.sh
fi
