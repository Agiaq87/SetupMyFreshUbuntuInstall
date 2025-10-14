#!/bin/bash
show_menu() {
    log INFO "Open menu"
    zenity --list --radiolist --title="SetupMyFreshUbuntuInstall" \
                --text="Choose what you want to do:" \
                --column="Selected" --column="ID" --column="Action" \
                --width=600 --height=500 \
                TRUE "1" "Browsers" \
                FALSE "2" "Development tools" \
                FALSE "3" "Gaming" \
                FALSE "4" "Multimedia" \
                FALSE "5" "Virtualization" \
                FALSE "6" "Writing" \
                FALSE "7" "Security & Penetration Testing" \
                FALSE "8" "System" \
                FALSE "9" "Trick & Tips" \
                FALSE "0" "Exit"
}