#!/bin/bash

show_virtualization_menu() {
    log INFO "Opening virtualization menu..."
    # Define available software (format: id|name|description)
    local virt_items=(
        "virtualbox|VirtualBox|Oracle VM VirtualBox - Desktop virtualization"
        "vagrant|Vagrant|Tool for building and managing virtual machine environments"
        "docker-desktop|Docker Desktop|Docker Desktop with GUI for container management"
        "docker-engine|Docker Engine|Docker Engine (CLI only) - Container runtime"
        "podman|Podman|Daemonless container engine alternative to Docker"
        "podman-desktop|Podman Desktop|Desktop application for managing containers with Podman"
        "kubernetes|Kubernetes (kubectl)|Kubernetes command-line tool"
        "minikube|Minikube|Local Kubernetes cluster for development"
        "k9s|K9s|Terminal UI to manage Kubernetes clusters"
        "helm|Helm|Kubernetes package manager"
        "kind|KIND|Kubernetes IN Docker - local Kubernetes clusters"
        "k3s|K3s|Lightweight Kubernetes distribution"
        "rancher-desktop|Rancher Desktop|Container management and Kubernetes on desktop"
        "lens|Lens|Kubernetes IDE - The largest Kubernetes platform"
        "qemu|QEMU/KVM|Full virtualization solution with KVM acceleration"
        "virt-manager|Virt-Manager|Virtual Machine Manager GUI for KVM/QEMU"
        "gnome-boxes|GNOME Boxes|Simple virtualization tool for GNOME"
        "lxd|LXD|System container and virtual machine manager"
        "lxc|LXC|Linux Containers - Lightweight virtualization"
        "incus|Incus|Modern system container and virtual machine manager (LXD fork)"
        "multipass|Multipass|Ubuntu VMs on demand for development"
        "distrobox|Distrobox|Run any Linux distribution inside your terminal"
        "toolbox|Toolbox|Tool for containerized command line environments"
        "dive|Dive|Tool for exploring Docker image layers"
        "lazydocker|Lazydocker|Terminal UI for Docker and docker-compose"
        "portainer|Portainer CE|Container management platform"
        "ctop|ctop|Top-like interface for container metrics"
        "skopeo|Skopeo|Work with remote container images and registries"
        "buildah|Buildah|Tool for building OCI container images"
        "kompose|Kompose|Convert docker-compose to Kubernetes"
        "terraform|Terraform|Infrastructure as Code tool"
        "packer|Packer|Automated machine image builder"
        "ansible|Ansible|IT automation platform"
        "vagrant-manager|Vagrant Manager|Manage Vagrant boxes graphically"
        "vmware-workstation|VMware Workstation Player|VMware virtualization (manual install)"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Virtualization Tools Selection" "Choose virtualization tools to install:" "${virt_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Virtualization tools selection cancelled"
        return
    fi

    log INFO "Selected virtualization tools: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "virtualbox")
                log INFO "Installing VirtualBox from Oracle repository..."
                add_repository "VirtualBox" \
                    "https://www.virtualbox.org/download/oracle_vbox_2016.asc" \
                    "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" \
                    "/etc/apt/sources.list.d/virtualbox.list"

                install_package_secure "VirtualBox" "virtualbox-7.1" "nala" "Oracle VM VirtualBox" || log WARN "VirtualBox installation failed, continuing..."

                sudo usermod -aG vboxusers $USER
                log INFO "User added to vboxusers group (requires logout to take effect)"
                ;;

            "vagrant")
                add_repository "Vagrant" \
                    "https://apt.releases.hashicorp.com/gpg" \
                    "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
                    "/etc/apt/sources.list.d/hashicorp.list"
                install_package_secure "Vagrant" "vagrant" "nala" "Virtual machine environment manager" || log WARN "Vagrant installation failed, continuing..."
                ;;

            "docker-desktop")
                log INFO "Installing Docker Desktop..."
                local docker_deb="/tmp/docker-desktop.deb"
                wget -O "$docker_deb" "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb" 2>&1 | \
                    zenity --progress --title="Downloading Docker Desktop" --text="Downloading..." --pulsate --auto-close

                if [ -f "$docker_deb" ]; then
                    install_package_secure "Docker Desktop" "$docker_deb" "nala" "Docker Desktop with GUI" || log WARN "Docker Desktop installation failed, continuing..."
                    rm -f "$docker_deb"
                else
                    log ERROR "Failed to download Docker Desktop"
                fi
                ;;

            "docker-engine")
                log INFO "Installing Docker Engine..."
                add_repository "Docker" \
                    "https://download.docker.com/linux/ubuntu/gpg" \
                    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
                    "/etc/apt/sources.list.d/docker.list"

                install_package_secure "Docker Engine" "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" "nala" "Docker container runtime" || log WARN "Docker Engine installation failed, continuing..."

                sudo usermod -aG docker $USER
                log INFO "User added to docker group (requires logout to take effect)"
                ;;

            "podman")
                install_package_secure "Podman" "podman podman-compose" "nala" "Daemonless container engine" || log WARN "Podman installation failed, continuing..."
                ;;

            "podman-desktop")
                log INFO "Installing Podman Desktop..."
                local podman_desktop_url=$(curl -s https://api.github.com/repos/containers/podman-desktop/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local podman_deb="/tmp/podman-desktop.deb"

                wget -O "$podman_deb" "$podman_desktop_url" 2>&1 | \
                    zenity --progress --title="Downloading Podman Desktop" --text="Downloading..." --pulsate --auto-close

                if [ -f "$podman_deb" ]; then
                    install_package_secure "Podman Desktop" "$podman_deb" "nala" "Desktop app for Podman" || log WARN "Podman Desktop installation failed, continuing..."
                    rm -f "$podman_deb"
                else
                    log ERROR "Failed to download Podman Desktop"
                fi
                ;;

            "kubernetes")
                log INFO "Installing kubectl..."
                add_repository "Kubernetes" \
                    "https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key" \
                    "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
                    "/etc/apt/sources.list.d/kubernetes.list"

                install_package_secure "kubectl" "kubectl" "nala" "Kubernetes command-line tool" || log WARN "kubectl installation failed, continuing..."
                ;;

            "minikube")
                log INFO "Installing Minikube..."
                local minikube_deb="/tmp/minikube.deb"
                wget -O "$minikube_deb" "https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb" 2>&1 | \
                    zenity --progress --title="Downloading Minikube" --text="Downloading..." --pulsate --auto-close

                if [ -f "$minikube_deb" ]; then
                    install_package_secure "Minikube" "$minikube_deb" "nala" "Local Kubernetes cluster" || log WARN "Minikube installation failed, continuing..."
                    rm -f "$minikube_deb"
                else
                    log ERROR "Failed to download Minikube"
                fi
                ;;

            "k9s")
                install_package_secure "K9s" "k9s" "snap" "Kubernetes cluster manager UI" || log WARN "K9s installation failed, continuing..."
                ;;

            "helm")
                log INFO "Installing Helm..."
                curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 2>&1 | \
                    zenity --progress --title="Installing Helm" --text="Installing Helm..." --pulsate --auto-close

                if command -v helm &> /dev/null; then
                    log INFO "Helm installed successfully"
                    show_notification "Installation completed" "Helm installed!"
                else
                    log WARN "Helm installation failed, continuing..."
                fi
                ;;

            "kind")
                log INFO "Installing KIND..."
                local kind_bin="/usr/local/bin/kind"
                sudo curl -Lo "$kind_bin" "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64" 2>&1 | \
                    zenity --progress --title="Downloading KIND" --text="Downloading..." --pulsate --auto-close

                sudo chmod +x "$kind_bin"
                if command -v kind &> /dev/null; then
                    log INFO "KIND installed successfully"
                    show_notification "Installation completed" "KIND installed!"
                else
                    log WARN "KIND installation failed, continuing..."
                fi
                ;;

            "k3s")
                log INFO "Installing K3s..."
                curl -sfL https://get.k3s.io | sh - 2>&1 | \
                    zenity --progress --title="Installing K3s" --text="Installing K3s..." --pulsate --auto-close

                if command -v k3s &> /dev/null; then
                    log INFO "K3s installed successfully"
                    show_notification "Installation completed" "K3s installed!"
                else
                    log WARN "K3s installation failed, continuing..."
                fi
                ;;

            "rancher-desktop")
                log INFO "Installing Rancher Desktop..."
                local rancher_deb="/tmp/rancher-desktop.deb"
                local rancher_url=$(curl -s https://api.github.com/repos/rancher-sandbox/rancher-desktop/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)

                wget -O "$rancher_deb" "$rancher_url" 2>&1 | \
                    zenity --progress --title="Downloading Rancher Desktop" --text="Downloading..." --pulsate --auto-close

                if [ -f "$rancher_deb" ]; then
                    install_package_secure "Rancher Desktop" "$rancher_deb" "nala" "Container and K8s desktop" || log WARN "Rancher Desktop installation failed, continuing..."
                    rm -f "$rancher_deb"
                else
                    log ERROR "Failed to download Rancher Desktop"
                fi
                ;;

            "lens")
                install_package_secure "Lens" "kontena-lens" "snap" "Kubernetes IDE" || log WARN "Lens installation failed, continuing..."
                ;;

            "qemu")
                install_package_secure "QEMU/KVM" "qemu-kvm qemu-system qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-viewer" "nala" "Full virtualization with KVM" || log WARN "QEMU/KVM installation failed, continuing..."

                sudo usermod -aG libvirt,kvm $USER
                log INFO "User added to libvirt and kvm groups (requires logout to take effect)"
                ;;

            "virt-manager")
                install_package_secure "Virt-Manager" "virt-manager" "nala" "Virtual Machine Manager GUI" || log WARN "Virt-Manager installation failed, continuing..."
                ;;

            "gnome-boxes")
                install_package_secure "GNOME Boxes" "gnome-boxes" "nala" "Simple virtualization for GNOME" || log WARN "GNOME Boxes installation failed, continuing..."
                ;;

            "lxd")
                install_package_secure "LXD" "lxd" "snap" "System container and VM manager" || log WARN "LXD installation failed, continuing..."

                sudo usermod -aG lxd $USER
                log INFO "User added to lxd group (requires logout to take effect)"
                ;;

            "lxc")
                install_package_secure "LXC" "lxc lxc-templates" "nala" "Linux Containers" || log WARN "LXC installation failed, continuing..."
                ;;

            "incus")
                log INFO "Installing Incus..."
                # Incus repository for Ubuntu
                curl -fsSL https://pkgs.zabbly.com/key.asc | sudo gpg --dearmor -o /usr/share/keyrings/zabbly.gpg
                echo "deb [signed-by=/usr/share/keyrings/zabbly.gpg] https://pkgs.zabbly.com/incus/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/zabbly-incus-stable.list

                install_package_secure "Incus" "incus" "nala" "Modern container/VM manager" || log WARN "Incus installation failed, continuing..."

                sudo usermod -aG incus-admin $USER
                log INFO "User added to incus-admin group (requires logout to take effect)"
                ;;

            "multipass")
                install_package_secure "Multipass" "multipass" "snap" "Ubuntu VMs on demand" || log WARN "Multipass installation failed, continuing..."
                ;;

            "distrobox")
                install_package_secure "Distrobox" "distrobox" "nala" "Run any distro in terminal" || log WARN "Distrobox installation failed, continuing..."
                ;;

            "toolbox")
                install_package_secure "Toolbox" "toolbox" "nala" "Containerized CLI environments" || log WARN "Toolbox installation failed, continuing..."
                ;;

            "dive")
                log INFO "Installing Dive..."
                local dive_deb="/tmp/dive.deb"
                local dive_url=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)

                wget -O "$dive_deb" "$dive_url" 2>&1 | \
                    zenity --progress --title="Downloading Dive" --text="Downloading..." --pulsate --auto-close

                if [ -f "$dive_deb" ]; then
                    install_package_secure "Dive" "$dive_deb" "nala" "Docker image explorer" || log WARN "Dive installation failed, continuing..."
                    rm -f "$dive_deb"
                else
                    log ERROR "Failed to download Dive"
                fi
                ;;

            "lazydocker")
                log INFO "Installing Lazydocker..."
                local lazydocker_dir="/tmp/lazydocker"
                mkdir -p "$lazydocker_dir"
                curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash 2>&1 | \
                    zenity --progress --title="Installing Lazydocker" --text="Installing..." --pulsate --auto-close

                if command -v lazydocker &> /dev/null; then
                    log INFO "Lazydocker installed successfully"
                    show_notification "Installation completed" "Lazydocker installed!"
                else
                    log WARN "Lazydocker installation failed, continuing..."
                fi
                ;;

            "portainer")
                log INFO "Installing Portainer CE..."
                show_message "Info" "Portainer will be installed as a Docker container.\nMake sure Docker is installed first.\n\nRun after installation:\nsudo docker volume create portainer_data\nsudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest"
                ;;

            "ctop")
                log INFO "Installing ctop..."
                sudo wget -O /usr/local/bin/ctop https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 2>&1 | \
                    zenity --progress --title="Downloading ctop" --text="Downloading..." --pulsate --auto-close

                sudo chmod +x /usr/local/bin/ctop
                if command -v ctop &> /dev/null; then
                    log INFO "ctop installed successfully"
                    show_notification "Installation completed" "ctop installed!"
                else
                    log WARN "ctop installation failed, continuing..."
                fi
                ;;

            "skopeo")
                install_package_secure "Skopeo" "skopeo" "nala" "Work with container images" || log WARN "Skopeo installation failed, continuing..."
                ;;

            "buildah")
                install_package_secure "Buildah" "buildah" "nala" "Build OCI containers" || log WARN "Buildah installation failed, continuing..."
                ;;

            "kompose")
                log INFO "Installing Kompose..."
                sudo curl -L https://github.com/kubernetes/kompose/releases/download/v1.34.0/kompose-linux-amd64 -o /usr/local/bin/kompose 2>&1 | \
                    zenity --progress --title="Downloading Kompose" --text="Downloading..." --pulsate --auto-close

                sudo chmod +x /usr/local/bin/kompose
                if command -v kompose &> /dev/null; then
                    log INFO "Kompose installed successfully"
                    show_notification "Installation completed" "Kompose installed!"
                else
                    log WARN "Kompose installation failed, continuing..."
                fi
                ;;

            "terraform")
                add_repository "Terraform" \
                    "https://apt.releases.hashicorp.com/gpg" \
                    "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
                    "/etc/apt/sources.list.d/hashicorp.list"
                install_package_secure "Terraform" "terraform" "nala" "Infrastructure as Code" || log WARN "Terraform installation failed, continuing..."
                ;;

            "packer")
                add_repository "Packer" \
                    "https://apt.releases.hashicorp.com/gpg" \
                    "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
                    "/etc/apt/sources.list.d/hashicorp.list"
                install_package_secure "Packer" "packer" "nala" "Machine image builder" || log WARN "Packer installation failed, continuing..."
                ;;

            "ansible")
                install_package_secure "Ansible" "ansible" "nala" "IT automation platform" || log WARN "Ansible installation failed, continuing..."
                ;;

            "vagrant-manager")
                log INFO "Vagrant Manager is primarily for macOS. Consider using 'vagrant global-status' for CLI management."
                show_message "Info" "Vagrant Manager is primarily for macOS.\n\nFor Linux, use:\n- vagrant global-status\n- vagrant-vmware-desktop (commercial)\n\nOr install a third-party GUI from GitHub."
                ;;

            "vmware-workstation")
                show_message "Manual Installation Required" "VMware Workstation Player requires manual installation:\n\n1. Download from: https://www.vmware.com/products/workstation-player.html\n2. Make executable: chmod +x VMware-Player-*.bundle\n3. Run: sudo ./VMware-Player-*.bundle\n\nNote: Free for personal use only."
                xdg-open "https://www.vmware.com/products/workstation-player.html" 2>/dev/null &
                ;;
        esac
    done

    show_message "Completed" "Virtualization tools installation completed!\n\nNote: Some tools require logout/reboot for group permissions to take effect.\n\nFor Portainer and other Docker-based tools, make sure Docker is running."
}