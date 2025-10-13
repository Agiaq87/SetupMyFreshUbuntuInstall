#!/bin/bash

# Preparation for mprogram
pre_start() {
    
    (
        echo "5"; check_internet
        echo "20"; check_ubuntu
        echo "25"; sudo apt update 2>&1
        echo "30"; sudo apt upgrade -y 2>&1
        echo "35"; sudo snap refresh 2>&1
        echo "40"; sudo apt install -y zenity yad 2>&1
        echo "50"; sudo apt autoremove -y 2>&1
        echo "55"; sudo apt install -y flatpak 2>&1
        echo "60"; flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        echo "70"; sudo apt install -y gnome-software-plugin-flatpak 2>&1
        echo "80"; sudo apt install -y nala 2>&1
        echo "95"; sudo nala fetch 2>&1
    ) | show_progress "Preparation" "Setup system for execution, please wait..."

    if command -v nala &> /dev/null; then
        log INFO "Nala installed successfully"
        return 0
    else
        log ERROR "Nala installation failed"
        return 1
    fi
}