#!/bin/bash

# テンプレートリポジトリとして使用される際に、
# 動的にプロジェクト名を取得してDockerコンテナに接続する

set -e

# 現在のディレクトリ名を取得（プロジェクト名として使用）
PROJECT_NAME=$(basename "$(pwd)")
CONTAINER_NAME="${PROJECT_NAME}-dev-1"

# コンテナが実行中か確認
if ! docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "エラー: コンテナ '${CONTAINER_NAME}' が実行されていません"
    echo "まず 'bun run docker:dev' でコンテナを起動してください"
    exit 1
fi

# TTYサポートの確認
if [ ! -t 0 ] || [ ! -t 1 ]; then
    echo "警告: TTY環境が検出されません"
    echo "直接以下のコマンドを実行してください:"
    echo "  docker exec -it ${CONTAINER_NAME} zsh"
    exit 0
fi

# ホストのユーザー名を取得（環境変数から、なければ現在のユーザー名を使用）
USER_NAME=${USER_NAME:-$(id -un)}

echo "コンテナ '${CONTAINER_NAME}' にユーザー '${USER_NAME}' として接続中..."

# ユーザーが存在するかチェック
if docker exec "${CONTAINER_NAME}" id "${USER_NAME}" >/dev/null 2>&1; then
    # ユーザーが存在する場合、そのユーザーとして接続
    docker exec -it --user "${USER_NAME}" "${CONTAINER_NAME}" zsh
else
    echo "警告: ユーザー '${USER_NAME}' がコンテナ内に存在しません"
    echo "rootユーザーとして接続します"
    docker exec -it "${CONTAINER_NAME}" zsh
fi