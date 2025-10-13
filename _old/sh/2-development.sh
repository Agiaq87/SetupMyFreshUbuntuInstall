#!/bin/bash
development_tools() {
    log "Opening development tools menu..."
    debug "Entering development_tools function"

    local dev_items=(
        "arduino|Arduino|IoT board development"
        "beekeeper-studio|Beekeper Studio|AN easy to use SQL editor and DB Manager for PSQL, MySQL & more"
        "bruno|Bruno|Opensource API Client for Exploring and Testing APIs"
        "dbeaver|DBeaver CE|Mysql inspector"
        "fiddler|Fiddler|Fiddler Everywhere for checking and debugging HTTP request"
        "flutter|Flutter|Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase"
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

    local choices
    choices=$(show_checklist "Development Tools" "Select tools to install:" "${dev_items[@]}")

    if [ $? -ne 0 ] || [ -z "$choices" ]; then
        debug "Development tools selection cancelled"
        return
    fi

    debug "Processing development tool choices: $choices"

    for choice in $choices; do
        choice=$(echo "$choice" | tr -d '"')
        debug "Processing dev tool: $choice"
        case $choice in
            "arduino")
                install_package_secure "Arduino" "arduino-*" "nala" "Iot development"
                ;;
            "beekeper-studio")
                install_package_secure "Beekeper Studio" "beekeeper-studio" "snap" "Psql, MySQL and other DB development"
                ;;
            "bruno")
                install_package_secure "Bruno" "bruno" "snap" "Opensource API Client for Exploring and Testing APIs"
                ;;
            "dbeaver")
                install_package_secure "DBeaver CE" "dbeaver-ce" "snap" "Mysql inspector"
                ;;
            "fiddler")
                echo "Not implemented yet"
                ;;
            "flutter")
                install_package_secure "Flutter" "flutter --classic" "snap" "Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase"
                flutter
                show_live_command "Flutter Configuration" "flutter config"
                show_live_command "Flutter Doctor" "flutter doctor -v"
                ;;
            "git")
                install_package_secure "Git" "git" "nala" "Version control system"
                ;;
            "go")
                install_package_secure "Go" "go --classic" "snap" "The Go programming language"
                install_package_secure "Gosec" "gosec" "snap" "Inspects source code for security problems by scanning the Go AST"
                show_live_command "Go version" "go version"
                ;;
            "insomnia")
                install_package_secure "Insomnia" "insomnia" "snap" "The Collaborative API Design Tool"
                ;;
            "vscode")
                add_repository "Visual Studio Code" \
                    "https://packages.microsoft.com/keys/microsoft.asc" \
                    "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                    "/etc/apt/sources.list.d/vscode.list"
                install_package_secure "Visual Studio Code" "code" "nala" "Advanced code editor"
                ;;
            "netbeans")
                install_package_secure "Netbeans" "netbeans --classic" "snap" "Apache NetBeans IDE for Java, Jakarta EE and Web applications"
                ;;
            "nodejs")
                install_package_secure "Node.js" "nodejs npm" "nala" "JavaScript runtime and package manager"
                ;;
            "pgAdmin")
                install_package_secure "pgAdmin" "pgadmin4" "snap" "Management tool for the PostgreSQL database"
                ;;
            "python-dev")
                install_package_secure "Python Dev Tools" "python3-pip python3-venv python3-dev build-essential" "nala" "Python development tools"
                ;;
            "postman")
                install_package_secure "Postman" "postman" "snap" "REST and GraphQL API testing"
                ;;
            "restfox")
                install_package_secure "Restfox" "restfox" "snap" "A lightweight REST / HTTP Client based on Insomnia and Postman"
                ;;
            "jetbrains-toolbox")
                jetbrainsToolbox
                ;;
        esac
    done

    show_message "Completed" "Development tools installation completed!"
    debug "Development tools menu completed"
}