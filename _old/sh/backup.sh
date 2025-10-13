#!/bin/bash

AUTO_PAGES=0
STREAM_CONTROLLER_INSTALLED=0

### FUNZIONI DI SUPPORTO ###
installNala() {
    sudo apt update && sudo apt install -y nala
}

enableFlatpak() {
    sudo nala install -y flatpak 
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 
    sudo nala install -y gnome-software-plugin-flatpak
}

request() {
    local message="$1"
    local command="$2"
    local package_manager="$3"

    if whiptail --title "Installazione pacchetti" --yesno "$message" 10 60; then
        case $package_manager in
            "apt")
                eval "sudo apt install -y ${command}"
                ;;
            "nala")
                installNala # Ensure Nala is installed  before using it
                eval "sudo nala install -y ${command}"
                ;;
            "snap")
                eval "sudo snap install ${command}"
                ;;
            "flatpak")
                eval "flatpak install flathub ${command} -y"
                ;;
            *)
                echo "Package manager non supportato."
                ;;
        esac
    else
        echo "Aborted."
    fi
}

### STREAM DECK AUTOMATION ###
checkStreamDeck() {
    local streamDeckFounded=0

    if lsusb | grep "Stream Deck"; then
        streamDeckFounded=1
    fi

    if [ $streamDeckFounded -eq 1 ]; then
        if whiptail --title "Stream Deck found" --yesno \
            "Stream Deck found, Do you want to install StreamController software [FLATPAK]?" \
            10 60; then
                STREAM_CONTROLLER_INSTALLED=1
                flatpak install flathub com.core447.StreamController -y
        fi
    fi

    if [ $STREAM_CONTROLLER_INSTALLED -eq 1 ]; then
        if whiptail --title "Stream Deck Automation" --yesno \
            "Stream Deck found, Do you want to automatic create page for this script?\n
            - For each submenu it create a page\n
            - For each package it create a launcher using OS plugin\n
            - A clock will be added upper left\n
            - A button to return to main menu will be added down left\n" \
            20 78; then
                AUTO_PAGES=1
        fi
    fi
}

add_app_to_page() {
    local page_file="$1"
    local app_name="$2"
    local command="$3"

    if [ $COUNTER -lt 5 ]; then
        ROW=$COUNTER
        COL=0
    else
        ROW=0
        COL=$((COUNTER - 5))
    fi

    jq --argjson row $ROW --argjson col $COL \
       --arg cmd "$command" \
       --arg name "$app_name" \
       '.buttons += [{"row":$row,"col":$col,"plugin":"os","settings":{"cmd":$cmd}}]' \
       "$page_file" > "${page_file}.tmp" && mv "${page_file}.tmp" "$page_file"

    COUNTER=$((COUNTER+1))
}


### FUNZIONI SPECIFICHE (da riempire dopo) ###
docker_install() {
    echo "TODO: installazione Docker"
}

development_tools() {
    echo "TODO: installazione strumenti sviluppo"
}

browsers_menu() {
    CHOICES=$(whiptail --title "Browser" --checklist \
    "Scegli i browser da installare:" 20 78 10 \
    "chrome" "Google Chrome (apt repo ufficiale)" OFF \
    "edge" "Microsoft Edge (flatpak)" OFF \
    "opera" "Opera (snap)" OFF \
    "vivaldi" "Vivaldi (snap)" OFF \
    "brave" "Brave (apt)" OFF \
    3>&1 1>&2 2>&3)

    for choice in $CHOICES; do
        case $choice in
            "\"chrome\"")
                wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
                echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
                sudo apt update
                request "Installare Google Chrome?" "google-chrome-stable" "nala"
                ;;
            "\"edge\"")
                request "Installare Microsoft Edge?" "com.microsoft.Edge" "flatpak"
                ;;
            "\"opera\"")
                request "Installare Opera?" "opera" "snap"
                ;;
            "\"vivaldi\"")
                request "Installare Vivaldi?" "vivaldi" "snap"
                ;;
            "\"brave\"")    
                sudo nala install -y curl 
                sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
                sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
                sudo apt update
                request "Installare Brave Browser?" "brave-browser" "nala"
                ;;
            *)  
                echo "Opzione non valida." ;;
        esac
    done
}

multimedia_menu() {
    echo "TODO: sottomenù multimedia"
}

games_menu() {
    echo "TODO: sottomenù giochi"
}

security_menu() {
    echo "TODO: sottomenù sicurezza"
}

gnome_menu() {
    echo "TODO: sottomenù GNOME extensions"
}

virtualization_menu() {
    echo "TODO: sottomenù VirtualBox / QEMU / KVM"
}

cloud_menu() {
    echo "TODO: sottomenù Cloud (Nextcloud, Synology, ecc.)"
}

utilities_menu() {
    echo "TODO: sottomenù utility varie"
}


### MENU PRINCIPALE ###
installNala
enableFlatpak
checkStreamDeck
while true; do
CHOICE=$(whiptail --title "Setup My Ubuntu Fresh Install" --menu "Select one:" 20 78 10 \
"1" "Update system" \
"2" "Development tools" \
"3" "Docker" \
"4" "Browser" \
"5" "Multimedia" \
"6" "Games" \
"7" "Security & CyberSec" \
"8" "GNOME Extensions" \
"9" "Virtualization" \
"10" "Cloud & Backup" \
"11" "Utilities" \
"12" "Exit" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus -ne 0 ]; then
    echo "Uscita annullata."
    exit 1
fi

case $CHOICE in
    1) sudo apt update && sudo apt upgrade -y && sudo snap refresh ;;
    2) development_tools ;;
    3) docker_install ;;
    4) browsers_menu ;;
    5) multimedia_menu ;;
    6) games_menu ;;
    7) security_menu ;;
    8) gnome_menu ;;
    9) virtualization_menu ;;
    10) cloud_menu ;;
    11) utilities_menu ;;
    12) exit 0 ;;
esac
done