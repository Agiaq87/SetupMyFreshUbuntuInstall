#!/bin/bash
### NALA INSTALLATION ###
install_nala() {
    if command -v nala &> /dev/null; then
        debug "Nala already installed"
        NALA_INSTALLED=1
        return 0
    fi

    log "Installing Nala package manager..."
    debug "Starting Nala installation"

    case $GUI_ENGINE in
        "zenity"|"yad")
            (
                echo "25"; sleep 1
                sudo apt update 2>&1 | tee -a "$LOG_FILE"
                echo "50"; sleep 1
                sudo apt install -y nala 2>&1 | tee -a "$LOG_FILE"
                echo "75"; sleep 1
                sudo nala fetch 2>&1 | tee -a "$LOG_FILE"
                echo "100"
            ) | show_progress "Installing Nala" "Installing Nala package manager..."
            ;;
        *)
            sudo apt update 2>&1 | tee -a "$LOG_FILE"
            sudo apt install -y nala 2>&1 | tee -a "$LOG_FILE"
            ;;
    esac

    if command -v nala &> /dev/null; then
        NALA_INSTALLED=1
        log "Nala installed successfully"
        debug "Nala installation completed"
        return 0
    else
        log "ERROR: Nala installation failed"
        debug "Nala installation failed"
        return 1
    fi
}

### PACKAGE INSTALLATION FUNCTIONS ###
### PACKAGE MANAGEMENT WITH GUI PRIVILEGES ###
# Enhanced package installation with GUI privilege handling
install_package_secure() {
    local package_name="$1"
    local package_cmd="$2"
    local package_manager="$3"
    local description="$4"

    debug "Installing package: $package_name via $package_manager"

    if ask_yesno "Installation Confirmation" "Do you want to install $package_name?\n\n$description"; then
        log "Starting installation of $package_name"

        # Ensure we have admin privileges
        maintain_sudo

        # Show progress with error handling
        case $GUI_ENGINE in
            "zenity"|"yad")
                (
                    echo "10" ; sleep 1
                    echo "# Preparing installation..."

                    case $package_manager in
                        "apt"|"nala")
                            if [ $NALA_INSTALLED -eq 1 ] && [ "$package_manager" != "apt" ]; then
                                echo "50"
                                echo "# Installing with Nala..."
                                if ! sudo nala install -y $package_cmd 2>&1 | tee -a "$LOG_FILE"; then
                                    echo "ERROR" ; exit 1
                                fi
                            else
                                echo "50"
                                echo "# Installing with APT..."
                                if ! sudo apt install -y $package_cmd 2>&1 | tee -a "$LOG_FILE"; then
                                    echo "ERROR" ; exit 1
                                fi
                            fi
                            ;;
                        "snap")
                            echo "50"
                            echo "# Installing with Snap..."
                            if ! sudo snap install $package_cmd 2>&1 | tee -a "$LOG_FILE"; then
                                echo "ERROR" ; exit 1
                            fi
                            ;;
                        "flatpak")
                            echo "50"
                            echo "# Installing with Flatpak..."
                            if ! flatpak install flathub $package_cmd -y 2>&1 | tee -a "$LOG_FILE"; then
                                echo "ERROR" ; exit 1
                            fi
                            ;;
                    esac
                    echo "100"
                    echo "# Installation completed"
                ) | case $GUI_ENGINE in
                    "zenity")
                        zenity --progress --title="Installing $package_name" \
                            --text="Preparing..." --percentage=0 --auto-close \
                            --width=400
                        ;;
                    "yad")
                        yad --progress --title="Installing $package_name" \
                            --text="Preparing..." --percentage=0 --auto-close \
                            --center --width=400
                        ;;
                esac

                # Check if installation succeeded
                if [ $? -ne 0 ]; then
                    error_exit "Installation of $package_name failed. Check log for details."
                fi
                ;;
            *)
                case $package_manager in
                    "apt"|"nala")
                        if [ $NALA_INSTALLED -eq 1 ] && [ "$package_manager" != "apt" ]; then
                            sudo nala install -y $package_cmd 2>&1 | tee -a "$LOG_FILE"
                        else
                            sudo apt install -y $package_cmd 2>&1 | tee -a "$LOG_FILE"
                        fi
                        ;;
                    "snap")
                        sudo snap install $package_cmd 2>&1 | tee -a "$LOG_FILE"
                        ;;
                    "flatpak")
                        flatpak install flathub $package_cmd -y 2>&1 | tee -a "$LOG_FILE"
                        ;;
                esac

                if [ $? -ne 0 ]; then
                    error_exit "Installation of $package_name failed. Check log for details."
                fi
                ;;
        esac

        log "$package_name installed successfully"
        show_notification "Installation completed" "$package_name installed!"
        return 0
    else
        log "$package_name installation cancelled"
        return 1
    fi
}

# Repository management with GUI
add_repository() {
    local repo_name="$1"
    local key_url="$2"
    local repo_url="$3"
    local list_file="$4"

    debug "Adding repository: $repo_name"

    if [ -f "$list_file" ]; then
        debug "Repository $repo_name already exists"
        return 0
    fi

    show_message "Repository Setup" "Adding $repo_name repository..."

    case $GUI_ENGINE in
        "zenity"|"yad")
            (
                echo "25"
                echo "# Downloading repository key..."
                if ! wget -q -O - "$key_url" | sudo apt-key add - 2>&1 | tee -a "$LOG_FILE"; then
                    exit 1
                fi

                echo "75"
                echo "# Adding repository..."
                if ! echo "$repo_url" | sudo tee "$list_file" >> "$LOG_FILE"; then
                    exit 1
                fi

                echo "90"
                echo "# Updating package list..."
                if ! sudo apt update 2>&1 | tee -a "$LOG_FILE"; then
                    exit 1
                fi

                echo "100"
                echo "# Repository added successfully"
            ) | case $GUI_ENGINE in
                "zenity")
                    zenity --progress --title="Adding $repo_name Repository" \
                        --text="Preparing..." --percentage=0 --auto-close
                    ;;
                "yad")
                    yad --progress --title="Adding $repo_name Repository" \
                        --text="Preparing..." --percentage=0 --auto-close --center
                    ;;
            esac
            ;;
        *)
            wget -q -O - "$key_url" | sudo apt-key add - 2>&1 | tee -a "$LOG_FILE"
            echo "$repo_url" | sudo tee "$list_file" >> "$LOG_FILE"
            sudo apt update 2>&1 | tee -a "$LOG_FILE"
            ;;
    esac

    if [ $? -ne 0 ]; then
        error_exit "Failed to add $repo_name repository"
    fi

    log "$repo_name repository added successfully"
}