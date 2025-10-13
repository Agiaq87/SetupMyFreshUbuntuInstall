#!/bin/bash
check_sudo() {
    log INFO "Checking sudo configuration"

    # Check if user is in sudo group
    if ! groups | grep -q sudo; then
        error_exit "User $USER is not in the sudo group. Please add user to sudo group first."
    fi

    log INFO "User is in sudo group"
}

# Function to keep sudo session alive during long operations
maintain_sudo() {
    log INFO "Maintaining sudo session"

    # Reset sudo timestamp
    sudo -v

    # Start background process to keep sudo alive
    (
        while true; do
            sleep 240  # Every 4 minutes
            sudo -v
        done
    ) &

    local sudo_keeper_pid=$!
    log INFO "Sudo keeper process started: $sudo_keeper_pid"

    # Store PID to kill it later if needed
    echo $sudo_keeper_pid > /tmp/ubuntu_setup_sudo_keeper.pid
}


check_internet() {
    log INFO "Checking internet connectivity..."
    if ! ping -c 1 google.com &> /dev/null; then
        error_exit "Internet connection not available"
    fi
    log INFO "Internet connectivity verified"
}

check_ubuntu() {
    log INFO "Checking Ubuntu version..."
    if ! command -v lsb_release &> /dev/null; then
        log WARN "lsb_release not found, skipping Ubuntu version check"
        return
    fi

    local ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "unknown")
    log INFO "Detected Ubuntu version: $ubuntu_version"
    log INFO "Ubuntu version check completed"
}
