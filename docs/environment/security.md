# セキュリティ設定ガイド

このガイドでは、セキュア開発環境におけるネットワーク制限とファイアウォール設定に
ついて詳しく説明します。

## セキュアモードの概要

セキュアモードは Claude Code による誤った破壊的操作（`rm -rf *`等）からホストマ
シンを保護する機能です。

### 主な特徴

- ネットワーク制限: 許可されたドメインのみアクセス可能
- ファイアウォール: DevContainer と同等の iptables 設定
- 隔離環境: ホストファイルシステムへの破壊的操作を防止
- 追加ドメイン許可: 環境変数で柔軟に設定可能

## セキュアモードの有効化

### DevContainer環境

```jsonc
// .devcontainer/devcontainer.json（デフォルトで有効）
{
  "containerEnv": {
    "SECURE_MODE": "true" // デフォルト設定
  }
}
```

### Docker環境

```bash
# セキュア開発環境の起動
docker compose --profile dev up -d dev
```

## 許可ドメインの管理

### デフォルト許可ドメイン

初期設定で以下のドメインが許可されています。

- GitHub: `github.com`, `api.github.com`, `raw.githubusercontent.com`
- パッケージレジストリ: `registry.npmjs.org`, `pypi.org`,
  `files.pythonhosted.org`
- Anthropic サービス: `api.anthropic.com`, `sentry.io`
- 統計・分析: `statsig.anthropic.com`, `statsig.com`

### 追加ドメインの許可方法

#### 方法1: 環境変数設定（推奨）

設定ファイルの作成:

```bash
# Yahoo Finance用（株式分析の場合）
cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json

# カスタム設定の場合
cp .devcontainer/devcontainer.local.json.clean-sample .devcontainer/devcontainer.local.json
```

設定例:

```json
{
  "containerEnv": {
    "SECURE_MODE": "true",
    "ADDITIONAL_ALLOWED_DOMAINS": "fc.yahoo.com,query1.finance.yahoo.com,query2.finance.yahoo.com"
  }
}
```

反映手順:

VS Code で「Rebuild and Reopen in Container」を実行。

#### 方法2: 実行時追加（一時的）

DevContainer 起動後に追加のドメインを許可。

```bash
# Yahoo Finance の場合
./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com query2.finance.yahoo.com

# 任意のドメインの場合
./scripts/allow-additional-domain.sh your-api-domain.com
```

注意: 方法 2 は一時的な解決策です。恒久的な設定には方法 1 を推奨します。

### 設定書式

追加ドメインの指定では以下の書式が利用可能。

- 区切り文字: カンマ`,`、セミコロン`;`、スペースのいずれも可
- スキーム付き URL: `https://cdn.company.com/packages` など
- CIDR 記法: `192.0.2.0/24` などの IP アドレス範囲

```json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "npm.company.com,https://pypi.company.com/simple/,192.168.1.0/24"
  }
}
```

## 外部API利用時の設定

### 株式分析（Yahoo Finance）

株式分析プラットフォーム等で外部 API（Yahoo Finance など）を使用する場合の設定
例。

```json
{
  "containerEnv": {
    "SECURE_MODE": "true",
    "ADDITIONAL_ALLOWED_DOMAINS": "fc.yahoo.com,query1.finance.yahoo.com,query2.finance.yahoo.com"
  }
}
```

### その他の外部API

企業プライベートレジストリ:

```json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "npm.company.com,pypi.company.com"
  }
}
```

CDN サービス:

```json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "cdn.jsdelivr.net,unpkg.com,dl.google.com"
  }
}
```

## 設定ファイルの管理

### 利用可能な設定ファイル

`.devcontainer/` フォルダ内の設定ファイル。

- `devcontainer.json`: メインの設定（リポジトリにコミット済み）
- `devcontainer.local.json`: **ユーザー固有の設定（.gitignore に含まれる）**
- `.json.clean-*` ファイル: 標準 JSON 形式のテンプレート（推奨）
- `.jsonc.*` ファイル: コメント付き JSONC 形式のテンプレート（参考用）

### テンプレートファイル

Yahoo Finance 用設定:

```bash
cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json
```

サンプル設定:

```bash
cp .devcontainer/devcontainer.local.json.clean-sample .devcontainer/devcontainer.local.json
```

## トラブルシューティング

### よくある問題と解決方法

#### 外部API接続エラー

症状: Yahoo Finance 等の外部 API に接続できない。

原因: セキュアモードでドメインが許可されていない。

解決策:

1. **設定確認**

   ```bash
   # 現在の環境変数を確認
   echo $ADDITIONAL_ALLOWED_DOMAINS

   # 許可されているIPを確認
   sudo ipset list allowed-domains | grep -E "(yahoo|finance)"
   ```

2. **即座に修正**

   ```bash
   # 必要なドメインを追加
   ./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com
   ```

3. **恒久的な修正**

   ```bash
   # 設定ファイルを作成
   cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json
   # VS Code で DevContainer を再ビルド
   ```

#### DevContainer 設定が反映されない

症状: `devcontainer.local.json` を作成したが環境変数が設定されない。

原因: DevContainer の再ビルドまたは再起動が必要。

解決策:

- VS Code: `Ctrl+Shift+P` → `Dev Containers: Rebuild Container`
- または、設定後に `./scripts/allow-additional-domain.sh` を使用

#### 権限エラー

症状: `ipset` コマンドで権限エラー。

解決策:

```bash
# スクリプト経由で実行（推奨）
./scripts/allow-additional-domain.sh your-domain.com

# 手動実行の場合は sudo を使用
sudo ipset add allowed-domains 1.2.3.4
```

### 詳細なデバッグ手順

#### 1. ネットワーク接続の確認

```bash
# 許可外サイトには到達不可（正常な状態）
curl -I https://example.com || true

# GitHub API は到達可能（正常な状態）
curl -s https://api.github.com/zen

# 名前解決の確認
dig example.com +short
```

#### 2. ファイアウォールルールの確認

```bash
# 許可ドメインリストの確認
sudo ipset list allowed-domains | head

# iptables ルールの確認
sudo iptables -S OUTPUT | head

# 特定ドメインの登録確認
sudo ipset list allowed-domains | grep yahoo
```

#### 3. ファイアウォールルールの再適用

```bash
# セキュアコンテナ内で実行（sudo 必須）
sudo .devcontainer/secure/init-firewall.sh
```

### 代表的な症状と対処

| 症状                           | 原因                     | 対処法                            |
| ------------------------------ | ------------------------ | --------------------------------- |
| `uv sync` 企業接続失敗         | 企業レジストリ未許可     | `ADDITIONAL_ALLOWED_DOMAINS` 追加 |
| `bun install` 外部失敗         | NPM以外レジストリ使用    | 使用レジストリを許可リスト追加    |
| `curl` `icmp-admin-prohibited` | ファイアウォール通信遮断 | 対象ドメインを許可リスト追加      |
| API呼出 `Connection timed out` | 外部API ドメイン未許可   | API ドメインを許可リスト追加      |

## セキュリティベストプラクティス

### 最小権限の原則

- 必要最小限のドメインのみ許可
- ワイルドカード（`*.example.com`）の使用は避ける
- 定期的な許可リストの見直し

### 設定の管理

- `devcontainer.local.json` は個人用設定（Git 管理外）
- チーム共通設定は `devcontainer.json` で管理
- 機密情報を含む設定は環境変数で分離

### 監査とログ

```bash
# 接続ログの確認
sudo iptables -L OUTPUT -v

# 拒否されたパケットの確認
sudo dmesg | grep -i "drop\|reject"
```

## 関連ドキュメント

- [DevContainer 完全ガイド](devcontainer.md)
- [Docker環境](docker.md)
- [MCPサーバー統合](mcp-servers.md)
