#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Helper script to load environment variables from devcontainer.local.json
# Usage: source load-local-env.sh /path/to/devcontainer.local.json

LOCAL_CONFIG_FILE="${1:-}"

if [ -z "$LOCAL_CONFIG_FILE" ]; then
    echo "❌ エラー: 設定ファイルのパスが指定されていません"
    echo "使用法: source load-local-env.sh /path/to/devcontainer.local.json"
    return 1 2>/dev/null || exit 1
fi

if [ ! -f "$LOCAL_CONFIG_FILE" ]; then
    echo "❌ エラー: 設定ファイルが見つかりません: $LOCAL_CONFIG_FILE"
    return 1 2>/dev/null || exit 1
fi

# Validate JSON syntax
if ! jq . "$LOCAL_CONFIG_FILE" > /dev/null 2>&1; then
    echo "❌ エラー: 不正なJSON形式: $LOCAL_CONFIG_FILE"
    return 1 2>/dev/null || exit 1
fi

# Check if containerEnv exists
if ! jq -e '.containerEnv' "$LOCAL_CONFIG_FILE" > /dev/null 2>&1; then
    echo "ℹ️  containerEnv セクションが見つかりません"
    return 0 2>/dev/null || exit 0
fi

echo "📋 環境変数を読み込み中: $LOCAL_CONFIG_FILE"

# Export each environment variable from containerEnv
while IFS="=" read -r key value; do
    if [ -n "$key" ] && [ -n "$value" ]; then
        # Remove quotes from value if present
        value=$(echo "$value" | sed 's/^"//; s/"$//')
        export "$key"="$value"
        echo "  ✓ $key=$value"
    fi
done < <(jq -r '.containerEnv | to_entries[] | "\(.key)=\(.value)"' "$LOCAL_CONFIG_FILE")

echo "✅ 環境変数の読み込み完了"