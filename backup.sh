#!/bin/bash
request() {
    local message="$1"
    local command="$2"

    # chiede conferma
    read -r -p "${message} (Y/N): " choice

    case "$choice" in
        y|Y )
            eval "sudo nala install -y ${command}"
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

requestSnap() {
    local message="$1"
    local command="$2"

    # chiede conferma
    read -r -p "${message} (Y/N): " choice

    case "$choice" in
        y|Y )
            eval "sudo snap install ${command}"
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

requestFlatpak() {
    local message="$1"
    local command="$2"

    # chiede conferma
    read -r -p "${message} (Y/N): " choice

    case "$choice" in
        y|Y )
            eval "flatpak install flathub ${command} -y"
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

docker() {
    read -r -p "Do you want to install Docker and Docker Compose? (Y/N): " choice

    case "$choice" in
        y|Y )
            sudo apt-get update
            sudo apt-get install ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo usermod -aG docker "$USER"
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

ulauncher() {
    read -r -p "Do you want to install ULauncher? (Y/N): " choice

    case "$choice" in
        y|Y )
            sudo add-apt-repository universe -y && sudo add-apt-repository ppa:agornostal/ulauncher -y && sudo apt update && sudo apt install ulauncher
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

chrome() {
    read -r -p "Do you want to install Google Chrome? (Y/N): " choice

    case "$choice" in
        y|Y )
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
            sudo apt update
            sudo apt install -y google-chrome-stable
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

teamViewer() {
    read -r -p "Do you want to install TeamViewer? (Y/N): " choice

    case "$choice" in
        y|Y )
            wget -O teamviewer.deb "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
            sudo dpkg -i teamviewer.deb
            sudo apt install -f -y
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

jetbrainsToolbox() {
# Ottiene l'URL dell'ultima versione
JETBRAINS_JSON=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")
JETBRAINS_URL=$(echo "$JETBRAINS_JSON" | grep -o '"linux":{"link":"[^"]*"' | cut -d'"' -f4)

echo "📥 Download da: $JETBRAINS_URL"
    wget -O jetbrains-toolbox.tar.gz "$JETBRAINS_URL"
    tar -xzf jetbrains-toolbox.tar.gz
    JETBRAINS_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -n 1)
    
    if [ -n "$JETBRAINS_DIR" ]; then
        # Installa in /opt
        sudo mkdir -p /opt/jetbrains-toolbox
        sudo cp -r "$JETBRAINS_DIR"/* /opt/jetbrains-toolbox/
        sudo chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox
        
        # Crea collegamento nel menu applicazioni
        cat << 'DESKTOP_EOF' | sudo tee /usr/share/applications/jetbrains-toolbox.desktop > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Icon=applications-development
Exec=/opt/jetbrains-toolbox/jetbrains-toolbox
Comment=JetBrains IDEs manager
Categories=Development;
StartupWMClass=jetbrains-toolbox
StartupNotify=true
DESKTOP_EOF
        
        echo "JetBrains Toolbox installed successfully."
    else
        echo "Cannot install JetBrains Toolbox"
    fi
    
}

synology() {
    DOWNLOAD_DIR="$HOME/deb_packages"
    mkdir -p "$DOWNLOAD_DIR"

    declare -a SYNOLGY_DEB_URLS=(
        "https://global.synologydownload.com/download/Utility/Assistant/7.0.5-50070/Ubuntu/x86_64/synology-assistant_7.0.5-50070_amd64.deb"
        "https://global.synologydownload.com/download/Utility/SynologyDriveClient/3.5.2-16111/Ubuntu/Installer/synology-drive-client-16111.x86_64.deb"
        "https://global.synologydownload.com/download/Utility/NoteStationClient/2.2.5-804/Ubuntu/x86_64/synology-note-station-client-2.2.5-804-linux-x64.deb"
        "https://global.synologydownload.com/download/Utility/Presto/2.1.2-0665/Ubuntu/x86_64/synology-presto-0665.x86_64.deb"
    )

    log INFO "Start download Synology packages"

    for url in "${SYNOLGY_DEB_URLS[@]}"; do
        filename=$(basename "$url")
        filepath="$DOWNLOAD_DIR/$filename"

        echo "Download $filename" 
        
        if wget -q -O "$filepath" "$url"; then
            echo "Download OK: $filename"
        else
            echo "Download failed: $filename"
        fi
    done

    cd "$DOWNLOAD_DIR" || exit 1

    for deb in *.deb; do
        if [ -f "$deb" ]; then
            echo "Install: $deb"
            #[ -f "$deb" ] && apt install -y "./$deb"
            if sudo apt install -y "./$deb"; then
                echo "Installation OK: $deb"
            else
                echo "Installation failed: $deb"
            fi
        fi
    done
}

optimizeCpu() {
    read -r -p "Do you want to set CPU governor to performance? (Y/N): " choice
    case "$choice" in
        y|Y )
            for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
                sudo cpufreq-set -c "${cpu##*/cpu}" -g performance
            done
            git clone https://github.com/AdnanHodzic/auto-cpufreq.git
            cd auto-cpufreq && sudo ./auto-cpufreq-installer
            ;;
        * )
            echo "Aborted."
            ;;
    esac
}

developmentTools() {
    read -r -p "Do you want to install development tools (curl, wget, build-essential, headers)? (Y/N): " choice

    case "$choice" in
        y|Y )
            KERNEL_VERSION=$(uname -r)
            eval "sudo nala install -y curl wget build-essential linux-headers-${KERNEL_VERSION} linux-headers-generic git"
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

echo "Starting backup script..."
# Update and upgrade the system
sudo apt update && sudo apt upgrade -y && sudo snap refresh && sudo apt install unattended-upgrades -y && sudo apt install -y nala && sudo nala fetch && sudo add-apt-repository multiverse

# Must install
request "Do you want to install package gui utils ?" "gdebi synaptic"
request "Do you want to install Flatpak and setup Flathub?" "flatpak && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
request "Do you need restricted extras (mp3, etc) and gstreamer codec?" "ubuntu-restricted-extras gstreamer1.0-vaapi"
request "Do you want to install system monitoring tools?" "htop neofetch bpytop"
request "Do you want to install file system tools?" "samba-common-bin exfat-fuse ntfs-3g"
developmentTools
request "Do you want to install video tools (libxi6, libxrender1, libxtst6, libfontconfig1, mesa-utils)?" "libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils"
request "Do you want to install neofetch?" "neofetch"
request "Do you want to install Fail2ban?" "fail2ban"
request "Do you want to install GPG?" "gnupg"

# AppImage 
request "Do you want to install AppImage support" "libfuse2t64"

# Browser
chrome
requestFlatpak "Do you want to install Microsoft Edge? [FLATPAK]" "com.microsoft.Edge"
requestSnap "Do you want to install Opera browser? [SNAP]" "opera"

# Cloud integration
request "Do you want to install cloud integration tools rclone?" "rclone"
request "Do you want to install Dropbox CLI?" "nautilus-dropbox"
request "Do you want to installNextcloud client?" "nextcloud-desktop"

# Compression
request "Do you want to install compression utils?" "unzip zip unrar p7zip tar"
requestFlatpak "Do you want to install PeaZip? [FLATPAK]" "io.github.peazip.PeaZip"

# Database 
requestSnap "Do you want to install DBeaver CE? [SNAP]" "dbeaver-ce"
request "Do you want to install PostgreSQL client tools?" "postgresql-client"

# Driver section
request "Do you want to install additional drivers?" "ubuntu-drivers-common && sudo ubuntu-drivers autoinstall"
request "Do you want to install CoreCtrl (AMD control daemon)?" "corectrl"
request "Do you want to install lm-sensors and psensor (hardware monitoring)?" "lm-sensors psensor"
request "Do you want to install cpufreq (CPU frequency scaling)?" "cpufrequtils"
optimizeCpu

# Docker
docker

# EFI tools
request "Do you want to install efibootmgr (manage UEFI boot entries)?" "efibootmgr"
request "Do you want to install EFI GUI tools?" "python3 python3-gi libgtk-4-1 gir1.2-gtk-4.0"
request "Do you want to install fwupd (firmware updates)?" "fwupd"
sudo fwupdmgr get-devices && sudo fwupdmgr refresh && sudo fwupdmgr get-updates && sudo fwupdmgr update

# Firewall
request "Do you want to install and enable UFW firewall?" "ufw"
request "Do you want to install UFW GUI?" "gufw"
sudo systemctl enable ufw
sudo systemctl start ufw

# Font
request "Do you want to install Microsoft fonts?" "ttf-mscorefonts-installer"
request "Do you want to install Font Manager?" "font-manager"
request "Do you want to install additional fonts (Noto, Papirus, Fira)?" "fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-powerline"
request "Do you want to install FiraCode font?" "fonts-firacode"
sudo fc-cache -f -v

# Flutter SDK
requestSnap "Do you want to install Flutter SDK? [SNAP]" "flutter"
flutter
flutter config
flutter doctor

# Games
request "Do you want to install Steam?" "steam"
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo apt update && sudo apt upgrade -y
request "Do you want to install Lutris (game launcher for Wine/Proton/Emulators)?" "lutris"
request "Do you want to install GameMode (Feral Interactive optimization daemon)?" "gamemode libgamemode0 libgamemodeauto0"
request "Do you want to install MangoHud (FPS overlay & performance metrics)?" "mangohud"
request "Do you want to install vkBasalt (Vulkan post-processing tool)?" "vkbasalt"
request "Do you want to install goverlay (GUI per MangoHud, vkBasalt, Gamescope)?" "goverlay"
request "Do you want to install RetroArch (multi-emulator frontend)?" "retroarch retroarch-assets retroarch-dbg"
request "Do you want to install Dolphin Emulator (GameCube/Wii)?" "dolphin-emu"
request "Do you want to install PCSX2 (PlayStation 2 emulator)?" "pcsx2"
request "Do you want to install PPSSPP (PSP emulator)?" "ppsspp"
request "Do you want to install Citra (Nintendo 3DS emulator)?" "citra-emu"
request "Do you want to install Yuzu (Nintendo Switch emulator)?" "yuzu"

# Gnome
request "Do you want to install gnome tweaks?" "gnome-tweaks"
request "Do you want to install Gnome extensions?" "gnome-shell-extensions chrome-gnome-shell"
request "Do you want to install Gnome Shell Extension Manager" "gnome-shell-extension-manager"

# Go
request "Do you want to install Go language?" "golang"

# Gparted
request "Do you want to install GParted (partition manager)?" "gparted"

# Jetbrains Toolbox
jetbrainsToolbox

# Latex
request "Do you want to install Texlive full?" "texlive-full"
request "Do you want to install Texlive GUI (Texstudio)?" "texstudio"

# Multimedia
request "Do you want to install VLC media player?" "vlc"
request "Do you want to install OBS Studio?" "obs-studio"
request "Do you want to install Audacity?" "audacity"
request "Do you want to install Kdenlive?" "kdenlive"
request "Do you want to install GIMP?" "gimp"
request "Do you want to install Inkscape?" "inkscape"
request "Do you want to install Darktable?" "darktable"
request "Do you want to install Shotcut?" "shotcut"
request "Do you want to install HandBrake?" "handbrake"

# Network
request "Do you want to install network tools?" "nmap tcpdump wireshark ipset traceroute tshark aircrack-ng bettercap net-tools"
requestSnap "Do you want to install Discord? [SNAP]" "discord"
requestSnap "Do you want to install Spotify? [SNAP]" "spotify"

# NodeJS
request "Do you want to install NodeJS and npm?" "nodejs npm"

# OpenRGB
requestFlatpak "Do you want to install OpenRGB? [FLATPAK]" "openrgb"

# Python
request "Do you want to install Python and pip?" "python3 python3-pip python3-dev"

# Qemu
request "Do you want to install QEMU and virt-manager?" "qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf"

# Rust
request "Do you want to install Rust toolchain?" "rustc cargo"

# StreamController
requestFlatpak "Do you want to install StreamController? [FLATPAK]" "streamcontroller"

# Synology tools
synology

# TeamViewer
teamViewer

# Ulauncher
ulauncher

# Utils
request "Do you want to install Stacer (system optimizer/monitor)?" "stacer"
request "Do you want to install BleachBit (system cleaner)?" "bleachbit"
request "Do you want to install OBS Studio (screen recorder)?" "obs-studio"

# VirtualBox
request "Do you want to install VirtualBox and extension pack?" "virtualbox virtualbox-ext-pack"
sudo usermod -aG vboxusers "$USER"

# Windows
requestFlatpak "Do you want to install Bottles (manage Windows apps)? [FLATPAK]" "com.usebottles.bottles"

# Finale
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "Completed! Bye"

