#!/bin/bash

declare -a ERROR_ENCOUNTERED

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log ERROR "Need admin privileges."
        exit 1
    fi
}

is_terminal() {
    [[ -t 1 ]]
}

log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    if is_terminal; then
        case "$level" in
            INFO)  color="\033[1;34m" ;;  # Blu
            WARN)  color="\033[1;33m" ;;  # Giallo
            ERROR) color="\033[1;31m" ;;  # Rosso
            DEBUG) color="\033[0;36m" ;;  # Ciano
            *)     color="\033[0m"     ;; # Reset
        esac
        echo -e "[$timestamp] [$level] ${color}${message}\033[0m"
    else
        echo "[$timestamp] [$level] $message"
    fi
}

ask() {
    local prompt="$1"
    read -rp "$prompt: " REPLY
    echo "$REPLY"
}

print_menu () {
    local strings=("$@")
    local BLUE='\033[0;34m'
    local NC='\033[0m'

    local counter=1
    for string in "${strings[@]}"; do
        echo -e "${BLUE}${counter}. ${string}${NC}"
        ((counter++))
    done
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-N}"
    local reply

    local suffix="[y/N]"
    [[ "$default" =~ ^[Yy]$ ]] && suffix="[Y/n]"

    while true; do
        read -rp "$prompt $suffix: " reply
        reply="${reply:-$default}"

        case "$reply" in
            [Yy]*) return 0 ;;  # true
            [Nn]*) return 1 ;;  # false
            *) log WARN "Risposta non valida. Digita Y o N." ;;
        esac
    done
}


confirm() {
    local prompt="${1:-Vuoi continuare?} [y/N] "
    read -rp "$prompt" REPLY
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

run_or_continue() {
    local description="$1"
    shift
    log INFO "$description..."
    if "$@"; then
        log INFO "$description completed"
    else
        log ERROR "$description failed"
        ERROR_ENCOUNTERED+=("$description")
        return 1
    fi
}

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    wait $pid
}

silent_run_with_spinner() {
    local description="$1"
    shift
    log INFO "$description..."
    ("$@" >/dev/null 2>&1) &
    spinner
    if [ $? -eq 0 ]; then
        log INFO "$description completed"
    else
        log ERROR "$description failed"
        ERROR_ENCOUNTERED+=("$description")
        return 1
    fi
}

detect_desktop_env() {
    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        local desktop_env
        desktop_env=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

        if [[ "$desktop_env" == *"gnome"* ]]; then
            echo "GNOME"
        elif [[ "$desktop_env" == *"kde"* || "$desktop_env" == *"plasma"* ]]; then
            echo "KDE"
        else
            echo "UNKNOWN"
        fi
    else
        echo "UNKNOWN"
    fi
}


check_if_extensions_directory_exists() {
    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    if [ -d "$extensions_dir" ]; then
        log INFO "Gnome extensions directory exists: $extensions_dir"
        return 0
    else
        log WARN "Gnome extensions directory does not exist: $extensions_dir"
        return 1
    fi
}

# Gnome
install_gnome_extension_from_url() {
    local extension_url="$1"
    if [[ -z "$extension_url" ]]; then
        log ERROR "No URL provided for Gnome extension"
        return 1
    fi

    local timestamp=$(date +%s)
    local pid=$$
    local temp_zip="/tmp/gnome_extension_${timestamp}_${pid}.zip"
    local temp_dir="/tmp/gnome_extension_extract_${timestamp}_${pid}"

    if ! check_if_extensions_directory_exists; then
        log INFO "Creating Gnome extensions directory"
        mkdir -p "$HOME/.local/share/gnome-shell/extensions"
    fi

    log INFO "Installing Gnome extension from URL: $extension_url"

    # Download
    silent_run_with_spinner "Downloading Gnome extension" wget -q -O "$temp_zip" "$extension_url" || {
        log ERROR "Failed to download extension from $extension_url"
        return 1
    }

    # Extract to temporary directory
    mkdir -p "$temp_dir"
    silent_run_with_spinner "Extracting Gnome extension" unzip -q "$temp_zip" -d "$temp_dir" || {
        log ERROR "Failed to extract the extension ZIP file"
        rm -f "$temp_zip"
        rm -rf "$temp_dir"
        return 1
    }

    # Get the UUID from metadata.json
    local metadata_file="$temp_dir/metadata.json"
    if [[ ! -f "$metadata_file" ]]; then
        log ERROR "metadata.json not found in extension"
        rm -f "$temp_zip"
        rm -rf "$temp_dir"
        return 1
    fi

    local extension_uuid
    extension_uuid=$(jq -r '.uuid' "$metadata_file" 2>/dev/null)
    if [[ -z "$extension_uuid" || "$extension_uuid" == "null" ]]; then
        log ERROR "Could not extract valid UUID from metadata.json"
        rm -f "$temp_zip"
        rm -rf "$temp_dir"
        return 1
    fi

    # Prepare final extension directory
    local extension_dir="$HOME/.local/share/gnome-shell/extensions/$extension_uuid"
    if [[ -d "$extension_dir" ]]; then
        log INFO "Extension already exists, removing old version"
        rm -rf "$extension_dir"
    fi

    mkdir -p "$extension_dir"
    cp -r "$temp_dir"/* "$extension_dir"/ || {
        log ERROR "Failed to copy extension files"
        rm -f "$temp_zip"
        rm -rf "$temp_dir"
        return 1
    }

    # Clean up
    rm -f "$temp_zip"
    rm -rf "$temp_dir"

    # Enable extension
    if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
        log INFO "Gnome extension installed and enabled: $extension_uuid"
    else
        log WARN "Extension $extension_uuid installed, but enabling failed"
    fi
}

install_gnome_extension_from_prompt() {
    local extension_name="$1"
    local extension_url="$2"

    if [[ -z "$extension_name" || -z "$extension_url" ]]; then
        log ERROR "Missing name or URL for Gnome extension"
        return 1
    fi

    silent_run_with_spinner "Installing Gnome extension: $extension_name" install_gnome_extension_from_url "$extension_url"
}

# Develop
ask_to_install() {
    local app_name="$1"
    local execute="$2"
    if ask_yes_no "Do you need $app_name?" Y; then
        silent_run_with_spinner "Installing $app_name" "$execute"
    fi
}

