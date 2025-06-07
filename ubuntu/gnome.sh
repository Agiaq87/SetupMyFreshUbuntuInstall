#!/bin/bash
set -x
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "Gnome extensions section"
ask_yes_no "Do you want to install Gnome extensions?" Y; then
    silent_run_with_spinner "Installing Gnome extensions" bash -c '
        sudo nala install -y gnome-shell-extensions 
        chrome-gnome-shell
        gnome-tweaks
        gnome-extensions enable
        '
        if ! check_if_extensions_directory_exists; then
            log INFO "Make extensions directory"
            mkdir -p "$HOME/.local/share/gnome-shell/extensions"
        fi

    log INFO "Starting gnome shell extensions section" 
        silent_run_with_spinner "Check if tools are already installed" sudo nala install -y wget unzip jq
        log INFO " Starting installation of most popular Gnome extensions"
        install_gnome_extension_from_prompt "Removable Drive Menu" "https://extensions.gnome.org/extension-data/drive-menugnome-shell-extensions.gcampax.github.com.v63.shell-extension.zip"
        install_gnome_extension_from_prompt "AppIndicator and KStatusNotifierItem Support" "https://extensions.gnome.org/extension-data/appindicatorsupportrgcjonas.gmail.com.v60.shell-extension.zip"
        install_gnome_extension_from_prompt "VirtualBox applet" "https://extensions.gnome.org/extension-data/vbox-appletgs.eros2.info.v18.shell-extension.zip"
        install_gnome_extension_from_prompt "Simple Timer" "https://extensions.gnome.org/extension-data/simple-timermajortomvr.github.com.v15.shell-extension.zip"
        install_gnome_extension_from_prompt "GSConnect" "https://extensions.gnome.org/extension-data/gsconnectandyholmes.github.io.v62.shell-extension.zip"
        install_gnome_extension_from_prompt "RebootToUEFI" "https://extensions.gnome.org/extension-data/reboottouefiubaygd.com.v24.shell-extension.zip"
        install_gnome_extension_from_prompt "Pip on top" "https://extensions.gnome.org/extension-data/pip-on-toprafostar.github.com.v8.shell-extension.zip"
        install_gnome_extension_from_prompt "Display Configuration Switcher" "https://extensions.gnome.org/extension-data/display-configuration-switcherknokelmaat.gitlab.com.v10.shell-extension.zip"
        install_gnome_extension_from_prompt "Proxy Switcher" "https://extensions.gnome.org/extension-data/ProxySwitcherflannaghan.com.v23.shell-extension.zip"
        install_gnome_extension_from_prompt "Touchpad Switcher" "https://extensions.gnome.org/extension-data/touchpadgpawru.v7.shell-extension.zip"
        install_gnome_extension_from_prompt "StreamController Integration" "https://extensions.gnome.org/extension-data/streamcontrollercore447.com.v4.shell-extension.zip"
        install_gnome_extension_from_prompt "Steal my focus window" "https://extensions.gnome.org/extension-data/steal-my-focus-windowsteal-my-focus-window.v5.shell-extension.zip"
        install_gnome_extension_from_prompt "Night Light Slider" "https://extensions.gnome.org/extension-data/night-light-sliderdevoscarm.github.com.v1.shell-extension.zip"
        install_gnome_extension_from_prompt "Caffeine" "https://extensions.gnome.org/extension-data/caffeinepatapon.info.v57.shell-extension.zip"
        install_gnome_extension_from_prompt "TeaTimer" "https://extensions.gnome.org/extension-data/TeaTimerzener.sbg.at.v9.shell-extension.zip"
        install_gnome_extension_from_prompt "Wifi QR Code" "https://extensions.gnome.org/extension-data/wifiqrcodeglerro.pm.me.v17.shell-extension.zip"
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
        install_gnome_extension_from_prompt
