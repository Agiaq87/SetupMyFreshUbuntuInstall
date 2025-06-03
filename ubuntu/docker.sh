#!/bin/bash
set -x
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

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
systemctl --user start docker-desktop '

log INFO "Docker desktop OK"
