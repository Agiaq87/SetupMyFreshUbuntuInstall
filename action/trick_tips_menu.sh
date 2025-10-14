#!/bin/bash

show_trick_tips_menu() {
    log INFO "Opening Trick & Tips menu..."
    # Define available tips (format: id|name|description)
    local tip_items=(
        "animations|Animations|Disable desktop animations for performance"
        "governor|Governor|Setup governor for performance"
        "kernel|Kernel|Install and configure a custom kernel"
        "preload|Preload|Install and configure Preload for faster application startup"
        "shell|Gnome Shell Extensions|Install useful Gnome Shell extensions"
        "swap|Swap|Optimize swap usage for better performance"
        "tip3|Tip 3|Description for Tip 3"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Trick & Tips Selection" "Choose tips to view:" "${tip_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Trick & Tips selection cancelled"
        return
    fi

    log INFO "Selected tips: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "animations")
                (
                    echo "10" ; sleep 0.1
                    gsettings set org.gnome.desktop.interface enable-animations false
                    echo "50" ; sleep 0.1
                    gsettings set org.gnome.desktop.interface cursor-blink false
                    echo "100" ; sleep 0.1
                ) zenity --progress --title="Disabling Animations" --text="Applying settings to disable desktop animations..." --percentage=0 --auto-close
                ;;
            "governor")
                install_package_secure "CPU Governor" "cpufrequtils" "nala" "Setup CPU governor for performance" || log WARN "CPU Governor installation failed, continuing..."
                (
                    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
                        sudo cpufreq-set -c "${cpu##*/cpu}" -g performance
                    done
                ) | zenity --progress --title="Setting CPU Governor" --text="Applying performance governor to all CPUs..." --percentage=0 --auto-close
                ;;
            "kernel")
                show_kernel_menu
                ;;
            "preload")
                install_package_secure "Preload" "preload" "nala" "Install and configure Preload for faster application startup" || log WARN "Preload installation failed, continuing..."
                ;;
            "shell")
                gnome_shell_extensions_menu
                ;;
            "swap")
                (
                    echo "10" ; sleep 0.1
                    sudo sysctl vm.swappiness=40
                    echo "50" ; sleep 0.1
                    sudo echo "vm.swappiness=40" | sudo tee -a /etc/sysctl.conf
                    #echo "50" ; sleep 0.1
                    #sudo sysctl vm.vfs_cache_pressure=50
                    echo "100" ; sleep 0.1
                ) | zenity --progress --title="Optimizing Swap Usage" --text="Applying swap usage optimizations..." --percentage=0 --auto-close
            "tip3")
                show_message "Tip 3" "Here is the content for Tip 3."
                ;;
            *)
                log WARN "Unknown tip selected: $choice"
                ;;
        esac
    done
}