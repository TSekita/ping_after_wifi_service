# ping_after_wifi_service

Ubuntu Desktop / Raspberry Pi で「起動後に Wi-Fi 接続完了を待ってから ping を実行」するための `systemd` サービスです。

## 構成

- `ping_target.sh`
  - Wi-Fi が有効化されるまで待機
  - 指定インターフェースが `connected` になるまで待機
  - タイムアウト付きで `ping` を実行
- `ping-after-wifi.service`
  - 起動時に上記スクリプトを `oneshot` 実行
  - 環境変数でターゲットや待機時間を指定

## インストール手順

1. スクリプト配置

```bash
sudo install -m 755 ping_target.sh /usr/local/bin/ping_target.sh
```

2. サービス配置

```bash
sudo install -m 644 ping-after-wifi.service /etc/systemd/system/ping-after-wifi.service
```

3. systemd へ反映・有効化

```bash
sudo systemctl daemon-reload
sudo systemctl enable ping-after-wifi.service
```

## 動作確認

```bash
sudo systemctl start ping-after-wifi.service
journalctl -u ping-after-wifi.service -f
```

## カスタマイズ

`/etc/systemd/system/ping-after-wifi.service` の `Environment=` を変更します。

- `WIFI_INTERFACE` : 監視する NIC (例: `wlan0`)
- `PING_TARGET` : ping 先 IP/ホスト
- `PING_COUNT` : ping 回数
- `MAX_WAIT_SECONDS` : 接続待機タイムアウト秒数

変更後は以下を実行:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ping-after-wifi.service
```
