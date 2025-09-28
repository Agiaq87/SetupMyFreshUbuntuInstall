#!/bin/bash

# SetupMyFreshUbuntuInstall - Hybrid GUI/TUI Version
# Supports both graphical (Zenity/YAD) and text-based (Whiptail) interfaces

### GLOBAL VARIABLES ###
SCRIPT_VERSION="1.2.0"
LOG_FILE="/tmp/ubuntu_setup_$(date +%Y%m%d_%H%M%S).log"
USE_GUI="auto"  # auto, gui, tui
GUI_ENGINE=""   # zenity, yad, whiptail
DEBUG_MODE=0    # 0=off, 1=on
NALA_INSTALLED=0

### DEBUG AND LOGGING FUNCTIONS ###
debug() {
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "[DEBUG $(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE" >&2
    fi
}

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
    debug "Logged: $message"
}

error_exit() {
    local error_msg="$1"
    log "ERROR: $error_msg"
    
    case $GUI_ENGINE in
        "zenity")
            zenity --error --text="ERROR: $error_msg" --width=400
            ;;
        "yad")
            yad --error --text="ERROR: $error_msg" --width=400 --center
            ;;
        *)
            whiptail --title "ERROR" --msgbox "$error_msg" 8 60
            ;;
    esac
    exit 1
}

### PRIVILEGE MANAGEMENT ###
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

### GUI ENGINE DETECTION ###
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

### UNIVERSAL INTERFACE FUNCTIONS ###

# Information messages
show_message() {
    local title="$1"
    local message="$2"
    local width="${3:-400}"
    
    debug "Showing message: $title"
    
    case $GUI_ENGINE in
        "zenity")
            zenity --info --title="$title" --text="$message" --width="$width"
            ;;
        "yad")
            yad --info --title="$title" --text="$message" --width="$width" --center
            ;;
        *)
            whiptail --title "$title" --msgbox "$message" 12 70
            ;;
    esac
}

# Yes/No questions
ask_yesno() {
    local title="$1"
    local question="$2"
    local width="${3:-400}"
    
    debug "Asking yes/no: $title"
    
    case $GUI_ENGINE in
        "zenity")
            zenity --question --title="$title" --text="$question" --width="$width"
            ;;
        "yad")
            yad --question --title="$title" --text="$question" --width="$width" --center
            ;;
        *)
            whiptail --title "$title" --yesno "$question" 10 60
            ;;
    esac
}

# Progress bar
show_progress() {
    local title="$1"
    local text="$2"
    
    debug "Showing progress bar: $title"
    
    case $GUI_ENGINE in
        "zenity")
            zenity --progress --title="$title" --text="$text" --percentage=0 --auto-close
            ;;
        "yad")
            yad --progress --title="$title" --text="$text" --percentage=0 --auto-close --center
            ;;
        *)
            # For whiptail we use gauge
            whiptail --title "$title" --gauge "$text" 8 60 0
            ;;
    esac
}

# Show command output in GUI window
show_command_output() {
    local title="$1"
    local command="$2"
    local temp_file="/tmp/command_output_$"
    
    debug "Showing command output: $command"
    
    # Execute command and capture output
    if eval "$command" > "$temp_file" 2>&1; then
        local exit_code=0
    else
        local exit_code=$?
    fi
    
    local output=$(cat "$temp_file")
    rm -f "$temp_file"
    
    case $GUI_ENGINE in
        "zenity")
            if [ $exit_code -eq 0 ]; then
                zenity --info --title="$title" --text="$output" --width=600 --height=400
            else
                zenity --error --title="$title - Error" --text="Command failed with exit code $exit_code:\n\n$output" --width=600 --height=400
            fi
            ;;
        "yad")
            if [ $exit_code -eq 0 ]; then
                echo "$output" | yad --text-info --title="$title" --width=700 --height=500 --center --button="OK:0"
            else
                echo "$output" | yad --text-info --title="$title - Error" --width=700 --height=500 --center --button="OK:0"
            fi
            ;;
        *)
            # For TUI, use whiptail scrollbox
            if [ $exit_code -eq 0 ]; then
                whiptail --title "$title" --scrolltext --msgbox "$output" 20 80
            else
                whiptail --title "$title - Error" --scrolltext --msgbox "Command failed with exit code $exit_code:\n\n$output" 20 80
            fi
            ;;
    esac
    
    return $exit_code
}

# Show live command output with progress
show_live_command() {
    local title="$1"
    local command="$2"
    local temp_file="/tmp/live_command_$"
    
    debug "Showing live command: $command"
    
    case $GUI_ENGINE in
        "zenity")
            # Use zenity progress with pulsate for live output
            (
                eval "$command" 2>&1 | tee "$temp_file"
                echo "100"
            ) | zenity --progress --title="$title" --text="Executing command..." --pulsate --auto-close --width=400
            
            local exit_code=${PIPESTATUS[0]}
            
            # Show final output
            if [ -f "$temp_file" ]; then
                local output=$(cat "$temp_file")
                if [ $exit_code -eq 0 ]; then
                    zenity --info --title="$title - Completed" --text="$output" --width=600 --height=400
                else
                    zenity --error --title="$title - Failed" --text="Command failed:\n\n$output" --width=600 --height=400
                fi
                rm -f "$temp_file"
            fi
            ;;
        "yad")
            # Use yad with progress and final text output
            (
                eval "$command" 2>&1 | tee "$temp_file"
                echo "100"
            ) | yad --progress --title="$title" --text="Executing command..." --pulsate --auto-close --center --width=400
            
            local exit_code=${PIPESTATUS[0]}
            
            # Show final output in text window
            if [ -f "$temp_file" ]; then
                if [ $exit_code -eq 0 ]; then
                    cat "$temp_file" | yad --text-info --title="$title - Completed" --width=700 --height=500 --center --button="OK:0"
                else
                    cat "$temp_file" | yad --text-info --title="$title - Failed" --width=700 --height=500 --center --button="OK:0"
                fi
                rm -f "$temp_file"
            fi
            ;;
        *)
            # For TUI, just run and show final output
            eval "$command" 2>&1 | tee "$temp_file"
            local exit_code=${PIPESTATUS[0]}
            
            if [ -f "$temp_file" ]; then
                local output=$(cat "$temp_file")
                if [ $exit_code -eq 0 ]; then
                    whiptail --title "$title - Completed" --scrolltext --msgbox "$output" 20 80
                else
                    whiptail --title "$title - Failed" --scrolltext --msgbox "Command failed:\n\n$output" 20 80
                fi
                rm -f "$temp_file"
            fi
            ;;
    esac
    
    return $exit_code
}

# Terminal window launcher for complex commands
show_terminal_command() {
    local title="$1"
    local command="$2"
    local wait_for_key="${3:-true}"
    
    debug "Showing terminal command: $command"
    
    case $GUI_ENGINE in
        "zenity"|"yad")
            # Create a wrapper script that shows the command output
            local wrapper_script="/tmp/terminal_wrapper_$.sh"
            cat > "$wrapper_script" << EOF
#!/bin/bash
echo "=== $title ==="
echo "Command: $command"
echo "=================="
echo
$command
exit_code=\$?
echo
echo "=================="
if [ \$exit_code -eq 0 ]; then
    echo "Command completed successfully (exit code: \$exit_code)"
else
    echo "Command failed with exit code: \$exit_code"
fi
if [ "$wait_for_key" = "true" ]; then
    echo
    read -p "Press Enter to continue..." dummy
fi
EOF
            chmod +x "$wrapper_script"
            
            # Launch in terminal
            if command -v gnome-terminal &> /dev/null; then
                gnome-terminal --title="$title" -- bash "$wrapper_script"
            elif command -v xterm &> /dev/null; then
                xterm -title "$title" -e bash "$wrapper_script"
            elif command -v konsole &> /dev/null; then
                konsole --title "$title" -e bash "$wrapper_script"
            else
                # Fallback to text info dialog
                show_command_output "$title" "$command"
            fi
            
            # Clean up wrapper script after a delay
            (sleep 10 && rm -f "$wrapper_script") &
            ;;
        *)
            # For TUI, just execute and show output
            show_command_output "$title" "$command"
            ;;
    esac
}

# Notifications
show_notification() {
    local title="$1"
    local message="$2"
    
    debug "Showing notification: $title - $message"
    
    case $GUI_ENGINE in
        "zenity")
            zenity --notification --text="$title: $message"
            ;;
        "yad")
            yad --notification --text="$title: $message"
            ;;
        *)
            # For TUI show only in log
            log "NOTIFICATION: $title - $message"
            ;;
    esac
}

# Universal checklist menu
show_checklist() {
    local title="$1"
    local text="$2"
    shift 2
    local items=("$@")
    
    debug "Showing checklist: $title with ${#items[@]} items"
    
    case $GUI_ENGINE in
        "zenity")
            local zenity_args=()
            zenity_args+=(--list --checklist --title="$title" --text="$text")
            zenity_args+=(--column="Select" --column="Software" --column="Description")
            zenity_args+=(--width=600 --height=400 --separator=" ")
            
            # Build list for Zenity
            for item in "${items[@]}"; do
                IFS='|' read -ra PARTS <<< "$item"
                zenity_args+=(FALSE "${PARTS[0]}" "${PARTS[1]}")
            done
            
            zenity "${zenity_args[@]}"
            ;;
        "yad")
            local yad_args=()
            yad_args+=(--list --checklist --title="$title" --text="$text")
            yad_args+=(--column="Sel" --column="Software" --column="Description")
            yad_args+=(--width=600 --height=400 --center --separator=" ")
            
            # Build list for YAD
            for item in "${items[@]}"; do
                IFS='|' read -ra PARTS <<< "$item"
                yad_args+=(FALSE "${PARTS[0]}" "${PARTS[1]}")
            done
            
            yad "${yad_args[@]}"
            ;;
        *)
            # Whiptail - different format
            local whiptail_args=()
            whiptail_args+=(--title "$title" --checklist "$text" 20 78 10)
            
            for item in "${items[@]}"; do
                IFS='|' read -ra PARTS <<< "$item"
                whiptail_args+=("${PARTS[0]}" "${PARTS[1]}" OFF)
            done
            
            whiptail "${whiptail_args[@]}" 3>&1 1>&2 2>&3
            ;;
    esac
}

# Main menu
show_main_menu() {
    local title="Ubuntu Setup v$SCRIPT_VERSION"
    
    debug "Showing main menu"
    
    case $GUI_ENGINE in
        "zenity")
            zenity --list --radiolist --title="$title" \
                --text="Choose what you want to do:" \
                --column="Sel" --column="ID" --column="Action" \
                --width=500 --height=400 \
                TRUE "1" "Update system" \
                FALSE "2" "Development tools" \
                FALSE "3" "Virtualization" \
                FALSE "4" "Browsers" \
                FALSE "5" "Multimedia" \
                FALSE "6" "Gaming" \
                FALSE "7" "System" \
                FALSE "0" "Exit"
            ;;
        "yad")
            yad --list --radiolist --title="$title" \
                --text="Choose what you want to do:" \
                --column="Sel" --column="ID" --column="Action" \
                --width=500 --height=400 --center \
                TRUE "1" "Update system" \
                FALSE "2" "Development tools" \
                FALSE "3" "Virtualization" \
                FALSE "4" "Browsers" \
                FALSE "5" "Multimedia" \
                FALSE "6" "Gaming" \
                FALSE "7" "System" \
                FALSE "0" "Exit"
            ;;
        *)
            whiptail --title "$title" --menu "Choose an option:" 16 60 8 \
                "1" "Update system" \
                "2" "Development tools" \
                "3" "Virtualization" \
                "4" "Browsers" \
                "5" "Multimedia" \
                "6" "Gaming" \
                "7" "System" \
                "0" "Exit" \
                3>&1 1>&2 2>&3
            ;;
    esac
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

### BROWSER MENU ###
browsers_menu() {
    log "Opening browser menu..."
    debug "Entering browsers_menu function"
    
    # Define available software (format: id|name|description)
    local browser_items=(
        "chrome|Google Chrome|Google browser with account synchronization"
        "firefox|Firefox|Mozilla open source browser"
        "edge|Microsoft Edge|Microsoft browser based on Chromium"
        "opera|Opera|Browser with integrated VPN and workspace"
        "vivaldi|Vivaldi|Customizable browser for power users"
        "brave|Brave Browser|Privacy and security focused browser"
        "tor|Tor Browser|Anonymous browser for private navigation"
        "chromium|Chromium|Open source version of Chrome"
    )
    
    # Show checklist
    local choices
    choices=$(show_checklist "Browser Selection" "Choose browsers to install:" "${browser_items[@]}")
    
    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log "Browser selection cancelled"
        debug "Browser menu cancelled by user"
        return
    fi
    
    log "Selected browsers: $choices"
    debug "Processing browser choices: $choices"
    
    # Process each choice
    for choice in $choices; do
        choice=$(echo "$choice" | tr -d '"')  # Remove quotes
        debug "Processing browser choice: $choice"
        case $choice in
            "chrome")
                # Add Chrome repository if not present
                add_repository "Google Chrome" \
                    "https://dl.google.com/linux/linux_signing_key.pub" \
                    "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
                    "/etc/apt/sources.list.d/google-chrome.list"
                install_package_secure "Google Chrome" "google-chrome-stable" "nala" "Complete Google browser with extensions and sync"
                ;;
            "firefox")
                install_package_secure "Firefox" "firefox" "snap" "Latest version Mozilla browser"
                ;;
            "edge")
                install_package_secure "Microsoft Edge" "com.microsoft.Edge" "flatpak" "Microsoft browser for Linux"
                ;;
            "opera")
                install_package_secure "Opera" "opera" "snap" "Browser with integrated VPN and workspace"
                ;;
            "vivaldi")
                install_package_secure "Vivaldi" "vivaldi" "snap" "Highly customizable browser"
                ;;
            "brave")
                # Add Brave repository if not present
                add_repository "Brave Browser" \
                    "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
                    "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                    "/etc/apt/sources.list.d/brave-browser-release.list"
                install_package_secure "Brave Browser" "brave-browser" "nala" "Privacy and security focused browser"
                ;;
            "tor")
                install_package_secure "Tor Browser" "com.github.micahflee.torbrowser-launcher" "flatpak" "Browser for anonymous navigation"
                ;;
            "chromium")
                install_package_secure "Chromium" "chromium" "snap" "Open source version of Chrome"
                ;;
        esac
    done
    
    show_message "Completed" "Browser installation completed!\n\nCheck log for details: $LOG_FILE"
    debug "Browser menu completed"
}

### ADDITIONAL FUNCTIONS ###

update_system() {
    log "Starting system update..."
    debug "Entering update_system function"
    
    if ask_yesno "System Update" "Update the system? This may take several minutes."; then
        case $GUI_ENGINE in
            "zenity"|"yad")
                (
                    echo "20" ; sudo apt update 2>&1 | tee -a "$LOG_FILE"
                    echo "60" ; sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"
                    echo "80" ; sudo snap refresh 2>&1 | tee -a "$LOG_FILE"
                    echo "100" ; sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ) | show_progress "System Update" "Updating system in progress..."
                ;;
            *)
                sudo apt update 2>&1 | tee -a "$LOG_FILE"
                sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE" 
                sudo snap refresh 2>&1 | tee -a "$LOG_FILE"
                sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac
        
        show_message "Completed" "System updated successfully!"
        log "System update completed"
        debug "System update finished successfully"
    else
        debug "System update cancelled by user"
    fi
}

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

jq() {
    log "Check jq framework"
    debug "Check jq"
    if ! command -v jq >/dev/null 2>&1; then
        debug "jq not found, install it..."
        sudo apt update && sudo apt install -y jq
    fi
}

jetbrains_private() {
    debug "Cleaning...."
    sudo rm -rf /opt/jetbrains-toolbox
    sudo rm -f /usr/share/applications/jetbrains-toolbox.desktop
    rm -f jetbrains-toolbox.tar.gz
    rm -rf jetbrains-toolbox-*

    debug "Get last version..."
    JETBRAINS_JSON=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release")
    JETBRAINS_URL=$(debug "$JETBRAINS_JSON" | jq -r '.TBA[0].downloads.linux.link')

    if [[ -z "$JETBRAINS_URL" || "$JETBRAINS_URL" == "null" ]]; then
        debug "Cannot download app from url"
        return 1
    fi

    debug "Download from: $JETBRAINS_URL"
    wget -O jetbrains-toolbox.tar.gz "$JETBRAINS_URL"
    tar -xzf jetbrains-toolbox.tar.gz

    JETBRAINS_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -n 1)

    if [ -n "$JETBRAINS_DIR" ]; then
        debug "Installation..."
        sudo mv "$JETBRAINS_DIR" /opt/jetbrains-toolbox

        # binario vero: /opt/jetbrains-toolbox/bin/jetbrains-toolbox
        sudo chmod +x /opt/jetbrains-toolbox/bin/jetbrains-toolbox

        debug "🖥️ Creazione collegamento desktop..."
        cat << 'DESKTOP_EOF' | sudo tee /usr/share/applications/jetbrains-toolbox.desktop > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Icon=applications-development
Exec=/opt/jetbrains-toolbox/bin/jetbrains-toolbox
Comment=JetBrains IDEs manager
Categories=Development;
StartupWMClass=jetbrains-toolbox
StartupNotify=true
DESKTOP_EOF

        debug "JetBrains Toolbox installed"
    else
        debug "Cannot install JetBrains Toolboox"
        return 1
    fi
}

jetbrainsToolbox() {
    log "Start install jetbrains toolbox"
    debug "Check dependencies..."

    case $GUI_ENGINE in
        "zenity|yad")
            echo "10" ; jq 2>&1 | tee -a "$LOG_FILE"
            echo "70" ; jetbrains_private 2>&1 | tee -a "$LOG_FILE"
        ;;
        *)
            jq 2>&1 | tee -a "$LOG_FILE"
            jetbrains_private 2>&1 | tee -a "$LOG_FILE"
        ;;
    esac    
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

development_tools() {
    log "Opening development tools menu..."
    debug "Entering development_tools function"
    
    local dev_items=(
        "arduino|Arduino|IoT board development"
        "beekeeper-studio|Beekeper Studio|AN easy to use SQL editor and DB Manager for PSQL, MySQL & more"
        "bruno|Bruno|Opensource API Client for Exploring and Testing APIs"
        "dbeaver|DBeaver CE|Mysql inspector"
        "fiddler|Fiddler|Fiddler Everywhere for checking and debugging HTTP request"
        "flutter|Flutter|Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase"
        "git|Git|Distributed version control system"
        "go|Go|The Go programming language"
        "insomnia|Insomnia|The Collaborative API Design Tool"
        "vscode|Visual Studio Code|Microsoft code editor"
        "netbeans|Apache Netbeans IDE|Apache NetBeans IDE for Java, Jakarta EE and Web applications"
        "nodejs|Node.js|JavaScript runtime and npm package manager"
        "pgadmin|pgAdmin|Management tool for the PostgreSQL database"
        "python-dev|Python Dev Tools|Pip, venv and Python development tools"
        "postman|Postman|REST API testing tool"
        "restfox|Restfox|A lightweight REST / HTTP Client based on Insomnia and Postman"
        "jetbrains-toolbox|JetBrains Toolbox|Integrated app for install multiple IDE from JetBrains"
    )
    
    local choices
    choices=$(show_checklist "Development Tools" "Select tools to install:" "${dev_items[@]}")
    
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        debug "Development tools selection cancelled"
        return
    fi
    
    debug "Processing development tool choices: $choices"
    
    for choice in $choices; do
        choice=$(echo "$choice" | tr -d '"')
        debug "Processing dev tool: $choice"
        case $choice in
            "arduino")
                install_package_secure "Arduino" "arduino-*" "nala" "Iot development"
                ;;
            "beekeper-studio")
                install_package_secure "Beekeper Studio" "beekeeper-studio" "snap" "Psql, MySQL and other DB development"
                ;;
            "bruno")
                install_package_secure "Bruno" "bruno" "snap" "Opensource API Client for Exploring and Testing APIs"
                ;;
            "dbeaver")
                install_package_secure "DBeaver CE" "dbeaver-ce" "snap" "Mysql inspector"
                ;;
            "fiddler")
                echo "Not implemented yet"
                ;;
            "flutter")
                install_package_secure "Flutter" "flutter --classic" "snap" "Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase"
                flutter
                show_live_command "Flutter Configuration" "flutter config"
                show_live_command "Flutter Doctor" "flutter doctor -v"
                ;;
            "git")
                install_package_secure "Git" "git" "nala" "Version control system"
                ;;
            "go")
                install_package_secure "Go" "go --classic" "snap" "The Go programming language"
                install_package_secure "Gosec" "gosec" "snap" "Inspects source code for security problems by scanning the Go AST"
                show_live_command "Go version" "go version"
                ;;
            "insomnia")
                install_package_secure "Insomnia" "insomnia" "snap" "The Collaborative API Design Tool"
                ;;
            "vscode")
                add_repository "Visual Studio Code" \
                    "https://packages.microsoft.com/keys/microsoft.asc" \
                    "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                    "/etc/apt/sources.list.d/vscode.list"
                install_package_secure "Visual Studio Code" "code" "nala" "Advanced code editor"
                ;;
            "netbeans")
                install_package_secure "Netbeans" "netbeans --classic" "snap" "Apache NetBeans IDE for Java, Jakarta EE and Web applications"
                ;;
            "nodejs")
                install_package_secure "Node.js" "nodejs npm" "nala" "JavaScript runtime and package manager"
                ;;
            "pgAdmin")
                install_package_secure "pgAdmin" "pgadmin4" "snap" "Management tool for the PostgreSQL database"
                ;;
            "python-dev")
                install_package_secure "Python Dev Tools" "python3-pip python3-venv python3-dev build-essential" "nala" "Python development tools"
                ;;
            "postman")
                install_package_secure "Postman" "postman" "snap" "REST and GraphQL API testing"
                ;;
            "restfox")
                install_package_secure "Restfox" "restfox" "snap" "A lightweight REST / HTTP Client based on Insomnia and Postman"
                ;;
            "jetbrains-toolbox")
                jetbrainsToolbox
                ;;
        esac
    done
    
    show_message "Completed" "Development tools installation completed!"
    debug "Development tools menu completed"
}

system_menu() {
    log "Opening system tools menu..."
    debug "Entering system_menu function"
    
    local dev_items=(
        "arduino|Arduino|IoT board development"
        "beekeeper-studio|Beekeper Studio|AN easy to use SQL editor and DB Manager for PSQL, MySQL & more"
        "bruno|Bruno|Opensource API Client for Exploring and Testing APIs"
        "dbeaver|DBeaver CE|Mysql inspector"
        "fiddler|Fiddler|Fiddler Everywhere for checking and debugging HTTP request"
        "flutter|Flutter|Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase"
        "git|Git|Distributed version control system"
        "go|Go|The Go programming language"
        "insomnia|Insomnia|The Collaborative API Design Tool"
        "vscode|Visual Studio Code|Microsoft code editor"
        "netbeans|Apache Netbeans IDE|Apache NetBeans IDE for Java, Jakarta EE and Web applications"
        "nodejs|Node.js|JavaScript runtime and npm package manager"
        "pgadmin|pgAdmin|Management tool for the PostgreSQL database"
        "python-dev|Python Dev Tools|Pip, venv and Python development tools"
        "postman|Postman|REST API testing tool"
        "restfox|Restfox|A lightweight REST / HTTP Client based on Insomnia and Postman"
        "jetbrains-toolbox|JetBrains Toolbox|Integrated app for install multiple IDE from JetBrains"
    )
    
    local choices
    choices=$(show_checklist "System Tools" "Select tools to install:" "${dev_items[@]}")
    
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        debug "System tools selection cancelled"
        return
    fi
    
    debug "Processing System tool choices: $choices"
    
    for choice in $choices; do
        choice=$(echo "$choice" | tr -d '"')
        debug "Processing sys tool: $choice"
        case $choice in
            "arduino")
                install_package_secure "Arduino" "arduino-*" "nala" "Iot development"
                ;;
            "beekeper-studio")
                install_package_secure "Beekeper Studio" "beekeeper-studio" "snap" "Psql, MySQL and other DB development"
                ;;
            "bruno")
                install_package_secure "Bruno" "bruno" "snap" "Opensource API Client for Exploring and Testing APIs"
                ;;
            "dbeaver")
                install_package_secure "DBeaver CE" "dbeaver-ce" "snap" "Mysql inspector"
                ;;
            "fiddler")
                echo "Not implemented yet"
                ;;
            "flutter")
                install_package_secure "Flutter" "flutter --classic" "snap" "Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase"
                flutter
                show_live_command "Flutter Configuration" "flutter config"
                show_live_command "Flutter Doctor" "flutter doctor -v"
                ;;
            "git")
                install_package_secure "Git" "git" "nala" "Version control system"
                ;;
            "go")
                install_package_secure "Go" "go --classic" "snap" "The Go programming language"
                install_package_secure "Gosec" "gosec" "snap" "Inspects source code for security problems by scanning the Go AST"
                show_live_command "Go version" "go version"
                ;;
            "insomnia")
                install_package_secure "Insomnia" "insomnia" "snap" "The Collaborative API Design Tool"
                ;;
            "vscode")
                add_repository "Visual Studio Code" \
                    "https://packages.microsoft.com/keys/microsoft.asc" \
                    "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                    "/etc/apt/sources.list.d/vscode.list"
                install_package_secure "Visual Studio Code" "code" "nala" "Advanced code editor"
                ;;
            "netbeans")
                install_package_secure "Netbeans" "netbeans --classic" "snap" "Apache NetBeans IDE for Java, Jakarta EE and Web applications"
                ;;
            "nodejs")
                install_package_secure "Node.js" "nodejs npm" "nala" "JavaScript runtime and package manager"
                ;;
            "pgAdmin")
                install_package_secure "pgAdmin" "pgadmin4" "snap" "Management tool for the PostgreSQL database"
                ;;
            "python-dev")
                install_package_secure "Python Dev Tools" "python3-pip python3-venv python3-dev build-essential" "nala" "Python development tools"
                ;;
            "postman")
                install_package_secure "Postman" "postman" "snap" "REST and GraphQL API testing"
                ;;
            "restfox")
                install_package_secure "Restfox" "restfox" "snap" "A lightweight REST / HTTP Client based on Insomnia and Postman"
                ;;
            "jetbrains-toolbox")
                jetbrainsToolbox
                ;;
        esac
    done
    
    show_message "Completed" "Development tools installation completed!"
    debug "Development tools menu completed"
}

### MAIN MENU ###
main_menu() {
    debug "Entering main menu loop"
    
    while true; do
        local choice
        choice=$(show_main_menu)
        
        # Extract only the number for compatibility
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            log "Exiting main menu"
            debug "Main menu exit requested"
            break
        fi
        
        debug "Main menu choice selected: $choice"
        
        case $choice in
            "1")
                update_system
                ;;
            "2")
                development_tools
                ;;
            "3")
                show_message "TODO" "Docker installation - To be implemented"
                ;;
            "4")
                browsers_menu
                ;;
            "5")
                show_message "TODO" "Multimedia tools - To be implemented"
                ;;
            "6")
                show_message "TODO" "Gaming tools - To be implemented"
                ;;
            "7")
                system_menu
                ;;
            "0")
                if ask_yesno "Exit Confirmation" "Are you sure you want to exit?"; then
                    show_message "Goodbye!" "Setup completed!\n\nLog available at: $LOG_FILE"
                    log "Script terminated by user"
                    debug "Clean script termination"
                    exit 0
                fi
                ;;
            *)
                show_message "Error" "Invalid option: $choice"
                debug "Invalid menu choice: $choice"
                ;;
        esac
    done
}

### INITIAL CHECKS ###
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

### CLEANUP FUNCTIONS ###
cleanup() {
    log "Script interrupted - cleaning up..."
    debug "Cleanup function called"
    
    # Kill sudo keeper if running
    if [ -f /tmp/ubuntu_setup_sudo_keeper.pid ]; then
        local sudo_keeper_pid=$(cat /tmp/ubuntu_setup_sudo_keeper.pid)
        kill $sudo_keeper_pid 2>/dev/null || true
        rm -f /tmp/ubuntu_setup_sudo_keeper.pid
        debug "Sudo keeper process terminated"
    fi
    
    exit 130
}

### COMMAND LINE PARAMETERS ###
show_help() {
    cat << EOF
Ubuntu Fresh Install Setup Script v$SCRIPT_VERSION

Usage: $0 [OPTIONS]

OPTIONS:
  -g, --gui      Force graphical interface (requires X11/Wayland)
  -t, --tui      Force text-based interface 
  -d, --debug    Enable debug mode (verbose output)
  -h, --help     Show this help
  -v, --version  Show version

EXAMPLES:
  $0              # Auto-detect interface
  $0 --gui        # Force GUI (Zenity/YAD)
  $0 --tui        # Force TUI (Whiptail)
  $0 --debug      # Enable debug output
  $0 -d --gui     # Debug mode with GUI

Log saved to: $LOG_FILE
EOF
}

# Parse parameters
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gui)
            USE_GUI="gui"
            debug "GUI mode requested via command line"
            shift
            ;;
        -t|--tui)
            USE_GUI="tui"
            debug "TUI mode requested via command line"
            shift
            ;;
        -d|--debug)
            DEBUG_MODE=1
            echo "DEBUG MODE ENABLED"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "Ubuntu Setup Script v$SCRIPT_VERSION"
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            show_help
            exit 1
            ;;
    esac
done

### SIGNAL HANDLING ###
cleanup() {
    log "Script interrupted - cleaning up..."
    debug "Cleanup function called"
    exit 130
}

trap cleanup INT TERM

### MAIN ###
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    startup_checks
    main_menu
fi