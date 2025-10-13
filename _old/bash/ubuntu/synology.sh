#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

DOWNLOAD_DIR="$HOME/deb_packages"
mkdir -p "$DOWNLOAD_DIR"

declare -a SYNOLGY_DEB_URLS=(
    "https://global.synologydownload.com/download/Utility/Assistant/7.0.5-50070/Ubuntu/x86_64/synology-assistant_7.0.5-50070_amd64.deb"
    "https://global.synologydownload.com/download/Utility/SynologyDriveClient/3.5.2-16111/Ubuntu/Installer/synology-drive-client-16111.x86_64.deb"
    "https://global.synologydownload.com/download/Utility/NoteStationClient/2.2.5-804/Ubuntu/x86_64/synology-note-station-client-2.2.5-804-linux-x64.deb"
    "https://global.synologydownload.com/download/Utility/Presto/2.1.2-0665/Ubuntu/x86_64/synology-presto-0665.x86_64.deb"
)

log INFO "Start download Synology packages"

for url in "${SYNOLGY_DEB_URLS[@]}"; do
    filename=$(basename "$url")
    filepath="$DOWNLOAD_DIR/$filename"

    log INFO "Download: $filename"
    silent_run_with_spinner "Download $filename" wget -q -O "$filepath" "$url"

    if [ $? -eq 0 ]; then
        log INFO "Download OK: $filename"
    else
        log ERROR "Download failed: $filename"
    fi
done

log INFO "Start install"
cd "$DOWNLOAD_DIR" || exit 1

for deb in *.deb; do
    if [ -f "$deb" ]; then
        log INFO "Install: $deb"
        [ -f "$deb" ] && silent_run_with_spinner "Install $deb" apt install -y "./$deb"
        if [ $? -eq 0 ]; then
            log INFO "Installation OK: $deb"
        else
            log ERROR "Installation failed: $deb"
        fi
    fi
done
