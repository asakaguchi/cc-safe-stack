# Claude Code テンプレート - AI駆動フルスタック開発スターター

Claude Code を活用した高速フルスタック開発のためのテンプレートリポジトリ。

## このテンプレートについて

Claude Code（Anthropic の AI 開発パートナー）を使って、仕様書から 30 分で高品質
なフルスタックアプリケーションを構築するためのテンプレートです。従来の段階的開発
ではなく、一括実装による劇的な開発効率向上を実現します。

### このテンプレート + Claude Code で実現すること

- 30 分で本格アプリ完成 - 仕様書提示から動作確認まで
- 3 つのフロントエンド同時実装 - React + Streamlit + API Docs
- 自動品質担保 - TDD/BDD、型安全性、80%テストカバレッジ
- 並列実装 - バックエンド・フロントエンドを同時開発

## Claude Code 最適化技術スタック

### AI 駆動開発基盤

- **Claude Code** - 仕様書からアプリを自動実装する AI エンジニア
- **Context7 MCP** - 最新ライブラリドキュメントのリアルタイム統合
- **Playwright MCP** - 自動ブラウザテストで品質担保
- **VS Code DevContainers** - ゼロ設定の統一開発環境

### 並列実装対応スタック

#### バックエンド（Python）

- **Python 3.12+** + **FastAPI** - Claude Code が最も効率的に実装可能
- **Pydantic** - TypeScript と型安全性を共有
- **uv** - 依存関係の高速解決

#### フロントエンド（TypeScript）

- **TypeScript** + **React 18** - Claude Code の強力な型推論能力を活用
- **Vite** - 高速ビルドで繰り返し測定を加速
- **bun** - npm より 10 倍高速なパッケージ管理

#### データ分析（Streamlit - 管理者ダッシュボード）

- **Streamlit** - Python で高機能ダッシュボードを瞬時構築
- **Pandas** + **Plotly** - インタラクティブなデータ可視化

### 自動品質担保

- **TDD/BDD** - Gherkin 仕様からテストを自動生成
- **型安全性** - TypeScript ↔ Pydantic 間の型一致を保証
- **Ruff** + **ESLint** - コード品質を自動維持
- **80%テストカバレッジ** - Claude Code が自動達成

## クイックスタート

### ステップ 1: テンプレートから新しいプロジェクト作成

1. **GitHubでテンプレート使用**

   - 右上の「**Use this template**」ボタンをクリック
   - 新しいリポジトリ名を入力して作成

2. **作成したプロジェクトをクローン**

   ```bash
   git clone https://github.com/your-username/your-project-name.git
   cd your-project-name
   ```

### ステップ 2: 開発環境を選択

以下の 3 つから最適な環境を選択してください。

| 環境             | 特徴                       | 推奨ケース               |
| ---------------- | -------------------------- | ------------------------ |
| **DevContainer** | VS Code専用・ゼロ設定      | **VS Code利用者**        |
| **Docker**       | エディタ不問・コンテナ統一 | **Vim/Emacs/IntelliJ等** |
| **ローカル**     | 高速・カスタマイズ自由     | パフォーマンス重視       |

#### オプション A: VS Code DevContainer（セキュア隔離環境・デフォルト）

**Claude Codeを安全に実行するための推奨環境**です。破壊的操作からホストシステム
を保護します。

```bash
code .
# コマンドパレット: "Reopen in Container"
# 自動で Python + TypeScript + 全ツール + セキュリティ設定が完了
```

主な特徴は次のとおりです。

- デフォルトでセキュアモード有効（SECURE_MODE=true）
- Claude Code の誤操作（`rm -rf *`等）をコンテナ内に隔離
- ネットワーク制限により外部への不正アクセスを防止
- 完全な開発環境がゼロ設定で利用可能

#### オプション B: Docker Compose（セキュア隔離環境）

Claude Code を隔離環境で安全に実行し、破壊的コマンドの実行リスクを最小化します。
**ファイル権限の問題を自動解決する機能付き**です。

```bash
# 方法1: docker-compose.sh ラッパースクリプト使用（推奨）
# UID/GIDを自動検出してファイル権限を同期
chmod +x docker-compose.sh

# 通常のdocker composeコマンドの代わりに使用
./docker-compose.sh up          # 全サービス起動
./docker-compose.sh up -d       # バックグラウンド起動
./docker-compose.sh down        # 停止
./docker-compose.sh build       # イメージビルド

# セキュア開発環境起動（Claude Code CLI内蔵）
./docker-compose.sh --profile dev up -d
./docker-compose.sh exec dev claude  # 安全にClaude Code実行

# または方法2: 環境変数を手動設定
# 1. 環境変数ファイルを作成（初回のみ）
cp .env.example .env

# 2. 必要に応じて環境変数を編集
#    主な設定項目：
#    - SECURE_MODE: セキュアモード有効/無効（デフォルト: true）
#    - ADDITIONAL_ALLOWED_DOMAINS: 追加で許可するドメイン（企業プロキシ等）
#    - UID/GID/USER: ホストとの権限同期（通常は自動設定）
#    詳細は .env.example のコメントを参照
# nano .env  # または好みのエディタで編集

# 3. 通常のdocker compose起動
export UID=$(id -u) GID=$(id -g) USER=$(id -un)  # 権限同期用
docker compose up

# 開発サーバーアクセス
# - React: http://localhost:3000
# - FastAPI: http://localhost:8000
# - Streamlit: http://localhost:8501
```

**ファイル権限の自動同期機能:**

- **docker-compose.sh**: ホストのUID/GIDを自動検出し、コンテナ内ファイルと権限を
  同期
- **権限問題なし**: ToDoアプリ作成時もホストユーザーと同じ権限でファイルが作成さ
  れる
- **DevContainer互換**: DevContainerと同様の権限管理を実現

主な利点は次のとおりです。

- セキュリティ重視設計により Claude Code の誤操作からホスト環境を保護
- ファイル権限の問題を自動解決（DevContainer環境と同等）
- 開発環境がコンテナ内に完全分離され安全
- VS Code Remote Containers や IntelliJ 等からの接続に対応

#### オプション C: ローカル開発（高速・カスタマイズ自由・セキュリティなし）

**パフォーマンス重視・手動開発向け**の環境です。Claude Code の使用は非推奨（ホス
ト環境リスクがあります）。

```bash
# 依存関係セットアップ
bun run setup

# 全サービス並列起動
bun run dev
```

重要な注意事項は次のとおりです。

- Claude Code を使用する場合は上記セキュア環境を使用してください
- ホスト環境での破壊的操作リスクが存在します
- 手動開発・学習目的・パフォーマンス重視の場合に最適

### ステップ 3: Claude Code で実装開始

セキュア環境で Claude Code を使用する手順は次のとおりです。

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

## ドキュメント

### Claude Code を今すぐ始める

- **[Claude Code 実践ガイド](TUTORIAL.md)** - 30 分でアプリ完成。具体的な手順
- **[仕様書の書き方](specs/README.md)** - Claude Code が理解しやすい仕様書作成法

### 環境構築（必要時のみ）

- **[セットアップガイド](docs/getting-started/installation.md)** - 手動セット
  アップの詳細
- **[DevContainer完全ガイド](docs/environment/devcontainer.md)** - VS Code 環境
  の詳細設定
- **[セキュリティ設定](docs/environment/security.md)** - 外部 API 利用時の設定

### プロジェクト理解（参考）

- **[アーキテクチャガイド](docs/development/architecture.md)** - 技術構成と設計
  思想
- **[API開発ガイド](docs/development/api-development.md)** - 従来的な開発手法

## このテンプレートの特徴

### 従来開発 vs Claude Code + このテンプレート

| 項目         | 従来の開発   | Claude Code + テンプレート |
| ------------ | ------------ | -------------------------- |
| **開発時間** | 2-3週間      | **30分-2時間**             |
| **実装方式** | 段階的・手動 | **一括・自動**             |
| **品質担保** | 手動テスト   | **TDD/BDD自動**            |
| **型安全性** | 後付け対応   | **最初から完全対応**       |
| **並列開発** | 困難         | **フロント・バック同時**   |

### 3つのフロントエンドが同時に手に入る

- **React** - エンドユーザー向けのモダン UI
- **Streamlit** - データ分析・管理者ダッシュボード
- **FastAPI Docs** - 開発者向け API 仕様書（自動生成）

### 品質・セキュリティ標準装備

- **型安全性** TypeScript ↔ Pydantic 完全連携
- **テストカバレッジ** 80%以上の自動達成
- **セキュリティ** DevContainer セキュアモード対応
- **コード品質** ESLint + Ruff 自動適用

## 参考・クレジット

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
- [Python Project Template](https://github.com/mjun0812/python-project-template)
- [モダンフルスタック開発のベストプラクティス](https://zenn.dev/mjun0812/articles/0ae2325d40ed20)

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照。

---

**今すぐ始めよう** 右上の「Use this template」ボタンから、あなたの AI 駆動開発を
開始してください。
