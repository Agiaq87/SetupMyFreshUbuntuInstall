#!/bin/bash
### MAIN MENU ###
main_menu() {
    debug "Entering main menu loop"

    while true; do
        local choice
        choice=$(show_main_menu)

        # Extract only the number for compatibility
        choice=$(echo "$choice" | cut -d'|' -f1)

        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            log "Exiting main menu"
            debug "Main menu exit requested"
            break
        fi

        debug "Main menu choice selected: $choice"

        case $choice in
            "1")
                update_system
                ;;
            "2")
                development_tools
                ;;
            "3")
                show_message "TODO" "Docker installation - To be implemented"
                ;;
            "4")
                browsers_menu
                ;;
            "5")
                show_message "TODO" "Multimedia tools - To be implemented"
                ;;
            "6")
                show_message "TODO" "Gaming tools - To be implemented"
                ;;
            "7")
                system_menu
                ;;
            "0")
                if ask_yesno "Exit Confirmation" "Are you sure you want to exit?"; then
                    show_message "Goodbye!" "Setup completed!\n\nLog available at: $LOG_FILE"
                    log "Script terminated by user"
                    debug "Clean script termination"
                    exit 0
                fi
                ;;
            *)
                show_message "Error" "Invalid option: $choice"
                debug "Invalid menu choice: $choice"
                ;;
        esac
    done
}

# Main menu
show_main_menu() {
    local title="Ubuntu Setup v$SCRIPT_VERSION"

    debug "Showing main menu"

    case $GUI_ENGINE in
        "zenity")
            zenity --list --radiolist --title="$title" \
                --text="Choose what you want to do:" \
                --column="Sel" --column="ID" --column="Action" \
                --width=500 --height=400 \
                TRUE "1" "Update system" \
                FALSE "2" "Development tools" \
                FALSE "3" "Virtualization" \
                FALSE "4" "Browsers" \
                FALSE "5" "Multimedia" \
                FALSE "6" "Gaming" \
                FALSE "7" "System" \
                FALSE "0" "Exit"
            ;;
        "yad")
            yad --list --radiolist --title="$title" \
                --text="Choose what you want to do:" \
                --column="Sel" --column="ID" --column="Action" \
                --width=500 --height=400 --center \
                TRUE "1" "Update system" \
                FALSE "2" "Development tools" \
                FALSE "3" "Virtualization" \
                FALSE "4" "Browsers" \
                FALSE "5" "Multimedia" \
                FALSE "6" "Gaming" \
                FALSE "7" "System" \
                FALSE "0" "Exit"
            ;;
        *)
            whiptail --title "$title" --menu "Choose an option:" 16 60 8 \
                "1" "Update system" \
                "2" "Development tools" \
                "3" "Virtualization" \
                "4" "Browsers" \
                "5" "Multimedia" \
                "6" "Gaming" \
                "7" "System" \
                "0" "Exit" \
                3>&1 1>&2 2>&3
            ;;
    esac
}