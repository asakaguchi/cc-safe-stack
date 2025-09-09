# フルスタック開発ガイドライン

この文書には、Python (FastAPI) + TypeScript (React) フルスタック・モノリポでの作
業に関する重要な情報が含まれています。これらのガイドラインを厳密に従ってくださ
い。

## プロジェクト構成

### モノリポアーキテクチャ

```text
claude-code-polyglot-starter/
├── backend/              # Python (FastAPI) バックエンド
│   ├── src/              # バックエンドソースコード
│   ├── pyproject.toml    # Python依存関係・設定
│   └── main.py           # FastAPIアプリケーション
├── frontend/             # TypeScript (React) フロントエンド
│   ├── src/              # フロントエンドソースコード
│   ├── package.json      # Node.js依存関係
│   └── vite.config.ts    # Vite設定
├── shared/               # 言語間共有リソース
│   └── types/            # TypeScript型定義（Python Pydantic互換）
├── scripts/              # 統合開発スクリプト
└── package.json          # ルートワークスペース設定
```

### 責任分離

- **backend/**: API、データ処理、業務ロジック
- **frontend/**: UI、ユーザー体験、クライアント状態管理
- **shared/**: 型定義、API 契約、共通ユーティリティ

## 統合ルール

### 1. パッケージ管理

#### Python (Backend)

- **必須**: uv パッケージマネージャーのみ使用
- インストール: `uv add package`
- 開発依存関係: `uv add --dev package`
- **禁止**: `pip`、`uv pip install`、`@latest`構文

#### TypeScript/JavaScript (Frontend)

- **必須**: bun パッケージマネージャーのみ使用
- インストール: `bun add package`
- 開発依存関係: `bun add -D package`
- **禁止**: `npm install`、`yarn`、`pnpm`

### 2. コード品質基準

#### 共通要件

- すべてのコードに型定義必須
- 関数・クラスには docstring/JSDoc 必須
- 既存のコードパターンに厳密に従う
- エラーハンドリング必須

#### Python固有

- Google スタイル docstring
- Pydantic Base モデル使用
- FastAPI 規約準拠
- 型ヒント完全対応 (mypy 厳格モード)

#### TypeScript固有

- JSDoc 形式コメント
- React 関数コンポーネント優先
- 厳密 TypeScript 設定準拠
- ESLint 設定完全対応

### 3. API契約管理

- shared/types/配下で TypeScript 型定義を管理
- Pydantic モデルと TypeScript 型の一致を保証
- API 変更時は両方同時更新必須
- スキーマ破壊的変更は事前協議

## 開発コマンド

### 統合コマンド (推奨)

```bash
# 初期セットアップ
bun run setup

# 開発サーバー起動（フロント＋バック並行）
bun run dev

# 個別起動
bun run dev:frontend    # http://localhost:3000
bun run dev:backend     # http://localhost:8000

# 全体ビルド
bun run build

# 全体テスト
bun run test

# 全体リント
bun run lint
bun run lint:fix

# 全体フォーマット
bun run format
```

### 言語別コマンド

#### Python (backend/)

```bash
# 依存関係同期
uv sync --frozen

# サーバー起動
uv run uvicorn main:app --reload

# テスト実行
uv run --frozen pytest

# リント・フォーマット
uv run --frozen ruff check .
uv run --frozen ruff check . --fix
uv run --frozen ruff format .

# 型チェック
uv run --frozen mypy .
```

#### TypeScript (frontend/)

```bash
# 依存関係インストール
bun install

# 開発サーバー
bun dev

# ビルド
bun run build

# リント・フォーマット
bun run lint
bun run lint:fix
bun prettier --write .

# 型チェック
bun run type-check
```

## テスト要件

### Python

- **フレームワーク**: `uv run --frozen pytest`
- **カバレッジ**: エッジケースとエラー処理必須
- **新機能**: テストコード必須
- **バグ修正**: リグレッションテスト必須
- **非同期**: pytest-asyncio 使用

### TypeScript

- **フレームワーク**: 設定予定（Vitest 推奨）
- **コンポーネント**: React Testing Library
- **統合テスト**: E2E 対応
- **型テスト**: TypeScript コンパイル確認

## コード品質管理

### リント・フォーマット設定

#### Python (Ruff)

```bash
# チェック
uv run --frozen ruff check .

# 自動修正
uv run --frozen ruff check . --fix

# フォーマット
uv run --frozen ruff format .
```

#### TypeScript (ESLint + Prettier)

```bash
# リント
bun run lint

# 自動修正
bun run lint:fix

# フォーマット
bun prettier --write .
```

#### Markdown/ドキュメント (textlint)

```bash
# 日本語文書チェック
bun run lint:text

# 自動修正
bun run lint:text:fix
```

### Pre-commit フック

- 設定ファイル: `.pre-commit-config.yaml`
- **Python**: Ruff (linter/formatter)
- **TypeScript/JavaScript**: Prettier (formatter) ※ESLint 設定は開発中
- **実行**: `uv run pre-commit install`

## Git運用

### ブランチ戦略

- **main**: 本番デプロイ可能状態
- **develop**: 開発統合ブランチ
- **feature/\***: 機能開発ブランチ
- **fix/\***: バグ修正ブランチ

### コミットメッセージ

Conventional Commits 形式必須:

```text
feat(backend): add user authentication API
fix(frontend): resolve login form validation issue
docs: update development guidelines
style(shared): format type definitions
```

### プルリクエスト

- **必須**: 両言語の影響範囲を明記
- **テスト**: 全テストパス確認
- **リント**: 品質チェック完全クリア
- **型チェック**: TypeScript/mypy 両方クリア

## 開発環境

### DevContainer対応

- **標準環境**: `.devcontainer/devcontainer.json`（`SECURE_MODE=true` がデフォル
  ト）
- **セキュア環境**: `.devcontainer/secure/`
- **共通基盤**: Python 3.12+ + Node.js 18+ + Claude Code CLI

### VS Code設定

- Python: Ruff + mypy 統合
- TypeScript: ESLint + Prettier 統合
- 保存時自動フォーマット有効

### Docker環境

```bash
# コンテナビルド・起動
bun run docker:build
bun run docker:up
```

## 共有コンポーネント管理

### 型定義 (shared/types/)

- **API契約**: shared/types/api.ts
- **データモデル**: Python Pydantic ⟷ TypeScript interface 対応
- **更新ルール**: 破壊的変更は両言語同時対応

### ユーティリティ

- **共通ロジック**: 言語別実装、インターフェース統一
- **バリデーション**: 同一仕様で両言語実装
