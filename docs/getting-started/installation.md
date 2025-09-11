# セットアップガイド

このガイドでは、プロジェクトの初期セットアップから開発サーバーの起動まで詳しく説
明します。

## 前提条件

### システム要件

- **OS**: Windows 10/11, macOS 10.15+, Ubuntu 18.04+
- **Docker**: Docker Desktop または Docker Engine
- **Git**: バージョン管理

### 開発環境別の追加要件

#### VS Code DevContainer（推奨）

- **VS Code**: 最新版
- **Dev Containers 拡張機能**: Microsoft 公式拡張
- **Docker**: Docker Desktop

#### Docker単体

- **Docker**: Docker Compose v2 対応版
- **bun**: JavaScript/TypeScript パッケージマネージャー

#### ローカル開発

- **Python**: 3.12 以上
- **Node.js**: 18 以上
- **uv**: Python パッケージマネージャー
- **bun**: JavaScript/TypeScript パッケージマネージャー

## 初期セットアップ

### 1. リポジトリのクローン

```bash
# GitHubで「Use this template」ボタンをクリックして新しいリポジトリを作成
# 作成したリポジトリをクローン
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>
```

### 2. 依存関係のインストール

```bash
# 統合セットアップスクリプトを実行
bun run setup
```

このコマンドは以下を自動実行します：

- フロントエンド依存関係のインストール（`bun install`）
- バックエンド依存関係の同期（`uv sync`）
- 開発環境の初期化

### 3. 環境変数の設定（オプション）

```bash
# 必要に応じて環境変数ファイルを作成
cp .env.example .env
```

基本的な環境変数：

```env
# バックエンド設定
API_HOST=0.0.0.0
API_PORT=8000

# フロントエンド設定
VITE_API_URL=http://localhost:8000

# CORS設定（開発時）
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8501"]

# セキュア環境用（必要に応じて）
SECURE_MODE=true
ADDITIONAL_ALLOWED_DOMAINS=example.com,api.example.com
```

## 開発サーバーの起動

### 統合起動（推奨）

```bash
# 3つのサーバーを同時に起動
bun run dev
```

このコマンドで以下が起動します：

- **React**: <http://localhost:3000>
- **FastAPI**: <http://localhost:8000>
- **Streamlit**: <http://localhost:8501>

### 個別起動

```bash
# バックエンド（FastAPI）
bun run dev:backend

# フロントエンド（React）
bun run dev:frontend

# データアプリ（Streamlit）
bun run dev:streamlit
```

### サービス確認

各サービスが正常に起動していることを確認：

```bash
# API の動作確認
curl http://localhost:8000/api/health

# フロントエンドの確認
curl http://localhost:3000

# Streamlit の確認
curl http://localhost:8501
```

## プラットフォーム別のセットアップ

### Windows

#### PowerShell での実行

```powershell
# Git Bash または PowerShell を使用
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>
bun run setup
```

#### WSL2 環境（推奨）

```bash
# WSL2 内でのセットアップ
wsl
cd /mnt/c/path/to/your/project
bun run setup
```

#### 注意事項

- Docker Desktop で WSL2 バックエンドを有効化
- VS Code で WSL 拡張機能をインストール
- ファイルパスの区切り文字に注意

### macOS

#### Homebrew でのツールインストール

```bash
# 必要なツールのインストール
brew install git docker
brew install oven-sh/bun/bun

# プロジェクトセットアップ
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>
bun run setup
```

#### macOS での注意事項

- Docker Desktop for Mac をインストール
- Apple Silicon（M1/M2）では互換性に注意
- Rosetta 2 が必要な場合がある

### Linux

#### Ubuntu/Debian

```bash
# Docker のインストール
sudo apt update
sudo apt install docker.io docker-compose-plugin git

# bun のインストール
curl -fsSL https://bun.sh/install | bash

# プロジェクトセットアップ
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>
bun run setup
```

#### CentOS/RHEL

```bash
# Docker のインストール
sudo yum install docker git

# bun のインストール
curl -fsSL https://bun.sh/install | bash

# プロジェクトセットアップ
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>
bun run setup
```

## パッケージマネージャーの詳細

### uv（Python）

```bash
# インストール（まだインストールしていない場合）
curl -LsSf https://astral.sh/uv/install.sh | sh

# プロジェクト依存関係の管理
cd backend
uv sync                 # 依存関係の同期
uv add fastapi          # パッケージの追加
uv add --dev pytest     # 開発依存関係の追加
uv remove package-name  # パッケージの削除
```

### bun（JavaScript/TypeScript）

```bash
# インストール（まだインストールしていない場合）
curl -fsSL https://bun.sh/install | bash

# プロジェクト依存関係の管理
bun install                    # 依存関係のインストール
bun add react                  # パッケージの追加
bun add -D @types/node         # 開発依存関係の追加
bun remove package-name        # パッケージの削除
```

## コード品質管理

### リンティングとフォーマット

```bash
# 全体のリンティング
bun run lint

# 自動修正
bun run lint:fix

# フォーマッティング
bun run format

# TypeScript 型チェック
bun run type-check
```

### Pre-commit フックの設定

```bash
# pre-commit のインストールと設定
uv run pre-commit install

# 手動での実行
uv run pre-commit run --all-files
```

## テスト実行

### 全体テスト

```bash
# 全プロジェクトのテスト実行
bun run test
```

### 個別テスト

```bash
# バックエンドテスト
cd backend
uv run pytest

# フロントエンドテスト
cd frontend
bun test

# Streamlit アプリのテスト
cd streamlit
uv run pytest
```

## プロダクションビルド

### 全体ビルド

```bash
# 全プロジェクトのビルド
bun run build
```

### 個別ビルド

```bash
# バックエンド依存関係の同期
bun run build:backend

# React アプリのビルド
bun run build:frontend

# Streamlit 依存関係の同期
bun run build:streamlit
```

## トラブルシューティング

### よくある問題

#### ポート競合

**症状**: `EADDRINUSE: address already in use :::3000`

**解決策**:

```bash
# 使用中のポートを確認
lsof -i :3000
netstat -tulpn | grep :3000

# プロセスを終了
kill -9 <PID>
```

#### 依存関係のインストールエラー

**症状**: `uv sync` や `bun install` が失敗

**解決策**:

```bash
# キャッシュをクリア
uv cache clean
bun pm cache rm

# ロックファイルを削除して再インストール
rm backend/uv.lock
rm bun.lockb
bun run setup
```

#### Docker 関連エラー

**症状**: Docker コンテナが起動しない

**解決策**:

```bash
# Docker の状態確認
docker --version
docker compose --version

# Docker サービスの再起動
sudo systemctl restart docker

# Docker Desktop の再起動（Windows/macOS）
```

### 権限エラー

#### Linux での権限問題

```bash
# Docker グループにユーザーを追加
sudo usermod -aG docker $USER

# ログアウト・ログインして再試行
```

#### ファイル権限の修正

```bash
# スクリプトファイルに実行権限を付与
chmod +x scripts/*.sh

# 必要に応じて所有者を変更
sudo chown -R $USER:$USER .
```

### パフォーマンスの問題

#### 開発サーバーが重い場合

```bash
# Node.js のメモリ制限を増加
export NODE_OPTIONS=\"--max-old-space-size=4096\"
bun run dev
```

#### Docker のパフォーマンス改善

```bash
# Docker Desktop のリソース設定を調整
# Settings → Resources → Memory/CPU を増加
```

## 次のステップ

セットアップが完了したら、以下のドキュメントを参照して開発を始めてください：

1. **[Claude Code 実践ガイド](../../TUTORIAL.md)** - Claude Code を使った開発方
   法
2. **[API開発ガイド](../development/api-development.md)** - FastAPI による API
   開発
3. **[アーキテクチャガイド](../development/architecture.md)** - プロジェクト構造
   の理解
4. **[環境設定ガイド](../environment/)** - DevContainer や Docker の詳細設定

## サポート情報

### ヘルプコマンド

```bash
# 利用可能なスクリプトの確認
bun run

# プロジェクト固有のヘルプ
bun run help
```

### デバッグ情報の収集

```bash
# システム情報の出力
bun --version
uv --version
docker --version
docker compose version

# 環境変数の確認
echo $PATH
echo $NODE_ENV
```

問題が解決しない場合は、プロジェクトの Issues ページで報告してください。
