#!/bin/bash

install_gnome_extension() {
    local EXTENSION_ID="$1" # ID numerico dell'estensione (es. 307 per Dash to Dock)
    local GNOME_VERSION=$(gnome-shell --version 2>/dev/null | cut -d ' ' -f3 | cut -d '.' -f1)

    if [ -z "$GNOME_VERSION" ]; then
        zenity --error --title="Errore GNOME" --text="Impossibile determinare la versione di GNOME Shell. Installazione annullata."
        return 1
    fi

    local EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions"
    local URL="https://extensions.gnome.org/extension-data/${EXTENSION_ID}.shell-extension.zip"
    local TEMP_FILE=$(mktemp /tmp/gnome_extension_XXXXXX.zip)
    
    # 1. Scarica l'estensione (Ignoriamo il controllo della versione per semplicità qui)
    if ! curl -L -o "$TEMP_FILE" "$URL" 2>/dev/null; then
        zenity --error --title="Errore Download" --text="Impossibile scaricare l'estensione con ID: $EXTENSION_ID"
        rm -f "$TEMP_FILE"
        return 1
    fi
    
    # 2. Installa l'estensione dal file ZIP scaricato
    if gnome-extensions install "$TEMP_FILE"; then
        
        # 3. Trova l'UUID per l'abilitazione
        local UUID=$(unzip -qc "$TEMP_FILE" "metadata.json" | grep '"uuid":' | head -n 1 | awk -F'"' '{print $4}')
        
        if [ -n "$UUID" ]; then
            # 4. Abilita l'estensione
            gnome-extensions enable "$UUID" 2>/dev/null
            
            # (Opzionale) Riavvia la shell (funziona solo con X11, non con Wayland)
            # dbus-send --session --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'Meta.restart("Riavvio dopo installazione estensione");'
            
            echo "Estensione $EXTENSION_ID ($UUID) installata e abilitata con successo."
            rm -f "$TEMP_FILE"
            return 0
        else
            zenity --warning --title="Installazione Fallita" --text="Estensione $EXTENSION_ID installata ma UUID non trovato. Abilitazione manuale richiesta."
            rm -f "$TEMP_FILE"
            return 1
        fi
    else
        zenity --error --title="Installazione Fallita" --text="gnome-extensions non è riuscito a installare $EXTENSION_ID."
        rm -f "$TEMP_FILE"
        return 1
    fi
}


gnome_shell_extensions_menu() {
    log INFO "Opening Gnome Shell Extensions menu..."
    # Define available extensions (format: id|name|description)
    local extension_items=(
        "307|Dash to Dock|Trasforma il tuo dock in una barra delle applicazioni altamente personalizzabile"
        "28|User Themes|Abilita l'uso di temi personalizzati per GNOME Shell"
        "19|Workspace Indicator|Aggiunge un indicatore della scrivania alla barra superiore"
        "1460|Clipboard Indicator|Gestore avanzato degli appunti con cronologia"
        "708|Caffeine|Disabilita temporaneamente lo screensaver e la sospensione automatica"
        "779|OpenWeather|Visualizza le condizioni meteo attuali nella barra superiore"
        "15|Removable Drive Menu|Aggiunge un menu per dispositivi rimovibili nella barra superiore"
        "906|Sound Input & Output Device Chooser|Consente di cambiare rapidamente i dispositivi audio dalla barra superiore"
        "1313|TopIcons Plus|Sposta le icone delle applicazioni di sistema nella barra superiore"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Gnome Shell Extensions Selection" "Choose extensions to install:" "${extension_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Gnome Shell Extensions selection cancelled"
        return
    fi

    log INFO "Selected extensions: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "307")
                install_gnome_extension "307" || log WARN "Dash to Dock installation failed, continuing..."
                ;;
            "28")
                install_gnome_extension "28" || log WARN "User Themes installation failed, continuing..."
                ;;
            "19")
                install_gnome_extension "19" || log WARN "Workspace Indicator installation failed, continuing..."
                ;;
            "1460")                
                install_gnome_extension "1460" || log WARN "Clipboard Indicator installation failed, continuing..."
                ;;
            "708")
                install_gnome_extension "708" || log WARN "Caffeine installation failed, continuing..."
                ;;
            "779")
                install_gnome_extension "779" || log WARN "OpenWeather installation failed, continuing..."
                ;;
            "15")
                install_gnome_extension "15" || log WARN "Removable Drive Menu installation failed, continuing..."
                ;;
            "906")
                install_gnome_extension "906" || log WARN "Sound Input & Output Device Chooser installation failed, continuing..."
                ;;
            "1313")
                install_gnome_extension "1313" || log WARN "TopIcons Plus installation failed, continuing..."
                ;;
            *)
                log WARN "Unknown extension selected: $choice"
                ;;
        esac
    done
}   