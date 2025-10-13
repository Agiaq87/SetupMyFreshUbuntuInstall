#!/bin/bash
request() {
    local message="$1"
    local command="$2"

    if whiptail --title "Install" --yesno "$message" 8 78; then
        eval "sudo nala install -y ${command}"
    else
        echo "Aborted."
    fi
}

requestSnap() {
    local message="$1"
    local command="$2"

    if whiptail --title "Install" --yesno "$message" 8 78; then
        eval "sudo snap install ${command}"
    else
        echo "Aborted."
    fi
}

requestFlatpak() {
    local message="$1"
    local command="$2"

    if whiptail --title "Install" --yesno "$message" 8 78; then
        eval "flatpak install flathub ${command} -y"
    else
        echo "Aborted."
    fi
}

log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    if is_terminal; then
        case "$level" in
            INFO)  color="\033[1;34m" ;;  # Blu
            WARN)  color="\033[1;33m" ;;  # Giallo
            ERROR) color="\033[1;31m" ;;  # Rosso
            DEBUG) color="\033[0;36m" ;;  # Ciano
            *)     color="\033[0m"     ;; # Reset
        esac
        echo -e "[$timestamp] [$level] ${color}${message}\033[0m"
    else
        echo "[$timestamp] [$level] $message"
    fi
}

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    wait $pid
}

silent_run_with_spinner() {
    local description="$1"
    shift
    log INFO "$description..."
    ("$@" >/dev/null 2>&1) &
    spinner
    if [ $? -eq 0 ]; then
        log INFO "$description completed"
    else
        log ERROR "$description failed"
        ERROR_ENCOUNTERED+=("$description")
        return 1
    fi
}

install_gnome_extension_from_prompt() {
    local extension_name="$1"
    local extension_url="$2"

    if [[ -z "$extension_name" || -z "$extension_url" ]]; then
        log ERROR "Missing name or URL for Gnome extension"
        return 1
    fi

    silent_run_with_spinner "Installing Gnome extension: $extension_name" install_gnome_extension_from_url "$extension_url"
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
            echo "Aborted."
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
            echo "Aborted."
            ;;
    esac
}

albert() {
    read -r -p "Do you want to install Albert? (Y/N): " choice

    case "$choice" in
        y|Y )
            echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_24.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_24.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null
sudo apt update
sudo apt install albert
            ;;
        * )
            echo "Aborted."
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
            echo "Aborted."
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
            echo "Aborted."
            ;;
    esac
}

# jetbrainsToolbox() {
# # Ottiene l'URL dell'ultima versione
# JETBRAINS_JSON=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")
# JETBRAINS_URL=$(echo "$JETBRAINS_JSON" | grep -o '"linux":{"link":"[^"]*"' | cut -d'"' -f4)

# echo "Download da: $JETBRAINS_URL"
#     wget -O jetbrains-toolbox.tar.gz "$JETBRAINS_URL"
#     tar -xzf jetbrains-toolbox.tar.gz
#     JETBRAINS_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -n 1)
    
#     if [ -n "$JETBRAINS_DIR" ]; then
#         # Installa in /opt
#         sudo mkdir -p /opt/jetbrains-toolbox
#         sudo cp -r "$JETBRAINS_DIR"/* /opt/jetbrains-toolbox/
#         sudo chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox
        
#         # Crea collegamento nel menu applicazioni
#         cat << 'DESKTOP_EOF' | sudo tee /usr/share/applications/jetbrains-toolbox.desktop > /dev/null
# [Desktop Entry]
# Version=1.0
# Type=Application
# Name=JetBrains Toolbox
# Icon=applications-development
# Exec=/opt/jetbrains-toolbox/jetbrains-toolbox
# Comment=JetBrains IDEs manager
# Categories=Development;
# StartupWMClass=jetbrains-toolbox
# StartupNotify=true
# DESKTOP_EOF
        
#         echo "JetBrains Toolbox installed successfully."
#     else
#         echo "Cannot install JetBrains Toolbox"
#     fi
    
# }

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
            echo "Aborted."
            ;;
    esac
}


fiddler() {
    read -r -p "Do you want to install Fiddler Everywhere? (Y/N): " choice

    case "$choice" in
        y|Y )
            google-chrome "https://www.telerik.com/download/fiddler/fiddler-everywhere-linux"
            ;;
        * )
            echo "Aborted."
            ;;
    esac
}

charles() {
    read -r -p "Do you want to install Charles Proxy? (Y/N): " choice

    case "$choice" in
        y|Y )
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://www.charlesproxy.com/packages/apt/charles-repo.asc | sudo gpg --dearmor -o /etc/apt/keyrings/charles-repo.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charles-repo.gpg] https://www.charlesproxy.com/packages/apt/ charles-proxy main" | sudo tee /etc/apt/sources.list.d/charles.list
            sudo apt update && sudo apt install charles-proxy5

            ;;
        * )
            echo "Aborted."
            ;;
    esac
}

openRgb() {
    read -r -p "Do you want to install OpenRGB (RGB lighting control)? (Y/N): " choice

    case "$choice" in
        y|Y )
            sudo apt install libi2c-dev
            wget -O openrgb.deb "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/openrgb_1.0rc2_amd64_bookworm_0fca93e.deb"
            sudo dpkg -i openrgb.deb
            sudo apt install -f -y
            ;;
        * )
            echo "Aborted."
            ;;
    esac
}

cyberSecurity() {
    read -r -p "Do you want to install cybersecurity tools (John the Ripper, Hashcat, Hydra, Metasploit Framework, Burp Suite)? (Y/N): " choice

    case "$choice" in
        y|Y )
            eval "sudo apt install -y john hashcat hydra metasploit-framework burpsuite"
            # Network tools
            request "Install Nmap?" "nmap"
            request "Install Masscan?" "masscan"
            request "Install Wireshark?" "wireshark"
            request "Install Tcpdump?" "tcpdump"

            # Pentesting
            request "Install Metasploit Framework?" "metasploit-framework"
            request "Install Hydra?" "hydra"
            request "Install SQLmap?" "sqlmap"
            request "Install John the Ripper?" "john"

            # Forensics & OSINT
            request "Install Binwalk?" "binwalk"
            request "Install Radare2?" "radare2"
            request "Install Ghidra (reverse engineering)?" "ghidra"
            request "Install theHarvester?" "theharvester"
            requestFlatpak "Install Maltego (OSINT GUI)? [FLATPAK]" "com.paterva.maltego"

            # System security
            request "Install Lynis (Linux auditing)?" "lynis"
            request "Install Chkrootkit?" "chkrootkit"
            request "Install RKHunter?" "rkhunter"
            request "Install Fail2ban?" "fail2ban"
            ;;
        * )
            echo "Aborted."
            ;;
    esac
}

tlp() {
    read -r -p "Do you want to install TLP (advanced power management for Linux)? (Y/N): " choice

    case "$choice" in
        y|Y )
            eval "sudo apt install -y tlp tlp-rdw"
            sudo systemctl enable tlp
            sudo systemctl start tlp
            ;;
        * )
            echo "Aborted."
            ;;
    esac
}


echo "Starting backup script..."
# Update and upgrade the system
#sudo apt update && sudo apt upgrade -y && sudo snap refresh && sudo apt install unattended-upgrades -y && sudo apt install -y nala && sudo nala fetch && sudo add-apt-repository multiverse
# Install whiptail for dialog boxes
sudo nala install whiptail -y

# Must install
#sudo nala install -y flatpak && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && sudo nala install -y gnome-software-plugin-flatpak
#request "Do you need restricted extras (mp3, etc) and gstreamer codec?" "ubuntu-restricted-extras gstreamer1.0-vaapi"
tlp

# Start
request "Do you want to install package gui utils ?" "gdebi synaptic"
#request "Do you want to install system monitoring tools?" "htop neofetch bpytop"
#request "Do you want to install file system tools?" "samba-common-bin exfat-fuse ntfs-3g"
developmentTools
#request "Do you want to install video tools (libxi6, libxrender1, libxtst6, libfontconfig1, mesa-utils)?" "libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils"
#request "Do you want to install neofetch?" "neofetch"
request "Do you want to install Fail2ban?" "fail2ban"
#request "Do you want to install GPG?" "gnupg"

# Arduino
# requestSnap "Do you want to install Arduino IDE? [SNAP]" "arduino"
# sudo usermod -a -G dialout "$USER"
# arduino.pip install requests

# AppImage 
# request "Do you want to install AppImage support" "libfuse2t64"

# Backup
request "Do you want to install Timeshift (system backup)?" "timeshift"

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
# requestSnap "Do you want to install DBeaver CE? [SNAP]" "dbeaver-ce"
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
request "Do you want to install additional fonts (Noto, Papirus, Fira)?" "fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-powerline fonts-roboto fonts-cascadia-code"
request "Do you want to install FiraCode font?" "fonts-firacode"
sudo fc-cache -f -v

# Flutter SDK
# requestSnap "Do you want to install Flutter SDK? [SNAP]" "flutter"
# flutter
# flutter config
# flutter doctor

# Games
request "Do you want to install Steam?" "steam"
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo apt update && sudo apt upgrade -y
request "Do you want to install Lutris (game launcher for Wine/Proton/Emulators)?" "lutris"
request "Do you want to install GameMode (Feral Interactive optimization daemon)?" "gamemode libgamemode0 libgamemodeauto0"
request "Do you want to install MangoHud (FPS overlay & performance metrics)?" "mangohud"
request "Do you want to install vkBasalt (Vulkan post-processing tool)?" "vkbasalt"
request "Do you want to install goverlay (GUI per MangoHud, vkBasalt, Gamescope)?" "goverlay"
requestFlatpak "Do you want to install ProtonUp-Qt (manage Proton-GE versions)? [FLATPAK]" "net.davidotek.pupgui2"
requestFlatpak "Do you want to install Heroic Games Launcher (Epic/GOG integration)? [FLATPAK]" "com.heroicgameslauncher.hgl"
request "Do you want to install itch.io client?" "itch"
request "Do you want to install PlayOnLinux?" "playonlinux"


# Games - Emulator
requestSnap "Do you want to install RetroArch (multi-emulator frontend)? [SNAP]" "retroarch"
request "Do you want to install MAME (arcade emulator)?" "mame"
request "Do you want to install ScummVM (classic adventure games emulator)?" "scummvm"
requestFlatpak "Do you want to install Dolphin (GameCube/Wii emulator)? [FLATPAK]" "org.DolphinEmu.dolphin-emu"
requestFlatpak "Do you want to install PCSX2 (PS2 emulator)? [FLATPAK]" "net.pcsx2.PCSX2"
requestFlatpak "Do you want to install DuckStation (PS1 emulator)? [FLATPAK]" "org.duckstation.DuckStation"
requestFlatpak "Do you want to install RPCS3 (PS3 emulator)? [FLATPAK]" "net.rpcs3.RPCS3"
requestFlatpak "Do you want to install Yuzu (Switch emulator)? [FLATPAK]" "org.yuzu_emu.yuzu"
requestFlatpak "Do you want to install Ryujinx (Switch emulator)? [FLATPAK]" "org.ryujinx.Ryujinx"
requestFlatpak "Do you want to install Citra (3DS emulator)? [FLATPAK]" "org.citra_emu.citra"
requestFlatpak "Do you want to install PPSSPP (PSP emulator)? [FLATPAK]" "org.ppsspp.PPSSPP"
requestFlatpak "Do you want to install Mupen64Plus-Next (Nintendo 64 emulator)? [FLATPAK]" "org.mupen64plus.Mupen64Plus-Next"
requestFlatpak "Do you want to install DOSBox-X (MS-DOS emulator)? [FLATPAK]" "com.dosbox_x.DOSBox-X"

# Gnome
request "Do you want to install gnome tweaks?" "gnome-tweaks"
request "Do you want to install Gnome extensions?" "gnome-shell-extensions chrome-gnome-shell"
request "Do you want to install Gnome Shell Extension Manager" "gnome-shell-extension-manager"
install_gnome_extension_from_prompt "Removable Drive Menu" "https://extensions.gnome.org/extension-data/drive-menugnome-shell-extensions.gcampax.github.com.v63.shell-extension.zip"
install_gnome_extension_from_prompt "AppIndicator and KStatusNotifierItem Support" "https://extensions.gnome.org/extension-data/appindicatorsupportrgcjonas.gmail.com.v60.shell-extension.zip"
install_gnome_extension_from_prompt "VirtualBox applet" "https://extensions.gnome.org/extension-data/vbox-appletgs.eros2.info.v18.shell-extension.zip"
install_gnome_extension_from_prompt "Simple Timer" "https://extensions.gnome.org/extension-data/simple-timermajortomvr.github.com.v15.shell-extension.zip"
install_gnome_extension_from_prompt "GSConnect" "https://extensions.gnome.org/extension-data/gsconnectandyholmes.github.io.v62.shell-extension.zip"
install_gnome_extension_from_prompt "RebootToUEFI" "https://extensions.gnome.org/extension-data/reboottouefiubaygd.com.v24.shell-extension.zip"
install_gnome_extension_from_prompt "Pip on top" "https://extensions.gnome.org/extension-data/pip-on-toprafostar.github.com.v8.shell-extension.zip"
install_gnome_extension_from_prompt "Display Configuration Switcher" "https://extensions.gnome.org/extension-data/display-configuration-switcherknokelmaat.gitlab.com.v10.shell-extension.zip"
install_gnome_extension_from_prompt "Proxy Switcher" "https://extensions.gnome.org/extension-data/ProxySwitcherflannaghan.com.v23.shell-extension.zip"
install_gnome_extension_from_prompt "Touchpad Switcher" "https://extensions.gnome.org/extension-data/touchpadgpawru.v7.shell-extension.zip"
install_gnome_extension_from_prompt "StreamController Integration" "https://extensions.gnome.org/extension-data/streamcontrollercore447.com.v4.shell-extension.zip"
install_gnome_extension_from_prompt "Steal my focus window" "https://extensions.gnome.org/extension-data/steal-my-focus-windowsteal-my-focus-window.v5.shell-extension.zip"
install_gnome_extension_from_prompt "Night Light Slider" "https://extensions.gnome.org/extension-data/night-light-sliderdevoscarm.github.com.v1.shell-extension.zip"
install_gnome_extension_from_prompt "Caffeine" "https://extensions.gnome.org/extension-data/caffeinepatapon.info.v57.shell-extension.zip"
install_gnome_extension_from_prompt "TeaTimer" "https://extensions.gnome.org/extension-data/TeaTimerzener.sbg.at.v9.shell-extension.zip"
install_gnome_extension_from_prompt "Wifi QR Code" "https://extensions.gnome.org/extension-data/wifiqrcodeglerro.pm.me.v17.shell-extension.zip"
install_gnome_extension_from_prompt "Resolution and Refresh Rate in Quick Settings" "https://extensions.gnome.org/extension-data/quick-settings-resolution-and-refresh-raterukins.github.io.v6.shell-extension.zip"
install_gnome_extension_from_prompt "Notifications Alert" "https://extensions.gnome.org/extension-data/notifications-alert-on-user-menuhackedbellini.gmail.com.v53.shell-extension.zip"
install_gnome_extension_from_prompt "Clipboard Indicator" "https://extensions.gnome.org/extension-data/clipboard-indicatortudmotu.com.v68.shell-extension.zip"
install_gnome_extension_from_prompt "Better End Session Dialog" "https://extensions.gnome.org/extension-data/better-end-session-dialogpopov895.ukr.net.v28.shell-extension.zip"
install_gnome_extension_from_prompt "Bluetooth File Sender" "https://extensions.gnome.org/extension-data/bluetooth-file-senderChristophrrb.github.io.v8.shell-extension.zip"
install_gnome_extension_from_prompt "Zen" "https://extensions.gnome.org/extension-data/zenle0.gs.v9.shell-extension.zip"
install_gnome_extension_from_prompt "Systemd Status" "https://extensions.gnome.org/extension-data/systemd-statusne0sight.github.io.v8.shell-extension.zip"
install_gnome_extension_from_prompt "Keyboard Backlight Slider" "https://extensions.gnome.org/extension-data/keyboard-backlight-menuophir.dev.v6.shell-extension.zip"
install_gnome_extension_from_prompt "Custom OSD" "https://extensions.gnome.org/extension-data/custom-osdneuromorph.v28.shell-extension.zip"
install_gnome_extension_from_prompt "Containers" "https://extensions.gnome.org/extension-data/containersroyg.v38.shell-extension.zip"
install_gnome_extension_from_prompt "HeadsetControl" "https://extensions.gnome.org/extension-data/HeadsetControllauinger-clan.de.v59.shell-extension.zip"
install_gnome_extension_from_prompt "Smart Home" "https://extensions.gnome.org/extension-data/smart-homechlumskyvaclav.gmail.com.v13.shell-extension.zip"
install_gnome_extension_from_prompt "Printers" "https://extensions.gnome.org/extension-data/printerslinux-man.org.v29.shell-extension.zip"
install_gnome_extension_from_prompt "SettingsCenter" "https://extensions.gnome.org/extension-data/SettingsCenterlauinger-clan.de.v31.shell-extension.zip"
install_gnome_extension_from_prompt "Bluetooth Battery Meter" "https://extensions.gnome.org/extension-data/Bluetooth-Battery-Metermaniacx.github.com.v32.shell-extension.zip"
install_gnome_extension_from_prompt "Tweaks & Extensions in System Menu" "https://extensions.gnome.org/extension-data/tweaks-system-menuextensions.gnome-shell.fifi.org.v24.shell-extension.zip"
install_gnome_extension_from_prompt "Easy Docker Containers" "https://extensions.gnome.org/extension-data/easy_docker_containersred.software.systems.v29.shell-extension.zip"
install_gnome_extension_from_prompt "Status Area Horizontal Spacing" "https://extensions.gnome.org/extension-data/status-area-horizontal-spacingmathematical.coffee.gmail.com.v30.shell-extension.zip"
install_gnome_extension_from_prompt "Random Wallpaper" "https://extensions.gnome.org/extension-data/randomwallpaperiflow.space.v36.shell-extension.zip"
install_gnome_extension_from_prompt "Lock Keys" "https://extensions.gnome.org/extension-data/lockkeysvaina.lt.v61.shell-extension.zip"
install_gnome_extension_from_prompt "ArcMenu" "https://extensions.gnome.org/extension-data/arcmenuarcmenu.com.v66.shell-extension.zip" 
install_gnome_extension_from_prompt "Media Controls" "https://extensions.gnome.org/extension-data/mediacontrolscliffniff.github.com.v37.shell-extension.zip"
install_gnome_extension_from_prompt "Dash to Panel" "https://extensions.gnome.org/extension-data/dash-to-paneljderose9.github.com.v68.shell-extension.zip"

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
cyberSecurity
requestSnap "Do you want to install Discord? [SNAP]" "discord"
requestSnap "Do you want to install Spotify? [SNAP]" "spotify"
requestSnap "Do you want to install Insomnia (API client)? [SNAP]" "insomnia"
requestSnap "Do you want to install Postman (API client)? [SNAP]" "postman"
requestSnap "Do you want to install Bruno? (API client)? [SNAP]" "bruno"
fiddler
charles
request "Do you want to install HTTP Toolkit (intercept HTTP/HTTPS)?" "httptoolkit"
request "Do you want to install mitmproxy (intercept HTTP/HTTPS)?" "mitmproxy"
requestSnap "Do you want to install OWASP ZAP? [SNAP]" "zaproxy --classic"
request "Do you want to install Filezilla FTP client?" "filezilla"


# NodeJS
request "Do you want to install NodeJS and npm?" "nodejs npm"

# Office
request "Do you want to install Onedrive client (rclone backend)?" "onedrive"
requestSnap "Do you want to install Office365 Web Desktop? [SNAP]" "office365webdesktop"

# OpenRGB
#requestFlatpak "Do you want to install OpenRGB? [FLATPAK]" "openrgb" # Not working on Ubuntu 22.04, need to compile from source
openRgb

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

# Launcher
ulauncher
albert

# Utils
request "Do you want to install Stacer (system optimizer/monitor)?" "stacer"
request "Do you want to install BleachBit (system cleaner)?" "bleachbit"
request "Do you want to install OBS Studio (screen recorder)?" "obs-studio"

# VirtualBox
request "Do you want to install VirtualBox and extension pack?" "virtualbox virtualbox-ext-pack"
sudo usermod -aG vboxusers "$USER"

# Windows
requestFlatpak "Do you want to install Bottles (manage Windows apps)? [FLATPAK]" "com.usebottles.bottles"

# Java
request "Do you want to install OpenJDK 11?" "openjdk-11-jdk"
request "Do you want to install OpenJDK 17?" "openjdk-17-jdk"
requestSnap "Do you want to install Apache Netbeans IDE? [SNAP]" "netbeans" 

# Other
requestSnap "Do you want to install TickTick? [SNAP]" "ticktick"


# Finale
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "Completed! Bye"

