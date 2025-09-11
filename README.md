# Claude-Code-Polyglot-Starter

モダンなフルスタック開発環境（Python + TypeScript）

## 概要

本プロジェクトは、Python（FastAPI）、TypeScript（React）、Streamlit を組み合わせ
たモダンなフルスタック開発環境です。モノリポ構成により、3 つのフロントエンドを統
合的に開発できます。

### 3つのフロントエンド構成

- **React** - プロダクション向けのモダン UI
- **Streamlit** - データ分析・管理者ダッシュボード
- **FastAPI Docs** - 自動生成される API 仕様書

## 🛠️ 技術スタック

### バックエンド（Python）

- **Python 3.12+** - モダンな Python 環境
- **FastAPI** - 高性能な Web API フレームワーク
- **Pydantic** - データバリデーション
- **uv** - 高速パッケージマネージャー

### フロントエンド（TypeScript）

- **TypeScript** - 型安全な JavaScript
- **React 18** - モダンな UI ライブラリ
- **Vite** - 高速ビルドツール
- **bun** - 高速パッケージマネージャー

### データアプリケーション（Streamlit）

- **Streamlit** - Python でのデータアプリ構築
- **Pandas** - データ分析・処理
- **Plotly** - インタラクティブな可視化

### 開発ツール

- **VS Code DevContainers** - 統一された開発環境
- **Claude Code CLI** - AI 支援開発ツール
- **Context7 MCP** - 最新ライブラリドキュメント統合
- **Docker Compose** - コンテナ オーケストレーション

## クイックスタート

### VS Code DevContainer（推奨）

```bash
# 1. VS Code でプロジェクトを開く
code .

# 2. コマンドパレットで「Reopen in Container」を実行
# → "Python & TypeScript Development Environment" を選択

# 3. コンテナ内で開発サーバーを起動
bun run dev
```

### Docker（エディタ不問）

```bash
# バックエンド依存関係の同期（初回のみ）
cd backend && uv sync && cd -

# バックエンド（FastAPI）をコンテナで起動
docker compose up app &

# フロントエンドはホストで起動
bun install && bun run dev:frontend
```

### ローカル開発

```bash
# 依存関係のインストールと環境構築
bun run setup

# 3つのサーバーを同時起動
bun run dev
```

## アクセス先

- **React** - <http://localhost:3000>
- **FastAPI** - <http://localhost:8000>
- **Streamlit** - <http://localhost:8501>

## ドキュメント

### はじめに

- **[Claude Code 実践ガイド](TUTORIAL.md)** - AI 支援開発の活用法
- **[セットアップガイド](docs/getting-started/installation.md)** - 詳細な環境構
  築手順

### 開発

- **[アーキテクチャガイド](docs/development/architecture.md)** - プロジェクト構
  造と設計思想
- **[API開発ガイド](docs/development/api-development.md)** - FastAPI + React 開
  発手法

### 環境設定

- **[DevContainer完全ガイド](docs/environment/devcontainer.md)** - VS Code
  DevContainer 詳細設定
- **[Docker環境ガイド](docs/environment/docker.md)** - Docker 開発環境の構築
- **[セキュリティ設定](docs/environment/security.md)** - セキュアモードと外部
  API 設定
- **[MCPサーバー統合](docs/environment/mcp-servers.md)** - Context7・Playwright
  活用

### 貢献・運用

- **[貢献ガイド](docs/guides/contributing.md)** - プロジェクトへの貢献方法

## 参考・クレジット

- [Python プロジェクトのためのテンプレート](https://zenn.dev/mjun0812/articles/0ae2325d40ed20)
- [Claude Code DevContainer](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
- [Python Project Template](https://github.com/mjun0812/python-project-template)

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照。
