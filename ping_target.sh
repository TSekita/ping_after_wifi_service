#!/bin/bash

INTERFACE="wlan0"
TARGET="192.168.10.3"

echo "Waiting for $INTERFACE IP..."

until ip addr show "$INTERFACE" | grep -q "inet "; do
    sleep 2
done

echo "$INTERFACE ready"

ping -c 4 "$TARGET"

echo "Done"
exit 0
