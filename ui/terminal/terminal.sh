#!/bin/bash

show_terminal_command() {
    local title="$1"
    local command="$2"
    local wait_for_key="${3:-true}"

    log DEBUG "Showing terminal command: $command"

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
}


show_live_command() {
    local title="$1"
    local command="$2"
    local temp_file="/tmp/live_command_$"

    log DEBUG "Showing live command: $command"

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

    return $exit_code
}