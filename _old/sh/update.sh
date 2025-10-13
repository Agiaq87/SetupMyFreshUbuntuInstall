#!/bin/bash
update_system() {
    log "Starting system update..."
    debug "Entering update_system function"

    if ask_yesno "System Update" "Update the system? This may take several minutes."; then
        case $GUI_ENGINE in
            "zenity"|"yad")
                (
                    echo "20" ; sudo apt update 2>&1 | tee -a "$LOG_FILE"
                    echo "60" ; sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"
                    echo "80" ; sudo snap refresh 2>&1 | tee -a "$LOG_FILE"
                    echo "100" ; sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ) | show_progress "System Update" "Updating system in progress..."
                ;;
            *)
                sudo apt update 2>&1 | tee -a "$LOG_FILE"
                sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"
                sudo snap refresh 2>&1 | tee -a "$LOG_FILE"
                sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
                ;;
        esac

        show_message "Completed" "System updated successfully!"
        log "System update completed"
        debug "System update finished successfully"
    else
        debug "System update cancelled by user"
    fi
}