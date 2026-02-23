# ping_after_wifi_service

Ubuntu Desktop / Raspberry Pi で「起動後にネットワーク接続完了を待ってから ping を実行」するための `systemd` サービスです。

## 構成

- `ping_target.sh`
  - 指定インターフェースが `connected` になるまで待機
  - タイムアウト付きで `ping` を実行
  - 起動時に依存コマンド (`nmcli`, `ping`) と監視インターフェースの存在を検証し、誤設定時は単発ログで終了
- `ping-after-wifi.env`
  - 監視インターフェースや ping 先 IP を定義する設定ファイル
- `ping-after-wifi.service`
  - 起動時に上記スクリプトを `oneshot` 実行
  - `/etc/default/ping-after-wifi` から環境変数を読み込み

## インストール手順

1. スクリプト配置

```bash
sudo install -m 755 ping_target.sh /usr/local/bin/ping_target.sh
```

2. 設定ファイル配置 (ping 先 IP はここだけ編集)

```bash
sudo install -m 644 ping-after-wifi.env /etc/default/ping-after-wifi
```

3. サービス配置

```bash
sudo install -m 644 ping-after-wifi.service /etc/systemd/system/ping-after-wifi.service
```

4. systemd へ反映・有効化

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

`/etc/default/ping-after-wifi` の値を変更します（`PING_TARGET` の編集箇所はここだけです）。

- `NETWORK_INTERFACE` : 監視する NIC (例: `wlan0`)
- `PING_TARGET` : ping 先 IP/ホスト
- `PING_COUNT` : ping 回数
- `MAX_WAIT_SECONDS` : 接続待機タイムアウト秒数

変更後は以下を実行:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ping-after-wifi.service
```
