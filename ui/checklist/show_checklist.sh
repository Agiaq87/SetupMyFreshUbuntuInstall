#!/bin/bash

show_checklist() {
    local title="$1"
    local text="$2"
    shift 2
    local items=("$@")

    local zenity_args=()
            zenity_args+=(--list --checklist --title="$title" --text="$text")
            zenity_args+=(--column="Select" --column="Software" --column="Description")
            zenity_args+=(--width=700 --height=600 --separator="|")

            # Build list for Zenity
            for item in "${items[@]}"; do
                IFS='|' read -ra PARTS <<< "$item"
                zenity_args+=(FALSE "${PARTS[0]}" "${PARTS[1]}")
            done

            zenity "${zenity_args[@]}"
}