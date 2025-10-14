#!/bin/bash

show_kernel_menu() {
    log INFO "Opening Kernel menu..."
    # Placeholder for kernel-related actions
    
    local kernel_items=(
        "xanmod|XanMod|XanMod kernel is built to provide a stable, smooth and solid system experience."
        "liquorix|Liquorix|Liquorix is an enthusiast Linux kernel designed for uncompromised responsiveness in interactive systems, enabling low latency compute in A/V production, and reduced frame time deviations in games."
    )

    local choices
    choices=$(show_checklist "Kernel Selection" "Choose kernel options to install:" "${kernel_items[@]}")
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Kernel selection cancelled"
        return
    fi
    log INFO "Selected kernel options: $choices"
    IFS='|' read -ra choice_array <<< "$choices"
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"
        case $choice in
            "xanmod")
                (
                    echo "10" ; wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
                    echo "35" ; echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/xanmod-release.list
                    echo "50" ; sudo nala update 
                    echo "75" ; sudo nala install -y linux-xanmod-x64v3
                    echo "100" ; sleep 0.1
                )
                ;;
            "liquorix")
                (
                    curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
                ) | zenity --progress --title="Installing Liquorix Kernel" --text="Installing Liquorix kernel, please wait..." --percentage=0 --auto-close
            *)
                log WARN "Unknown kernel option: $choice"
                ;;
        esac
    done
}