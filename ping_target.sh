#!/usr/bin/env bash
set -euo pipefail

readonly NETWORK_INTERFACE="${NETWORK_INTERFACE:-${WIFI_INTERFACE:-wlan0}}"
readonly PING_TARGET="${PING_TARGET:-192.168.10.10}"
readonly PING_COUNT="${PING_COUNT:-4}"
readonly CHECK_INTERVAL_SECONDS="${CHECK_INTERVAL_SECONDS:-1}"
readonly MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-120}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

wait_for_condition() {
  local description="$1"
  local condition_command="$2"
  local elapsed=0

  while ! eval "$condition_command"; do
    if (( elapsed >= MAX_WAIT_SECONDS )); then
      log "Timeout while waiting for: ${description}"
      return 1
    fi

    sleep "$CHECK_INTERVAL_SECONDS"
    elapsed=$((elapsed + CHECK_INTERVAL_SECONDS))
  done

  log "Detected: ${description}"
}

main() {
  log "Waiting for ${NETWORK_INTERFACE} to connect"
  wait_for_condition \
    "${NETWORK_INTERFACE} connected" \
    "nmcli -t -f DEVICE,STATE d | grep -qx '${NETWORK_INTERFACE}:connected'"

  log "Running ping: target=${PING_TARGET}, count=${PING_COUNT}"
  ping -c "$PING_COUNT" "$PING_TARGET"
}

main "$@"
