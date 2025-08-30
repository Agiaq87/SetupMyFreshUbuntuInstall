request() {
    local message="$1"
    local command="$2"

    # chiede conferma
    read -p "${message} (Y/N): " choice

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
    read -p "${message} (Y/N): " choice

    case "$choice" in
        y|Y )
            eval "sudo snap install ${command}"
            ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

ulauncher() {
    read -p "Do you want to install ULauncher? (Y/N): " choice

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
    read -p "Do you want to install Google Chrome? (Y/N): " choice

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

edge() {
    read -p "Do you want to install Microsoft Edge? (Y/N): " choice

    case "$choice" in
        y|Y )
            curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
            sudo apt update
            sudo apt install -y microsoft-edge-stable
                        ;;
        * )
            echo "Operazione annullata."
            ;;
    esac
}

teamViewer() {
    read -p "Do you want to install TeamViewer? (Y/N): " choice

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

echo "Starting backup script..."
# Update and upgrade the system
sudo apt update && sudo apt upgrade -y && sudo snap refresh

# Dirver section
request "Do you want to install additional drivers?" "ubuntu-drivers-common && sudo ubuntu-drivers autoinstall"

# Must install
request "Do you want to install nala?" "sudo apt install -y nala"
sudo nala fetch
request "Do you want to install package gui utils ?" "gdebi synaptic"
request "Do you want to install Flatpak and setup Flathub?" "flatpak && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
request "Do you want to install compression utils?" "unzip zip unrar p7zip tar"
request "Do you need restricted extras (mp3, etc) and gstreamer codec?" "ubuntu-restricted-extras gstreamer1.0-vaapi"
request "Do you want to install system monitoring tools?" "htop neofetch bpytop"
request "Do you want to install file system tools?" "samba-common-bin exfat-fuse ntfs-3g"
request "Do you want to install development tools (curl, wget, build-essential, headers)?" "curl wget build-essential linux-headers-$(uname -r) linux-headers-generic git"
request "Do you want to install video tools (libfuse2, libxi6, libxrender1, libxtst6, libfontconfig1, mesa-utils)?" "libfuse2 libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils"
request "Do you want to install neofetch?" "neofetch"

# Browser
chrome
edge
requestSnap "Do you want to install Opera browser? [SNAP]" "opera-stable"

# Cloud integration
request "Do you want to install cloud integration tools rclone?" "rclone"
request "Do you want to install Dropbox CLI?" "nautilus-dropbox"
request "Do you want to installNextcloud client?" "nextcloud-desktop"

# Firewall
request "Do you want to install and enable UFW firewall?" "ufw"
request "Do yopu want to install UFW GUI?" "gufw"
sudo ufw enable

# Font
request "Do you want to install Microsoft fonts?" "ttf-mscorefonts-installer"
request "Do you want to install Font Manager?" "font-manager"
request "Do you want to install additional fonts (Noto, Papirus, Fira)?" "fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-firacode fonts-powerline"
request "Do you want to install FiraCode font?" "fonts-firacode"

# Gnome
request "Do you want to install gnome tweaks?" "gnome-tweaks"
request "Do you want to install Gnome extensions?" "gnome-shell-extensions chrome-gnome-shell"

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

# Python
request "Do you want to install Python and pip?" "python3 python3-pip python3-dev"

# TeamViewer
teamViewer

# Ulauncher
ulauncher





