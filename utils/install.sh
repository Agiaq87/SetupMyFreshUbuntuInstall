install_package_secure() {
    local package_name="$1"
    local package_cmd="$2"
    local package_manager="$3"
    local description="$4"

    maintain_sudo

    (
        echo "10" ; sleep 1
        echo "# Preparing installation..."

        case $package_manager in
            "apt"|"nala")
                # Logica APT/NALA
                if [ $NALA_INSTALLED -eq 1 ] && [ "$package_manager" != "apt" ]; then
                    echo "50"
                    echo "# Installing with Nala..."
                    # Esegue il comando e verifica il successo
                    if ! sudo nala install -y $package_cmd 2>&1; then
                        echo "ERROR" ; exit 1
                    fi
                else
                    echo "50"
                    echo "# Installing with APT..."
                    if ! sudo apt install -y $package_cmd 2>&1; then
                        echo "ERROR" ; exit 1
                    fi
                fi
                ;;
            "snap")
                # Logica SNAP
                echo "50"
                echo "# Installing with Snap..."
                if ! sudo snap install $package_cmd 2>&1; then
                    echo "ERROR" ; exit 1
                fi
                ;;
            "flatpak")
                # Logica FLATPAK (non richiede sudo per installazione utente)
                echo "50"
                echo "# Installing with Flatpak..."
                if ! flatpak install flathub $package_cmd -y 2>&1; then
                    echo "ERROR" ; exit 1
                fi
                ;;
        esac
        echo "100"
        echo "# Installation completed"
    # La pipe convoglia l'output a zenity --progress
    ) | zenity --progress --title="Installing $package_name" \
                --text="Preparing $package_name..." --percentage=0 --auto-close \
                --width=400 --no-cancel

    # Controlla l'uscita dell'intera pipe (di zenity)
    if [ $? -ne 0 ]; then
        # Se zenity è stato interrotto o il processo ha inviato "ERROR"
        return 1
    fi

    # Se l'installazione ha avuto successo
    log INFO "$package_name installed successfully"
    show_notification "Installation completed" "$package_name installed!"
    return 0
}

add_repository() {
    local repo_name="$1"
    local key_url="$2"
    local repo_url="$3"
    local list_file="$4"

    log INFO "Adding repository: $repo_name"

    # Controlla se il repository esiste già
    if [ -f "$list_file" ]; then
        log INFO "Repository $repo_name already exists"
        return 0
    fi

    # Assumo che 'maintain_sudo' gestisca i privilegi admin
    maintain_sudo

    # Blocco principale di esecuzione: l'output viene piped a zenity --progress
    (
        echo "25"
        echo "# Downloading repository key..."
        # Scarica la chiave e la aggiunge con apt-key
        if ! wget -q -O - "$key_url" | sudo apt-key add - 2>&1; then
            echo "ERROR" ; exit 1
        fi

        echo "75"
        echo "# Adding repository..."
        # Aggiunge la riga del repository al file list
        if ! echo "$repo_url"; then
            echo "ERROR" ; exit 1
        fi

        echo "90"
        echo "# Updating package list..."
        # Aggiorna gli indici dei pacchetti
        if ! sudo apt update 2>&1; then
            echo "ERROR" ; exit 1
        fi

        echo "100"
        echo "# Repository added successfully"
    # Pipe l'output a Zenity (rimosso il case per yad e zenity)
    ) | zenity --progress --title="Adding $repo_name Repository" \
                --text="Preparing..." --percentage=0 --auto-close \
                --no-cancel # Aggiunto --no-cancel

    # Controllo l'uscita dell'intera pipe zenity
    if [ $? -ne 0 ]; then
        # Se zenity viene interrotto o il processo interno ha inviato "ERROR"
        error_exit "Failed to add $repo_name repository. Check log for details."
        return 1
    fi

    log INFO "$repo_name repository added successfully"
    return 0
}