#!/bin/bash

show_system_menu() {
    log INFO "Opening system tools menu..."
    # Define available software (format: id|name|description)
    local system_items=(
        "gparted|GParted|Partition editor for managing disk partitions"
        "gnome-disks|GNOME Disks|Disk management utility for GNOME"
        "kde-partition-manager|KDE Partition Manager|KDE tool for managing disk devices"
        "balena-etcher|balenaEtcher|Flash OS images to SD cards and USB drives"
        "ventoy|Ventoy|Multiboot USB drive creator (keeps ISO files)"
        "unetbootin|UNetbootin|Create bootable USB drives from ISO"
        "woeusb|WoeUSB-ng|Create Windows bootable USB from ISO"
        "popsicle|Popsicle|USB flasher for multiple drives simultaneously"
        "multibootusb|MultiBootUSB|Create multiboot USB with multiple distros"
        "testdisk|TestDisk|Data recovery software for lost partitions"
        "photorec|PhotoRec|File data recovery software"
        "ddrescue|GNU ddrescue|Data recovery tool for damaged drives"
        "foremost|Foremost|Recover files based on headers and footers"
        "extundelete|Extundelete|Recover deleted files from ext3/ext4"
        "scalpel|Scalpel|Fast file carving tool"
        "safecopy|Safecopy|Data recovery tool for damaged sources"
        "brasero|Brasero|CD/DVD burning application for GNOME"
        "k3b|K3B|CD/DVD burning application for KDE"
        "xfburn|Xfburn|Simple CD/DVD burning tool"
        "cdrdao|cdrdao|CD recording tool (command-line)"
        "dvd+rw-tools|dvd+rw-tools|DVD burning tools"
        "gnomebaker|GnomeBaker|CD/DVD burning application"
        "smartmontools|smartmontools|Monitor and control storage devices (S.M.A.R.T.)"
        "hdparm|hdparm|Tune hard disk parameters"
        "nvme-cli|nvme-cli|NVMe management command line interface"
        "disks-analyzer|Baobab|Disk usage analyzer"
        "filelight|Filelight|Disk usage statistics (KDE)"
        "ncdu|ncdu|NCurses Disk Usage analyzer"
        "duf|duf|Modern disk usage/free utility"
        "gdu|gdu|Fast disk usage analyzer with console interface"
        "fdupes|fdupes|Find and remove duplicate files"
        "rmlint|rmlint|Find duplicate files and other lint"
        "czkawka|Czkawka|Multi-functional app to find duplicates, empty folders, etc"
        "bleachbit|BleachBit|System cleaner and privacy tool"
        "stacer|Stacer|System optimizer and monitoring tool"
        "syncthing|Syncthing|Continuous file synchronization"
        "rsync|rsync|Fast incremental file transfer"
        "rclone|Rclone|Sync files to/from cloud storage"
        "timeshift|Timeshift|System restore utility"
        "backintime|Back In Time|Backup tool inspired by Time Machine"
        "deja-dup|Déjà Dup|Simple backup tool for GNOME"
        "borg|BorgBackup|Deduplicating backup program"
        "restic|Restic|Fast and secure backup program"
        "duplicity|Duplicity|Encrypted backup using rsync"
        "grsync|Grsync|GUI for rsync"
        "fsarchiver|FSArchiver|Filesystem archiver"
        "partclone|Partclone|Partition cloning tool"
        "clonezilla|Clonezilla|Partition and disk imaging/cloning"
        "ddrescueview|ddrescueview|Graphical viewer for GNU ddrescue log files"
        "testdisk-gui|QPhotoRec|GUI for PhotoRec"
        "mkusb|mkusb|Tool for creating bootable USB drives"
        "usb-creator-gtk|USB Startup Disk Creator|Create bootable USB from Ubuntu ISO"
        "fatrace|fatrace|Report system-wide file access events"
        "iotop|iotop|Monitor I/O usage by processes"
        "htop|htop|Interactive process viewer"
        "btop|btop++|Resource monitor with a nice interface"
        "nmon|nmon|Performance monitoring tool"
        "sysstat|sysstat|Performance monitoring tools collection"
        "lm-sensors|lm-sensors|Hardware monitoring tools"
        "psensor|Psensor|Graphical hardware temperature monitor"
        "hardinfo|HardInfo|System information and benchmark tool"
        "cpu-x|CPU-X|System information software (like CPU-Z)"
        "inxi|inxi|Full featured system information script"
        "neofetch|Neofetch|System information tool"
        "fastfetch|Fastfetch|Faster neofetch alternative"
        "usbview|USBView|USB device viewer"
        "lsusb|usbutils|USB device listing utilities"
        "usb-devices|usbutils|Display USB devices information"
        "ext4magic|ext4magic|Recover deleted files from ext4"
        "recoverjpeg|recoverjpeg|Recover JPEG images from damaged media"
        "magicrescue|magicrescue|Recover files by looking for magic bytes"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "System Tools Selection" "Choose system and storage tools to install:" "${system_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "System tools selection cancelled"
        return
    fi

    log INFO "Selected system tools: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "gparted")
                install_package_secure "GParted" "gparted" "nala" "Partition editor" || log WARN "GParted installation failed, continuing..."
                ;;

            "gnome-disks")
                install_package_secure "GNOME Disks" "gnome-disk-utility" "nala" "Disk management utility" || log WARN "GNOME Disks installation failed, continuing..."
                ;;

            "kde-partition-manager")
                install_package_secure "KDE Partition Manager" "partitionmanager" "nala" "KDE partition tool" || log WARN "KDE Partition Manager installation failed, continuing..."
                ;;

            "balena-etcher")
                log INFO "Installing balenaEtcher..."
                local etcher_url=$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local etcher_deb="/tmp/balena-etcher.deb"

                wget -O "$etcher_deb" "$etcher_url" 2>&1 | \
                    zenity --progress --title="Downloading balenaEtcher" --text="Downloading..." --pulsate --auto-close

                if [ -f "$etcher_deb" ]; then
                    install_package_secure "balenaEtcher" "$etcher_deb" "nala" "USB/SD card flasher" || log WARN "balenaEtcher installation failed, continuing..."
                    rm -f "$etcher_deb"
                else
                    log ERROR "Failed to download balenaEtcher"
                fi
                ;;

            "ventoy")
                log INFO "Installing Ventoy..."
                show_message "Info" "Ventoy will be downloaded to /tmp/ventoy\n\nTo install:\n1. Extract the archive\n2. Run: sudo ./Ventoy2Disk.sh -i /dev/sdX\n\nReplace /dev/sdX with your USB drive"

                local ventoy_file="/tmp/ventoy-linux.tar.gz"
                wget -O "$ventoy_file" "https://github.com/ventoy/Ventoy/releases/download/v1.0.99/ventoy-1.0.99-linux.tar.gz" 2>&1 | \
                    zenity --progress --title="Downloading Ventoy" --text="Downloading..." --pulsate --auto-close

                if [ -f "$ventoy_file" ]; then
                    tar -xzf "$ventoy_file" -C /tmp/
                    log INFO "Ventoy downloaded and extracted to /tmp/ventoy-1.0.99"
                    show_notification "Download complete" "Ventoy extracted to /tmp/ventoy-1.0.99"
                else
                    log ERROR "Failed to download Ventoy"
                fi
                ;;

            "unetbootin")
                install_package_secure "UNetbootin" "unetbootin" "nala" "Bootable USB creator" || log WARN "UNetbootin installation failed, continuing..."
                ;;

            "woeusb")
                log INFO "Installing WoeUSB-ng..."
                install_package_secure "WoeUSB-ng" "python3-pip" "nala" "Python pip for WoeUSB" || log WARN "pip installation failed, continuing..."

                sudo pip3 install WoeUSB-ng 2>&1 | \
                    zenity --progress --title="Installing WoeUSB-ng" --text="Installing..." --pulsate --auto-close

                if command -v woeusb &> /dev/null; then
                    log INFO "WoeUSB-ng installed successfully"
                    show_notification "Installation completed" "WoeUSB-ng installed!"
                else
                    log WARN "WoeUSB-ng installation failed, continuing..."
                fi
                ;;

            "popsicle")
                install_package_secure "Popsicle" "popsicle" "flatpak" "Multiple USB flasher" || log WARN "Popsicle installation failed, continuing..."
                ;;

            "multibootusb")
                install_package_secure "MultiBootUSB" "multibootusb" "nala" "Multiboot USB creator" || log WARN "MultiBootUSB installation failed, continuing..."
                ;;

            "testdisk")
                install_package_secure "TestDisk" "testdisk" "nala" "Data recovery tool" || log WARN "TestDisk installation failed, continuing..."
                ;;

            "photorec")
                install_package_secure "PhotoRec" "testdisk" "nala" "File recovery tool (included with TestDisk)" || log WARN "PhotoRec installation failed, continuing..."
                ;;

            "ddrescue")
                install_package_secure "GNU ddrescue" "gddrescue" "nala" "Data recovery from damaged drives" || log WARN "ddrescue installation failed, continuing..."
                ;;

            "foremost")
                install_package_secure "Foremost" "foremost" "nala" "File recovery tool" || log WARN "Foremost installation failed, continuing..."
                ;;

            "extundelete")
                install_package_secure "Extundelete" "extundelete" "nala" "Ext3/4 file recovery" || log WARN "Extundelete installation failed, continuing..."
                ;;

            "scalpel")
                install_package_secure "Scalpel" "scalpel" "nala" "Fast file carving" || log WARN "Scalpel installation failed, continuing..."
                ;;

            "safecopy")
                install_package_secure "Safecopy" "safecopy" "nala" "Safe data recovery" || log WARN "Safecopy installation failed, continuing..."
                ;;

            "brasero")
                install_package_secure "Brasero" "brasero" "nala" "CD/DVD burning for GNOME" || log WARN "Brasero installation failed, continuing..."
                ;;

            "k3b")
                install_package_secure "K3B" "k3b" "nala" "CD/DVD burning for KDE" || log WARN "K3B installation failed, continuing..."
                ;;

            "xfburn")
                install_package_secure "Xfburn" "xfburn" "nala" "Simple CD/DVD burner" || log WARN "Xfburn installation failed, continuing..."
                ;;

            "cdrdao")
                install_package_secure "cdrdao" "cdrdao" "nala" "CD recording CLI tool" || log WARN "cdrdao installation failed, continuing..."
                ;;

            "dvd+rw-tools")
                install_package_secure "dvd+rw-tools" "dvd+rw-tools" "nala" "DVD burning tools" || log WARN "dvd+rw-tools installation failed, continuing..."
                ;;

            "gnomebaker")
                install_package_secure "GnomeBaker" "gnomebaker" "nala" "CD/DVD burning app" || log WARN "GnomeBaker installation failed, continuing..."
                ;;

            "smartmontools")
                install_package_secure "smartmontools" "smartmontools" "nala" "S.M.A.R.T. monitoring" || log WARN "smartmontools installation failed, continuing..."
                ;;

            "hdparm")
                install_package_secure "hdparm" "hdparm" "nala" "Hard disk tuning" || log WARN "hdparm installation failed, continuing..."
                ;;

            "nvme-cli")
                install_package_secure "nvme-cli" "nvme-cli" "nala" "NVMe management" || log WARN "nvme-cli installation failed, continuing..."
                ;;

            "disks-analyzer")
                install_package_secure "Baobab" "baobab" "nala" "Disk usage analyzer" || log WARN "Baobab installation failed, continuing..."
                ;;

            "filelight")
                install_package_secure "Filelight" "filelight" "nala" "Disk usage (KDE)" || log WARN "Filelight installation failed, continuing..."
                ;;

            "ncdu")
                install_package_secure "ncdu" "ncdu" "nala" "NCurses disk usage" || log WARN "ncdu installation failed, continuing..."
                ;;

            "duf")
                log INFO "Installing duf..."
                local duf_url=$(curl -s https://api.github.com/repos/muesli/duf/releases/latest | grep "browser_download_url.*linux_amd64.deb" | cut -d '"' -f 4)
                local duf_deb="/tmp/duf.deb"

                wget -O "$duf_deb" "$duf_url" 2>&1 | \
                    zenity --progress --title="Downloading duf" --text="Downloading..." --pulsate --auto-close

                if [ -f "$duf_deb" ]; then
                    install_package_secure "duf" "$duf_deb" "nala" "Modern disk usage utility" || log WARN "duf installation failed, continuing..."
                    rm -f "$duf_deb"
                else
                    log ERROR "Failed to download duf"
                fi
                ;;

            "gdu")
                install_package_secure "gdu" "gdu" "snap" "Fast disk usage analyzer" || log WARN "gdu installation failed, continuing..."
                ;;

            "fdupes")
                install_package_secure "fdupes" "fdupes" "nala" "Find duplicate files" || log WARN "fdupes installation failed, continuing..."
                ;;

            "rmlint")
                install_package_secure "rmlint" "rmlint" "nala" "Find duplicates and lint" || log WARN "rmlint installation failed, continuing..."
                ;;

            "czkawka")
                log INFO "Installing Czkawka..."
                local czkawka_url=$(curl -s https://api.github.com/repos/qarmin/czkawka/releases/latest | grep "browser_download_url.*ubuntu.*gui.deb" | cut -d '"' -f 4 | head -n1)
                local czkawka_deb="/tmp/czkawka.deb"

                wget -O "$czkawka_deb" "$czkawka_url" 2>&1 | \
                    zenity --progress --title="Downloading Czkawka" --text="Downloading..." --pulsate --auto-close

                if [ -f "$czkawka_deb" ]; then
                    install_package_secure "Czkawka" "$czkawka_deb" "nala" "Multi-functional cleaner" || log WARN "Czkawka installation failed, continuing..."
                    rm -f "$czkawka_deb"
                else
                    log ERROR "Failed to download Czkawka"
                fi
                ;;

            "bleachbit")
                install_package_secure "BleachBit" "bleachbit" "nala" "System cleaner" || log WARN "BleachBit installation failed, continuing..."
                ;;

            "stacer")
                log INFO "Installing Stacer..."
                local stacer_url=$(curl -s https://api.github.com/repos/oguzhaninan/Stacer/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local stacer_deb="/tmp/stacer.deb"

                wget -O "$stacer_deb" "$stacer_url" 2>&1 | \
                    zenity --progress --title="Downloading Stacer" --text="Downloading..." --pulsate --auto-close

                if [ -f "$stacer_deb" ]; then
                    install_package_secure "Stacer" "$stacer_deb" "nala" "System optimizer" || log WARN "Stacer installation failed, continuing..."
                    rm -f "$stacer_deb"
                else
                    log ERROR "Failed to download Stacer"
                fi
                ;;

            "syncthing")
                install_package_secure "Syncthing" "syncthing" "snap" "File synchronization" || log WARN "Syncthing installation failed, continuing..."
                ;;

            "rsync")
                install_package_secure "rsync" "rsync" "nala" "File transfer tool" || log WARN "rsync installation failed, continuing..."
                ;;

            "rclone")
                install_package_secure "Rclone" "rclone" "nala" "Cloud storage sync" || log WARN "Rclone installation failed, continuing..."
                ;;

            "timeshift")
                install_package_secure "Timeshift" "timeshift" "nala" "System restore utility" || log WARN "Timeshift installation failed, continuing..."
                ;;

            "backintime")
                install_package_secure "Back In Time" "backintime-qt" "nala" "Backup tool" || log WARN "Back In Time installation failed, continuing..."
                ;;

            "deja-dup")
                install_package_secure "Déjà Dup" "deja-dup" "nala" "Simple backup tool" || log WARN "Déjà Dup installation failed, continuing..."
                ;;

            "borg")
                install_package_secure "BorgBackup" "borgbackup" "nala" "Deduplicating backup" || log WARN "BorgBackup installation failed, continuing..."
                ;;

            "restic")
                install_package_secure "Restic" "restic" "nala" "Fast secure backup" || log WARN "Restic installation failed, continuing..."
                ;;

            "duplicity")
                install_package_secure "Duplicity" "duplicity" "nala" "Encrypted backup" || log WARN "Duplicity installation failed, continuing..."
                ;;

            "grsync")
                install_package_secure "Grsync" "grsync" "nala" "GUI for rsync" || log WARN "Grsync installation failed, continuing..."
                ;;

            "fsarchiver")
                install_package_secure "FSArchiver" "fsarchiver" "nala" "Filesystem archiver" || log WARN "FSArchiver installation failed, continuing..."
                ;;

            "partclone")
                install_package_secure "Partclone" "partclone" "nala" "Partition cloning" || log WARN "Partclone installation failed, continuing..."
                ;;

            "clonezilla")
                show_message "Info" "Clonezilla is a live CD/USB distribution.\n\nDownload from:\nhttps://clonezilla.org/downloads.php\n\nUse balenaEtcher or similar to create bootable media."
                xdg-open "https://clonezilla.org/downloads.php" 2>/dev/null &
                ;;

            "ddrescueview")
                install_package_secure "ddrescueview" "ddrescueview" "nala" "ddrescue log viewer" || log WARN "ddrescueview installation failed, continuing..."
                ;;

            "testdisk-gui")
                install_package_secure "QPhotoRec" "qphotorec" "nala" "PhotoRec GUI (included with TestDisk)" || log WARN "QPhotoRec installation failed, continuing..."
                ;;

            "mkusb")
                add_repository "mkusb" \
                    "" \
                    "deb http://ppa.launchpad.net/mkusb/ppa/ubuntu $(lsb_release -cs) main" \
                    "/etc/apt/sources.list.d/mkusb.list"
                install_package_secure "mkusb" "mkusb mkusb-nox usb-pack-efi" "nala" "Bootable USB creator" || log WARN "mkusb installation failed, continuing..."
                ;;

            "usb-creator-gtk")
                install_package_secure "USB Startup Disk Creator" "usb-creator-gtk" "nala" "Ubuntu USB creator" || log WARN "USB Startup Disk Creator installation failed, continuing..."
                ;;

            "fatrace")
                install_package_secure "fatrace" "fatrace" "nala" "File access tracer" || log WARN "fatrace installation failed, continuing..."
                ;;

            "iotop")
                install_package_secure "iotop" "iotop" "nala" "I/O monitor" || log WARN "iotop installation failed, continuing..."
                ;;

            "htop")
                install_package_secure "htop" "htop" "nala" "Process viewer" || log WARN "htop installation failed, continuing..."
                ;;

            "btop")
                install_package_secure "btop++" "btop" "snap" "Resource monitor" || log WARN "btop++ installation failed, continuing..."
                ;;

            "nmon")
                install_package_secure "nmon" "nmon" "nala" "Performance monitor" || log WARN "nmon installation failed, continuing..."
                ;;

            "sysstat")
                install_package_secure "sysstat" "sysstat" "nala" "Performance tools" || log WARN "sysstat installation failed, continuing..."
                ;;

            "lm-sensors")
                install_package_secure "lm-sensors" "lm-sensors" "nala" "Hardware monitoring" || log WARN "lm-sensors installation failed, continuing..."
                sudo sensors-detect --auto 2>&1 | \
                    zenity --progress --title="Detecting sensors" --text="Detecting hardware sensors..." --pulsate --auto-close
                ;;

            "psensor")
                install_package_secure "Psensor" "psensor" "nala" "Temperature monitor" || log WARN "Psensor installation failed, continuing..."
                ;;

            "hardinfo")
                install_package_secure "HardInfo" "hardinfo" "nala" "System information" || log WARN "HardInfo installation failed, continuing..."
                ;;

            "cpu-x")
                install_package_secure "CPU-X" "cpu-x" "flatpak" "System information tool" || log WARN "CPU-X installation failed, continuing..."
                ;;

            "inxi")
                install_package_secure "inxi" "inxi" "nala" "System info script" || log WARN "inxi installation failed, continuing..."
                ;;

            "neofetch")
                install_package_secure "Neofetch" "neofetch" "nala" "System info tool" || log WARN "Neofetch installation failed, continuing..."
                ;;

            "fastfetch")
                install_package_secure "Fastfetch" "fastfetch" "nala" "Fast system info" || log WARN "Fastfetch installation failed, continuing..."
                ;;

            "usbview")
                install_package_secure "USBView" "usbview" "nala" "USB device viewer" || log WARN "USBView installation failed, continuing..."
                ;;

            "lsusb")
                install_package_secure "usbutils" "usbutils" "nala" "USB utilities" || log WARN "usbutils installation failed, continuing..."
                ;;

            "usb-devices")
                install_package_secure "usbutils" "usbutils" "nala" "USB device info (included in usbutils)" || log WARN "usbutils installation failed, continuing..."
                ;;

            "ext4magic")
                install_package_secure "ext4magic" "ext4magic" "nala" "Ext4 file recovery" || log WARN "ext4magic installation failed, continuing..."
                ;;

            "recoverjpeg")
                install_package_secure "recoverjpeg" "recoverjpeg" "nala" "JPEG recovery" || log WARN "recoverjpeg installation failed, continuing..."
                ;;

            "magicrescue")
                install_package_secure "magicrescue" "magicrescue" "nala" "Magic bytes recovery" || log WARN "magicrescue installation failed, continuing..."
                ;;
        esac
    done

    show_message "Completed" "System tools installation completed!\n\nNote:\n- For Ventoy, check /tmp/ventoy-1.0.99\n- Some tools may require root privileges\n- Data recovery tools work best when used on unmounted drives"
}