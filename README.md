# ping_after_wifi_service

## 目的：

「Ubuntu Desktopが起動→Wi-Fiが接続完了→pingを自動で打つ」これを達成する現実的な方法はsystemdサービスを作ること。

## 方法：systemdのWi-Fi接続後フックでpingを自動実行する

systemdは「ネットワーク接続完了後にコマンド実行」が可能。以下の手順をRaspberry Pi側で行う。

## 手順（確実に動く方法）

１．pingスクリプトを作成

例：/usr/local/bin/ping_target.sh

```bash
#!/bin/bash

# Wi-Fi (wlan0) が有効になるまで待機
while ! nmcli -t -f WIFI g | grep -q enabled; do
    sleep 1
done

# 接続されるまで待機
while ! nmcli -t -f DEVICE,STATE d | grep -q "wlan0:connected"; do
    sleep 1
done

# ping 実行
ping -c 4 192.168.xxx.xxx
```

### 保存したら実行権限：

```bash
sudo chmod +x /usr/local/bin/ping_target.sh
```

２．systemdサービスファイルを作る

/etc/systemd/system/ping-after-wifi.service

```ini
[Unit]
Description=Ping target after Wi-Fi is connected
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ping_target.sh

[Install]
WantedBy=multi-user.target
```

３．サービスを有効化

```pgsql
sudo systemctl daemon-reload
sudo systemctl enable ping-after-wifi.service
```

### テスト起動：

```powershell
sudo systemctl start ping-after-wifi.service
```

### ログ確認：

```powershell
journalctl -u ping-after-wifi.service -f
```

## これでできること

・起動してWi-Fiが接続されると→自動で192.168.xxx.xxxにpingを送る
・cloud-init不要
・Ubuntu Desktopでも確実に動く
