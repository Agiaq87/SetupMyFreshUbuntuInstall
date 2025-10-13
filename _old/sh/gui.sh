#!/bin/bash
### UNIVERSAL INTERFACE FUNCTIONS ###
# Information messages
show_message() {
    local title="$1"
    local message="$2"
    local width="${3:-400}"

    debug "Showing message: $title"

    case $GUI_ENGINE in
        "zenity")
            zenity --info --title="$title" --text="$message" --width="$width"
            ;;
        "yad")
            yad --info --title="$title" --text="$message" --width="$width" --center
            ;;
        *)
            whiptail --title "$title" --msgbox "$message" 12 70
            ;;
    esac
}

# Yes/No questions
ask_yesno() {
    local title="$1"
    local question="$2"
    local width="${3:-400}"

    debug "Asking yes/no: $title"

    case $GUI_ENGINE in
        "zenity")
            zenity --question --title="$title" --text="$question" --width="$width"
            ;;
        "yad")
            yad --question --title="$title" --text="$question" --width="$width" --center
            ;;
        *)
            whiptail --title "$title" --yesno "$question" 10 60
            ;;
    esac
}

# Progress bar
show_progress() {
    local title="$1"
    local text="$2"

    debug "Showing progress bar: $title"

    case $GUI_ENGINE in
        "zenity")
            zenity --progress --title="$title" --text="$text" --percentage=0 --auto-close
            ;;
        "yad")
            yad --progress --title="$title" --text="$text" --percentage=0 --auto-close --center
            ;;
        *)
            # For whiptail we use gauge
            whiptail --title "$title" --gauge "$text" 8 60 0
            ;;
    esac
}

# Show command output in GUI window
show_command_output() {
    local title="$1"
    local command="$2"
    local temp_file="/tmp/command_output_$"

    debug "Showing command output: $command"

    # Execute command and capture output
    if eval "$command" > "$temp_file" 2>&1; then
        local exit_code=0
    else
        local exit_code=$?
    fi

    local output=$(cat "$temp_file")
    rm -f "$temp_file"

    case $GUI_ENGINE in
        "zenity")
            if [ $exit_code -eq 0 ]; then
                zenity --info --title="$title" --text="$output" --width=600 --height=400
            else
                zenity --error --title="$title - Error" --text="Command failed with exit code $exit_code:\n\n$output" --width=600 --height=400
            fi
            ;;
        "yad")
            if [ $exit_code -eq 0 ]; then
                echo "$output" | yad --text-info --title="$title" --width=700 --height=500 --center --button="OK:0"
            else
                echo "$output" | yad --text-info --title="$title - Error" --width=700 --height=500 --center --button="OK:0"
            fi
            ;;
        *)
            # For TUI, use whiptail scrollbox
            if [ $exit_code -eq 0 ]; then
                whiptail --title "$title" --scrolltext --msgbox "$output" 20 80
            else
                whiptail --title "$title - Error" --scrolltext --msgbox "Command failed with exit code $exit_code:\n\n$output" 20 80
            fi
            ;;
    esac

    return $exit_code
}

# Show live command output with progress
show_live_command() {
    local title="$1"
    local command="$2"
    local temp_file="/tmp/live_command_$"

    debug "Showing live command: $command"

    case $GUI_ENGINE in
        "zenity")
            # Use zenity progress with pulsate for live output
            (
                eval "$command" 2>&1 | tee "$temp_file"
                echo "100"
            ) | zenity --progress --title="$title" --text="Executing command..." --pulsate --auto-close --width=400

            local exit_code=${PIPESTATUS[0]}

            # Show final output
            if [ -f "$temp_file" ]; then
                local output=$(cat "$temp_file")
                if [ $exit_code -eq 0 ]; then
                    zenity --info --title="$title - Completed" --text="$output" --width=600 --height=400
                else
                    zenity --error --title="$title - Failed" --text="Command failed:\n\n$output" --width=600 --height=400
                fi
                rm -f "$temp_file"
            fi
            ;;
        "yad")
            # Use yad with progress and final text output
            (
                eval "$command" 2>&1 | tee "$temp_file"
                echo "100"
            ) | yad --progress --title="$title" --text="Executing command..." --pulsate --auto-close --center --width=400

            local exit_code=${PIPESTATUS[0]}

            # Show final output in text window
            if [ -f "$temp_file" ]; then
                if [ $exit_code -eq 0 ]; then
                    cat "$temp_file" | yad --text-info --title="$title - Completed" --width=700 --height=500 --center --button="OK:0"
                else
                    cat "$temp_file" | yad --text-info --title="$title - Failed" --width=700 --height=500 --center --button="OK:0"
                fi
                rm -f "$temp_file"
            fi
            ;;
        *)
            # For TUI, just run and show final output
            eval "$command" 2>&1 | tee "$temp_file"
            local exit_code=${PIPESTATUS[0]}

            if [ -f "$temp_file" ]; then
                local output=$(cat "$temp_file")
                if [ $exit_code -eq 0 ]; then
                    whiptail --title "$title - Completed" --scrolltext --msgbox "$output" 20 80
                else
                    whiptail --title "$title - Failed" --scrolltext --msgbox "Command failed:\n\n$output" 20 80
                fi
                rm -f "$temp_file"
            fi
            ;;
    esac

    return $exit_code
}

# Terminal window launcher for complex commands
show_terminal_command() {
    local title="$1"
    local command="$2"
    local wait_for_key="${3:-true}"

    debug "Showing terminal command: $command"

    case $GUI_ENGINE in
        "zenity"|"yad")
            # Create a wrapper script that shows the command output
            local wrapper_script="/tmp/terminal_wrapper_$.sh"
            cat > "$wrapper_script" << EOF
#!/bin/bash
echo "=== $title ==="
echo "Command: $command"
echo "=================="
echo
$command
exit_code=\$?
echo
echo "=================="
if [ \$exit_code -eq 0 ]; then
    echo "Command completed successfully (exit code: \$exit_code)"
else
    echo "Command failed with exit code: \$exit_code"
fi
if [ "$wait_for_key" = "true" ]; then
    echo
    read -p "Press Enter to continue..." dummy
fi
EOF
            chmod +x "$wrapper_script"

            # Launch in terminal
            if command -v gnome-terminal &> /dev/null; then
                gnome-terminal --title="$title" -- bash "$wrapper_script"
            elif command -v xterm &> /dev/null; then
                xterm -title "$title" -e bash "$wrapper_script"
            elif command -v konsole &> /dev/null; then
                konsole --title "$title" -e bash "$wrapper_script"
            else
                # Fallback to text info dialog
                show_command_output "$title" "$command"
            fi

            # Clean up wrapper script after a delay
            (sleep 10 && rm -f "$wrapper_script") &
            ;;
        *)
            # For TUI, just execute and show output
            show_command_output "$title" "$command"
            ;;
    esac
}

# Notifications
show_notification() {
    local title="$1"
    local message="$2"

    debug "Showing notification: $title - $message"

    case $GUI_ENGINE in
        "zenity")
            zenity --notification --text="$title: $message"
            ;;
        "yad")
            yad --notification --text="$title: $message"
            ;;
        *)
            # For TUI show only in log
            log "NOTIFICATION: $title - $message"
            ;;
    esac
}