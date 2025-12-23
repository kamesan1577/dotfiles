# かんきょう

- Ubuntu 22.04
- zsh

# つかいかた

くろーんしてzsh install.shをじっこう

# CloudflareでDDNSを設定する方法

このリポジトリには Cloudflare DNS を使った DDNS 更新スクリプトが含まれています。
API トークンなどの秘密情報は git 管理しません。

## 必要なコマンド

```bash
sudo apt update
sudo apt install -y curl jq
```

## 1. Cloudflare 側の準備

### API Token を作成

- 権限：Zone → DNS → Edit
- 対象ゾーンのみ指定

### Zone ID を控える

1. Cloudflare ダッシュボードにアクセス
2. 対象ドメイン → Overview
3. 右側に表示される Zone ID を控える

## 2. 秘密情報を設定（git管理しない）

```bash
mkdir -p ~/.env_list
nano ~/.env_list/cf-ddns.secrets
```

以下の内容を記述：

```
CF_API_TOKEN="xxxxxxxxxxxxxxxx"
CF_ZONE_ID="yyyyyyyyyyyyyyyy"
```

```bash
chmod 600 ~/.env_list/cf-ddns.secrets
```

## 3. 更新するドメインを設定（git管理）

`conf/domains.conf` を編集：

```
CF_RECORD_NAMES=(
  "example.com"
  "n8n.example.com"
)

CF_RECORD_TYPE="A"
CF_PROXIED=true
```

## 4. 実行（動作確認）

```bash
~/dotfiles/bin/cf-ddns.sh
```

Cloudflare DNS 管理画面で IP が更新されていれば成功です。

## 5. 定期実行（cron）

```bash
crontab -e
```

以下の行を追加：

```
*/5 * * * * $HOME/dotfiles/bin/cf-ddns.sh >/dev/null 2>&1
```

## 方針

- ドメイン名：git 管理してOK
- API Token / Zone ID：絶対に git 管理しない
- スクリプト：dotfiles/bin に配置
