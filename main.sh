#!/bin/bash
set -x #Stop on error

#Find current directory where script it's located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"

#check_root

if [ -f /etc/arch-release ]; then
    log WARN "Found an Arch Linux installation"
    ./arch/install.sh
    ./arch/config.sh
elif [ -f /etc/lsb-release ]; then
    log "Found an Ubuntu installation"
    ./common/setup_bash.sh
    ./ubuntu/base.sh
    .ubuntu/develop.sh
    ./ubuntu/docker.sh
    ./ubuntu/latex.sh
    ./ubuntu/mobile.sh
    ./ubuntu/synology.sh
    ./ubuntu/config.sh
fi
