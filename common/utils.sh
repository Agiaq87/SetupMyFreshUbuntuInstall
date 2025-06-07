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
