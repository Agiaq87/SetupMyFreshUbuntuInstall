#!/bin/bash
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