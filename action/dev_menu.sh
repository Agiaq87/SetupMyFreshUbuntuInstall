#!/bin/bash

show_dev_menu() {
    log INFO "Opening development tools menu..."
    # Define available software (format: id|name|description)
    local dev_items=(
        "arduino|Arduino|IoT board development"
        "beekeeper-studio|Beekeeper Studio|An easy to use SQL editor and DB Manager for PSQL, MySQL & more"
        "bruno|Bruno|Opensource API Client for Exploring and Testing APIs"
        "dbeaver|DBeaver CE|MySQL inspector"
        "fiddler|Fiddler|Fiddler Everywhere for checking and debugging HTTP request"
        "flutter|Flutter|Flutter is Google's UI toolkit for building beautiful, natively compiled applications"
        "git|Git|Distributed version control system"
        "go|Go|The Go programming language"
        "insomnia|Insomnia|The Collaborative API Design Tool"
        "vscode|Visual Studio Code|Microsoft code editor"
        "netbeans|Apache Netbeans IDE|Apache NetBeans IDE for Java, Jakarta EE and Web applications"
        "nodejs|Node.js|JavaScript runtime and npm package manager"
        "pgadmin|pgAdmin|Management tool for the PostgreSQL database"
        "python-dev|Python Dev Tools|Pip, venv and Python development tools"
        "postman|Postman|REST API testing tool"
        "restfox|Restfox|A lightweight REST / HTTP Client based on Insomnia and Postman"
        "jetbrains-toolbox|JetBrains Toolbox|Integrated app for install multiple IDE from JetBrains"
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
            "arduino")
                install_package_secure "Arduino IDE" "cc.arduino.IDE2" "flatpak" "IoT board development" || log WARN "Arduino installation failed, continuing..."
                ;;
            "beekeeper-studio")
                install_package_secure "Beekeeper Studio" "io.beekeeperstudio.Studio" "flatpak" "SQL editor and DB Manager" || log WARN "Beekeeper Studio installation failed, continuing..."
                ;;
            "bruno")
                install_package_secure "Bruno" "bruno" "snap" "Opensource API Client" || log WARN "Bruno installation failed, continuing..."
                ;;
            "dbeaver")
                install_package_secure "DBeaver CE" "dbeaver-ce" "snap" "MySQL inspector" || log WARN "DBeaver installation failed, continuing..."
                ;;
            "fiddler")
                install_package_secure "Fiddler Everywhere" "fiddler-everywhere" "snap" "HTTP request debugging tool" || log WARN "Fiddler installation failed, continuing..."
                ;;
            "flutter")
                install_package_secure "Flutter" "flutter" "snap" "Google's UI toolkit" || log WARN "Flutter installation failed, continuing..."
                if [ $? -eq 0 ]; then
                    flutter_post_install
                fi
                ;;
            "git")
                install_package_secure "Git" "git" "nala" "Distributed version control system" || log WARN "Git installation failed, continuing..."
                ;;
            "go")
                install_package_secure "Go" "golang-go" "nala" "The Go programming language" || log WARN "Go installation failed, continuing..."
                ;;
            "insomnia")
                install_package_secure "Insomnia" "insomnia" "snap" "Collaborative API Design Tool" || log WARN "Insomnia installation failed, continuing..."
                ;;
            "vscode")
                # Add VSCode repository if not present
                add_repository "Visual Studio Code" \
                    "https://packages.microsoft.com/keys/microsoft.asc" \
                    "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" \
                    "/etc/apt/sources.list.d/vscode.list"
                install_package_secure "Visual Studio Code" "code" "nala" "Microsoft code editor" || log WARN "VSCode installation failed, continuing..."
                ;;
            "netbeans")
                install_package_secure "Apache Netbeans IDE" "org.apache.netbeans" "flatpak" "IDE for Java, Jakarta EE and Web" || log WARN "Netbeans installation failed, continuing..."
                ;;
            "nodejs")
                install_package_secure "Node.js" "nodejs npm" "nala" "JavaScript runtime and npm" || log WARN "Node.js installation failed, continuing..."
                ;;
            "pgadmin")
                install_package_secure "pgAdmin" "pgadmin4" "snap" "PostgreSQL management tool" || log WARN "pgAdmin installation failed, continuing..."
                ;;
            "python-dev")
                install_package_secure "Python Dev Tools" "python3-pip python3-venv python3-dev" "nala" "Python development tools" || log WARN "Python Dev Tools installation failed, continuing..."
                ;;
            "postman")
                install_package_secure "Postman" "postman" "snap" "REST API testing tool" || log WARN "Postman installation failed, continuing..."
                ;;
            "restfox")
                install_package_secure "Restfox" "restfox" "snap" "Lightweight REST / HTTP Client" || log WARN "Restfox installation failed, continuing..."
                ;;
            "jetbrains-toolbox")
                install_package_secure "JetBrains Toolbox" "jetbrains-toolbox" "snap" "JetBrains IDE manager" || log WARN "JetBrains Toolbox installation failed, continuing..."
                ;;
        esac
    done

    show_message "Completed" "Development tools installation completed!"
}