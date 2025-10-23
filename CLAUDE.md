# 言語設定

常に日本語で回答してください。

# フルスタック開発ガイドライン

この文書には、Python (FastAPI) + TypeScript (React) フルスタック・モノリポでの作
業に関する重要な情報が含まれています。これらのガイドラインを厳密に従ってくださ
い。

## プロジェクト構成

### モノリポアーキテクチャ

```text
cc-safe-stack/
├── apps/
│   ├── backend/          # Python (FastAPI) バックエンド
│   └── frontend/         # TypeScript (React) フロントエンド
├── extensions/
│   └── marimo/           # marimo ダッシュボード用ノートブック
├── packages/
│   └── shared/           # 言語間共有リソース
├── scripts/              # 統合開発スクリプト
└── package.json          # ルートワークスペース設定
```

### 責任分離

| パス                 | 役割                                                        |
| -------------------- | ----------------------------------------------------------- |
| `apps/backend/`      | バックエンド API、データ処理、業務ロジックを担当            |
| `apps/frontend/`     | フロントエンド UI、ユーザー体験、クライアント状態管理を担当 |
| `extensions/marimo/` | 管理ダッシュボードとデータ可視化ワークフローを担当          |
| `packages/shared/`   | 型定義、API 契約、共通ユーティリティを集約                  |

## 統合ルール

### 1. パッケージ管理

#### Python (Backend)

- 必須ツール: uv パッケージマネージャーのみ使用
- インストール: `uv add package`
- 開発依存関係: `uv add --dev package`
- 禁止事項: `pip`、`uv pip install`、`@latest`構文

#### TypeScript/JavaScript (Frontend)

- 必須ツール: pnpm パッケージマネージャーのみ使用
- インストール: `pnpm add package`
- 開発依存関係: `pnpm add -D package`
- 禁止事項: `npm install`、`yarn`、`bun`

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

- packages/shared/ 配下で TypeScript 型定義を管理
- Pydantic モデルと TypeScript 型の一致を保証
- API 変更時は両方を同じコミットで更新することを必須条件とする
- スキーマ破壊的変更は事前協議

## 開発コマンド

### 統合コマンド (推奨)

```bash
# 初期セットアップ
pnpm run setup

# 開発サーバー起動（フロント＋バック並行）
pnpm run dev
# marimo を含めたい場合は `pnpm run dev:all`（初回は enable:marimo）
# または別ターミナルで `pnpm run dev:marimo`

# 3 サービスをまとめて起動
pnpm run dev:all  # 初回は enable:marimo

# 個別起動
pnpm run dev:frontend    # http://localhost:3000
pnpm run dev:backend     # http://localhost:8000
pnpm run dev:marimo      # http://localhost:2718（初回は enable:marimo）

# 全体ビルド
pnpm run build

# 全体テスト
pnpm run test

# 全体リント
pnpm run lint
pnpm run lint:fix

# 全体フォーマット
pnpm run format
```

### 言語別コマンド

#### Python (apps/backend/)

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

#### TypeScript (apps/frontend/)

```bash
# 依存関係インストール
pnpm install

# 開発サーバー
pnpm run dev

# ビルド
pnpm run build

# リント・フォーマット
pnpm run lint
pnpm run lint:fix
pnpm prettier --write .

# 型チェック
pnpm run type-check
```

## テスト要件

### Python

- フレームワーク: `uv run --frozen pytest`
- カバレッジ: エッジケースとエラー処理必須
- 新機能: テストコード必須
- バグ修正: リグレッションテスト必須
- 非同期: pytest-asyncio 使用

### TypeScript

- フレームワーク: 設定予定（Vitest 推奨）
- コンポーネント: React Testing Library
- 統合テスト: E2E 対応
- 型テスト: TypeScript コンパイル確認

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
pnpm run lint

# 自動修正
pnpm run lint:fix

# フォーマット
pnpm prettier --write .
```

#### Markdown/ドキュメント (textlint)

```bash
# 日本語文書チェック
pnpm run lint:text

# 自動修正
pnpm run lint:text:fix
```

### Pre-commit フック

- 設定ファイル: `.pre-commit-config.yaml`
- Python: Ruff (linter/formatter)
- TypeScript/JavaScript: Prettier (formatter) ※ESLint 設定は開発中
- 実行: `uv run pre-commit install`

## Git運用

### ブランチ戦略

- main: 本番デプロイ可能状態
- develop: 開発統合ブランチ
- feature/\*: 機能開発ブランチ
- fix/\*: バグ修正ブランチ

### コミットメッセージ

Conventional Commits 形式が必須です。

```text
feat(backend): add user authentication API
fix(frontend): resolve login form validation issue
docs: update development guidelines
style(shared): format type definitions
```

### プルリクエスト

- 必須事項: 両言語の影響範囲を明記
- テスト: 全テストパス確認
- リント: 品質チェック完全クリア
- 型チェック: TypeScript/mypy 両方クリア

## 開発環境

### DevContainer対応

- 標準環境: `.devcontainer/devcontainer.json`（`SECURE_MODE=true` がデフォルト）
- セキュア環境: `.devcontainer/secure/`
- 共通基盤: Python 3.12+ + Node.js 18+ + Claude Code CLI

### VS Code設定

- Python: Ruff + mypy 統合
- TypeScript: ESLint + Prettier 統合
- 保存時自動フォーマット有効

### Docker環境

```bash
# コンテナビルド・起動
pnpm run docker:build
pnpm run docker:up
```

## 共有コンポーネント管理

### 型定義 (packages/shared/)

- API 契約: packages/shared/types/api.ts
- データモデル: Python Pydantic ⟷ TypeScript interface 対応
- 更新ルール: 破壊的変更は Python と TypeScript の両方を同時に更新する

### ユーティリティ

- 共通ロジック: 言語別実装、インターフェース統一
- バリデーション: 同一仕様で両言語実装
