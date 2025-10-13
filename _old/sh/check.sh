#!/bin/bash
check_sudo() {
    debug "Checking sudo configuration"

    # Check if user is in sudo group
    if ! groups | grep -q sudo; then
        error_exit "User $USER is not in the sudo group. Please add user to sudo group first."
    fi

    debug "User is in sudo group"
}

# Function to keep sudo session alive during long operations
maintain_sudo() {
    debug "Maintaining sudo session"

    # Reset sudo timestamp
    sudo -v

    # Start background process to keep sudo alive
    (
        while true; do
            sleep 240  # Every 4 minutes
            sudo -v
        done
    ) &

    local sudo_keeper_pid=$!
    debug "Sudo keeper process started: $sudo_keeper_pid"

    # Store PID to kill it later if needed
    echo $sudo_keeper_pid > /tmp/ubuntu_setup_sudo_keeper.pid
}

check_internet() {
    debug "Checking internet connectivity..."
    if ! ping -c 1 google.com &> /dev/null; then
        error_exit "Internet connection not available"
    fi
    debug "Internet connectivity verified"
}

check_ubuntu() {
    debug "Checking Ubuntu version..."
    if ! command -v lsb_release &> /dev/null; then
        log "WARNING: lsb_release not found, skipping Ubuntu version check"
        return
    fi

    local ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "unknown")
    log "Detected Ubuntu version: $ubuntu_version"
    debug "Ubuntu version check completed"
}

check_flatpak() {
    debug "Enable flatpak"

    log "Installing Flatpak package manager..."
    debug "Starting Flatpak installation"

    case $GUI_ENGINE in
        "zenity"|"yad")
            (
                echo "20"; sleep 1
                sudo apt update 2>&1 | tee -a "$LOG_FILE"
                echo "40"; sleep 1
                sudo apt install -y flatpak 2>&1 | tee -a "$LOG_FILE"
                echo "60"; sleep 1
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                echo "80"; sleep 1
                sudo nala install -y gnome-software-plugin-flatpak
                echo "100"
            ) | show_progress "Installing Flatpak" "Installing Flatpak package manager..."
            ;;
        *)
            sudo apt update 2>&1 | tee -a "$LOG_FILE"
            sudo nala install -y flatpak && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && sudo nala install -y gnome-software-plugin-flatpak 2>&1 | tee -a "$LOG_FILE"
            ;;
    esac

    if command -v nala &> /dev/null; then
        NALA_INSTALLED=1
        log "Flatpak installed successfully"
        debug "Flatpak installation completed"
        return 0
    else
        log "ERROR: Flatpak installation failed"
        debug "Flatpak installation failed"
        return 1
    fi
}

detect_gui_engine() {
    debug "Detecting GUI engine with preference: $1"

    # Force mode if specified by user
    if [ "$1" = "tui" ]; then
        GUI_ENGINE="whiptail"
        debug "Forced TUI mode"
        return
    elif [ "$1" = "gui" ]; then
        # Force GUI, fail if not available
        if [ -z "$DISPLAY" ]; then
            error_exit "GUI requested but DISPLAY not available"
        fi
    fi

    # Auto-detect
    if [ -n "$DISPLAY" ]; then
        if command -v zenity &> /dev/null; then
            GUI_ENGINE="zenity"
            log "Using Zenity for graphical interface"
        elif command -v yad &> /dev/null; then
            GUI_ENGINE="yad"
            log "Using YAD for graphical interface"
        else
            GUI_ENGINE="whiptail"
            log "GUI not available, using Whiptail (TUI)"
        fi
    else
        GUI_ENGINE="whiptail"
        log "DISPLAY not available, using Whiptail (TUI)"
    fi

    debug "Selected GUI engine: $GUI_ENGINE"
}

request_admin_privileges() {
    debug "Requesting admin privileges"

    # Check if we're already root (bad)
    if [[ $EUID -eq 0 ]]; then
        error_exit "Don't run this script as root. Run as regular user instead."
    fi

    # Test if user has sudo privileges
    if ! sudo -n true 2>/dev/null; then
        debug "No cached sudo credentials, requesting password"

        case $GUI_ENGINE in
            "zenity")
                # Use zenity for password prompt
                local password
                password=$(zenity --password --title="Administrator Password Required" \
                    --text="Enter your password to continue with system modifications:")

                if [ $? -ne 0 ] || [ -z "$password" ]; then
                    error_exit "Administrator privileges required to continue"
                fi

                # Test the password
                if ! echo "$password" | sudo -S true 2>/dev/null; then
                    error_exit "Invalid password or insufficient privileges"
                fi

                # Keep sudo session alive
                echo "$password" | sudo -S true
                ;;
            "yad")
                # Use yad for password prompt
                local password
                password=$(yad --entry --hide-text --title="Administrator Password" \
                    --text="Enter your password for system modifications:" --center)

                if [ $? -ne 0 ] || [ -z "$password" ]; then
                    error_exit "Administrator privileges required to continue"
                fi

                # Test the password
                if ! echo "$password" | sudo -S true 2>/dev/null; then
                    error_exit "Invalid password or insufficient privileges"
                fi

                # Keep sudo session alive
                echo "$password" | sudo -S true
                ;;
            *)
                # For TUI, use standard sudo prompt
                show_message "Admin Required" "This script requires administrator privileges.\nYou will be prompted for your password."
                if ! sudo true; then
                    error_exit "Administrator privileges required to continue"
                fi
                ;;
        esac
    else
        debug "Sudo credentials already cached"
    fi

    log "Administrator privileges granted"
}

check_cpu_vendor() {
    log "Check CPU vendor"
    debug "Entering check_cpu_vendor"

    vendor=$(lscpu | grep "Vendor ID" | awk '{print $3}')

    case "$vendor" in
        "GenuineIntel")
          return 0
          ;;
        "AuthenticAMD")
          return 1
          ;;
        *)
          return 2
          ;;
esac

}

startup_checks() {
    # Initialize log file
    touch "$LOG_FILE" || error_exit "Cannot create log file: $LOG_FILE"
    debug "Log file initialized: $LOG_FILE"

    log "=== STARTING UBUNTU SETUP SCRIPT v$SCRIPT_VERSION ==="
    log "User: $USER"
    log "Debug mode: $DEBUG_MODE"

    check_sudo
    check_internet
    check_ubuntu
    check_flatpak

    # Detect and configure interface
    detect_gui_engine "$USE_GUI"

    # Request admin privileges early
    request_admin_privileges

    # Install Nala immediately if not present
    if ! command -v nala &> /dev/null; then
        log "Nala not found, installing now..."
        install_nala
    else
        NALA_INSTALLED=1
        debug "Nala already available"
    fi

    # Welcome message
    show_message "Welcome!" "SetupMyFreshUbuntuInstall v$SCRIPT_VERSION\n\nInterface: $GUI_ENGINE\nNala installed: $([ $NALA_INSTALLED -eq 1 ] && echo 'Yes' || echo 'No')\n\n✅ Automates software installation\n✅ Supports GUI and TUI\n✅ Complete logging\n✅ Secure privilege management\n\nLog: $LOG_FILE"

    log "Interface activated: $GUI_ENGINE"
    log "Nala status: $([ $NALA_INSTALLED -eq 1 ] && echo 'installed' || echo 'not installed')"
    debug "Startup checks completed successfully"
}