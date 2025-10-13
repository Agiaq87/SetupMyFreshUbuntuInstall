#!/bin/bash
must_install() {
    log "Starting must install"
    debug "Entering must install section"

    case $GUI_ENGINE in
            "zenity"|"yad")
                (
                    echo "10" ;  sudo nala update 2>&1 | tee -a "$LOG_FILE"
                    echo "20" ;  sudo nala upgrade -y 2>&1 | tee -a "$LOG_FILE"
                    echo "40" ;  sudo nala install -y ubuntu-restricted-extras gstreamer1.0-vaapi cheese clang cargo p7zip bzip2 make 2>&1 | tee -a "$LOG_FILE"
                    echo "60" ;  sudo nala install -y libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils tar wget curl unrar 2>&1 | tee -a "$LOG_FILE"
                    echo "60" ;  sudo nala install -y samba-common-bin exfat-fuse ntfs-3g gnome-tweaks gnome-shell-extension-manager 2>&1 | tee -a "$LOG_FILE"
                    echo "80" ;  sudo nala install -y linux-headers-$(uname -r) linux-headers-generic libfuse2t64 gnupg gdebi htop bpytop neofetch 2>&1 | tee -a "$LOG_FILE"
                    echo "100" ; sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ) | show_progress "System Update" "Updating system in progress..."
                ;;
            *)
                sudo nala update 2>&1 | tee -a "$LOG_FILE"
                sudo nala upgrade -y 2>&1 | tee -a "$LOG_FILE"
                sudo nala install -y ubuntu-restricted-extras gstreamer1.0-vaapi cheese clang cargo p7zip bzip2 make 2>&1 | tee -a "$LOG_FILE"
                sudo nala install -y libxi6 libxrender1 libxtst6 libfontconfig1 mesa-utils tar wget curl unrar 2>&1 | tee -a "$LOG_FILE"
                sudo nala install -y samba-common-bin exfat-fuse ntfs-3g gnome-tweaks gnome-shell-extension-manager 2>&1 | tee -a "$LOG_FILE"
                sudo nala install -y linux-headers-$(uname -r) linux-headers-generic libfuse2t64 gnupg gdebi htop bpytop neofetch 2>&1 | tee -a "$LOG_FILE"
                sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac

        show_message "Completed" "System updated successfully!"
        log "System update completed"
        debug "System update finished successfully"
}