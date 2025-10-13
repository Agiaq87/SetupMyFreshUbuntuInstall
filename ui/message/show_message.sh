show_message() {
    local title="$1"
    local message="$2"
    local width="${3:-400}"

    log INFO "Showing message: $title"

    zenity --info --title="$title" --text="$message" --width="$width" 
}