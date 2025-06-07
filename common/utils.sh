#!/bin/bash

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

run_or_fail() {
    local description="$1"
    shift
    log INFO "$description..."
    if "$@"; then
        log INFO "$description completed"
    else
        log ERROR "$description failed"
        exit 1
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
        log INFO "$description completes"
    else
        log ERROR "$description failed"
        exit 1
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

install_gnome_extension_from_url() {
    local extension_url="$1"
    local temp_zip="/tmp/gnome_extension_$(date +%s).zip"
    local temp_dir="/tmp/gnome_extension_extract_$(date +%s)"
    
    if ! check_if_extensions_directory_exists; then
        log INFO "Creating Gnome extensions directory"
        mkdir -p "$HOME/.local/share/gnome-shell/extensions"
    fi

    log INFO "Installing Gnome extension from URL: $extension_url"
    
    # Download
    silent_run_with_spinner "Downloading Gnome extension" wget -q -O "$temp_zip" "$extension_url"
    
    # Extract to temporary directory
    mkdir -p "$temp_dir"
    silent_run_with_spinner "Extracting Gnome extension" unzip -q "$temp_zip" -d "$temp_dir"
    
    # Get the UUID from metadata.json
    local metadata_file="$temp_dir/metadata.json"
    if [[ ! -f "$metadata_file" ]]; then
        log ERROR "metadata.json not found in extension"
        rm -rf "$temp_dir" "$temp_zip"
        return 1
    fi
    
    # More compatible way to extract UUID
    local extension_uuid
    extension_uuid=$(jq -r '.uuid' "$metadata_file" 2>/dev/null)
    
    if [[ -z "$extension_uuid" ]]; then
        log ERROR "Could not extract UUID from metadata.json"
        rm -rf "$temp_dir" "$temp_zip"
        return 1
    fi
    
    # Create final directory and move contents
    local extension_dir="$HOME/.local/share/gnome-shell/extensions/$extension_uuid"
    if [[ -d "$extension_dir" ]]; then
        log INFO "Extension already exists, removing old version"
        rm -rf "$extension_dir"
    fi
    
    mkdir -p "$extension_dir"
    cp -r "$temp_dir"/* "$extension_dir"/
    rm -rf "$temp_dir" "$temp_zip"

    log INFO "Enabling Gnome extension: $extension_uuid"
    gnome-extensions enable "$extension_uuid"
    log INFO "Gnome extension installed and enabled: $extension_uuid"
}

install_gnome_extension_from_prompt() {
    local extension_name="$1"
    local extension_url="$2"

    if ask_yes_no "Do you want to install the Gnome extension '$extension_name'?" Y; then
        silent_run_with_spinner "Installing Gnome extension: $extension_name" install_gnome_extension_from_url "$extension_url"
    else
        log INFO "Skipping installation of Gnome extension: $extension_name"
    fi
}