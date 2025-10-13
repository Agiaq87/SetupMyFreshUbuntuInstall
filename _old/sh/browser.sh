#!/bin/bash
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