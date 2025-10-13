#!/bin/bash

flutter_post_install() {
    log INFO "Starting Flutter post-installation steps..."

    (
        echo "20" 
        echo "# Executing flutter script..."
        flutter upgrade 

        echo "50"
        echo "# Running flutter doctor..."
        flutter doctor -v

        echo "100"
        echo "# Flutter post-installation completed."
    ) | zenity --progress --title="Flutter Post-Installation" \
                --text="Running flutter doctor..." --percentage=0 --auto-close \
                --width=400 --no-cancel
}