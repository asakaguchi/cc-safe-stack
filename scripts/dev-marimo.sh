#!/bin/bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_PATH="$PROJECT_ROOT/extensions/marimo/app.py"

export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"

if [ ! -f "$APP_PATH" ]; then
  log_error "marimo ノートブックが見つかりません ($APP_PATH)"
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  log_error "uv が見つかりません。'pip install uv' あるいは 'curl -LsSf https://astral.sh/install.sh | sh' を実行してください"
  exit 1
fi

log_info "marimo ダッシュボードを起動します (http://localhost:2718)"
cd "$PROJECT_ROOT/apps/backend"
exec uv run --no-sync marimo run "$APP_PATH" --host 0.0.0.0 --port 2718 "$@"
