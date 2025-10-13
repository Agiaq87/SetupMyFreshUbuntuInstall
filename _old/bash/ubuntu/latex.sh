#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

silent_run_with_spinner "Install Texlive" sudo nala install -y texlive-full

if ask_yes_no "Install Texlive GUI (GUI)?"; then
    if [[ "$desktop" == "KDE" ]]; then
        silent_run_with_spinner "Install Texlive GUI" sudo nala install -y kile
    else
        silent_run_with_spinner "Install Texlive GUI" sudo nala install -y texstudio
    fi
fi