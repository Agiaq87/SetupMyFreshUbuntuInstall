#!/bin/bash

show_game_menu() {
    log INFO "Opening game tools menu..."
    # Define available software (format: id|name|description)
    local dev_items=(
        "steam|Steam|Game store"
        "lutris|Lutris|Game launcher for Wine/Proton/Emulators"
        "game_mode|GameMode|Feral Interactive optimization daemon"
        "mango_hud|MangoHUD|FPS overlay & performance metrics"
        "vk_basalt|vkBasalt|Vulkan post-processing tool"
        "goverlay|Flutter|GUI per MangoHud, vkBasalt, Gamescope"
        "proton_qt|Proton-Qt|Manage Proton-GE versions"
        "heroic_game_laucher|Heroic Games Launcher|Epic/GOG integration"
        "itch_io|itch.io|itch.io client for linux"
        "playonlinux|PlayOnLinux|Helper for install and manage games using Wine"
        "emulators|Emulators|Sub menu for install emulators"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Development Tools Selection" "Choose development tools to install:" "${dev_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Development tools selection cancelled"
        return
    fi

    log INFO "Selected development tools: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "steam")
                install_package_secure "Steam" "steam" "nala" "Game store" || log WARN "Steam installation failed, continuing..."
                ;;
            "lutris")
                install_package_secure "Lutris" "lutris" "nala" "Lame launcher for Wine/Proton/Emulators" || log WARN "Lutris installation failed, continuing..."
                ;;
            "game_mode")
                install_package_secure "GameMode" "gamemode libgamemode0 libgamemodeauto0" "nala" "Feral Interactive optimization daemon" || log WARN "GameMode installation failed, continuing..."
                ;;
            "mango_hud")
                install_package_secure "MangoHUD" "mangohud" "nala" "FPS overlay & performance metrics" || log WARN "MangoHUD installation failed, continuing..."
                ;;
            "vk_basalt")
                install_package_secure "vkBasalt" "vkbasalt" "nala" "Vulkan post-processing tool" || log WARN "vkBasalt installation failed, continuing..."
                ;;
            "goverlay")
                install_package_secure "Goverlay" "goverlay" "nala" "GUI per MangoHud, vkBasalt, Gamescope" || log WARN "Goverlay installation failed, continuing..."
                ;;
            "proton_qt")
                install_package_secure "Proton-Qt" "net.davidotek.pupgui2" "flatpak" "Manage Proton-GE versions" || log WARN "Proton-Qt installation failed, continuing..."
                ;;
            "heroic_game_laucher")
                install_package_secure "Heroic Games Launcher" "com.heroicgameslauncher.hgl" "flatpak" "Epic/GOG integration" || log WARN "Heroic Games Launcher installation failed, continuing..."
                ;;
            "itch_io")
                install_package_secure "itch.io" "itch" "nala" "itch.io client for linux" || log WARN "Itch.io installation failed, continuing..."
                ;;
            "playonlinux")
                install_package_secure "PlayOnLinux" "playonlinux" "nala" "Helper for install and manage games using Wine" || log WARN "PlayOnLinux installation failed, continuing..."
                ;;
            "emulators")
                show_game_emulator_menu
                ;;
        esac
    done

    show_message "Completed" "Game installation completed!"
}