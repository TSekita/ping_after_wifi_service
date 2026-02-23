# ping_after_wifi_service_stable

Waits for wlan0 to obtain an IP address and performs a single ping.

## Features

- Stable Wi-Fi detection (DHCP completion based)
- Runs only once at boot
- Prevents infinite journal logging
- Compatible with Ubuntu 22.04 / Raspberry Pi

## Install

```bash
sudo cp ping_target.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/ping_target.sh

sudo cp ping-after-wifi.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable ping-after-wifi.service
