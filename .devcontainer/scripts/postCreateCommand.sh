#!/bin/bash
set -e

echo "🚀 DevContainer セットアップ開始..."

# Python 環境のセットアップ
echo "🐍 Python 環境セットアップ中..."
# ルートの Python ツール群（pre-commit など）
uv sync --frozen
# バックエンド（FastAPI）の依存関係
pushd backend >/dev/null
uv sync --frozen
popd >/dev/null

# JavaScript/TypeScript グローバルツールのインストール（features で提供されないもの）
echo "📦 JavaScript ツールインストール中..."

# NVM環境をソースして npm/node を利用可能にする
export NVM_DIR="/usr/local/share/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  echo "✓ NVM 環境をロード完了"
else
  echo "⚠️  NVM が見つかりません。代替方法を試行..."
fi

# npm が利用可能かチェック
if command -v npm >/dev/null 2>&1; then
  echo "✓ npm が利用可能です"
  # npm のグローバルプレフィックスをユーザー書き込み可能に設定
  mkdir -p "$HOME/.npm-global"
  npm config set prefix "$HOME/.npm-global"
  
  # PATH 永続化（bash / zsh）
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    grep -q 'NPM_CONFIG_PREFIX' "$rc" 2>/dev/null || echo 'export NPM_CONFIG_PREFIX="$HOME/.npm-global"' >> "$rc"
    grep -q '.npm-global/bin' "$rc" 2>/dev/null || echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$rc"
  done

  # グローバルパッケージのインストール
  echo "📦 npm グローバルパッケージをインストール中..."
  npm install -g \
    textlint@latest \
    textlint-rule-preset-ja-technical-writing@latest \
    textlint-rule-preset-ja-spacing@latest \
    @textlint-ja/textlint-rule-preset-ai-writing@latest \
    textlint-filter-rule-comments@latest \
    markdownlint-cli2@latest

  # Claude Code（最新）をユーザー権限でインストール
  echo "🤖 Claude Code をインストール中..."
  npm i -g @anthropic-ai/claude-code@latest
  hash -r || true
  claude --version || true
else
  echo "❌ npm が利用できません。手動でツールをインストールしてください。"
  echo "   または、コンテナ内で以下を実行してください："
  echo "   source /usr/local/share/nvm/nvm.sh && npm install -g <packages>"
fi

# Git 設定の確認と修正
echo "🔧 Git 設定修正中..."
git config --global --add safe.directory /workspace || true

# Claude CLI 設定ディレクトリのセットアップ
echo "🤖 Claude CLI セットアップ中..."
sudo mkdir -p /home/vscode/.claude/plugins
sudo chmod -R 755 /home/vscode/.claude
sudo chown -R vscode:vscode /home/vscode/.claude

# pre-commit のセットアップ
echo "🔒 pre-commit セットアップ中..."
# pre-commit キャッシュディレクトリを作成
mkdir -p "${PRE_COMMIT_HOME:-$PWD/.cache/pre-commit}"
# pre-commit インストール実行
uv run pre-commit install --install-hooks || {
  echo "⚠️  pre-commit インストール失敗、権限を修正して再試行..."
  chmod -R 755 .git/hooks 2>/dev/null || true
  mkdir -p "${PRE_COMMIT_HOME:-$PWD/.cache/pre-commit}"
  uv run pre-commit install --install-hooks
}

echo "✅ DevContainer セットアップ完了！"
