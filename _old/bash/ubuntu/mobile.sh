#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "Installing mobile development tools"
silent_run_with_spinner "NodeJS installation" bash -c '
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo nala install -y nodejs npm'





