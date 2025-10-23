#!/bin/bash
set -euo pipefail

echo "🐳 Starting Full-Stack Development Servers in Docker (React + FastAPI)..."

# Docker環境用の動的パス設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

# DevContainer環境とDocker Compose環境の自動判定
if [ -d "/workspace" ] && [ -f "/workspace/package.json" ]; then
    # DevContainer環境 (/workspace)
    WORKSPACE_ROOT="/workspace"
elif [ -d "/app" ] && [ -f "/app/package.json" ]; then
    # Docker Compose環境 (/app)
    WORKSPACE_ROOT="/app"
fi

BACKEND_DIR="$WORKSPACE_ROOT/apps/backend"
FRONTEND_DIR="$WORKSPACE_ROOT/apps/frontend" 

export UV_CACHE_DIR="${WORKSPACE_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to cleanup background processes
cleanup() {
    log_info "Shutting down development servers..."
    jobs -p | xargs -r kill 2>/dev/null || true
    # Dockerコンテナ内では追加のクリーンアップを実行
    pkill -f "uvicorn main:app" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true
    exit 0
}

# Trap SIGINT and SIGTERM to cleanup
trap cleanup SIGINT SIGTERM

# Docker環境の確認
if [ ! -f "/.dockerenv" ]; then
    log_warning "Docker環境外で実行されています。通常のdev.shの使用を推奨します。"
fi

# プロジェクトファイルの存在確認
if [ ! -f "$WORKSPACE_ROOT/package.json" ]; then
    log_error "package.jsonが見つかりません in $WORKSPACE_ROOT"
    exit 1
fi

if [ ! -f "$BACKEND_DIR/pyproject.toml" ]; then
    log_error "pyproject.tomlが見つかりません in $BACKEND_DIR"
    exit 1
fi

# 依存関係の確認とインストール
log_info "依存関係を確認中..."

# バックエンド依存関係
if [ ! -d "$BACKEND_DIR/.venv" ]; then
    log_warning "Python仮想環境が見つかりません。作成中..."
    cd "$BACKEND_DIR"
    uv sync
fi

# フロントエンド依存関係
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    log_warning "Node.js依存関係が見つかりません。インストール中..."
    cd "$WORKSPACE_ROOT"
    pnpm install --recursive
fi

# バックエンドサーバーの起動
log_info "Starting backend server (Python/FastAPI)..."
cd "$BACKEND_DIR"
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000 > /tmp/backend.log 2>&1 &
BACKEND_PID=$!

# 少し待ってからバックエンドの起動確認
sleep 2
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    log_error "Backend server failed to start. Check logs:"
    cat /tmp/backend.log
    exit 1
fi

# フロントエンドサーバーの起動
log_info "Starting frontend server (TypeScript/React)..."
cd "$FRONTEND_DIR"
pnpm dev -- --host 0.0.0.0 --port 3000 > /tmp/frontend.log 2>&1 &
FRONTEND_PID=$!

# 少し待ってからフロントエンドの起動確認
sleep 2
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    log_error "Frontend server failed to start. Check logs:"
    cat /tmp/frontend.log
    exit 1
fi

log_success "Development servers started in Docker environment!"
echo ""
echo "🌐 服务端口 (Docker内部):"
echo "   React UI:    http://0.0.0.0:3000"
echo "   FastAPI:     http://0.0.0.0:8000"
echo "   API Docs:    http://0.0.0.0:8000/docs"
echo ""
echo "🌐 ホストからのアクセス:"
echo "   React UI:    http://localhost:3000"
echo "   FastAPI:     http://localhost:8000"
echo "   API Docs:    http://localhost:8000/docs"
echo ""
echo "📋 ログファイル:"
echo "   Backend:     /tmp/backend.log"
echo "   Frontend:    /tmp/frontend.log"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# プロセス監視と自動再起動
monitor_processes() {
    while true; do
        sleep 5
        
        # Backend monitoring
        if [ -n "${BACKEND_PID:-}" ] && ! kill -0 $BACKEND_PID 2>/dev/null; then
            log_warning "Backend server stopped unexpectedly. Restarting..."
            cd "$BACKEND_DIR"
            uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000 > /tmp/backend.log 2>&1 &
            BACKEND_PID=$!
        fi
        
        # Frontend monitoring
        if [ -n "${FRONTEND_PID:-}" ] && ! kill -0 $FRONTEND_PID 2>/dev/null; then
            log_warning "Frontend server stopped unexpectedly. Restarting..."
            cd "$FRONTEND_DIR"
            pnpm dev -- --host 0.0.0.0 --port 3000 > /tmp/frontend.log 2>&1 &
            FRONTEND_PID=$!
        fi
    done
}

# バックグラウンドでプロセス監視を開始
monitor_processes &
MONITOR_PID=$!

# メインプロセスの待機
wait
