#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Docker開発環境セットアップスクリプト
echo "🐳 Docker開発環境のセットアップを開始します..."

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# エラーハンドリング
error_exit() {
    echo -e "${RED}❌ エラー: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 必要条件の確認
echo "🔍 必要条件を確認中..."

# Dockerの確認
if ! command -v docker &> /dev/null; then
    error_exit "Dockerがインストールされていません。https://docs.docker.com/get-docker/ を参照してください。"
fi

# Docker Composeの確認
if ! docker compose version &> /dev/null; then
    error_exit "Docker Composeが利用できません。Dockerの最新版をインストールしてください。"
fi

success "Docker環境が利用可能です"

# プロジェクトルートの確認
if [ ! -f "compose.yml" ] || [ ! -f "docker/Dockerfile.dev" ]; then
    error_exit "プロジェクトルートで実行してください（compose.ymlとdocker/Dockerfile.devが必要）"
fi

# 環境変数ファイルの設定
echo "📝 環境変数の設定..."

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        success ".env.exampleから.envファイルを作成しました"
    else
        error_exit ".env.exampleファイルが見つかりません"
    fi
else
    info ".envファイルが既に存在します"
fi


# ユーザーID/グループIDの設定
echo "👤 ユーザー権限の設定..."

USER_ID=$(id -u)
GROUP_ID=$(id -g)

# .envファイルにユーザー情報を追加（既に存在しない場合）
if ! grep -q "USER_ID=" .env; then
    echo "USER_ID=$USER_ID" >> .env
    echo "GROUP_ID=$GROUP_ID" >> .env
    success "ユーザーID設定を追加しました（USER_ID=$USER_ID, GROUP_ID=$GROUP_ID）"
else
    info "ユーザーID設定は既に存在します"
fi

# Dockerイメージのビルド
echo "🔨 Dockerイメージをビルド中..."

if docker compose --profile dev build dev; then
    success "Dockerイメージのビルドが完了しました"
else
    error_exit "Dockerイメージのビルドに失敗しました"
fi

# 必要なボリュームの作成確認
echo "💾 Dockerボリュームの確認..."
docker compose --profile dev up -d dev --no-deps --no-recreate || true
docker compose --profile dev down || true
success "Dockerボリュームが準備されました"

# セットアップ完了メッセージ
echo ""
echo "🎉 Docker開発環境のセットアップが完了しました！"
echo ""
echo "📋 使用方法:"
echo "1. 開発環境の起動:"
echo "   ${GREEN}docker compose --profile dev up -d dev${NC}"
echo ""
echo "2. コンテナに接続:"
echo "   ${GREEN}docker exec -it claude-code-polyglot-starter-dev-1 zsh${NC}"
echo ""
echo "3. Claude Code CLIの起動（コンテナ内）:"
echo "   ${GREEN}claude${NC}"
echo ""
echo "4. 開発サーバーの起動（コンテナ内）:"
echo "   ${GREEN}bun run dev${NC}"
echo ""
echo "📖 詳細な使用方法は README.md の「Docker開発環境（セキュア・Claude Code統合）」セクションを参照してください。"
echo ""


echo "🚀 Happy coding with Claude Code!"