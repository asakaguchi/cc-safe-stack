#!/bin/bash
set -euo pipefail

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if ! command -v docker >/dev/null 2>&1; then
  log_error "docker が見つかりません"
  exit 1
fi

if [ $# -eq 0 ]; then
  log_error "コマンドを指定してください (例: up -d, down, logs marimo)"
  exit 1
fi

COMPOSE_MAIN="$PROJECT_ROOT/compose.yml"
COMPOSE_MARIMO="$PROJECT_ROOT/docker-compose.marimo.yml"

if [ ! -f "$COMPOSE_MARIMO" ]; then
  log_error "docker-compose.marimo.yml が見つかりません"
  exit 1
fi

export USER_ID=${USER_ID:-$(id -u)}
export GROUP_ID=${GROUP_ID:-$(id -g)}
export USER_NAME=${USER_NAME:-$(id -un)}

log_info "docker compose -f compose.yml -f docker-compose.marimo.yml $*"
exec docker compose -f "$COMPOSE_MAIN" -f "$COMPOSE_MARIMO" "$@"
