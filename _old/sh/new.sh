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

source check.sh
source install.sh
source update.sh
source gui.sh
source 2-development.sh
source browser.sh
source must_install.sh
source jetbrains.sh
source main_menu.sh


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

jq() {
    log "Check jq framework"
    debug "Check jq"
    if ! command -v jq >/dev/null 2>&1; then
        debug "jq not found, install it..."
        sudo apt update && sudo apt install -y jq
    fi
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