#!/bin/bash

set -e


# Aggiorna il sistema
update_system() {
    log INFO "Starting system update..."
    (
        echo "20" ; sudo apt update 2>&1
        echo "60" ; sudo apt upgrade -y 2>&1
        echo "80" ; sudo snap refresh 2>&1
        echo "100" ; sudo apt autoremove -y 2>&1
    ) | show_progress "System Update" "Updating system in progress..."
}