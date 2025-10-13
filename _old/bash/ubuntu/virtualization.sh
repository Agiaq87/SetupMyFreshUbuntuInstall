#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "VirtualBox section"
if ask_yes_no "Do you want to install VirtualBox?" Y; then
    if ask_yes_no "Do you prefer to install VirtualBox from official repository? [Suggested: No]" Y; then
        silent_run_with_spinner "Adding VirtualBox's Repo GPG key"  bash -c '
            wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
        '
        silent_run_with_spinner "Adding VirtualBox's Repo" bash -c '
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] http://download.virtualbox.org/virtualbox/debian $(. /etc/os-release && echo "$VERSION_CODENAME") contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
        '
        silent_run_with_spinner "Updating system" sudo nala update
        silent_run_with_spinner "Preparing system" sudo nala install dirmngr ca-certificates software-properties-common apt-transport-https curl wget -y
        silent_run_with_spinner "Installing VirtualBox from official repository" sudo nala install -y virtualbox-7.1 linux-headers-$(uname -r)
        silent_run_with_spinner "Update system" sudo apt-cache policy virtualbox-7.1
        silent_run_with_spinner "Installing VirtualBox Extension Pack" bash -c '
            wget https://download.virtualbox.org/virtualbox/7.1.0/Oracle_VirtualBox_Extension_Pack-7.1.0.vbox-extpack
            sudo vboxmanage extpack install Oracle_VirtualBox_Extension_Pack-7.1.0.vbox-extpack
        '
        silent_run_with_spinner "Setup VirtualBox" sudo usermod -aG vboxusers "$USER"
        silent_run_with_spinner "Setup systemd service" sudo systemctl enable vboxdrv --now
    else
        silent_run_with_spinner "Installing VirtualBox from ubuntu repository" sudo nala install -y virtualbox
    fi
fi

log INFO "Docker section"
if ask_yes_no "Do you want to install docker?" Y; then
    if ask_yes_no "Do you wanto to use Docker Desktop repository?"; Y then
        silent_run_with_spinner "Docker dependencies" sudo nala install apt-transport-https ca-certificates software-properties-common gnome-terminal -y
        silent_run_with_spinner "Add GPG key..." bash -c 'sudo install -m 0755 -d /etc/apt/keyrings 
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null 
        chmod a+r /etc/apt/keyrings/docker.asc'
        silent_run_with_spinner "Add Docker repository" bash -c 'echo 
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null '
        silent_run_with_spinner "Update packages list" sudo nala update
        silent_run_with_spinner "Download Docker Desktop deb package" curl -O https://desktop.docker.com/linux/main/amd64/docker-desktop-4.41.2-amd64.deb
        silent_run_with_spinner "Install..." sudo nala install -y ./docker-desktop-4.41.2-amd64.deb
        silent_run_with_spinner "Remove Docker Desktop deb package" rm docker-desktop-4.41.2-amd64.deb
        silent_run_with_spinner "Setup Docker desktop" bash -c '
        systemctl --user enable docker-desktop
        systemctl --user start docker-desktop 
        '
    else
        silent_run_with_spinner "Installing Docker from ubuntu repository" sudo nala install -y docker.io docker-compose
        silent_run_with_spinner "Setup Docker" sudo systemctl enable docker --now
        silent_run_with_spinner "Add user to docker group" sudo usermod -aG docker "$USER"
    fi
fi

log INFO "QEMU/KVM section"
if ask_yes_no "Do you want to install QEMU/KVM?" Y; then
    silent_run_with_spinner "Installing libraries" nala install -y qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf
    silent_run_with_spinner "Add user to kvm group" sudo adduser $USER kvm
    silent_run_with_spinner "Start service" sudo systemctl enable --now libvirtd
fi