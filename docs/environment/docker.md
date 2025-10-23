# Docker セキュア開発環境ガイド

このガイドでは、Claude Code を安全に実行するための Docker 開発環境について説明し
ます。

## 目的

Claude Code が誤って `rm -rf *` などの破壊的コマンドを実行してもホスト環境を保護
するため、ホストから隔離したセキュアな開発環境を提供します。

## 環境構成

プロジェクトでは 3 つの Docker 環境を提供しています。

1. セキュア Docker 開発環境（推奨）: Claude Code 専用の隔離環境
2. 標準 Docker: バックエンドのみ（フロントエンドはホスト実行）
3. フルスタック Docker: 全てのサービスをコンテナで実行

## セキュアDocker開発環境（推奨）

Claude Code を安全に実行するための専用環境です。ネットワーク制限により外部への不
正アクセスを防止し、破壊的操作をコンテナ内に隔離します。

### 必要条件

- Docker
- 環境変数設定（`.env`）

### セットアップ手順

#### 1. 環境変数の設定

```bash
cp .env.example .env
```

#### 2. セキュア開発環境の起動

```bash
# 推奨：package.jsonコマンド使用
pnpm run docker:dev

# 直接コマンド
docker compose --profile dev up -d dev
```

#### 3. コンテナに接続

```bash
# 推奨：package.jsonコマンド使用
pnpm run docker:dev:connect

# 直接コマンド
docker exec -it claude-polyglot-starter-dev-1 zsh
```

#### 4. Claude Codeで開発開始

重要: Claude Code はコンテナ内でのみ実行してください（ホスト環境での実行は非推
奨）

```bash
# コンテナ内でClaude Codeを安全に実行
claude
```

#### 5. 開発サーバーの起動（コンテナ内で実行）

```bash
pnpm run dev       # React(3000), FastAPI(8000)
pnpm run dev:all   # React(3000), FastAPI(8000), marimo(2718) を一括起動（初回は enable:marimo）
pnpm run dev:marimo # marimo のみ個別起動
```

### エディタの選択肢

#### Option A: コンテナ内エディタ（軽量）

```bash
# コンテナ内で直接編集
vim src/main.py
nano README.md
```

#### Option B: VS Code Remote Containers（推奨）

```bash
# VS Codeでコンテナに接続
code --remote-containers /workspace
```

#### Option C: ホストエディタ（ファイル共有）

```bash
# ホストマシンで任意のエディタを使用
# ファイルは自動で同期される
```

### セキュリティ機能

- 破壊的操作の隔離: `rm -rf *` 等の誤操作をコンテナ内に限定
- ネットワーク制限: 許可されたドメインのみアクセス可能
- ファイアウォール: DevContainer と同等の iptables 設定
- 追加ドメイン許可: 環境変数で柔軟に設定可能

### 追加ドメインの許可

```bash
# 追加ドメインの許可例（.envファイル）
ADDITIONAL_ALLOWED_DOMAINS=npm.company.com,pypi.company.com
```

## 標準Docker環境

エディタ不問（Vim/Emacs/IntelliJ 等）で開発できる汎用的な環境です。

### 標準Docker環境の必要条件

- Docker
- pnpm（フロントエンド用）

### 使用方法

```bash
# バックエンド依存関係の同期（初回のみ推奨）
cd backend && uv sync && cd -

# バックエンド（FastAPI）をコンテナで起動（http://localhost:8000）
docker compose up app

# フロントエンドはホストで起動（http://localhost:3000）
pnpm install --recursive
pnpm run dev:frontend
```

### 特徴

- フロントエンド：ホストで実行（ライブリロード高速）
- バックエンド：コンテナで実行（環境統一）
- 開発効率と環境統一のバランスが良い

## フルスタックDocker環境

全てのサービスをコンテナで実行する構成です。

### フルスタック環境の使用方法

```bash
# フルスタック（React + FastAPI）を同時起動
docker compose up

# アクセス先
# - Web ダッシュボード（Caddy 経由 React/Docs/ターミナル）: http://localhost:8080
# - FastAPI: http://localhost:8000
```

### フルスタック環境の特徴

- 全サービスがコンテナで統一
- 本番環境に近い構成
- 環境の完全な統一性

## Docker Compose 構成

### サービス一覧

| サービス名  | 説明                                        | ポート               | プロファイル |
| ----------- | ------------------------------------------- | -------------------- | ------------ |
| `app`       | FastAPI バックエンド                        | 8000                 | デフォルト   |
| `frontend`  | React フロントエンド（Node 20 ランタイム）  | 3001（内部のみ）     | デフォルト   |
| `workspace` | セキュア開発用 VS Code / CLI 環境           | 3000（エディタ接続） | デフォルト   |
| `proxy`     | Caddy リバースプロキシ + Web ダッシュボード | 8080                 | デフォルト   |
| `dev`       | セキュア開発環境（手動起動用プロファイル）  | -                    | `dev`        |

### コマンド例

```bash
# バックエンドのみ起動
docker compose up app

# フロントエンド + バックエンド
docker compose up

# セキュア開発環境（推奨）
pnpm run docker:dev

# 特定サービスの再ビルド
docker compose build app

# ログの確認
docker compose logs app

# サービスの停止・削除
docker compose down

# ボリュームも含めて削除
docker compose down -v
```

## ファイル権限の同期

Docker 環境でのファイル権限問題を解決する機能です。ホストと同じ UID/GID でファイ
ルが作成されるため、権限エラーを防げます。

### docker-compose.shラッパースクリプト（推奨）

ホストの UID/GID を自動検出して設定します。

```bash
# 実行権限を付与（初回のみ）
chmod +x docker-compose.sh

# 通常のdocker composeの代わりに使用
./docker-compose.sh up          # 全サービス起動
./docker-compose.sh up -d       # バックグラウンド起動
./docker-compose.sh down        # 停止
./docker-compose.sh build       # イメージビルド

# セキュア開発環境起動
./docker-compose.sh --profile dev up -d
./docker-compose.sh exec dev claude
```

### 手動でのUID/GID設定

```bash
# 方法1: 環境変数で一時設定
export UID=$(id -u) GID=$(id -g) USER=$(id -un)
docker compose up

# 方法2: .envファイルで永続設定
cp .env.example .env
# UID=1000, GID=1000, USER=developer を適切に設定
vim .env
docker compose up

# 方法3: シェル設定ファイルに追加（~/.bashrc等）
echo 'export UID=$(id -u)' >> ~/.bashrc
echo 'export GID=$(id -g)' >> ~/.bashrc
echo 'export USER=$(id -un)' >> ~/.bashrc
source ~/.bashrc
```

### 権限同期の仕組み

- app サービス・marimo サービス: `entrypoint.sh`で gosu を使った動的ユーザー作成
- frontend サービス: Node 20 の公式イメージ上で稼働し、起動時に
  `npm install -g pnpm@9` を実行してから `pnpm dev` を起動（UID/GID は共有ボ
  リューム経由でホストと同期される）
- dev サービス: `entrypoint-dev.sh`で完全な権限管理
- proxy サービス: Caddy で `/welcome.html` と各サービスへのリバースプロキシを提
  供

### トラブルシューティング（権限関連）

```bash
# 権限エラーが発生した場合
# 1. イメージを再ビルド
docker compose build --no-cache

# 2. 現在のUID/GIDを確認
echo "UID=$(id -u) GID=$(id -g) USER=$(id -un)"

# 3. ファイル所有者を確認
ls -la

# 4. 作成されたファイルの権限を修正（必要に応じて）
sudo chown -R $(id -u):$(id -g) .
```

## 開発ワークフロー

### 通常の開発

```bash
# 1. バックエンド起動
docker compose up app

# 2. フロントエンド起動（別ターミナル）
pnpm run dev:frontend

# 3. 開発作業
# - フロントエンド: ホストで編集、ライブリロード
# - バックエンド: ホストで編集、コンテナで実行
```

### フルスタック開発

```bash
# 1. 全サービス起動
docker compose up

# 2. 開発作業
# - 全てコンテナで実行
# - ファイル変更はボリュームマウントで反映
```

### セキュア開発（Claude Code開発環境）

```bash
# 1. セキュア環境起動（推奨コマンド）
pnpm run docker:dev

# 2. コンテナに接続（推奨コマンド）
pnpm run docker:dev:connect

# 3. Claude Code で安全に開発
claude  # コンテナ内で隔離実行

# 4. 開発サーバー起動（React + FastAPI）
pnpm run dev

# React + FastAPI + marimo をまとめて起動
pnpm run dev:all

# marimo だけ追加したい場合（初回は `pnpm run enable:marimo`）
pnpm run dev:marimo
```

## トラブルシューティング

### よくある問題

#### ポート競合

症状: `Port 3000 is already in use`

解決策として、次の方法を試してください。

```bash
# 使用中のプロセスを確認
lsof -i :3000

# プロセスを終了
kill -9 <PID>
```

#### ボリュームマウントの問題

症状: ファイル変更が反映されない。

解決策として、次の方法を試してください。

```bash
# ボリュームを削除して再作成
docker compose down -v
docker compose up
```

#### 依存関係の問題

症状: `uv.lock` が見つからない。

解決策として、次の方法を試してください。

```bash
# apps/backend/uv.lock を作成
cd backend && uv sync && cd -
docker compose build app
```

### デバッグコマンド

```bash
# コンテナの状態確認
docker compose ps

# コンテナ内でシェル実行
docker compose exec app bash

# ログの確認
docker compose logs -f app

# イメージの確認
docker images

# ボリュームの確認
docker volume ls
```

## パフォーマンス最適化

### ビルド最適化

```bash
# BuildKitを有効化
export DOCKER_BUILDKIT=1

# キャッシュを活用した高速ビルド
docker compose build --parallel
```

### ボリューム最適化

```dockerfile
# Dockerfileでのマルチステージビルド
FROM node:18 AS frontend
# ... フロントエンドビルド

FROM python:3.12 AS backend
# ... バックエンドビルド
```

## 本番デプロイメント

### プロダクションビルド

```bash
# 本番用ビルド
docker compose -f docker-compose.yml -f docker-compose.prod.yml build

# 本番環境での起動
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 環境変数の管理

```bash
# 本番用環境変数
cp .env.example .env.prod

# 本番環境での起動
docker compose --env-file .env.prod up -d
```

## 補足事項

- Compose は標準でバックエンド用コンテナのみ起動します
- フロントエンドはホストで並行起動するか、フルスタック開発をコンテナで統一したい
  場合は `docker compose up` で拡張してください
- セキュア開発環境は `--profile dev` で起動し、通常のサービスとは分離されていま
  す

## 関連ドキュメント

- [DevContainer完全ガイド](devcontainer.md)
- [セキュリティ設定](security.md)
- [MCPサーバー統合](mcp-servers.md)
