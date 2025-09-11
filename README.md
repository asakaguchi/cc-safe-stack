# Claude-Code-Polyglot-Starter

モダンなフルスタック開発環境（Python + TypeScript）

## 🚀 概要

本プロジェクトは、Python（FastAPI）、TypeScript（React）、Streamlit を組み合わせ
たモダンなフルスタック開発環境です。モノリポ構成により、3 つのフロントエンドを統
合的に開発できます。

### 🎯 3つのフロントエンド構成

- **React**: プロダクション向けのモダン UI
- **Streamlit**: データ分析・管理者ダッシュボード
- **FastAPI Docs**: 自動生成される API 仕様書

## 📖 チュートリアル

Claude Code を使った効率的な開発方法について学びたい方
は、[TUTORIAL.md](TUTORIAL.md) をご覧ください。実践的な例を通じて、仕様書駆動開
発や並列実行の威力を体験できます。

## 📝 チートシート（最短）

```bash
# DevContainer（VS Code 推奨）
code .     # → Reopen in Container → bun run dev
# 3つのサーバー同時起動: React(3000), FastAPI(8000), Streamlit(8501)

# Docker（フロント:ホスト / API:コンテナ）
cd backend && uv sync && cd - && docker compose up &
bun install && bun run dev:frontend

# Docker（フルスタックを両方コンテナで）
docker compose up
```

## ⚡ クイックスタート

このテンプレートは 2 つの使い方ができます。

- VS Code DevContainer（推奨／デフォルトでセキュア）
- Docker 単体（エディタ不問: Vim/Emacs/IntelliJ 等）

### 1. VS Code DevContainer（推奨）

- 必要条件: VS Code + Dev Containers 拡張機能 + Docker
- 使い方:
  1. リポジトリを VS Code で開く
  2. コマンドパレットで「Reopen in Container」を実行（次のどちらかを選択）
     - "Python & TypeScript Development Environment"（ルート定義・推奨。既定で
       `SECURE_MODE=true`）
     - "Secure Python & TypeScript Development
       Environment"（`.devcontainer/secure` の専用プロファイル。より厳格・追加
       ツール有）
     - 迷ったら前者で問題ありません（どちらもセキュア運用が可能）。
  3. コンテナ内で `bun run dev` を実行（フロントエンド+バックエンド同時起動）

選択ダイアログのイメージは次のとおりです。

```text
Reopen in Container →
  • Python & TypeScript Development Environment    ← 推奨（デフォルト）
  • Secure Python & TypeScript Development Environment
```

セキュア設定はデフォルトで有効になっています。

- 既定で `SECURE_MODE=true` が有効です（許可ドメイン以外の外部通信を遮断）
- 無効化したい場合のみ、ローカル上書きで切り替え

```bash
cp .devcontainer/devcontainer.local.json.sample .devcontainer/devcontainer.local.json
```

```jsonc
// .devcontainer/devcontainer.local.json の例
{
  "containerEnv": {
    // 無効化したい場合のみ false
    // "SECURE_MODE": "false",

    // セキュアのまま追加許可（例: 企業プライベートレジストリ）
    "ADDITIONAL_ALLOWED_DOMAINS": "npm.company.com, pypi.company.com"
  }
}
```

反映は「Rebuild and Reopen in Container」で行います。

VS Code なしで DevContainer を使用する場合のオプションです。

```bash
# Dev Containers CLI を利用
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

前提条件は以下のとおりです。

- Docker がインストール済み
- Dev Containers CLI をインストール: `npm i -g @devcontainers/cli`

主なコマンドは以下のとおりです。

```bash
# 起動（コンテナ作成・ビルド）
devcontainer up --workspace-folder .

# コンテナ内でコマンド実行
devcontainer exec --workspace-folder . bun run dev

# クリーンアップ
devcontainer down --workspace-folder . --remove-volumes
```

### 2. Docker（エディタ不問）

- 必要条件: Docker（お好みのエディタで編集）
- 使い方:

```bash
# バックエンド依存関係の同期（初回のみ推奨）
cd backend && uv sync && cd -

# バックエンド（FastAPI）をコンテナで起動（http://localhost:8000）
docker compose up app

# フロントエンドはホストで起動（http://localhost:3000）
bun install
bun run dev:frontend

# 代替: フロントエンドもコンテナで（http://localhost:3000）
docker compose up  # app と frontend の両方を起動
```

### 3. Docker開発環境（セキュア・Claude Code統合）

**⚠️ 安全性重視**: Claude Codeによる誤った破壊的操作（`rm -rf *`等）からホストマ
シンを保護

- 必要条件: Docker + Claude Code API キー
- 特徴: DevContainerと同等のセキュリティ機能を提供

```bash
# 1. 環境変数の設定
cp .env.example .env
# .env ファイルを編集して CLAUDE_API_KEY を設定

# 2. セキュア開発環境の起動
docker compose --profile dev up -d dev

# 3. コンテナに接続
docker exec -it claude-code-polyglot-starter-dev-1 zsh

# 4. Claude Code CLIを起動（コンテナ内で実行）
claude-code

# 5. 開発サーバーの起動（コンテナ内で実行）
bun run dev  # React(3000), FastAPI(8000), Streamlit(8501)
```

#### エディタの選択肢

**Option A: コンテナ内エディタ（軽量）**

```bash
# コンテナ内で直接編集
vim src/main.py
nano README.md
```

**Option B: VS Code Remote Containers（推奨）**

```bash
# VS Codeでコンテナに接続
code --remote-containers /workspace
```

**Option C: ホストエディタ（ファイル共有）**

```bash
# ホストマシンで任意のエディタを使用
# ファイルは自動で同期される
```

#### セキュリティ機能

- **ネットワーク制限**: 許可されたドメインのみアクセス可能
- **ファイアウォール**: DevContainerと同等のiptables設定
- **隔離環境**: ホストファイルシステムへの破壊的操作を防止
- **追加ドメイン許可**: 環境変数で柔軟に設定可能

```bash
# 追加ドメインの許可例（.envファイル）
ADDITIONAL_ALLOWED_DOMAINS=npm.company.com,pypi.company.com
```

補足事項は以下のとおりです。

- Compose は標準でバックエンド用コンテナのみ起動します。フロントエンドはホストで
  並行起動するか、フルスタック開発をコンテナで統一したい場合は
  `docker compose up` で拡張してください。
- セキュア開発環境は `--profile dev` で起動し、通常のサービスとは分離されていま
  す。

### 4. 技術スタック

#### バックエンド（Python）

- **Python 3.12+** - モダンな Python 環境
- **FastAPI** - 高性能な Web API フレームワーク
- **Uvicorn** - ASGI サーバー
- **Pydantic** - データバリデーション
- **uv** - 高速パッケージマネージャー
- **Ruff** - コードリンター・フォーマッター

#### フロントエンド（TypeScript）

- **TypeScript** - 型安全な JavaScript
- **React 18** - モダンな UI ライブラリ
- **Vite** - 高速ビルドツール
- **ESLint + Prettier** - コード品質管理
- **bun** - 超高速パッケージマネージャー・ランタイム

#### データアプリケーション（Streamlit）

- **Streamlit** - Python でのデータアプリ構築
- **Pandas** - データ分析・処理
- **Plotly** - インタラクティブな可視化
- **HTTPX** - FastAPI 統合の HTTP クライアント

#### 開発ツール

- **VS Code DevContainers** - 統一された開発環境
- **Claude Code CLI** - AI 支援開発ツール
- **Context7 MCP** - 最新ライブラリドキュメント統合
- **Git + GitHub CLI** - バージョン管理
- **Docker Compose** - コンテナ オーケストレーション

## 📁 プロジェクト構造

```text
├── backend/              # Python FastAPI アプリケーション
│   ├── main.py           # FastAPI エントリーポイント
│   ├── pyproject.toml    # Python 依存関係設定
│   └── src/              # バックエンドソースコード
├── frontend/             # TypeScript React アプリケーション
│   ├── src/              # フロントエンドソースコード
│   ├── package.json      # Node.js 依存関係
│   ├── tsconfig.json     # TypeScript設定
│   └── vite.config.ts    # Vite設定
├── streamlit/            # Streamlit データアプリケーション
│   └── app.py            # Streamlit メインアプリ
├── shared/               # 共有型定義・ユーティリティ
│   └── types/            # TypeScript 型定義
├── scripts/              # 開発用スクリプト
│   ├── setup.sh          # 初期セットアップ
│   ├── dev.sh            # 開発サーバー起動
│   ├── build.sh          # プロダクションビルド
│   └── lint.sh           # コード品質チェック
├── .devcontainer/        # VS Code DevContainer設定
│   ├── devcontainer.json # 標準（デフォルトでセキュア）
│   ├── Dockerfile.base   # 共通基盤イメージ
│   └── secure/           # セキュア開発環境
└── docker/               # Docker関連ファイル
```

### 🤖 MCPサーバー統合

本プロジェクトでは、Claude Code の MCP（Model Context Protocol）サーバーを活用し
て、開発効率を向上させています。

#### Context7 - 最新ドキュメント統合

Context7 MCP サーバーにより、常に最新のライブラリドキュメントとコード例を AI の
文脈に直接取り込むことができます。

##### 主な利点

- トレーニングデータではなく、リアルタイムの公式ドキュメントを参照
- 使用中のライブラリバージョンに対応した正確なコード例を提供
- 手動でのドキュメント検索が不要

##### 使用方法

プロンプトに「**use context7**」を追加するだけで、最新情報を取得できます。

```text
# FastAPI の例
「FastAPIでWebSocketを実装する方法を教えて use context7」

# React の例
「React 19のServer Componentsの使い方を説明して use context7」

# Next.js の例
「Next.js 15のApp Routerでミドルウェアを設定する方法は？ use context7」
```

##### 設定

プロジェクトルートの `.mcp.json` に Context7 の設定を記載済みです。初回使用時に
自動でインストールされ、チーム全体で同じ設定を共有できます。

##### 対応ライブラリ

Python（FastAPI, Pydantic, SQLAlchemy, Pandas 等）、
TypeScript/JavaScript（React, Next.js, Vite, Express 等）をはじめ、多数のライブ
ラリに対応しています。

詳細は [Context7 公式サイト](https://context7.com) を参照してください。

#### Playwright - ブラウザ自動化

Playwright MCPサーバーにより、ブラウザの自動操作やWebスクレイピング、E2Eテストの
実行が可能になります。

##### 主な機能

- Webページの自動操作（クリック、入力、ナビゲーション）
- スクリーンショット撮影とPDF生成
- 複数ブラウザ対応（Chromium、Firefox、WebKit）
- フォーム自動入力とファイルアップロード
- JavaScriptの実行とページ要素の操作

##### 使用方法（Playwright）

プロンプトに「**playwright mcp**」を含めて指示します。

```text
# Webスクレイピングの例
「playwright mcpを使って https://example.com から情報を取得して」

# E2Eテストの例
「playwright mcpでログインフォームのテストを実行して」

# スクリーンショットの例
「playwright mcpでページのスクリーンショットを撮って」
```

##### 設定（Playwright）

プロジェクトルートの `.mcp.json` に Playwright の設定を記載済みです。初回使用時
に自動でインストールされます。

**ヒント**:

- 認証が必要なサイトでは、最初にブラウザを表示して手動でログインすることも可能
- セッション中はクッキーが保持されるため、継続的な操作が可能

詳細は [Playwright MCP 公式サイト](https://github.com/microsoft/playwright-mcp)
を参照してください。

## 🔧 セットアップ

### 1. 初期セットアップ

```bash
# 1. GitHubで「Use this template」ボタンをクリックして新しいリポジトリを作成
# 2. 作成したリポジトリをクローン
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>

# 依存関係のインストールと環境構築
bun run setup
```

### 2. 開発サーバーの起動

```bash
# 3つのフロントエンド・バックエンドを同時に起動
bun run dev

# 個別起動
bun run dev:backend   # Python FastAPI (http://localhost:8000)
bun run dev:frontend  # TypeScript React (http://localhost:3000)
bun run dev:streamlit # Streamlit データアプリ (http://localhost:8501)
```

### 3. コード品質管理

```bash
# リンティング
bun run lint

# フォーマッティング
bun run format

# 自動修正
bun run lint:fix

# テスト実行
bun run test
```

### 4. プロダクションビルド

```bash
# 全体のビルド
bun run build

# 個別ビルド
bun run build:backend   # Python依存関係の同期
bun run build:frontend  # React アプリのビルド
bun run build:streamlit # Streamlit依存関係の同期
```

## 🐳 Docker開発

標準的な Docker 環境も提供しています（バックエンドのみ／フルスタックの両対応）。

```bash
# backend の uv.lock を作成
cd backend && uv sync && cd -

# バックエンドのみ（http://localhost:8000）
docker compose up app

# フルスタック（http://localhost:3000, http://localhost:8000）
docker compose up
```

## 🏠 VS Code DevContainer

プロジェクトでは統一された設計の 2 つの devcontainer 設定を提供しています。

### 共通基盤

両環境は次のような共通のベース環境を使用しています。

- ユーザー名: `vscode`
- ベース OS: Ubuntu 24.04
- Python 環境: `/home/vscode/.venv`
- 開発ツール: uv、git、GitHub CLI、ZSH、ripgrep 等
- フルスタック対応: Python + Node.js + TypeScript 完全対応
- Claude Code CLI: プリインストール済み

### 標準開発環境（SECURE_MODE=false 時）

```bash
# VS Codeでプロジェクトを開く
code .
# 「コンテナーで再度開く」コマンドを使用
```

**特徴:**

- フルネットワークアクセス（制限なし；`SECURE_MODE=false` 時）
- 自由なパッケージインストールと API 接続
- 学習・プロトタイピング・オープンソース開発に最適
- 迅速な開発サイクル

### セキュア開発環境（Claude Code／デフォルト）

2 通りの使い方が可能です。

1. デフォルト設定（おすすめ）

- ルートの `.devcontainer/devcontainer.json` では `SECURE_MODE` はデフォルトで
  `true` に設定されています（起動時にファイアウォール適用）。
- 無効化する場合のみ、`SECURE_MODE=false` を設定してください。反映は「Rebuild
  and Reopen in Container」で実施。

```jsonc
// .devcontainer/devcontainer.json の一部
{
  "containerEnv": {
    // セキュアモードを無効化したい場合のみ false を設定
    "SECURE_MODE": "false"
  }
}
```

1. サブフォルダ構成（従来どおり）

```bash
# セキュア設定ディレクトリを開いてから、コンテナーで再度開く
code .devcontainer/secure
```

**特徴:**

- 標準環境の全機能＋セキュリティ強化
- ネットワーク制限（ファイアウォール設定）
- 承認されたドメインのみアクセス許可
- 機密プロジェクト・顧客コード・セキュリティ監査に最適

**セキュリティ機能:**

- デフォルト拒否ネットワークポリシー（デフォルトで有効）
- 許可ドメイン: GitHub、NPM レジストリ、Anthropic サービス
- 自動ファイアウォール初期化
- コマンド履歴の永続化
- 権限制限付きコンテナ環境

### プロファイル比較（簡易）

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

### トラブルシュート（セキュア環境）

ネットワーク制限により、外部アクセスが既定で遮断されます。問題発生時は以下を確認
してください。

- 許可ドメイン（初期値）: GitHub（web/api/git 範囲）、
  `registry.npmjs.org`、`api.anthropic.com`、`sentry.io`、
  `statsig.anthropic.com`、`statsig.com`
- 代表的な症状: `uv sync` で企業レジストリへの接続失敗、 `bun install` の外部取
  得失敗、 `curl` が `icmp-admin-prohibited` で拒否
- 追加で許可が必要になりがちなドメイン例: CDN、企業プライベートレジストリなど

手順は以下のとおりです。

1. 接続可否の確認

```bash
# 許可外サイトには到達不可（OK）
curl -I https://example.com || true

# GitHub API は到達可能（OK）
curl -s https://api.github.com/zen
```

1. ドメインのホワイトリスト追加

```bash
# ファイアウォール設定スクリプトを編集
code .devcontainer/secure/init-firewall.sh

# for domain in ... のリストに必要なドメインを追記（例: 企業レジストリ）
#   "npm.company.com" \
#   "pypi.company.com" \
```

1. ルールの再適用

```bash
# セキュアコンテナ内で実行（sudo 必須）
sudo .devcontainer/secure/init-firewall.sh
```

1. ルールの確認

```bash
sudo ipset list allowed-domains | head
sudo iptables -S OUTPUT | head
```

補足事項は以下のとおりです。

- DNS は UDP/53 を許可済み。名前解決は `dig example.com +short` で確認
- 失敗する場合はコンテナを「Rebuild」しスクリプトの初期化を再実行
- 社内プロキシ経由が必要な場合は `curl`/`uv`/`bun` にプロキシ設定を適用

### 追加許可ドメイン（環境変数）

セキュア環境では、追加で許可したいドメインを環境変数で指定できます。コンテナ起動
時に `ADDITIONAL_ALLOWED_DOMAINS` を読み取り、A レコードを ipset に登録します
（CIDR も可）。

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

反映手順は以下のとおりです。

1. VS Code の「コンテナーで再度開く」または Rebuild
1. ファイアウォールルールが正常に適用されない場合（コンテナ再起動後など）、コン
   テナ内で手動再適用してください

```bash
sudo .devcontainer/secure/init-firewall.sh
```

書式は以下のとおりです。

- 区切り: カンマ`,`/セミコロン`;`/スペースいずれも可
- スキーム/パス付き OK（`https://cdn.company.com/packages` など）
- CIDR 記法も追加可（例: `192.0.2.0/24`）

### 使い分けガイド

```text
標準環境を選択:
✅ 新機能の開発・検証
✅ 外部APIとの統合開発
✅ ライブラリの調査・学習
✅ オープンソースプロジェクト
✅ フルスタック開発全般

セキュア環境を選択:
🔒 顧客の機密コード
🔒 セキュリティ監査対象
🔒 コンプライアンス要件
🔒 --dangerously-skip-permissions使用時
```

### ローカル上書き（devcontainer.local.json）

個人環境だけで設定を上書きしたい場合は、ローカル上書きを利用できます（Git 管理
外）。

```bash
cp .devcontainer/devcontainer.local.json.sample .devcontainer/devcontainer.local.json
code .devcontainer/devcontainer.local.json
```

例 1: セキュアモードを無効化（ネットワーク制限なしで利用したい場合）

```jsonc
{
  "containerEnv": {
    "SECURE_MODE": "false"
  }
}
```

例 2: 追加許可ドメインのみ指定（セキュアモードのまま）

```jsonc
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "dl.google.com, update.code.visualstudio.com"
  }
}
```

注意: `.devcontainer/devcontainer.local.json` は Git にコミットされません
（`.gitignore` 済み）。

## 🌟 特徴

### フルスタック統合開発

- 統一されたツールチェーン: Python・TypeScript・Streamlit・Claude Code が完全統
  合
- モノリポ管理: 1 つのリポジトリで 3 つのフロントエンド・バックエンドを管理
- 多様な UI 構成: React（プロダクション）・Streamlit（データ分析）・FastAPI
  Docs（API 仕様）
- 共有型定義: フロントエンド・バックエンド間で型を共有
- 統合テスト: 全スタックを通じた自動テスト

### モダンな開発体験

- 高速パッケージ管理: uv（Python）・bun（JavaScript/TypeScript）
- リアルタイム開発: ホットリロード対応
- コード品質自動化: ESLint・Prettier・Ruff 統合
- AI 支援開発: Claude Code CLI 完全対応

### 本番環境対応

- TypeScript 完全対応: 型安全なフルスタック開発
- パフォーマンス最適化: Vite・FastAPI 組み合わせ
- Docker 統合: 本番デプロイメント対応
- セキュリティ強化: ネットワーク制限・コンテナ分離

## 📚 開発ガイド

> 💡 **Claude Code を使った開発方法については [TUTORIAL.md](TUTORIAL.md) を参照
> してください。**

### API開発（Python）

```python
# backend/main.py
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class MessageResponse(BaseModel):
    message: str
    timestamp: str

@app.get("/api/hello/{name}")
async def hello_name(name: str) -> MessageResponse:
    from datetime import datetime
    return MessageResponse(
        message=f"Hello, {name}!",
        timestamp=datetime.now().isoformat(),
    )
```

### CORS 設定

バックエンドでは、`.env` の `CORS_ORIGINS` で許可オリジンを制御できます（JSON 配
列 or カンマ区切り）。未設定時は `http://localhost:3000` のみ許可されます。

```env
# backend/.env 例（JSON 配列）
CORS_ORIGINS=["http://localhost:3000", "https://example.com"]

# またはカンマ区切り文字列でも可
# CORS_ORIGINS=http://localhost:3000,https://example.com
```

`backend/main.py` では、`CORS_ORIGINS` を読み取り `CORSMiddleware` を自動設定し
ています。

### フロントエンド開発（TypeScript）

```typescript
// frontend/src/api.ts
import type { MessageResponse } from '@shared/types/api'

export async function fetchGreeting(name: string): Promise<MessageResponse> {
  const response = await fetch(`/api/hello/${encodeURIComponent(name)}`)
  return response.json()
}
```

### 共有型定義

```typescript
// shared/types/api.ts
export interface MessageResponse {
  message: string
  timestamp: string
}
```

## 🔄 開発ワークフロー

1. **機能開発**: `bun run dev` で開発サーバー起動
2. **コード品質**: `bun run lint` でチェック
3. **フォーマット**: `bun run format` でコード整形
4. **テスト**: `bun run test` で自動テスト
5. **ビルド**: `bun run build` で本番ビルド
6. **デプロイ**: Docker Compose またはコンテナデプロイ

## 🤝 貢献

1. プロジェクトをフォーク
2. 機能ブランチを作成: `git checkout -b feature/new-feature`
3. 変更をコミット: `git commit -m 'Add new feature'`
4. ブランチをプッシュ: `git push origin feature/new-feature`
5. プルリクエストを作成

## 🙏 参考・クレジット

本 README は、以下の記事およびリポジトリをもとに作成しています。

- 記事:
  [Python プロジェクトのためのテンプレート](https://zenn.dev/mjun0812/articles/0ae2325d40ed20)
- 記事:
  [Claude Code DevContainer](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
- リポジトリ:
  [Python Project Template](https://github.com/mjun0812/python-project-template)
- リポジトリ:
  [Claude Code DevContainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)ファイルを参照。
