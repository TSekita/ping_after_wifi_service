#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_NETWORK_INTERFACE="wlan0"
readonly DEFAULT_PING_TARGET="192.168.10.3"
readonly DEFAULT_PING_COUNT="4"
readonly DEFAULT_MAX_WAIT_SECONDS="60"
readonly POLL_INTERVAL_SECONDS="2"

NETWORK_INTERFACE="${NETWORK_INTERFACE:-${INTERFACE:-$DEFAULT_NETWORK_INTERFACE}}"
PING_TARGET="${PING_TARGET:-${TARGET:-$DEFAULT_PING_TARGET}}"
PING_COUNT="${PING_COUNT:-$DEFAULT_PING_COUNT}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-$DEFAULT_MAX_WAIT_SECONDS}"

log() {
    echo "[ping-after-wifi] $*"
}

require_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        log "ERROR: command '$command_name' is not available"
        exit 1
    fi
}

validate_interface() {
    if ! nmcli -g DEVICE device status | grep -Fxq "$NETWORK_INTERFACE"; then
        log "ERROR: network interface '$NETWORK_INTERFACE' is not managed by NetworkManager"
        exit 1
    fi
}

wait_for_connected() {
    local elapsed_seconds=0

    log "Waiting up to ${MAX_WAIT_SECONDS}s for '$NETWORK_INTERFACE' to become connected"

    while (( elapsed_seconds < MAX_WAIT_SECONDS )); do
        if [[ "$(nmcli -t -f GENERAL.STATE device show "$NETWORK_INTERFACE" 2>/dev/null || true)" == "GENERAL.STATE:100 (connected)" ]]; then
            log "Interface '$NETWORK_INTERFACE' is connected"
            return 0
        fi

        sleep "$POLL_INTERVAL_SECONDS"
        ((elapsed_seconds += POLL_INTERVAL_SECONDS))
    done

    log "ERROR: timeout waiting for '$NETWORK_INTERFACE' to connect"
    return 1
}

run_ping() {
    log "Pinging '$PING_TARGET' with count=$PING_COUNT"
    ping -c "$PING_COUNT" "$PING_TARGET"
}

main() {
    require_command nmcli
    require_command ping
    validate_interface
    wait_for_connected
    run_ping
    log "Completed"
}

main "$@"
