#!/bin/bash

while ! nmcli -t -f WIFI g | grep -q enabled; do
	sleep 1
done

while ! nmcli -t -f DEVICE,STATE d | grep -q "wlan0:connected"; do
	sleep 1
done

ping -c 4 192.168.10.10
