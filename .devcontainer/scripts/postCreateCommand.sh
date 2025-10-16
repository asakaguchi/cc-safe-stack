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

# NPM_CONFIG_PREFIXをunsetしてNVMとの競合を回避
unset NPM_CONFIG_PREFIX

# NVM環境をソースして npm/node を利用可能にする
export NVM_DIR="/usr/local/share/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  echo "✓ NVM 環境をロード完了"
  
  # NVMでNode.jsのバージョンを選択（デフォルト → LTS → 最新の順で試行）
  nvm use default 2>/dev/null || nvm use --lts 2>/dev/null || nvm use node 2>/dev/null
  echo "✓ Node.js $(node --version) を使用中"
else
  echo "⚠️  NVM が見つかりません。代替方法を試行..."
fi

# npm が利用可能かチェック
if command -v npm >/dev/null 2>&1; then
  echo "✓ npm が利用可能です（NVMにより管理）"
  
  # グローバルパッケージのインストール（NVMのディレクトリに自動配置）
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
  claude --version || echo "Claude Code のインストールが完了しました"

  # Chrome DevTools MCP 関連パッケージをインストール
  echo "🌐 Chrome DevTools MCP 関連パッケージをインストール中..."
  npm i -g \
    chrome-devtools-mcp@latest \
    puppeteer@latest \
    lighthouse@latest

  # Google Chrome のインストール
  echo "🌐 Google Chrome をインストール中..."
  if ! command -v google-chrome-stable >/dev/null 2>&1; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
    echo "✓ Google Chrome がインストールされました"
  else
    echo "✓ Google Chrome は既にインストールされています"
  fi

  # Google Cloud SDK の確認 (DevContainer Featureでインストール済み)
  echo "☁️  Google Cloud SDK を確認中..."
  if command -v gcloud >/dev/null 2>&1; then
    echo "✓ Google Cloud SDK は利用可能です ($(gcloud version --format='value(version)'))"
  else
    echo "⚠️  Google Cloud SDK が見つかりません"
  fi
else
  echo "❌ npm が利用できません。手動でツールをインストールしてください。"
  echo "   コンテナ内で以下を実行してください："
  echo "   source /usr/local/share/nvm/nvm.sh && nvm use --lts && npm install -g <packages>"
fi

# Git 設定の確認と修正
echo "🔧 Git 設定修正中..."
git config --global --add safe.directory /workspace || true

# Claude CLI 設定ディレクトリのセットアップ
echo "🤖 Claude CLI セットアップ中..."
sudo mkdir -p /home/vscode/.claude/plugins
sudo chmod -R 755 /home/vscode/.claude
sudo chown -R vscode:vscode /home/vscode/.claude

# Puppeteer キャッシュディレクトリのセットアップ
echo "🌐 Puppeteer キャッシュディレクトリセットアップ中..."
mkdir -p "${PUPPETEER_CACHE_DIR:-/workspace/.cache/puppeteer}"
chmod -R 755 "${PUPPETEER_CACHE_DIR:-/workspace/.cache/puppeteer}"

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
