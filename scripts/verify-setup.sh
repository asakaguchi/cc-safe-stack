#!/bin/bash

# セットアップ検証スクリプト - 開発環境の正常性を確認

set -euo pipefail

# 色付きログ出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 成功・失敗カウンター
SUCCESS_COUNT=0
ERROR_COUNT=0

check_command() {
    local cmd=$1
    local name=$2
    local required_version=${3:-}

    if command -v "$cmd" >/dev/null 2>&1; then
        local version
        version=$($cmd --version 2>/dev/null | head -1 || echo "version unknown")
        log_success "$name が利用可能: $version"
        ((SUCCESS_COUNT++))

        if [[ -n "$required_version" ]]; then
            local current_version
            current_version=$($cmd --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "0.0.0")
            if [[ "$current_version" < "$required_version" ]]; then
                log_warning "$name のバージョンが古い可能性があります (現在: $current_version, 推奨: $required_version 以上)"
            fi
        fi
    else
        log_error "$name が見つかりません"
        ((ERROR_COUNT++))
    fi
}

check_directory() {
    local dir=$1
    local description=$2

    if [[ -d "$dir" ]]; then
        log_success "$description ディレクトリが存在: $dir"
        ((SUCCESS_COUNT++))
    else
        log_error "$description ディレクトリが見つかりません: $dir"
        ((ERROR_COUNT++))
    fi
}

check_file() {
    local file=$1
    local description=$2

    if [[ -f "$file" ]]; then
        log_success "$description ファイルが存在: $file"
        ((SUCCESS_COUNT++))
    else
        log_error "$description ファイルが見つかりません: $file"
        ((ERROR_COUNT++))
    fi
}

main() {
    log_info "Claude Code テンプレート環境検証を開始..."
    echo

    # 1. 必須コマンドの確認
    log_info "1. 必須コマンドの確認"
    check_command "bun" "Bun" "1.0.0"
    check_command "uv" "uv" "0.1.0"
    check_command "git" "Git" "2.0.0"
    echo

    # 2. オプショナルコマンドの確認
    log_info "2. オプショナルコマンド（推奨）の確認"
    check_command "docker" "Docker"
    check_command "code" "VS Code CLI"
    echo

    # 3. プロジェクト構造の確認
    log_info "3. プロジェクト構造の確認"
    check_directory "backend" "バックエンド"
    check_directory "frontend" "フロントエンド"
    check_directory "streamlit" "Streamlit"
    check_directory "shared" "共有"
    check_directory "scripts" "スクリプト"
    check_directory "specs" "仕様書"
    echo

    # 4. 重要なファイルの確認
    log_info "4. 重要ファイルの確認"
    check_file "package.json" "ルート package.json"
    check_file "backend/pyproject.toml" "バックエンド設定"
    check_file "frontend/package.json" "フロントエンド package.json"
    check_file "TUTORIAL.md" "チュートリアル"
    check_file "CLAUDE.md" "Claude Code 設定"
    echo

    # 5. 依存関係の確認
    log_info "5. 依存関係の確認"

    # Node.js 依存関係
    if [[ -f "node_modules/.pnpm" || -d "node_modules" ]]; then
        log_success "Node.js 依存関係がインストール済み"
        ((SUCCESS_COUNT++))
    else
        log_warning "Node.js 依存関係が未インストール - 'bun install' を実行してください"
    fi

    # Python 依存関係
    if [[ -f "backend/.venv/pyvenv.cfg" || -f "backend/uv.lock" ]]; then
        log_success "Python 依存関係がインストール済み"
        ((SUCCESS_COUNT++))
    else
        log_warning "Python 依存関係が未インストール - 'cd backend && uv sync' を実行してください"
    fi
    echo

    # 6. Docker 環境の確認（オプション）
    if command -v docker >/dev/null 2>&1; then
        log_info "6. Docker 環境の確認"

        if docker info >/dev/null 2>&1; then
            log_success "Docker デーモンが起動中"
            ((SUCCESS_COUNT++))
        else
            log_warning "Docker デーモンが起動していません"
        fi

        if [[ -f "compose.yml" ]]; then
            log_success "Docker Compose 設定ファイルが存在"
            ((SUCCESS_COUNT++))
        else
            log_error "Docker Compose 設定ファイルが見つかりません"
            ((ERROR_COUNT++))
        fi
        echo
    fi

    # 7. Claude Code テンプレート固有の確認
    log_info "7. Claude Code テンプレート固有の確認"

    # backend/src ディレクトリ構造
    local backend_dirs=("models" "routers" "services" "utils" "websocket")
    for dir in "${backend_dirs[@]}"; do
        check_directory "backend/src/$dir" "backend/$dir"
    done

    # 仕様書例の確認
    if [[ -f "specs/examples/todo-app.spec.md" ]]; then
        log_success "TODO アプリ仕様書が利用可能"
        ((SUCCESS_COUNT++))
    else
        log_error "TODO アプリ仕様書が見つかりません"
        ((ERROR_COUNT++))
    fi
    echo

    # 結果サマリー
    log_info "検証結果サマリー"
    echo "✅ 成功: $SUCCESS_COUNT"
    echo "❌ エラー: $ERROR_COUNT"
    echo

    if [[ $ERROR_COUNT -eq 0 ]]; then
        log_success "すべての検証に成功しました！Claude Code での開発を開始できます。"
        echo
        log_info "次のステップ:"
        echo "1. 'bun run dev' で開発サーバーを起動"
        echo "2. Claude Code に仕様書を使った実装を依頼"
        echo "   例: \"specs/examples/todo-app.spec.md の仕様で実装してください\""
        exit 0
    else
        log_error "$ERROR_COUNT 個の問題が見つかりました。上記のエラーを解決してから再実行してください。"
        echo
        log_info "トラブルシューティング:"
        echo "- 依存関係の問題: 'bun run setup' を実行"
        echo "- 詳細なセットアップ手順: README.md を参照"
        echo "- Docker 関連の問題: 'bun run docker:dev' を試行"
        exit 1
    fi
}

main "$@"