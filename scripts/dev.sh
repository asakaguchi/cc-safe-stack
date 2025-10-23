#!/bin/bash
set -euo pipefail

# Docker環境の検出
if [ -f "/.dockerenv" ]; then
    echo "🐳 Docker environment detected. Using Docker-optimized development script..."
    exec "$(dirname "$0")/dev-docker.sh"
fi

# marimo 同時起動の有無（環境変数 or フラグ）
START_MARIMO="${WITH_MARIMO:-0}"

if [[ "${1:-}" == "--with-marimo" ]]; then
    START_MARIMO=1
    shift
fi

if [[ "$START_MARIMO" == "1" ]]; then
    echo "🚀 Starting Full-Stack Development Servers (React + FastAPI + marimo)..."
else
    echo "🚀 Starting Full-Stack Development Servers (React + FastAPI)..."
fi

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Function to cleanup background processes
cleanup() {
    log_info "Shutting down development servers..."
    jobs -p | xargs -r kill
    exit 0
}

# Trap SIGINT and SIGTERM to cleanup
trap cleanup SIGINT SIGTERM

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/apps/backend/pyproject.toml" ]; then
    echo "❌ Could not find project files in $PROJECT_ROOT"
    exit 1
fi

# Check if dependencies are installed
if [ ! -d "$PROJECT_ROOT/apps/backend/.venv" ]; then
    log_warning "Backend dependencies not found. Running setup..."
    "$PROJECT_ROOT/scripts/setup.sh"
fi

if [ ! -d "$PROJECT_ROOT/apps/frontend/node_modules" ]; then
    log_warning "Frontend dependencies not found. Running setup..."
    "$PROJECT_ROOT/scripts/setup.sh"
fi

log_info "Starting backend server (Python/FastAPI)..."
cd "$PROJECT_ROOT/apps/backend"
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

log_info "Starting frontend server (TypeScript/React)..."
cd "$PROJECT_ROOT"
pnpm --dir "$PROJECT_ROOT/apps/frontend" dev -- --host 0.0.0.0 &
FRONTEND_PID=$!

if [[ "$START_MARIMO" == "1" ]]; then
    STATE_FILE="$PROJECT_ROOT/extensions/marimo/.enabled"
    if [[ ! -f "$STATE_FILE" ]]; then
        log_warning "marimo 拡張が有効化されていません。'pnpm run enable:marimo' 実行後に依存を同期してください。"
    fi

    log_info "Starting marimo dashboard (Python/marimo)..."
    "$SCRIPT_DIR/dev-marimo.sh" &
    MARIMO_PID=$!
fi

log_success "All development servers started!"
echo ""
echo "🌐 React UI:    http://localhost:3000"
echo "🐍 FastAPI:     http://localhost:8000"
echo "📚 API Docs:    http://localhost:8000/docs"
if [[ "$START_MARIMO" == "1" ]]; then
    echo "🧮 marimo:      http://localhost:2718"
fi
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for background processes
wait
