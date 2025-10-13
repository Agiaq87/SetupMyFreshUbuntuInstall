#!/bin/bash

show_browser_menu() {
    log INFO "Opening browser menu..."

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
    log DEBUG "$choice"

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Browser selection cancelled"
        return
    fi

    log INFO "Selected browsers: $choices"
    IFS='|' read -ra choice_array <<< "$choices"
    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        #choice=$(echo "$choice" | tr -d '"')  # Remove quotes
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "chrome")
                # Add Chrome repository if not present
                add_repository "Google Chrome" \
                    "https://dl.google.com/linux/linux_signing_key.pub" \
                    "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
                    "/etc/apt/sources.list.d/google-chrome.list"
                install_package_secure "Google Chrome" "google-chrome-stable" "nala" "Complete Google browser with extensions and sync" || log WARN "Chrome installation failed, continuing..."
                ;;
            "firefox")
                install_package_secure "Firefox" "firefox" "snap" "Latest version Mozilla browser" || log WARN "Chrome installation failed, continuing..."
                ;;
            "edge")
                install_package_secure "Microsoft Edge" "com.microsoft.Edge" "flatpak" "Microsoft browser for Linux" || log WARN "Chrome installation failed, continuing..."
                ;;
            "opera")
                install_package_secure "Opera" "opera" "snap" "Browser with integrated VPN and workspace" || log WARN "Chrome installation failed, continuing..."
                ;;
            "vivaldi")
                install_package_secure "Vivaldi" "vivaldi" "snap" "Highly customizable browser" || log WARN "Chrome installation failed, continuing..."
                ;;
            "brave")
                # Add Brave repository if not present
                add_repository "Brave Browser" \
                    "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
                    "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                    "/etc/apt/sources.list.d/brave-browser-release.list"
                install_package_secure "Brave Browser" "brave-browser" "nala" "Privacy and security focused browser" || log WARN "Chrome installation failed, continuing..."
                ;;
            "tor")
                install_package_secure "Tor Browser" "com.github.micahflee.torbrowser-launcher" "flatpak" "Browser for anonymous navigation" || log WARN "Chrome installation failed, continuing..."
                ;;
            "chromium")
                install_package_secure "Chromium" "chromium" "snap" "Open source version of Chrome" || log WARN "Chrome installation failed, continuing..."
                ;;
        esac
    done

    show_message "Completed" "Browser installation completed!"
}