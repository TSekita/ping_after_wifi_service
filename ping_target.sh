#!/usr/bin/env bash
set -euo pipefail

readonly NETWORK_INTERFACE="${NETWORK_INTERFACE:-${WIFI_INTERFACE:-wlan0}}"
readonly PING_TARGET="${PING_TARGET:?PING_TARGET must be set}"
readonly PING_COUNT="${PING_COUNT:-4}"
readonly CHECK_INTERVAL_SECONDS="${CHECK_INTERVAL_SECONDS:-1}"
readonly MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-120}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

require_positive_integer() {
  local var_name="$1"
  local var_value="$2"

  if ! [[ "$var_value" =~ ^[1-9][0-9]*$ ]]; then
    log "Invalid ${var_name}: ${var_value}. It must be a positive integer."
    return 1
  fi
}

require_network_interface_exists() {
  if [[ ! -d "/sys/class/net/${NETWORK_INTERFACE}" ]]; then
    log "Network interface not found: ${NETWORK_INTERFACE}"
    return 1
  fi
}

require_command_exists() {
  local command_name="$1"

  if ! command -v "$command_name" > /dev/null 2>&1; then
    log "Required command not found: ${command_name}"
    return 1
  fi
}

is_interface_connected() {
  nmcli -t -f DEVICE,STATE d 2>/dev/null | \
    awk -F: -v iface="${NETWORK_INTERFACE}" '$1 == iface && $2 ~ /^connected/ { found=1 } END { exit found ? 0 : 1 }'
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
  require_positive_integer "PING_COUNT" "$PING_COUNT"
  require_positive_integer "CHECK_INTERVAL_SECONDS" "$CHECK_INTERVAL_SECONDS"
  require_positive_integer "MAX_WAIT_SECONDS" "$MAX_WAIT_SECONDS"
  require_command_exists "nmcli"
  require_command_exists "ping"
  require_network_interface_exists

  log "Waiting for ${NETWORK_INTERFACE} to connect"

  wait_for_condition \
    "${NETWORK_INTERFACE} connected" \
    "is_interface_connected"

  log "Running ping: target=${PING_TARGET}, count=${PING_COUNT}"

  ping -c "$PING_COUNT" "$PING_TARGET" || \
    log "Ping failed but service continues"
}

main
