#!/bin/bash

set -e

request_admin_privileges() {
    log INFO "Requesting admin privileges"

    # Check if we're already root (bad)
    if [[ $EUID -eq 0 ]]; then
        error_exit "Don't run this script as root. Run as regular user instead."
    fi

    # Test if user has sudo privileges
    if ! sudo -n true 2>/dev/null; then
        log INFO "No cached sudo credentials, requesting password"

        # Use zenity for password prompt
        local password
        password=$(zenity --password --title="Administrator Password Required" \
            --text="Enter your password to continue with system modifications:")

        if [ $? -ne 0 ] || [ -z "$password" ]; then
            error_exit "Administrator privileges required to continue"
        fi

        # Test the password
        if ! echo "$password" | sudo -S true 2>/dev/null; then
            error_exit "Invalid password or insufficient privileges"
        fi

        # Keep sudo session alive
        echo "$password" | sudo -S true
    else
        log INFO "Sudo credentials already cached"
    fi

    log INFO "Administrator privileges granted"
}