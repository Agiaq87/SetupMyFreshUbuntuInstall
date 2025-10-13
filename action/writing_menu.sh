#!/bin/bash

show_writing_menu() {
    log INFO "Opening writing and productivity tools menu..."
    
    local writing_items=(
        "libreoffice|LibreOffice|Full-featured office suite"
        "onlyoffice|OnlyOffice|Collaborative office suite compatible with MS Office"
        "wps_office|WPS Office|Lightweight office suite with MS Office compatibility"
        "zotero|Zotero|Research reference manager and citation tool"
        "mendeley|Mendeley|Reference manager for research papers"
        "focuswriter|FocusWriter|Distraction-free writing environment"
        "language_tool|LanguageTool|Grammar and spell checker (open source)"
        "bibisco|Bibisco|Novel writing software with character and scene management"
        "typora|Typora|Beautiful minimalist Markdown editor"
        "obsidian|Obsidian|Markdown-based knowledge base and note-taking"
        "joplin|Joplin|Open source note-taking and to-do application"
        "simplenote|Simplenote|Lightweight cross-platform note-taking app"
        "notable|Notable|Markdown-based note-taking app"
        "standard-notes|Standard Notes|Encrypted note-taking application"
        "anki|Anki|Powerful flashcard-based learning tool"
        "calibre|Calibre|E-book library management and conversion"
        "sigil|Sigil|EPUB e-book editor"
        "pandoc|Pandoc|Universal document converter"
        "marktext|Mark Text|Simple and elegant Markdown editor"
        "zettlr|Zettlr|Markdown editor for academic writing"
        "ghostwriter|Ghostwriter|Distraction-free Markdown editor"
        "pdf-arranger|PDF Arranger|Merge, split and rearrange PDF documents"
        "xournalpp|Xournal++|Handwriting note-taking and PDF annotation"
        "pdfmod|PDF Mod|Simple tool for modifying PDF documents"
        "masterpdf|Master PDF Editor|Advanced PDF editor (free version)"
        "texlive|TeX Live|Comprehensive LaTeX typesetting system"
        "lyx|LyX|Document processor based on LaTeX"
        "texmaker|Texmaker|LaTeX editor with integrated PDF viewer"
        "texstudio|TeXstudio|LaTeX editor with advanced features"
        "kile|Kile|User-friendly LaTeX editor for KDE"
        "gedit|gedit|Simple text editor for GNOME"
        "kate|Kate|Advanced text editor for KDE"
        "pluma|Pluma|Text editor for MATE desktop"
        "mousepad|Mousepad|Simple text editor for Xfce"
        "apostrophe|Apostrophe|Distraction-free Markdown editor for GNOME"
    )

    # Show checklist
    local choices
    choices=$(show_checklist "Writing Tools Selection" "Choose writing and productivity tools to install:" "${writing_items[@]}")

    # Exit if cancelled
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        log INFO "Writing tools selection cancelled"
        return
    fi

    log INFO "Selected writing tools: $choices"
    IFS='|' read -ra choice_array <<< "$choices"

    # Process each choice
    for choice_raw in "${choice_array[@]}"; do
        local choice
        choice=$(echo "$choice_raw" | xargs)
        log DEBUG "Processing selection: $choice"

        case $choice in
            "libreoffice")
                install_package_secure "LibreOffice" "libreoffice" "nala" "Full office suite" || log WARN "LibreOffice installation failed, continuing..."
                ;;
            "onlyoffice")
                log INFO "Installing OnlyOffice..."
                local onlyoffice_deb="/tmp/onlyoffice-desktopeditors.deb"
                wget -O "$onlyoffice_deb" "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb" 2>&1 | \
                    zenity --progress --title="Downloading OnlyOffice" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$onlyoffice_deb" ]; then
                    install_package_secure "OnlyOffice" "$onlyoffice_deb" "nala" "Collaborative office suite" || log WARN "OnlyOffice installation failed, continuing..."
                    rm -f "$onlyoffice_deb"
                else
                    log ERROR "Failed to download OnlyOffice"
                fi
                ;;
            "wps_office")
                show_message "Manual Installation" "WPS Office requires manual installation:\n\n1. Visit: https://www.wps.com/office/linux/\n2. Download the DEB package\n3. Install with: sudo dpkg -i wps-office*.deb\n\nNote: Free for personal use."
                xdg-open "https://www.wps.com/office/linux/" 2>/dev/null &
                ;;
            "zotero")
                log INFO "Installing Zotero..."
                local zotero_dir="/opt/zotero"
                sudo mkdir -p "$zotero_dir"
                
                wget -O /tmp/zotero.tar.bz2 "https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64" 2>&1 | \
                    zenity --progress --title="Downloading Zotero" --text="Downloading..." --pulsate --auto-close
                
                if [ -f /tmp/zotero.tar.bz2 ]; then
                    sudo tar -xjf /tmp/zotero.tar.bz2 -C /opt/
                    sudo /opt/Zotero_linux-x86_64/set_launcher_icon
                    sudo ln -s /opt/Zotero_linux-x86_64/zotero.desktop /usr/share/applications/zotero.desktop
                    rm /tmp/zotero.tar.bz2
                    log INFO "Zotero installed successfully"
                    show_notification "Installation completed" "Zotero installed!"
                else
                    log WARN "Zotero installation failed, continuing..."
                fi
                ;;
            "mendeley")
                log INFO "Installing Mendeley..."
                local mendeley_deb="/tmp/mendeleydesktop.deb"
                wget -O "$mendeley_deb" "https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming" 2>&1 | \
                    zenity --progress --title="Downloading Mendeley" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$mendeley_deb" ]; then
                    install_package_secure "Mendeley" "$mendeley_deb" "nala" "Reference manager" || log WARN "Mendeley installation failed, continuing..."
                    rm -f "$mendeley_deb"
                else
                    log ERROR "Failed to download Mendeley"
                fi
                ;;
            "focuswriter")
                install_package_secure "FocusWriter" "focuswriter" "nala" "Distraction-free writing" || log WARN "FocusWriter installation failed, continuing..."
                ;;
            "language_tool")
                install_package_secure "LanguageTool" "languagetool" "snap" "Grammar checker" || log WARN "LanguageTool installation failed, continuing..."
                ;;
            "bibisco")
                install_package_secure "Bibisco" "com.bibisco.BibiscoApp" "flatpak" "Novel writing software" || log WARN "Bibisco installation failed, continuing..."
                ;;
            "typora")
                show_message "Manual Installation" "Typora requires manual installation:\n\n1. Visit: https://typora.io/#linux\n2. Follow installation instructions\n\nNote: Typora is now paid software after beta period."
                xdg-open "https://typora.io/#linux" 2>/dev/null &
                ;;
            "obsidian")
                log INFO "Installing Obsidian..."
                local obsidian_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local obsidian_deb="/tmp/obsidian.deb"
                
                wget -O "$obsidian_deb" "$obsidian_url" 2>&1 | \
                    zenity --progress --title="Downloading Obsidian" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$obsidian_deb" ]; then
                    install_package_secure "Obsidian" "$obsidian_deb" "nala" "Knowledge base" || log WARN "Obsidian installation failed, continuing..."
                    rm -f "$obsidian_deb"
                else
                    log ERROR "Failed to download Obsidian"
                fi
                ;;
            "joplin")
                log INFO "Installing Joplin..."
                wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash 2>&1 | \
                    zenity --progress --title="Installing Joplin" --text="Installing..." --pulsate --auto-close
                
                if command -v joplin &> /dev/null; then
                    log INFO "Joplin installed successfully"
                    show_notification "Installation completed" "Joplin installed!"
                else
                    log WARN "Joplin installation failed, continuing..."
                fi
                ;;
            "simplenote")
                install_package_secure "Simplenote" "simplenote" "snap" "Note-taking app" || log WARN "Simplenote installation failed, continuing..."
                ;;
            "notable")
                log INFO "Installing Notable..."
                local notable_url=$(curl -s https://api.github.com/repos/notable/notable/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local notable_deb="/tmp/notable.deb"
                
                wget -O "$notable_deb" "$notable_url" 2>&1 | \
                    zenity --progress --title="Downloading Notable" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$notable_deb" ]; then
                    install_package_secure "Notable" "$notable_deb" "nala" "Markdown notes" || log WARN "Notable installation failed, continuing..."
                    rm -f "$notable_deb"
                else
                    log ERROR "Failed to download Notable"
                fi
                ;;
            "standard-notes")
                install_package_secure "Standard Notes" "org.standardnotes.standardnotes" "flatpak" "Encrypted notes" || log WARN "Standard Notes installation failed, continuing..."
                ;;
            "anki")
                install_package_secure "Anki" "net.ankiweb.Anki" "flatpak" "Flashcard learning tool" || log WARN "Anki installation failed, continuing..."
                ;;
            "calibre")
                install_package_secure "Calibre" "calibre" "nala" "E-book management" || log WARN "Calibre installation failed, continuing..."
                ;;
            "sigil")
                install_package_secure "Sigil" "sigil" "nala" "EPUB editor" || log WARN "Sigil installation failed, continuing..."
                ;;
            "pandoc")
                install_package_secure "Pandoc" "pandoc" "nala" "Document converter" || log WARN "Pandoc installation failed, continuing..."
                ;;
            "marktext")
                log INFO "Installing Mark Text..."
                local marktext_url=$(curl -s https://api.github.com/repos/marktext/marktext/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local marktext_deb="/tmp/marktext.deb"
                
                wget -O "$marktext_deb" "$marktext_url" 2>&1 | \
                    zenity --progress --title="Downloading Mark Text" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$marktext_deb" ]; then
                    install_package_secure "Mark Text" "$marktext_deb" "nala" "Markdown editor" || log WARN "Mark Text installation failed, continuing..."
                    rm -f "$marktext_deb"
                else
                    log ERROR "Failed to download Mark Text"
                fi
                ;;
            "zettlr")
                log INFO "Installing Zettlr..."
                local zettlr_url=$(curl -s https://api.github.com/repos/Zettlr/Zettlr/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
                local zettlr_deb="/tmp/zettlr.deb"
                
                wget -O "$zettlr_deb" "$zettlr_url" 2>&1 | \
                    zenity --progress --title="Downloading Zettlr" --text="Downloading..." --pulsate --auto-close
                
                if [ -f "$zettlr_deb" ]; then
                    install_package_secure "Zettlr" "$zettlr_deb" "nala" "Academic Markdown editor" || log WARN "Zettlr installation failed, continuing..."
                    rm -f "$zettlr_deb"
                else
                    log ERROR "Failed to download Zettlr"
                fi
                ;;
            "ghostwriter")
                install_package_secure "Ghostwriter" "ghostwriter" "nala" "Markdown editor" || log WARN "Ghostwriter installation failed, continuing..."
                ;;
            "pdf-arranger")
                install_package_secure "PDF Arranger" "pdf-arranger" "nala" "PDF manipulation" || log WARN "PDF Arranger installation failed, continuing..."
                ;;
            "xournalpp")
                install_package_secure "Xournal++" "xournalpp" "nala" "Note-taking and PDF annotation" || log WARN "Xournal++ installation failed, continuing..."
                ;;
            "pdfmod")
                install_package_secure "PDF Mod" "pdfmod" "nala" "PDF modifier" || log WARN "PDF Mod installation failed, continuing..."
                ;;
            "masterpdf")
                show_message "Manual Installation" "Master PDF Editor requires manual installation:\n\n1. Visit: https://code-industry.net/free-pdf-editor/\n2. Download the DEB package\n3. Install with: sudo dpkg -i master-pdf-editor*.deb\n\nNote: Free version available with watermark."
                xdg-open "https://code-industry.net/free-pdf-editor/" 2>/dev/null &
                ;;
            "texlive")
                install_package_secure "TeX Live" "texlive-full" "nala" "Complete LaTeX system" || log WARN "TeX Live installation failed, continuing..."
                show_message "Info" "TeX Live full installation is very large (several GB).\nFor a minimal installation, consider 'texlive-base' instead."
                ;;
            "lyx")
                install_package_secure "LyX" "lyx" "nala" "LaTeX document processor" || log WARN "LyX installation failed, continuing..."
                ;;
            "texmaker")
                install_package_secure "Texmaker" "texmaker" "nala" "LaTeX editor" || log WARN "Texmaker installation failed, continuing..."
                ;;
            "texstudio")
                install_package_secure "TeXstudio" "texstudio" "nala" "Advanced LaTeX editor" || log WARN "TeXstudio installation failed, continuing..."
                ;;
            "kile")
                install_package_secure "Kile" "kile" "nala" "LaTeX editor for KDE" || log WARN "Kile installation failed, continuing..."
                ;;
            "gedit")
                install_package_secure "gedit" "gedit" "nala" "Text editor for GNOME" || log WARN "gedit installation failed, continuing..."
                ;;
            "kate")
                install_package_secure "Kate" "kate" "nala" "Advanced text editor for KDE" || log WARN "Kate installation failed, continuing..."
                ;;
            "pluma")
                install_package_secure "Pluma" "pluma" "nala" "Text editor for MATE" || log WARN "Pluma installation failed, continuing..."
                ;;
            "mousepad")
                install_package_secure "Mousepad" "mousepad" "nala" "Text editor for Xfce" || log WARN "Mousepad installation failed, continuing..."
                ;;
            "apostrophe")
                install_package_secure "Apostrophe" "org.gnome.gitlab.somas.Apostrophe" "flatpak" "Markdown editor for GNOME" || log WARN "Apostrophe installation failed, continuing..."
                ;;
        esac
    done

    show_message "Completed" "Writing and productivity tools installation completed!"
}