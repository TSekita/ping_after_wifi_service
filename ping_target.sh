#!/usr/bin/env bash
set -u

WIFI_INTERFACE="${WIFI_INTERFACE:-wlan0}"
TARGET_IP="${TARGET_IP:-192.168.10.3}"
PING_COUNT="${PING_COUNT:-4}"
TIMEOUT_SEC="${TIMEOUT_SEC:-60}"

log() {
    echo "[ping-after-wifi] $*"
}

log "Waiting up to ${TIMEOUT_SEC}s for ${WIFI_INTERFACE} connection..."

elapsed=0

while true; do
    state=$(nmcli -t -f DEVICE,STATE device status \
        | grep "^${WIFI_INTERFACE}:" \
        | cut -d: -f2)

    if [[ "$state" == "接続済み" || "$state" == "connected" ]]; then
        log "${WIFI_INTERFACE} connected"
        break
    fi

    if (( elapsed >= TIMEOUT_SEC )); then
        log "Timeout waiting for ${WIFI_INTERFACE}"
        exit 0
    fi

    sleep 1
    ((elapsed++))
done

log "Pinging ${TARGET_IP} (${PING_COUNT} times)"

if ping -c "${PING_COUNT}" "${TARGET_IP}"; then
    log "Ping success"
else
    log "Ping failed (ignored)"
fi

exit 0
