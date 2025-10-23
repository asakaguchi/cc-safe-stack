#!/bin/bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OVERRIDE_PATH="$PROJECT_ROOT/docker-compose.override.yml"
STATE_FILE="$PROJECT_ROOT/extensions/marimo/.enabled"

log_info "marimo 拡張を無効化します"

if [ -L "$OVERRIDE_PATH" ]; then
  TARGET="$(readlink "$OVERRIDE_PATH")"
  if [[ "$TARGET" == "docker-compose.marimo.yml" || "$TARGET" == "$PROJECT_ROOT/docker-compose.marimo.yml" ]]; then
    rm "$OVERRIDE_PATH"
    log_success "docker-compose.override.yml のシンボリックリンクを削除しました"
  else
    log_warning "docker-compose.override.yml は他の用途で使用されています (→ $TARGET)"
  fi
elif [ -e "$OVERRIDE_PATH" ]; then
  log_warning "docker-compose.override.yml はファイルとして存在するため削除しません"
else
  log_info "docker-compose.override.yml は存在しません"
fi

rm -f "$STATE_FILE"
log_success "marimo 拡張を無効化しました"
log_info "不要になった依存パッケージを削除する場合は 'uv cache prune' を利用してください"
