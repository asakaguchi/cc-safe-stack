# VS Code DevContainer セキュア開発環境ガイド

このガイドでは、Claude Code を安全に実行するための VS Code DevContainer 環境につ
いて説明します。

## 目的

Claude Code の破壊的操作（`rm -rf *`等）からホスト環境を保護し、セキュアな開発環
境を提供します。

## 概要

プロジェクトでは統一された設計の 2 つの devcontainer 設定を提供しています。

- セキュア開発環境（デフォルト・推奨）: SECURE_MODE=true
- 標準開発環境（オプション）: SECURE_MODE=false

### 共通基盤

両環境は次のような共通のベース環境を使用しています。

- ユーザー名: `vscode`
- ベース OS: Ubuntu 24.04
- Python 環境: `/home/vscode/.venv`
- 開発ツール: uv、git、GitHub CLI、ZSH、ripgrep 等
- フルスタック対応: Python + Node.js + TypeScript 完全対応
- Claude Code CLI: プリインストール済み

## 環境の選択

VS Code でプロジェクトを開いた際に表示される選択ダイアログ。

```text
Reopen in Container →
  • Python & TypeScript Development Environment    ← 推奨（デフォルト）
  • Secure Python & TypeScript Development Environment
```

## セキュア開発環境（デフォルト・推奨）

Claude Code を安全に実行するための推奨環境です。デフォルトで SECURE_MODE=true が
有効になっています。

### 利用方法

#### 1. デフォルト設定（推奨）

```bash
# VS Codeでプロジェクトを開く
code .
# 「コンテナーで再度開く」コマンドを使用
# 自動でセキュアモードが有効になります
```

- ルートの `.devcontainer/devcontainer.json` では `SECURE_MODE` はデフォルトで
  `true` に設定されています（起動時にファイアウォール適用）
- 無効化する場合のみ、`SECURE_MODE=false` を設定してください

```jsonc
// .devcontainer/devcontainer.json の一部
{
  "containerEnv": {
    // セキュアモードを無効化したい場合のみ false を設定
    "SECURE_MODE": "false"
  }
}
```

#### 2. サブフォルダ構成（従来どおり）

```bash
# セキュア設定ディレクトリを開いてから、コンテナーで再度開く
code .devcontainer/secure
```

### セキュリティ機能

- 破壊的操作の隔離: `rm -rf *` 等の誤操作をコンテナ内に限定
- ネットワーク制限（ファイアウォール設定）
- 承認されたドメインのみアクセス許可
- Claude Code・機密プロジェクト・セキュリティ監査に最適

具体的なセキュリティ機能は次の通りです。

- デフォルト拒否ネットワークポリシー（デフォルトで有効）
- 許可ドメイン: GitHub、NPM レジストリ、Anthropic サービス
- 自動ファイアウォール初期化
- コマンド履歴の永続化
- 権限制限付きコンテナ環境

## 標準開発環境（オプション・SECURE_MODE=false時）

セキュアモードを無効化した場合の環境です。Claude Code 使用時は非推奨。

### 特徴

- フルネットワークアクセス（制限なし；`SECURE_MODE=false` 時）
- 自由なパッケージインストールと API 接続
- 学習・プロトタイピング・手動開発に最適
- 注意: Claude Code はセキュア環境での使用を推奨

### 使用方法

```bash
# VS Codeでプロジェクトを開く
code .
# devcontainer.jsonでSECURE_MODE=falseに設定後
# 「コンテナーで再度開く」コマンドを使用
```

## プロファイル比較

| 項目         | 環境名                                   | 詳細                 |
| ------------ | ---------------------------------------- | -------------------- |
| ルート環境   | Python & TypeScript Development          | 標準開発環境         |
| セキュア環境 | Secure Python & TypeScript Development   | ネットワーク制限付き |
| ---          | ---                                      | ---                  |
| 定義ファイル | `.devcontainer/devcontainer.json`        | ルート設定           |
|              | `.devcontainer/secure/devcontainer.json` | セキュア専用         |
| セキュア既定 | `SECURE_MODE=true`                       | デフォルト有効       |
|              | 常にセキュア                             | 強制適用             |
| 追加ツール   | iptables/ipset/aggregate/dig             | セキュリティツール   |
|              | 同等（セキュア向けに最適化）             | 最適化済み           |
| 主要起動手順 | Reopen → Python & TypeScript             | 標準環境             |
|              | Reopen → Secure Python & TypeScript      | セキュア環境         |
| 追加許可設定 | `devcontainer.local.json`                | 追加ドメイン許可設定 |
|              | `secure/devcontainer.json`               | セキュア専用設定     |
| 主な用途     | 一般開発・OSS・学習                      | 柔軟な開発           |
|              | 機密/監査/ネットワーク制限               | 厳格なセキュリティ   |

## ローカル上書き設定

個人環境だけで設定を上書きしたい場合は、ローカル上書きを利用できます（Git 管理
外）。

### 設定手順

```bash
cp .devcontainer/devcontainer.local.json.sample .devcontainer/devcontainer.local.json
code .devcontainer/devcontainer.local.json
```

### 設定例

#### 例1: セキュアモードを無効化

ネットワーク制限なしで利用したい場合。

```jsonc
{
  "containerEnv": {
    "SECURE_MODE": "false"
  }
}
```

#### 例2: 追加許可ドメインのみ指定

セキュアモードのまま特定ドメインを許可。

```jsonc
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "dl.google.com, update.code.visualstudio.com"
  }
}
```

注意: `.devcontainer/devcontainer.local.json` は Git にコミットされません
（`.gitignore` 済み）。

## 追加許可ドメイン設定

セキュア環境では、追加で許可したいドメインを環境変数で指定できます。コンテナ起動
時に `ADDITIONAL_ALLOWED_DOMAINS` を読み取り、A レコードを ipset に登録します
（CIDR も可）。

### ドメイン設定例

```jsonc
// 例1（推奨）: ローカル上書きで追加ドメインを設定
// .devcontainer/devcontainer.local.json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "npm.company.com,pypi.company.com"
  }
}

// 例2: セキュア専用定義で追加
// .devcontainer/secure/devcontainer.json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "cdn.jsdelivr.net,unpkg.com"
  }
}
```

### 反映手順

1. VS Code の「コンテナーで再度開く」または Rebuild
2. ファイアウォールルールが正常に適用されない場合（コンテナ再起動後など）、コン
   テナ内で手動再適用：

```bash
sudo .devcontainer/secure/init-firewall.sh
```

### 書式

- 区切り: カンマ`,`/セミコロン`;`/スペースいずれも可
- スキーム/パス付き OK（`https://cdn.company.com/packages` など）
- CIDR 記法も追加可（例: `192.0.2.0/24`）

## トラブルシューティング

### ネットワーク制限による問題

ネットワーク制限により、外部アクセスが既定で遮断されます。問題発生時は以下を確認
してください。

許可ドメインの初期設定は以下の通りです。

- GitHub（web/api/git 範囲）
- `registry.npmjs.org`
- `api.anthropic.com`
- `sentry.io`
- `statsig.anthropic.com`
- `statsig.com`

代表的な症状として、以下があります。

- `uv sync` で企業レジストリへの接続失敗
- `pnpm install` の外部取得失敗
- `curl` が `icmp-admin-prohibited` で拒否

### 解決手順

#### 1. 接続可否の確認

```bash
# 許可外サイトには到達不可（OK）
curl -I https://example.com || true

# GitHub API は到達可能（OK）
curl -s https://api.github.com/zen
```

#### 2. ドメインのホワイトリスト追加

```bash
# ファイアウォール設定スクリプトを編集
code .devcontainer/secure/init-firewall.sh

# for domain in ... のリストに必要なドメインを追記（例: 企業レジストリ）
#   "npm.company.com" \
#   "pypi.company.com" \
```

#### 3. ルールの再適用

```bash
# セキュアコンテナ内で実行（sudo 必須）
sudo .devcontainer/secure/init-firewall.sh
```

#### 4. ルールの確認

```bash
sudo ipset list allowed-domains | head
sudo iptables -S OUTPUT | head
```

### その他の注意事項

- DNS は UDP/53 を許可済み。名前解決は `dig example.com +short` で確認。
- 失敗する場合はコンテナを「Rebuild」しスクリプトの初期化を再実行。
- 社内プロキシ経由が必要な場合は `curl`/`uv`/`pnpm` にプロキシ設定を適用。

## VS Code なしでの DevContainer 利用

VS Code なしで DevContainer を使用する場合のオプションです。

### 前提条件

- Docker がインストール済み
- Dev Containers CLI をインストール: `npm i -g @devcontainers/cli`

### 主要コマンド

```bash
# 起動（コンテナ作成・ビルド）
devcontainer up --workspace-folder .

# コンテナ内でコマンド実行
devcontainer exec --workspace-folder . bash

# 開発サーバー起動
devcontainer exec --workspace-folder . pnpm run dev

# クリーンアップ
devcontainer down --workspace-folder . --remove-volumes
```

## 使い分けガイド

### 標準環境を選択する場合

✅ 新機能の開発・検証 ✅ 外部 API との統合開発 ✅ ライブラリの調査・学習 ✅ オー
プンソースプロジェクト ✅ フルスタック開発全般。

### セキュア環境を選択する場合

🔒 顧客の機密コード 🔒 セキュリティ監査対象 🔒 コンプライアンス要件 🔒
--dangerously-skip-permissions 使用時。

## 関連ドキュメント

- [セキュリティ詳細設定](security.md)
- [Docker環境](docker.md)
- [MCPサーバー統合](mcp-servers.md)
