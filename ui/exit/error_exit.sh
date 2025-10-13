#!/bin/bash

error_exit() {
    local error_msg="$1"
    log ERROR "$error_msg"

    zenity --error --text="ERROR: $error_msg" --width=400
    exit 1
}