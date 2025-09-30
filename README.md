# Claude Code テンプレート - AI駆動フルスタック開発スターター

これは開発テンプレートです。Claude Code を使って仕様書から実装を生成するための土
台となります。

Claude Code を活用した効率的フルスタック開発のためのテンプレートリポジトリです。

## このテンプレートについて

Claude Code（Anthropic の AI 開発パートナー）を使って、仕様書から効率的に高品質
なフルスタックアプリケーションを構築するためのテンプレートです。AI 支援による高
速な段階的開発で開発効率を向上させます。

### このテンプレート + Claude Code で実現すること

- 数時間で動作するプロトタイプ完成 - 仕様書提示から動作確認まで
- 3 つのインターフェース構築 - React UI + Streamlit 管理画面 + API Docs
- 品質重視開発 - TDD/BDD、型安全性、高テストカバレッジ推奨
- 効率的開発 - バックエンド・フロントエンドの迅速な実装

## Claude Code 最適化技術スタック

### AI 駆動開発基盤

- **Claude Code** - 仕様書からアプリを自動実装する AI エンジニア
- **Context7 MCP** - 最新ライブラリドキュメントのリアルタイム統合
- **Chrome DevTools MCP** - パフォーマンス分析・デバッグ・Core Web Vitals測定
- **VS Code DevContainers** - ゼロ設定の統一開発環境

### 並列実装対応スタック

#### バックエンド（Python）

- **Python 3.12+** + **FastAPI** - Claude Code が最も効率的に実装可能
- **Pydantic** - TypeScript と型安全性を共有
- **uv** - 依存関係の高速解決

#### フロントエンド（TypeScript）

- **TypeScript** + **React 18** - Claude Code の強力な型推論能力を活用
- **Vite** - 高速ビルドで繰り返し測定を加速
- **pnpm** - 高速・省ストレージなワークスペース対応パッケージマネージャー

#### データ分析（Streamlit - 管理者ダッシュボード）

- **Streamlit** - Python で高機能ダッシュボードを瞬時構築
- **Pandas** + **Plotly** - インタラクティブなデータ可視化

### 自動品質担保

- **TDD/BDD** - Gherkin 仕様からテストを自動生成
- **型安全性** - TypeScript ↔ Pydantic 間の型一致を保証
- **Ruff** + **ESLint** - コード品質を自動維持
- **高テストカバレッジ** - Claude Code が支援

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

| 環境             | 特徴                           | 推奨ケース                            |
| ---------------- | ------------------------------ | ------------------------------------- |
| **DevContainer** | VS Code専用・ゼロ設定          | **VS Code利用者**                     |
| **Docker**       | エディタ不問・ブラウザ接続対応 | **Vim/Emacs/IntelliJ等/ブラウザのみ** |
| **ローカル**     | 高速・カスタマイズ自由         | パフォーマンス重視                    |

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
ブラウザ中心の **Web ダッシュボード** と、従来の **CLI 接続** のどちらでも同じセ
キュア開発コンテナを共有します。

```bash
# 1. 環境変数ファイルを作成（初回のみ）
cp .env.example .env

# 2. 必要に応じて環境変数を編集
#    主な設定項目：
#    - SECURE_MODE: セキュアモード有効/無効（デフォルト: true）
#    - ADDITIONAL_ALLOWED_DOMAINS: 追加で許可するドメイン（企業プロキシ等）
#    - USER_ID/GROUP_ID: ホストとの権限同期（通常は自動設定）
#    詳細は .env.example のコメントを参照
```

- **ブラウザ中心（推奨）**

  ```bash
  pnpm run docker:dashboard         # セキュア開発コンテナ + Web ダッシュボードを起動
  pnpm run docker:dashboard -- -d   # バックグラウンド実行（任意）
  ```

  1. ブラウザで <http://localhost:8080> にアクセス（認証なし - ローカル開発専
     用）
  2. 2x2 レイアウトで VS Code / アプリプレビュー / ターミナル / ユーティリティ画
     面を操作
  3. 左下ターミナルは `claude` CLI を含むセキュア開発コンテナに接続
  4. 利用終了後は `pnpm run docker:dashboard:down` で停止

- **CLI で直接接続（従来の手順）**

  ```bash
  pnpm run docker:dev         # セキュア開発コンテナを起動
  pnpm run docker:dev:connect # シェルで接続
  claude                     # CLI から直接実行

  pnpm run dev               # 必要に応じて開発サーバー起動
  # - React: http://localhost:3000
  # - FastAPI: http://localhost:8000
  # - Streamlit: http://localhost:8501
  ```

##### Web ダッシュボードで 4 分割ワークスペースを利用する

ブラウザ一枚で VS Code / アプリプレビュー / ターミナル / メモ & 追加ビューを操作
できる 2x2 ダッシュボードを用意しています。Docker Compose 環境で以下を実行してく
ださい。

1. ダッシュボードを起動:

   ```bash
   pnpm run docker:dashboard
   ```

   必要に応じてバックグラウンド実行したい場合は
   `pnpm run docker:dashboard -- -d` を利用できます。`proxy` サービスの依存とし
   て `frontend` / `app` / `streamlit` / `workspace` が自動的に立ち上がります。

2. ブラウザで <http://localhost:8080> にアクセスすると以下の 4 画面が表示されま
   す。

   - 左上: `/vscode/`（OpenVSCode Server - セキュア開発コンテナ内で動作）
   - 右上: `/preview/`（Vite 開発サーバー）
   - 左下: `/terminal/`（ttyd ベースのシェル。同じセキュア開発コンテナに接続して
     おり `claude` コマンドも利用可能）
   - 右下: ローカルストレージ保存メモ／`Streamlit`／`API Docs` を切り替え

   ダッシュボード上部のショートカット説明にある通り、`Ctrl + Shift + Alt + D` で
   全画面表示をトグルできます。

3. VS Code は認証なしで即座にアクセスできます（ローカル開発専用設定）。

> **ヒント:** Path ベースのリバースプロキシを行っているため、各サービスに直接ア
> クセスしたい場合は `http://localhost:8080/vscode/` などのパスをそのまま利用で
> きます。

> **停止方法:** ダッシュボード一式を停止するには
> `pnpm run docker:dashboard:down` を実行してください。

> **セキュリティ注意:** ローカル開発専用のため VS Code 認証は無効化されていま
> す。本番環境や共有環境で使用する場合は、Caddy で basicauth 等の認証を追加して
> ください（詳細は `.env.example` を参照）。

> **セキュア環境との連携:** ダッシュボードの VS Code / ターミナルは
> `docker compose --profile dev up` で利用するセキュア開発コンテナと同じ環境を共
> 有しています。ファイアウォール設定（`SECURE_MODE` や
> `ADDITIONAL_ALLOWED_DOMAINS`）や `claude` CLI の設定も引き継がれるため、ブラウ
> ザからでも安全なワークスペースを利用できます。

主な利点は次のとおりです。

- セキュリティ重視設計により Claude Code の誤操作からホスト環境を保護
- 開発環境がコンテナ内に完全分離され安全
- VS Code Remote Containers や IntelliJ 等からの接続に対応

#### オプション C: ローカル開発（高速・カスタマイズ自由・セキュリティなし）

**パフォーマンス重視・手動開発向け**の環境です。Claude Code の使用は非推奨（ホス
ト環境リスクがあります）。

```bash
# 依存関係セットアップ
pnpm run setup

# 環境の正常性確認
pnpm run verify-setup

# 全サービス並列起動
pnpm run dev
```

重要な注意事項は次のとおりです。

- Claude Code を使用する場合は上記セキュア環境を使用してください
- ホスト環境での破壊的操作リスクが存在します
- 手動開発・学習目的・パフォーマンス重視の場合に最適

### ステップ 3: Claude Code で実装開始

セキュア環境で Claude Code を使用する手順は次のとおりです。

```text
specs/examples/todo-app.spec.md の仕様で実装してください
```

**30分後に完成したアプリを確認：**

- **React** <http://localhost:3000>
- **FastAPI** <http://localhost:8000>
- **Streamlit** <http://localhost:8501>

### ステップ 4: カスタマイズ

"specs/templates/" を参考に、あなたのプロジェクトの仕様書を作成そして Claude
Code に実装を依頼！

## ドキュメント

### Claude Code を今すぐ始める

- **[Claude Code 実践ガイド](docs/TUTORIAL.md)** - 30 分でアプリ完成。具体的な手
  順
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

### 意図的な最小限設計

このテンプレートは **Claude Code による実装生成** を前提として設計されています。

- **backend/src/** - ディレクトリ構造のみ提供、実装は Claude Code が生成
- **streamlit/pages/** - UI 構造の例示、実際の API 接続は Claude Code が実装
- **specs/examples/** - 豊富な仕様書テンプレートから選択して実装依頼

既存の実装例がないことで、Claude Code が仕様書に忠実な実装を生成できます。

### 従来開発 vs Claude Code + このテンプレート

| 項目         | 従来の開発       | Claude Code + テンプレート |
| ------------ | ---------------- | -------------------------- |
| **開発時間** | 数日～数週間     | **数時間～1日**            |
| **実装方式** | 手動コーディング | **AI支援・半自動**         |
| **品質担保** | 手動テスト       | **TDD/BDD推奨**            |
| **型安全性** | 後付け対応       | **最初から完全対応**       |
| **並列開発** | 困難             | **Git worktreesで可能※**   |

※ 複数の Claude Code インスタンスを使用した場合。

### 3つのインターフェースが構築される

- **React** - エンドユーザー向けのモダン UI
- **Streamlit** - データ分析・管理者ダッシュボード（Python）
- **FastAPI Docs** - 開発者向け API 仕様書（Swagger 自動生成）

### 品質・セキュリティ標準装備

- **型安全性** TypeScript ↔ Pydantic 完全連携
- **テストカバレッジ** 高カバレッジ推奨
- **セキュリティ** DevContainer セキュアモード対応
- **コード品質** ESLint + Ruff 自動適用

### 並列開発の実現方法

Claude Code で真の並列開発を実現するには、Git worktrees を使用して複数インスタン
スを起動します。

```bash
# フロントエンド開発用
git worktree add ../project-frontend feature-frontend
cd ../project-frontend && claude

# バックエンド開発用（別ターミナル）
git worktree add ../project-backend feature-backend
cd ../project-backend && claude
```

**※注釈：** 単一の Claude Code インスタンス内では、Task tool による調査・計画の
並列実行は可能です。ただし、実際のコード実装は順次実行となります。真の並列実装に
は複数の Claude Code インスタンスが必要です。

## 参考・クレジット

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
- [Python Project Template](https://github.com/mjun0812/python-project-template)
- [モダンフルスタック開発のベストプラクティス](https://zenn.dev/mjun0812/articles/0ae2325d40ed20)

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照。

---

**今すぐ始めよう** 右上の「Use this template」ボタンから、あなたの AI 駆動開発を
開始してください。
