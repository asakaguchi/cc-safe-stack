#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# PostStart script - runs every time the container starts
echo "🔄 DevContainer 起動時処理開始..."

# Load environment variables from devcontainer.local.json if it exists
LOCAL_CONFIG_FILE="${PWD}/.devcontainer/devcontainer.local.json"

if [ -f "$LOCAL_CONFIG_FILE" ]; then
    echo "📋 devcontainer.local.json を検出、環境変数を読み込み中..."
    
    # Call the helper script to load environment variables
    if [ -f "${PWD}/.devcontainer/scripts/load-local-env.sh" ]; then
        source "${PWD}/.devcontainer/scripts/load-local-env.sh" "$LOCAL_CONFIG_FILE"
    else
        echo "⚠️  load-local-env.sh が見つかりません"
    fi
else
    echo "ℹ️  devcontainer.local.json が見つかりません（オプション設定）"
fi

# Run firewall initialization if secure mode is enabled
if [ "${SECURE_MODE:-}" = "true" ]; then
    echo "🛡️  セキュアモード有効、ファイアウォール設定実行中..."
    
    # Show current additional domains if any
    if [ -n "${ADDITIONAL_ALLOWED_DOMAINS:-}" ]; then
        echo "📡 追加許可ドメイン: $ADDITIONAL_ALLOWED_DOMAINS"
    fi
    
    sudo "${PWD}/.devcontainer/secure/init-firewall.sh"
    echo "✅ ファイアウォール設定完了"
else
    echo "ℹ️  セキュアモード無効"
fi

echo "✅ DevContainer 起動時処理完了"