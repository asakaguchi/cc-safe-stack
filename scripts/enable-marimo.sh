#!/bin/bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OVERRIDE_PATH="$PROJECT_ROOT/docker-compose.override.yml"
MARIMO_COMPOSE="$PROJECT_ROOT/docker-compose.marimo.yml"
STATE_FILE="$PROJECT_ROOT/extensions/marimo/.enabled"

export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"

log_info "marimo 拡張を有効化します"

if [ ! -f "$MARIMO_COMPOSE" ]; then
  log_error "docker-compose.marimo.yml が見つかりません"
  exit 1
fi

# docker-compose.override.yml が既に存在する場合の保護
if [ -e "$OVERRIDE_PATH" ] && [ ! -L "$OVERRIDE_PATH" ]; then
  log_warning "既存の docker-compose.override.yml が存在します。marimo 用に上書きしません。"
  log_warning "手動で compose ファイルに docker-compose.marimo.yml を追加してください。"
else
  ln -sfn "docker-compose.marimo.yml" "$OVERRIDE_PATH"
  log_success "docker-compose.override.yml を marimo 用に作成しました"
fi

# marimo 拡張依存の同期
if command -v uv >/dev/null 2>&1; then
  log_info "uv sync --group marimo-extensions を実行します"
  if (cd "$PROJECT_ROOT/apps/backend" && uv sync --group marimo-extensions); then
    log_success "marimo 拡張依存を同期しました"
  else
    log_warning "marimo 拡張依存の同期に失敗しました。後で 'cd apps/backend && uv sync --group marimo-extensions' を試してください"
  fi
else
  log_warning "uv が見つかりません。marimo 拡張依存の同期をスキップしました"
fi

mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n' "enabled" > "$STATE_FILE"
log_success "marimo 拡張を有効化しました"
log_info "marimo ダッシュボードを起動するには 'pnpm run dev:marimo' を実行してください"
