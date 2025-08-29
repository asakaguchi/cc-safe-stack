# Claude-Code-Polyglot-Starter

モダンなフルスタック開発環境（Python + TypeScript）

## 🚀 概要

本プロジェクトは、Python（FastAPI）と TypeScript（React）を組み合わせたモダンな
フルスタック開発環境です。モノリポ構成により、バックエンドとフロントエンドを統合
的に開発できます。

## 📝 チートシート（最短）

```bash
# DevContainer（VS Code 推奨）
code .     # → Reopen in Container → bun run dev

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

### 1) VS Code DevContainer（推奨）

- 必要条件: VS Code + Dev Containers 拡張機能 + Docker
- 使い方:
  1. リポジトリを VS Code で開く
  2. コマンドパレットで「Reopen in Container」を実行（次のどちらかを選択）
     - "Python & TypeScript Development Environment"（ルート定義・推奨。既定で `SECURE_MODE=true`）
     - "Secure Python & TypeScript Development Environment"（`.devcontainer/secure` の専用プロファイル。より厳格・追加ツール有）
     - 迷ったら前者で問題ありません（どちらもセキュア運用が可能）。
  3. コンテナ内で `bun run dev` を実行（フロントエンド+バックエンド同時起動）

選択ダイアログ（イメージ）:

```text
Reopen in Container →
  • Python & TypeScript Development Environment    ← 推奨（デフォルト）
  • Secure Python & TypeScript Development Environment
```

セキュア設定（デフォルトで有効）:

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

    // セキュアのまま追加許可（例: PyPI）
    "ADDITIONAL_ALLOWED_DOMAINS": "pypi.org, files.pythonhosted.org"
 }
}
```

反映は「Rebuild and Reopen in Container」で行います。

オプション（VS Code なしで DevContainer を使う場合）:

```bash
# Dev Containers CLI を利用
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

前提条件:

- Docker がインストール済み
- Dev Containers CLI をインストール: `npm i -g @devcontainers/cli`

主なコマンド:

```bash
# 起動（コンテナ作成・ビルド）
devcontainer up --workspace-folder .

# コンテナ内でコマンド実行
devcontainer exec --workspace-folder . bun run dev

# クリーンアップ
devcontainer down --workspace-folder . --remove-volumes
```

### 2) Docker（エディタ不問）

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

補足:

- Compose は標準でバックエンド用コンテナのみ起動します。フロントエンドはホストで並行起動するか、必要に応じて Compose を拡張してください。
- `SECURE_MODE` は DevContainer のみの設定で、Docker Compose には影響しません。

### 技術スタック

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

#### 開発ツール

- **VS Code DevContainers** - 統一された開発環境
- **Claude Code CLI** - AI 支援開発ツール
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

## 🔧 セットアップ

### 1. 初期セットアップ

```bash
# プロジェクトのクローン
git clone <repository-url>
cd claude-code-polyglot-starter

# 依存関係のインストールと環境構築
bun run setup
```

### 2. 開発サーバーの起動

```bash
# フロントエンド・バックエンドを同時に起動
bun run dev

# 個別起動
bun run dev:backend   # Python FastAPI (http://localhost:8000)
bun run dev:frontend  # TypeScript React (http://localhost:3000)
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

- ユーザー名: `developer`
- ベース OS: Ubuntu 24.04
- Python 環境: `/home/developer/.venv`
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

2通りの使い方が可能です。

1) デフォルト設定（おすすめ）

- ルートの `.devcontainer/devcontainer.json` では `SECURE_MODE` はデフォルトで `true` に設定されています（起動時にファイアウォール適用）。
- 無効化する場合のみ、`SECURE_MODE=false` を設定してください。反映は「Rebuild and Reopen in Container」で実施。

```jsonc
// .devcontainer/devcontainer.json の一部
{
  "containerEnv": {
    // セキュアモードを無効化したい場合のみ false を設定
    "SECURE_MODE": "false"
  }
}
```

2) サブフォルダ構成（従来どおり）

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

| 項目 | ルート: Python & TypeScript Development Environment | セキュア: Secure Python & TypeScript Development Environment |
|---|---|---|
| 定義ファイル | `.devcontainer/devcontainer.json` | `.devcontainer/secure/devcontainer.json` |
| セキュア既定 | `SECURE_MODE=true`（postStart でFW自動） | 常にセキュア（postStart でFW強制） |
| 追加ツール | iptables/ipset/aggregate/dig など導入済み | 同等（セキュア向けに最適化） |
| 主要起動手順 | Reopen →「Python & TypeScript ...」 | Reopen →「Secure Python & TypeScript ...」 |
| 追加許可設定 | `.devcontainer/devcontainer.local.json`の`ADDITIONAL_ALLOWED_DOMAINS` | `.devcontainer/secure/devcontainer.json`の`ADDITIONAL_ALLOWED_DOMAINS` |
| 主な用途 | 一般開発・OSS・学習（必要に応じて無制限化も可） | 機密/監査/厳格なネットワーク制限が必要な開発 |

### トラブルシュート（セキュア環境）

ネットワーク制限により、外部アクセスが既定で遮断されます。問題発生時は以下を確認してください。

- 許可ドメイン（初期値）: GitHub（web/api/git 範囲）、`registry.npmjs.org`、`api.anthropic.com`、`sentry.io`、`statsig.anthropic.com`、`statsig.com`
- 代表的な症状: `uv sync` で PyPI への接続失敗、`bun install` の外部取得失敗、`curl` が `icmp-admin-prohibited` で拒否
- 追加で許可が必要になりがちなドメイン例: `pypi.org`、`files.pythonhosted.org`

手順:

1) 接続可否の確認

```bash
# 許可外サイトには到達不可（OK）
curl -I https://example.com || true

# GitHub API は到達可能（OK）
curl -s https://api.github.com/zen
```

2) ドメインのホワイトリスト追加

```bash
# ファイアウォール設定スクリプトを編集
code .devcontainer/secure/init-firewall.sh

# for domain in ... のリストに必要なドメインを追記（例: pypi）
#   "pypi.org" \
#   "files.pythonhosted.org" \
```

3) ルールの再適用

```bash
# セキュアコンテナ内で実行（sudo 必須）
sudo .devcontainer/secure/init-firewall.sh
```

4) ルールの確認

```bash
sudo ipset list allowed-domains | head
sudo iptables -S OUTPUT | head
```

補足:

- DNS は UDP/53 を許可済み。名前解決は `dig example.com +short` で確認
- 失敗する場合はコンテナを「Rebuild」しスクリプトの初期化を再実行
- 社内プロキシ経由が必要な場合は `curl`/`uv`/`bun` にプロキシ設定を適用

### 追加許可ドメイン（環境変数）

セキュア環境では、追加で許可したいドメインを環境変数で指定できます。コンテナ起動時に `ADDITIONAL_ALLOWED_DOMAINS` を読み取り、A レコードを ipset に登録します（CIDR も可）。

```jsonc
// 例1（推奨）: ローカル上書きで追加ドメインを設定
// .devcontainer/devcontainer.local.json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "pypi.org,files.pythonhosted.org"
  }
}

// 例2: セキュア専用定義で追加
// .devcontainer/secure/devcontainer.json
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "pypi.org,files.pythonhosted.org"
  }
}
```

反映手順:

1) VS Code の「コンテナーで再度開く」または Rebuild
2) 必要に応じて、コンテナ内で再適用

```bash
sudo .devcontainer/secure/init-firewall.sh
```

書式:

- 区切り: カンマ`,`/セミコロン`;`/スペースいずれも可
- スキーム/パス付き OK（`https://pypi.org/simple` など）
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

個人環境だけで設定を上書きしたい場合は、ローカル上書きを利用できます（Git 管理外）。

```bash
cp .devcontainer/devcontainer.local.json.sample .devcontainer/devcontainer.local.json
code .devcontainer/devcontainer.local.json
```

例1: セキュアモードを無効化（ネットワーク制限なしで利用したい場合）

```jsonc
{
  "containerEnv": {
    "SECURE_MODE": "false"
  }
}
```

例2: 追加許可ドメインのみ指定（セキュアモードのまま）

```jsonc
{
  "containerEnv": {
    "ADDITIONAL_ALLOWED_DOMAINS": "pypi.org, files.pythonhosted.org"
  }
}
```

注意: `.devcontainer/devcontainer.local.json` は Git にコミットされません（`.gitignore` 済み）。

## 🌟 特徴

### フルスタック統合開発

- 統一されたツールチェーン: Python・TypeScript・Claude Code が完全統合
- モノリポ管理: 1 つのリポジトリでフロントエンド・バックエンドを管理
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

バックエンドでは、`.env` の `CORS_ORIGINS` で許可オリジンを制御できます（JSON 配列 or カンマ区切り）。未設定時は `http://localhost:3000` のみ許可されます。

```env
# backend/.env 例（JSON 配列）
CORS_ORIGINS=["http://localhost:3000", "https://example.com"]

# またはカンマ区切り文字列でも可
# CORS_ORIGINS=http://localhost:3000,https://example.com
```

`backend/main.py` では、`CORS_ORIGINS` を読み取り `CORSMiddleware` を自動設定しています。

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

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)ファイルを参照。
