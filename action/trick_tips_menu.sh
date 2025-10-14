#!/bin/bash

show_trick_tips_menu() {
    log INFO "Opening Trick & Tips menu..."
    # Define available tips (format: id|name|description)
    local tip_items=(
        "governor|Governor|Setup governor for performance"
        "shell|Gnome Shell Extensions|Install useful Gnome Shell extensions"
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
            "governor")
                install_package_secure "CPU Governor" "cpufrequtils" "nala" "Setup CPU governor for performance" || log WARN "CPU Governor installation failed, continuing..."
                (
                    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
                        sudo cpufreq-set -c "${cpu##*/cpu}" -g performance
                    done
                ) | zenity --progress --title="Setting CPU Governor" --text="Applying performance governor to all CPUs..." --percentage=0 --auto-close
                ;;
            "shell")
                gnome_shell_extensions_menu
                ;;
            "tip3")
                show_message "Tip 3" "Here is the content for Tip 3."
                ;;
            *)
                log WARN "Unknown tip selected: $choice"
                ;;
        esac
    done
}