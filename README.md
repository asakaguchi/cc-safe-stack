# Claude Code テンプレート - AI駆動フルスタック開発スターター

**Claude Code**を活用した高速フルスタック開発のためのテンプレートリポジトリ。

## 🎯 このテンプレートについて

**Claude Code**（Anthropic の AI 開発パートナー）を使って、仕様書から**30分で高
品質なフルスタックアプリケーション**を構築するためのテンプレートです。従来の段階
的開発ではなく、**一括実装による劇的な開発効率向上**を実現します。

### ✨ このテンプレート + Claude Code で実現すること

- **30分で本格アプリ完成** - 仕様書提示から動作確認まで
- **🎨 3つのフロントエンド同時実装** - React + Streamlit + API Docs
- **🧪 自動品質担保** - TDD/BDD、型安全性、80%テストカバレッジ
- **🔄 並列実装** - バックエンド・フロントエンドを同時開発

## 🛠️ Claude Code 最適化技術スタック

### 🤖 AI 駆動開発基盤

- **🧿 Claude Code** - 仕様書からアプリを自動実装する AI エンジニア
- **📑 Context7 MCP** - 最新ライブラリドキュメントのリアルタイム統合
- **🤖 Playwright MCP** - 自動ブラウザテストで品質担保
- **📦 VS Code DevContainers** - ゼロ設定の統一開発環境

### 🔄 並列実装対応スタック

#### バックエンド（Python - AIが得意）

- **Python 3.12+** + **FastAPI** - Claude Code が最も効率的に実装可能
- **Pydantic** - TypeScript と型安全性を共有
- **uv** - 依存関係の高速解決

#### フロントエンド（TypeScript - AIが得意）

- **TypeScript** + **React 18** - Claude Code の強力な型推論能力を活用
- **Vite** - 高速ビルドで繰り返し測定を加速
- **bun** - npm より 10 倍高速なパッケージ管理

#### データ分析（Streamlit - 管理者ダッシュボード）

- **Streamlit** - Python で高機能ダッシュボードを瞬時構築
- **Pandas** + **Plotly** - インタラクティブなデータ可視化

### 🧪 自動品質担保

- **TDD/BDD** - Gherkin 仕様からテストを自動生成
- **型安全性** - TypeScript ↔ Pydantic 間の型一致を保証
- **Ruff** + **ESLint** - コード品質を自動維持
- **80%テストカバレッジ** - Claude Code が自動達成

## 🚀 クイックスタート

### ステップ 1: テンプレートから新しいリポジトリ作成

1. **GitHubでテンプレート使用**

   ```bash
   # このページの「Use this template」ボタンをクリック
   # 新しいリポジトリ名を入力して作成
   ```

2. **ローカルにクローン**

   ```bash
   git clone https://github.com/your-username/your-project-name.git
   cd your-project-name
   ```

### ステップ 2: 開発環境を選択

以下の 3 つから最適な環境を選択してください。

| 環境                | 特徴                      | 推奨ケース                 |
| ------------------- | ------------------------- | -------------------------- |
| **🧿 DevContainer** | Claude Code統合・ゼロ設定 | **初回利用・AI開発重視**   |
| **🐳 Docker**       | コンテナ環境・チーム統一  | チーム開発・本番環境準拠   |
| **💻 ローカル**     | 高速・カスタマイズ自由    | 経験者・パフォーマンス重視 |

#### オプション A: VS Code DevContainer（推奨）

```bash
code .
# コマンドパレット: "Reopen in Container"
# 自動で Claude Code + 全ツールがセットアップ完了
```

#### オプション B: Docker Compose

```bash
# 全サービス（React + FastAPI + Streamlit）を一括起動
bun run docker:up

# 起動確認
# - React: http://localhost:3000
# - FastAPI: http://localhost:8000
# - Streamlit: http://localhost:8501
```

#### オプション C: ローカル開発

```bash
# 依存関係セットアップ
bun run setup

# 全サービス並列起動
bun run dev
```

### ステップ 3: Claude Code で一括実装

```text
「specs/examples/todo-app.spec.md の仕様で実装してください」
```

**30分後に完成したアプリを確認：**

- **React** <http://localhost:3000>
- **FastAPI** <http://localhost:8000>
- **Streamlit** <http://localhost:8501>

### ステップ 4: カスタマイズ

```text
"specs/templates/" を参考に、あなたのプロジェクトの仕様書を作成
そして Claude Code に実装を依頼！
```

## 📖 ドキュメント

### 🎯 Claude Code を今すぐ始める

- **[Claude Code 実践ガイド](TUTORIAL.md)** - **30分でアプリ完成。具体的な手順**
- **[仕様書の書き方](specs/README.md)** - Claude Code が理解しやすい仕様書作成法

### 🛠️ 環境構築（必要時のみ）

- **[セットアップガイド](docs/getting-started/installation.md)** - 手動セット
  アップの詳細
- **[DevContainer完全ガイド](docs/environment/devcontainer.md)** - VS Code 環境
  の詳細設定
- **[セキュリティ設定](docs/environment/security.md)** - 外部 API 利用時の設定

### 🏗️ プロジェクト理解（参考）

- **[アーキテクチャガイド](docs/development/architecture.md)** - 技術構成と設計
  思想
- **[API開発ガイド](docs/development/api-development.md)** - 従来的な開発手法

## 🎯 このテンプレートの特徴

### 📊 従来開発 vs Claude Code + このテンプレート

| 項目         | 従来の開発   | Claude Code + テンプレート |
| ------------ | ------------ | -------------------------- |
| **開発時間** | 2-3週間      | **30分-2時間**             |
| **実装方式** | 段階的・手動 | **一括・自動**             |
| **品質担保** | 手動テスト   | **TDD/BDD自動**            |
| **型安全性** | 後付け対応   | **最初から完全対応**       |
| **並列開発** | 困難         | **フロント・バック同時**   |

### 🎨 3つのフロントエンドが同時に手に入る

- **React** - エンドユーザー向けのモダン UI
- **Streamlit** - データ分析・管理者ダッシュボード
- **FastAPI Docs** - 開発者向け API 仕様書（自動生成）

### 🛡️ 品質・セキュリティ標準装備

- **型安全性** TypeScript ↔ Pydantic 完全連携
- **テストカバレッジ** 80%以上の自動達成
- **セキュリティ** DevContainer セキュアモード対応
- **コード品質** ESLint + Ruff 自動適用

## 🔗 参考・クレジット

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
- [Python Project Template](https://github.com/mjun0812/python-project-template)
- [モダンフルスタック開発のベストプラクティス](https://zenn.dev/mjun0812/articles/0ae2325d40ed20)

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照。

---

**今すぐ始めよう** 右上の「Use this template」ボタンから、あなたの AI 駆動開発を
開始してください。
