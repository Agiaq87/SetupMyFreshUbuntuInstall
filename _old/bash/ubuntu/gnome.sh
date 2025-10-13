#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

log INFO "GNOME Tools"
if ask_yes_no "Do you want to install gnome tweaks?" Y; then
    silent_run_with_spinner "Install gnome tweaks" sudo nala install gnome-tweaks
fi

log INFO "Gnome extensions section"
if ask_yes_no "Do you want to install Gnome extensions?" Y; then
    silent_run_with_spinner "Installing Gnome extensions" bash -c '
        sudo nala install -y gnome-shell-extensions chrome-gnome-shell \
        gnome-tweaks
        '
        if ! check_if_extensions_directory_exists; then
            log INFO "Make extensions directory"
            mkdir -p "$HOME/.local/share/gnome-shell/extensions"
        fi

    log INFO "Starting gnome shell extensions section" 
        silent_run_with_spinner "Check if tools are already installed" bash -c '
        sudo nala install -y wget unzip jq
        '
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
        install_gnome_extension_from_prompt "Resolution and Refresh Rate in Quick Settings" "https://extensions.gnome.org/extension-data/quick-settings-resolution-and-refresh-raterukins.github.io.v6.shell-extension.zip"
        install_gnome_extension_from_prompt "Notifications Alert" "https://extensions.gnome.org/extension-data/notifications-alert-on-user-menuhackedbellini.gmail.com.v53.shell-extension.zip"
        install_gnome_extension_from_prompt "Clipboard Indicator" "https://extensions.gnome.org/extension-data/clipboard-indicatortudmotu.com.v68.shell-extension.zip"
        install_gnome_extension_from_prompt "Better End Session Dialog" "https://extensions.gnome.org/extension-data/better-end-session-dialogpopov895.ukr.net.v28.shell-extension.zip"
        install_gnome_extension_from_prompt "Bluetooth File Sender" "https://extensions.gnome.org/extension-data/bluetooth-file-senderChristophrrb.github.io.v8.shell-extension.zip"
        install_gnome_extension_from_prompt "Zen" "https://extensions.gnome.org/extension-data/zenle0.gs.v9.shell-extension.zip"
        install_gnome_extension_from_prompt "Systemd Status" "https://extensions.gnome.org/extension-data/systemd-statusne0sight.github.io.v8.shell-extension.zip"
        install_gnome_extension_from_prompt "Keyboard Backlight Slider" "https://extensions.gnome.org/extension-data/keyboard-backlight-menuophir.dev.v6.shell-extension.zip"
        install_gnome_extension_from_prompt "Custom OSD" "https://extensions.gnome.org/extension-data/custom-osdneuromorph.v28.shell-extension.zip"
        install_gnome_extension_from_prompt "Containers" "https://extensions.gnome.org/extension-data/containersroyg.v38.shell-extension.zip"
        install_gnome_extension_from_prompt "HeadsetControl" "https://extensions.gnome.org/extension-data/HeadsetControllauinger-clan.de.v59.shell-extension.zip"
        install_gnome_extension_from_prompt "Smart Home" "https://extensions.gnome.org/extension-data/smart-homechlumskyvaclav.gmail.com.v13.shell-extension.zip"
        install_gnome_extension_from_prompt "Printers" "https://extensions.gnome.org/extension-data/printerslinux-man.org.v29.shell-extension.zip"
        install_gnome_extension_from_prompt "SettingsCenter" "https://extensions.gnome.org/extension-data/SettingsCenterlauinger-clan.de.v31.shell-extension.zip"
        install_gnome_extension_from_prompt "Bluetooth Battery Meter" "https://extensions.gnome.org/extension-data/Bluetooth-Battery-Metermaniacx.github.com.v32.shell-extension.zip"
        install_gnome_extension_from_prompt "Tweaks & Extensions in System Menu" "https://extensions.gnome.org/extension-data/tweaks-system-menuextensions.gnome-shell.fifi.org.v24.shell-extension.zip"
        install_gnome_extension_from_prompt "Easy Docker Containers" "https://extensions.gnome.org/extension-data/easy_docker_containersred.software.systems.v29.shell-extension.zip"
        install_gnome_extension_from_prompt "Status Area Horizontal Spacing" "https://extensions.gnome.org/extension-data/status-area-horizontal-spacingmathematical.coffee.gmail.com.v30.shell-extension.zip"
        install_gnome_extension_from_prompt "Random Wallpaper" "https://extensions.gnome.org/extension-data/randomwallpaperiflow.space.v36.shell-extension.zip"
        install_gnome_extension_from_prompt "Lock Keys" "https://extensions.gnome.org/extension-data/lockkeysvaina.lt.v61.shell-extension.zip"
        install_gnome_extension_from_prompt "ArcMenu" "https://extensions.gnome.org/extension-data/arcmenuarcmenu.com.v66.shell-extension.zip" 
        install_gnome_extension_from_prompt "Media Controls" "https://extensions.gnome.org/extension-data/mediacontrolscliffniff.github.com.v37.shell-extension.zip"
        install_gnome_extension_from_prompt "Dash to Panel" "https://extensions.gnome.org/extension-data/dash-to-paneljderose9.github.com.v68.shell-extension.zip"
fi

log INFO "Other GUI tools"
if ask_yes_no "Do you want to install Ulauncher?" Y; then
    silent_run_with_spinner "Add repository" sudo add-apt-repository universe -y && sudo add-apt-repository ppa:agornostal/ulauncher -y && sudo nala update && sudo nala install ulauncher
fi