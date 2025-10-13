#!/bin/bash

show_notification() {
    local title="$1"
    local message="$2"

    log INFO "Showing notification: $title - $message"

    zenity --notification --text="$title: $message"
}