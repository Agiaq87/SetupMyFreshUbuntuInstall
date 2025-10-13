#!/bin/bash
detect_streamcontroller_dir() {
    # Flatpak
    if [ -d "$HOME/.var/app/io.streamcontroller.StreamController/config/streamcontroller" ]; then
        STREAMCTL_DIR="$HOME/.var/app/io.streamcontroller.StreamController/config/streamcontroller"
    # Installazione standard
    elif [ -d "$HOME/.config/streamcontroller" ]; then
        STREAMCTL_DIR="$HOME/.config/streamcontroller"
    # Fallback
    else
        STREAMCTL_DIR="$HOME/.config/streamcontroller"
        mkdir -p "$STREAMCTL_DIR"
    fi

    echo "StreamController dir: $STREAMCTL_DIR"
}

detect_streamcontroller_dir