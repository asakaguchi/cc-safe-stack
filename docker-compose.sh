#!/bin/bash

# Docker Compose ラッパースクリプト
# ホストのUID/GID/USERを自動検出してdocker composeを実行する

set -euo pipefail
IFS=$'\n\t'

# 色付きメッセージ用の関数
info() {
    echo -e "\033[36m[INFO]\033[0m $1"
}

warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# UID/GID/USERを自動検出
export UID=$(id -u)
export GID=$(id -g)
export USER=$(id -un)

# デバッグ情報を表示
info "Docker Compose with Host User Sync"
info "UID=$UID, GID=$GID, USER=$USER"

# Docker Composeが利用可能かチェック
if ! command -v docker &> /dev/null; then
    error "Docker is not installed or not in PATH"
    exit 1
fi

if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    error "Docker Compose is not installed or not in PATH"
    exit 1
fi

# Docker Composeコマンドを決定（新しい形式を優先）
if command -v docker compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    warn "Using legacy docker-compose command. Consider updating to 'docker compose'"
fi

# 引数がない場合はヘルプを表示
if [ $# -eq 0 ]; then
    info "Usage: $0 [docker-compose-options]"
    info ""
    info "Examples:"
    info "  $0 up                    # Start all services"
    info "  $0 up -d                 # Start in detached mode"
    info "  $0 down                  # Stop all services"
    info "  $0 build                 # Build all images"
    info "  $0 build --no-cache      # Rebuild from scratch"
    info "  $0 logs -f app           # Follow logs for app service"
    info ""
    info "This script automatically sets UID=$UID, GID=$GID, USER=$USER"
    info "to ensure proper file ownership in containers."
    exit 0
fi

# Docker Composeを実行
info "Running: $COMPOSE_CMD $*"
exec $COMPOSE_CMD "$@"