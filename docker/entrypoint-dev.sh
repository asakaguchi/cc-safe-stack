#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Docker開発環境用エントリポイントスクリプト
echo "🚀 Docker開発環境を初期化中..."

DEV_ENTRY_MODE=${DEV_ENTRY_MODE:-shell}

# ユーザーIDとグループIDの設定（ホストとの同期）
USER_ID=${USER_ID:-$(stat -c '%u' /workspace 2>/dev/null || echo 1000)}
GROUP_ID=${GROUP_ID:-$(stat -c '%g' /workspace 2>/dev/null || echo 1000)}
USER_NAME=${USER_NAME:-developer}
GROUP_NAME=${GROUP_NAME:-${USER_NAME:-developer}}

echo "ℹ️  ユーザー設定: $USER_NAME($USER_ID), グループ: $GROUP_NAME($GROUP_ID)"

# 既存のユーザーを削除してから新しく作成
userdel -r vscode > /dev/null 2>&1 || true
groupadd -g ${GROUP_ID} ${GROUP_NAME} > /dev/null 2>&1 || true
useradd -u ${USER_ID} -g ${GROUP_NAME} -G sudo -o -m -s /bin/zsh ${USER_NAME} > /dev/null 2>&1 || true

# ZShell設定をユーザーホームディレクトリにコピー
if [ -f /etc/skel/.zshrc ]; then
    cp /etc/skel/.zshrc /home/${USER_NAME}/.zshrc
    chown ${USER_NAME}:${GROUP_NAME} /home/${USER_NAME}/.zshrc
fi

# 作業ディレクトリの権限を調整
chown -R ${USER_NAME}:${GROUP_NAME} /workspace || true

# セキュアモードのチェック
if [ "${SECURE_MODE:-true}" = "true" ]; then
    echo "🛡️  セキュアモード有効、ファイアウォール設定実行中..."
    
    # 追加許可ドメインの表示
    if [ -n "${ADDITIONAL_ALLOWED_DOMAINS:-}" ]; then
        echo "📡 追加許可ドメイン: $ADDITIONAL_ALLOWED_DOMAINS"
    fi
    
    # ファイアウォール設定の実行
    /usr/local/bin/init-firewall.sh
    echo "✅ ファイアウォール設定完了"
else
    echo "ℹ️  セキュアモード無効（SECURE_MODE=${SECURE_MODE:-}）"
fi

# Claude Code CLIディレクトリの設定
echo "🤖 Claude Code CLI設定中..."
# ユーザーのホームディレクトリにClaude設定を配置
gosu ${USER_NAME} bash -c "
    mkdir -p /home/${USER_NAME}/.claude
    echo 'Claude Code CLIディレクトリを設定しました'
"

# Python環境の初期化
echo "🐍 Python環境を確認中..."
if [ -f "/workspace/backend/pyproject.toml" ]; then
    echo "📦 Python依存関係を同期中..."
    gosu ${USER_NAME} bash -c "cd /workspace/backend && uv sync" || echo "⚠️  uv sync failed"
fi

# Node.js環境の初期化
echo "📦 Node.js環境を確認中..."
if [ -f "/workspace/frontend/package.json" ]; then
    echo "📦 Node.js依存関係をインストール中..."
    gosu ${USER_NAME} bash -c "cd /workspace && pnpm install --recursive" || echo "⚠️  pnpm install failed"
fi

# 開発ツールの使用方法を表示
echo ""
echo "🎉 Docker開発環境の初期化完了！"
echo ""
echo "📋 利用可能なコマンド:"
echo "   claude           # Claude Code CLIを起動"
echo "   pnpm run dev     # 全サーバーを起動"
echo "   pnpm run lint    # コード品質チェック"
echo "   vim/nano         # エディタ"
echo ""
echo "🔧 開発サーバー:"
echo "   - React(frontend): http://localhost:3000"
echo "   - FastAPI(backend): http://localhost:8000"  
echo "   - Streamlit: http://localhost:8501"
echo ""

# 実行モードに応じた処理
if [[ "$DEV_ENTRY_MODE" == "workspace" ]]; then
    echo "🌐 Webワークスペースモードで起動します（ローカル開発専用 - 認証なし）"

    WORKSPACE_TMP=/tmp/workspace-services
    mkdir -p "$WORKSPACE_TMP"

    start_openvscode() {
        echo "▶️  OpenVSCode Server を起動します（認証なし - ローカル開発専用）..."
        exec gosu ${USER_NAME} "${OPENVSCODE_SERVER_DIR}/bin/openvscode-server" \
            --host 0.0.0.0 \
            --port 3000 \
            --server-base-path /vscode \
            --without-connection-token \
            --telemetry-level off
    }

    start_ttyd_1() {
        echo "▶️  ttyd 1 を起動します..."
        exec ttyd -p 7681 -i 0.0.0.0 -b /terminal/1 -W gosu ${USER_NAME} /bin/zsh
    }

    start_ttyd_2() {
        echo "▶️  ttyd 2 を起動します..."
        exec ttyd -p 7682 -i 0.0.0.0 -b /terminal/2 -W gosu ${USER_NAME} /bin/zsh
    }

    start_ttyd_3() {
        echo "▶️  ttyd 3 を起動します..."
        exec ttyd -p 7683 -i 0.0.0.0 -b /terminal/3 -W gosu ${USER_NAME} /bin/zsh
    }

    trap 'echo "⏹️  サービスを停止中..."; kill 0' SIGINT SIGTERM

    start_openvscode &
    vscode_pid=$!

    start_ttyd_1 &
    ttyd1_pid=$!

    start_ttyd_2 &
    ttyd2_pid=$!

    start_ttyd_3 &
    ttyd3_pid=$!

    echo "✅ Webワークスペースが起動しました"
    echo "   VSCode: PID=${vscode_pid}"
    echo "   ターミナル1: PID=${ttyd1_pid}"
    echo "   ターミナル2: PID=${ttyd2_pid}"
    echo "   ターミナル3: PID=${ttyd3_pid}"

    wait -n $vscode_pid $ttyd1_pid $ttyd2_pid $ttyd3_pid
    exit $?
fi

# コマンドの実行（引数がある場合はそれを実行、なければzshを起動）
if [[ $# -eq 0 ]]; then
    echo "🚀 インタラクティブシェルを起動中..."
    exec gosu ${USER_NAME} /bin/zsh
else
    echo "🔧 コマンドを実行中: $*"
    exec gosu ${USER_NAME} "$@"
fi
