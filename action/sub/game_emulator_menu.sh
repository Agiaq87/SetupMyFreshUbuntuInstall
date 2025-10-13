#!/bin/bash

show_game_emulator_menu() {
  log INFO "Opening emulators menu..."
    # Define available software (format: id|name|description)
    local emulator_items=(
        "retroarch|RetroArch|Multi-emulator frontend with extensive core support"
        "mame|MAME|Multiple Arcade Machine Emulator"
        "scummvm|ScummVM|Classic adventure games emulator"
        "dolphin|Dolphin|GameCube and Wii emulator"
        "pcsx2|PCSX2|PlayStation 2 emulator"
        "duckstation|DuckStation|PlayStation 1 emulator"
        "rpcs3|RPCS3|PlayStation 3 emulator"
        "yuzu|Yuzu|Nintendo Switch emulator"
        "ryujinx|Ryujinx|Nintendo Switch emulator (alternative)"
        "citra|Citra|Nintendo 3DS emulator"
        "ppsspp|PPSSPP|PlayStation Portable emulator"
        "mupen64plus|Mupen64Plus-Next|Nintendo 64 emulator"
        "dosbox-x|DOSBox-X|MS-DOS emulator with advanced features"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Emulators Selection" "Choose emulators to install:" "${emulator_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Emulators selection cancelled"
        return
    fi

    log INFO "Selected emulators: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "retroarch")
                install_package_secure "RetroArch" "retroarch" "snap" "Multi-emulator frontend" || log WARN "RetroArch installation failed, continuing..."
                ;;
            "mame")
                install_package_secure "MAME" "mame" "nala" "Arcade emulator" || log WARN "MAME installation failed, continuing..."
                ;;
            "scummvm")
                install_package_secure "ScummVM" "scummvm" "nala" "Adventure games emulator" || log WARN "ScummVM installation failed, continuing..."
                ;;
            "dolphin")
                install_package_secure "Dolphin" "org.DolphinEmu.dolphin-emu" "flatpak" "GameCube/Wii emulator" || log WARN "Dolphin installation failed, continuing..."
                ;;
            "pcsx2")
                install_package_secure "PCSX2" "net.pcsx2.PCSX2" "flatpak" "PS2 emulator" || log WARN "PCSX2 installation failed, continuing..."
                ;;
            "duckstation")
                install_package_secure "DuckStation" "org.duckstation.DuckStation" "flatpak" "PS1 emulator" || log WARN "DuckStation installation failed, continuing..."
                ;;
            "rpcs3")
                install_package_secure "RPCS3" "net.rpcs3.RPCS3" "flatpak" "PS3 emulator" || log WARN "RPCS3 installation failed, continuing..."
                ;;
            "yuzu")
                install_package_secure "Yuzu" "org.yuzu_emu.yuzu" "flatpak" "Switch emulator" || log WARN "Yuzu installation failed, continuing..."
                ;;
            "ryujinx")
                install_package_secure "Ryujinx" "org.ryujinx.Ryujinx" "flatpak" "Switch emulator" || log WARN "Ryujinx installation failed, continuing..."
                ;;
            "citra")
                install_package_secure "Citra" "org.citra_emu.citra" "flatpak" "3DS emulator" || log WARN "Citra installation failed, continuing..."
                ;;
            "ppsspp")
                install_package_secure "PPSSPP" "org.ppsspp.PPSSPP" "flatpak" "PSP emulator" || log WARN "PPSSPP installation failed, continuing..."
                ;;
            "mupen64plus")
                install_package_secure "Mupen64Plus-Next" "org.mupen64plus.Mupen64Plus-Next" "flatpak" "N64 emulator" || log WARN "Mupen64Plus installation failed, continuing..."
                ;;
            "dosbox-x")
                install_package_secure "DOSBox-X" "com.dosbox_x.DOSBox-X" "flatpak" "MS-DOS emulator" || log WARN "DOSBox-X installation failed, continuing..."
                ;;
        esac
    done

    show_message "Completed" "Emulators installation completed!\n\nNote: You may need to provide your own game files/ROMs.\nEnsure you own the games you emulate."
}