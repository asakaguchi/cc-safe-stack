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

設定ファイルの作成手順は以下のとおりです。

```bash
# Yahoo Finance用（株式分析の場合）
cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json

# カスタム設定の場合
cp .devcontainer/devcontainer.local.json.clean-sample .devcontainer/devcontainer.local.json
```

設定例は次のとおりです。

```json
{
  "containerEnv": {
    "SECURE_MODE": "true",
    "ADDITIONAL_ALLOWED_DOMAINS": "fc.yahoo.com,query1.finance.yahoo.com,query2.finance.yahoo.com"
  }
}
```

反映手順は次のとおりです。

VS Code で「Rebuild and Reopen in Container」を実行します。

#### 方法2: 実行時追加（一時的）

DevContainer 起動後に追加のドメインを許可します。永続化されないため、再起動のた
びに再設定が必要です。

```bash
# Yahoo Finance の場合
./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com query2.finance.yahoo.com

# 任意のドメインの場合
./scripts/allow-additional-domain.sh your-api-domain.com
```

##### allow-additional-domain.sh の使い方

1. `SECURE_MODE=true` のコンテナで実行します。セキュアモード以外では実行不要で
   す。
2. 引数に許可したいドメインを列挙します。スキームやパスが含まれていても自動で正
   規化されます。
3. スクリプトは `dig` で IP を解決し、`ipset` の `allowed-domains` セットへ追加
   します。
4. 追加後は即時反映されます。永続化したい場合は方法 1 で環境変数に設定してくださ
   い。

エラーになる場合は以下を確認してください。

- `SECURE_MODE` が `true` になっているか
- `ipset` コマンドが利用可能か（DevContainer では標準でインストール済み）
- DNS で IP が引けるか (`dig example.com +short`)
- sudo 権限が必要な場合は `sudo ./scripts/allow-additional-domain.sh ...` を使用
  する

### 設定書式

追加ドメインの指定では以下の書式が利用可能です。

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

### Google Cloud Platform の認証

セキュアモード環境で Google Cloud（gcloud）を使用する場合、ホスト側で認証を行
い、認証情報をコンテナにマウントする方式を推奨します。

#### 推奨方法: ホスト側で認証

この方式では、`gcloud auth login` をホスト側で実行し、認証情報をコンテナにマウン
トします。トークン自動更新のため書き込み可能でマウントされます（約 1 時間で失
効）ため、セキュアモードを維持したまま gcloud コマンドが使用できます。

**ホスト側で認証（初回のみ）**

次のコマンドをホストで実行します。

```bash
# ホスト側（WSL/Linux/Mac）で実行
gcloud auth login
gcloud auth application-default login
```

**Docker環境の場合**

認証情報は自動的にマウントされます。コンテナを起動するだけで使用可能です。

Linux/Mac/WSL2 の場合は以下の手順を実施します。

```bash
# コンテナ起動（認証情報は自動マウント）
pnpm run docker:dev
pnpm run docker:dev:connect

# gcloudコマンドが使用可能
gcloud auth list
gcloud projects list
```

Windows PowerShell の場合は以下を追加します。

```bash
# .env ファイルに以下を追加
GCLOUD_CONFIG_PATH=%APPDATA%/gcloud

# コンテナ起動
pnpm run docker:dev
pnpm run docker:dev:connect

# gcloudコマンドが使用可能
gcloud auth list
gcloud projects list
```

**DevContainer環境の場合**:

認証情報は自動的にマウントされます。VS Code でコンテナを開くだけで使用可能です。

```bash
# コンテナ内で確認
gcloud auth list
gcloud projects list
```

#### 仕組みの説明

**マウントされる認証情報**:

- ホスト側の `~/.config/gcloud` ディレクトリがコンテナにマウントされます
- マウントは **書き込み可能** です（トークン更新のため必須、詳細は後述）
- 認証情報には以下が含まれます:
  - アクセストークン（`access_tokens.db`）
  - 認証情報（`credentials.db`）
  - 設定ファイル（`configurations/config_default`）

**トークン更新の仕組み**

Google Cloud のアクセストークンは約 1 時間で失効します。`gcloud projects list`
などのコマンドを実行すると gcloud CLI が自動的にトークンを更新
し、`access_tokens.db` ファイルを書き換えます。このため、マウントを read-only に
すると更新が失敗します。必ず **書き込み可能** としてマウントしてください。

read-only でマウントすると次のような問題が発生します。

- トークン失効後に `gcloud` コマンドが失敗する
- `access_tokens.db` の更新ができずエラーになる
- 毎回ホスト側で `gcloud auth login` を再実行する必要がある

**セキュリティ上の利点**

- セキュアモード（SECURE_MODE=true）を維持できる
- ファイアウォール設定の変更が不要になる
- IP アドレス変更の影響を受けない（認証済みであるため）
- コンテナ再作成時も認証情報が保持される
- トークン自動更新により長時間の作業が可能になる

**Windows（WSL2）での注意事項**:

- WSL2 内で `gcloud auth login` を実行する（PowerShell / CMD での認証は不可）
- 認証情報は `${HOME}/.config/gcloud`（WSL2）または
  `${APPDATA}/gcloud`（Windows）に保存され、自動でマウントされる

```bash
# WSL2内で実行
wsl
gcloud auth login
gcloud auth application-default login
```

**Windows PowerShell で認証する場合**:

PowerShell で `gcloud auth login` を実行した場合、資格情報は `%APPDATA%\gcloud`
に保存されます。この場合は、`.devcontainer/devcontainer.local.json` を作成して
`APPDATA` 環境変数を使用してマウントします。

```bash
# PowerShellで認証
gcloud auth login
gcloud auth application-default login

# テンプレートをコピー
cp .devcontainer/devcontainer.local.jsonc.gcloud-powershell .devcontainer/devcontainer.local.json

# VS Codeで DevContainer を再ビルド
# Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

注意：WSL2 で認証した場合は、このテンプレートは不要です。`devcontainer.json` の
デフォルト設定（`HOME` 環境変数）がそのまま使用できます。

### 株式分析（Yahoo Finance）

株式分析プラットフォーム等で外部 API（Yahoo Finance など）を使用する場合の設定例
です。

```json
{
  "containerEnv": {
    "SECURE_MODE": "true",
    "ADDITIONAL_ALLOWED_DOMAINS": "fc.yahoo.com,query1.finance.yahoo.com,query2.finance.yahoo.com"
  }
}
```

### その他の外部API

企業プライベートレジストリの場合は次のとおりです。

```json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "npm.company.com,pypi.company.com"
  }
}
```

CDN サービスの場合は次のとおりです。

```json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "cdn.jsdelivr.net,unpkg.com,dl.google.com"
  }
}
```

## 設定ファイルの管理

### 利用可能な設定ファイル

`.devcontainer/` フォルダ内の設定ファイルを以下に示します。

- `devcontainer.json`: メインの設定（リポジトリにコミット済み）
- `devcontainer.local.json`: **ユーザー固有の設定（.gitignore に含まれる）**
- `.json.clean-*` ファイル: 標準 JSON 形式のテンプレート（推奨）
- `.jsonc.*` ファイル: コメント付き JSONC 形式のテンプレート（参考用）

### テンプレートファイル

Yahoo Finance 用設定の例です。

```bash
cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json
```

サンプル設定の例です。

```bash
cp .devcontainer/devcontainer.local.json.clean-sample .devcontainer/devcontainer.local.json
```

## トラブルシューティング

### よくある問題と解決方法

#### 外部API接続エラー

症状：Yahoo Finance 等の外部 API に接続できない。

原因：セキュアモードでドメインが許可されていない。

解決策：次の手順を順に実施します。

1. **設定確認**

   ```bash
   # 現在の環境変数を確認
   echo $ADDITIONAL_ALLOWED_DOMAINS

   # 許可されているIPを確認
   sudo ipset list allowed-domains | grep -E "(yahoo|finance)"
   ```

2. **即座に修正する**

   ```bash
   # 必要なドメインを追加
   ./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com
   ```

3. **恒久的な修正を実施する**

   ```bash
   # 設定ファイルを作成
   cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json
   # VS Code で DevContainer を再ビルド
   ```

#### DevContainer 設定が反映されない

症状：`devcontainer.local.json` を作成したが環境変数が設定されない。

原因：DevContainer の再ビルドまたは再起動が必要。

解決策：以下のいずれかを実行します。

- VS Code: `Ctrl+Shift+P` → `Dev Containers: Rebuild Container`
- または、設定後に `./scripts/allow-additional-domain.sh` を使用

#### 権限エラー

症状：`ipset` コマンドで権限エラーが発生する。

解決策：以下の手順を実行します。

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
| `pnpm install` 外部失敗        | NPM以外レジストリ使用    | 使用レジストリを許可リスト追加    |
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
