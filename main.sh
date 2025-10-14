#!/bin/bash
set -e 

source ./utils/log.sh
source ./ui/menu/main_menu.sh
source ./ui/progress/progress.sh
source ./action/up.sh
source ./action/admin.sh
source ./utils/check.sh
source ./action/pre.sh
source ./ui/exit/error_exit.sh
source ./utils/install.sh
source ./ui/notification/notification.sh
source ./ui/message/show_message.sh
source ./ui/checklist/show_checklist.sh
source ./ui/terminal/terminal.sh
source ./action/browser_menu.sh
source ./action/dev_menu.sh
source ./action/sub/dev_action.sh
source ./action/virt_menu.sh
source ./action/multimedia_menu.sh
source ./action/system_menu.sh
source ./action/game_menu.sh
source ./action/sub/game_emulator_menu.sh
source ./action/writing_menu.sh
source ./action/security_menu.sh
source ./action/trick_tips_menu.sh
source ./action/sub/gnome_shell_extensions.sh

log INFO "SetupMyFreshUbuntuInstall init"

request_admin_privileges
#pre_start
nalaResult=$?

if [ "$nalaResult" -ne 0 ]; then
    log ERROR "Nala error!!! Exit"
    error_exit "Nala installation failed, exit"
else
    NALA_INSTALLED=1
fi

while true; do
    choice=$(show_menu)
    log INFO "Selected $choice"

    # Extract only the number for compatibility
    choice=$(echo "$choice" | cut -d'|' -f1)
    log INFO "Extracted $choice"

    choice="${choice//$'\n'/}"
    choice="${choice// /}"
    log INFO "Trimmed choice: '$choice'"

    if [ $? -ne 0 ] || [ -z "$choice" ]; then
            log INFO "Exit app"
            break
    fi

    case $choice in
            "1") # Browser
                show_browser_menu
                ;;
            "2") # Dev
                show_dev_menu
                ;;
            "3") # Gaming
                show_game_menu
                ;;
            "4") # Multimedia
                show_multimedia_menu
                ;;
            "5") # Virtualization
                show_virtualization_menu
                ;;
            "6") # Writing
                show_writing_menu
                ;;    
            "7") # Security e penetration testing
                show_security_menu
                ;;
            "8") # System
                show_system_menu
                ;;
            "9") # Trick & Tips
                show_trick_tips_menu
                ;;
            "0") # Exit
                log INFO "Setup completed!"
                exit 0
                ;;
            *)
                log INFO "Invalid option: $choice"
                ;;
        esac
done






