#!/usr/bin/env bash

INTERFACE="wlan0"
TARGET_IP="192.168.10.3"
PING_COUNT=4
SLEEP_SEC=2

log() {
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

log "Waiting for $INTERFACE to obtain IP address..."

until ip addr show "$INTERFACE" | grep -q "inet "; do
    sleep "$SLEEP_SEC"
done

IP_ADDR=$(ip -4 addr show "$INTERFACE" | awk '/inet /{print $2}')
log "$INTERFACE ready with IP $IP_ADDR"

log "Running ping to $TARGET_IP"

# ★重要：失敗してもservice成功にする
ping -c "$PING_COUNT" "$TARGET_IP" || log "Ping failed (ignored)"

log "Service finished"
exit 0
