#!/bin/bash

set -e


# Progress bar
show_progress() {
    local title="$1"
    local text="$2"

    log INFO "Showing progress bar: $title"

    zenity --progress --title="$title" --text="$text" --percentage=0 --auto-close --no-cancel
}

