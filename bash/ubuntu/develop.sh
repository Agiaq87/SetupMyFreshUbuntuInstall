#!/bin/bash
#set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

silent_run_with_spinner "Install base development" bash -c '
sudo nala install -y \
    git build-essential libgl1-mesa-dev libclang-dev cmake ninja-build adb fastboot openjdk-17-jdk lib32z1 lib32ncurses6 lib32stdc++6 \
    clang cargo libc6-i386 libc6-x32 libu2f-udev bzip2 tar gcc g++ make python3 python3-pip python3-venv python-is-python3 \
    libgl1-mesa-dri libgbm-dev libdrm-dev libx11-dev libxext-dev libgtk-3-dev libgdk-pixbuf2.0-dev libpango1.0-dev libcairo2-dev \
    libdbus-1-dev libpulse-dev libasound2-dev libcap-dev libudev-dev libusb-1.0-0-dev jq
'

if ask_yes_no "Do you want to install github desktop?" Y; then
    silent_run_with_spinner "Setup for GitHub desktop" sudo wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
    silent_run_with_spinner "Update apt" sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'
    silent_run_with_spinner "Update system" sudo nala update
    silent_run_with_spinner "Installing GitHub desktop" sudo nala install -y github-desktop
else
    log INFO "Skipping GitHub desktop installation"
fi

ask_to_install "GitKraken Desktop" sudo snap install --classic  gitkraken

ask_to_install "Postman" sudo snap install postman
ask_to_install "Insomnia" sudo snap install insomnia

if ask_yes_no "Do you want to install Bruno (Postman like app)?" Y; then
    silent_run_with_spinner "Installing Bruno" sudo snap install bruno
fi

ask_to_install "Visual Studio Code" sudo snap install code
ask_to_install "VSCodium" sudo snap install codium

ask_to_install "Sublime Text" sudo snap install sublime-text
ask_to_install "Eclipse" sudo snap install eclipse
ask_to_install "Apache Netbeans" sudo snap install netbeans

log INFO "JetBrains section"
if ask_yes_no "Do you prefer JetBrains Toolbox?" Y; then
    local download_url="https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.2.3.20090.tar.gz"
    local latest_url
    local install_dir ="/opt/jetbrains"

    latest_url=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" | grep -o '"linux"[^}]*"link":"[^"]*' | sed 's/.*"link":"//g' | head -1 2>/dev/null || echo "")

    if [[ -n "$latest_url" ]]; then
        download_url="$latest_url"
        log INFO "Found latest version URL"
    else
        log WARNING "Using fallback download URL"
    fi

    silent_run_with_spinner "Download" wget -q -O "jetbrains-toolbox.tar.gz" "$download_url"
    silent_run_with_spinner "Extracting" tar -xzf "jetbrains-toolbox.tar.gz" --strip-components=1

    local toolbox_binary
    toolbox_binary=$(find "$temp_dir" -name "jetbrains-toolbox" -type f -executable | head -1)

    if [[ -z "$toolbox_binary" ]]; then
        log ERROR "Could not find jetbrains-toolbox executable"
        exit 1
    fi

    sudo mkdir -p "$install_dir"
    sudo cp "$toolbox_binary" "$install_dir/"
    sudo chmod +x "$install_dir/jetbrains-toolbox"
    sudo ln -sf "$install_dir/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox
    sudo rm "$toolbox_binary"

    log INFO "Successfully installed JetBrains Toolbox"
else
    log INFO "Starting ask to install all JetBrains IDE"
    ask_to_install "PyCharm Community" sudo snap install pycharm-community
    ask_to_install "PyCharm Professional" sudo snap install pycharm-professional
    ask_to_install "IntelliJ IDEA Community" sudo snap install intellij-idea-community
    ask_to_install "IntelliJ IDEA Ultimate" sudo snap install intellij-idea-ultimate
    ask_to_install "Android Studio" sudo snap install android-studio
    ask_to_install "PhpStorm" sudo snap install phpstorm
    ask_to_install "WebStorm" sudo snap install webstorm
    ask_to_install "CLion" sudo snap install clion
    ask_to_install "DataGrip" sudo snap install datagrip
    ask_to_install "RubyMine" sudo snap install rubymine
    ask_to_install "RustRover" sudo snap install rustrover
    ask_to_install "GoLand" sudo snap install goland
    ask_to_install "Space" sudo snap install space
    ask_to_install "DataSpell" sudo snap install dataspell
    ask_to_install "Rider" sudo snap install rider
fi

log INFO "Database section"
print_menu "DBeaver" "Beekeeper Studio" "Antares SQL Client"
ask_to_install "DBeaver" sudo snap install dbeaver-ce
ask_to_install "Beekeeper Studio" sudo snap install beekeeper-studio
ask_to_install "Antares SQL Client" sudo snap install antares



