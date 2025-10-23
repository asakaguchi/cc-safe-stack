# アーキテクチャガイド

このガイドでは、プロジェクトのアーキテクチャ設計と技術スタックについて詳しく説明
します。

## プロジェクト概要

### コンセプト

本プロジェクトは、Python（FastAPI）、TypeScript（React）、marimo を組み合わせた
モダンなフルスタック開発環境です。モノリポ構成により、3 つのインターフェースを統
合的に開発できます。

### 3つのフロントエンド構成

- React はプロダクション向けのモダン UI
- marimo はデータ分析・管理者ダッシュボード
- FastAPI Docs は自動生成される API 仕様書

## プロジェクト構造

```text
cc-safe-stack/
├── apps/
│   ├── backend/          # Python FastAPI アプリケーション
│   │   ├── main.py       # FastAPI エントリーポイント
│   │   ├── pyproject.toml
│   │   └── src/          # バックエンドソースコード
│   └── frontend/         # TypeScript React アプリケーション
│       ├── src/          # フロントエンドソースコード
│       ├── package.json
│       ├── tsconfig.json
│       └── vite.config.ts
├── extensions/
│   └── marimo/           # marimo ダッシュボード用ノートブック
├── packages/
│   └── shared/           # TypeScript 共有型定義
├── scripts/              # 開発用スクリプト
│   ├── setup.sh          # 初期セットアップ
│   ├── dev.sh            # 開発サーバー起動
│   ├── dev-marimo.sh     # marimo ノートブック起動
│   └── lint.sh           # コード品質チェック
├── .devcontainer/        # VS Code DevContainer設定
├── docker/               # Docker関連ファイル
└── docs/                 # プロジェクトドキュメント
```

## モノリポアーキテクチャ

### 責任分離

#### apps/backend/ - APIとビジネスロジック

役割として、以下を担当します。

- REST API の提供
- データ処理とビジネスロジック
- データベースとの連携
- 認証・認可の管理

技術スタックには、以下を使用します。

- Python 3.12+: モダンな Python 環境
- FastAPI: 高性能な Web API フレームワーク
- Uvicorn: ASGI サーバー
- Pydantic: データバリデーション
- uv: 高速パッケージマネージャー
- Ruff: コードリンター・フォーマッター

#### apps/frontend/ - ユーザーインターフェース

役割として、以下を担当します。

- ユーザー向けの Web アプリケーション
- クライアントサイドの状態管理
- API との通信
- レスポンシブデザイン

技術スタックには、以下を使用します。

- TypeScript: 型安全な JavaScript
- React 18: モダンな UI ライブラリ
- Vite: 高速ビルドツール
- ESLint + Prettier: コード品質管理
- pnpm: 高速・省スペースなパッケージマネージャー

#### extensions/marimo/ - データアプリケーション

役割として、以下を担当します。

- データ分析ダッシュボード
- 管理者向けインターフェース
- API との連携検証
- プロトタイピング環境

技術スタックには、以下を使用します。

- marimo: Python でのインタラクティブノートブック構築
- duckdb / polars（オプション）: データ処理
- HTTPX: FastAPI 統合の HTTP クライアント

#### packages/shared/ - 共有リソース

役割として、以下を担当します。

- 型定義の一元管理
- フロントエンド・バックエンド間の契約
- 共通ユーティリティ
- API 仕様の共有

## 技術スタック詳細

### 開発ツール

- VS Code DevContainers: 統一された開発環境
- Claude Code CLI: AI 支援開発ツール
- Context7 MCP: 最新ライブラリドキュメント統合
- Git + GitHub CLI: バージョン管理
- Docker Compose: コンテナ オーケストレーション

### パッケージ管理戦略

#### Python（uv）

```bash
# 高速な依存関係管理
uv add fastapi uvicorn
uv add --dev pytest ruff mypy

# 仮想環境の自動管理
uv sync
```

#### TypeScript/JavaScript（pnpm）

```bash
# 高速で省スペースなパッケージ管理
pnpm add react @types/react
pnpm add -D @types/node typescript

# 高速な実行環境
pnpm run dev
```

### 型安全性の確保

#### 共有型定義

```typescript
// shared/types/api.ts
export interface User {
  id: number
  name: string
  email: string
  created_at: string
}

export interface CreateUserRequest {
  name: string
  email: string
}
```

#### Pydantic モデル

```python
# backend/src/models.py
from pydantic import BaseModel
from datetime import datetime

class User(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

class CreateUserRequest(BaseModel):
    name: str
    email: str
```

#### TypeScript インターフェース

```typescript
// frontend/src/types/api.ts
import type { User, CreateUserRequest } from '@shared/types/api'

export async function createUser(data: CreateUserRequest): Promise<User> {
  // API 呼び出し実装
}
```

## データフロー

### アーキテクチャ図

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │    │   marimo App    │    │   FastAPI Docs  │
│  (Frontend)     │    │  (Analytics)    │    │   (API Spec)    │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │ HTTP API             │ HTTP API             │ OpenAPI
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                         ┌───────▼───────┐
                         │   FastAPI     │
                         │   Backend     │
                         └───────┬───────┘
                                 │
                         ┌───────▼───────┐
                         │   Database    │
                         │   Storage     │
                         └───────────────┘
```

### リクエストフロー

1. **React → FastAPI**

   ```text
   Frontend Request → API Router → Business Logic → Database → Response
   ```

2. **marimo → FastAPI**

   ```text
   Dashboard Request → API Client → FastAPI → Data Processing → Visualization
   ```

3. **型安全性の保証**

   ```text
   TypeScript Types ↔ Pydantic Models ↔ Database Schema
   ```

## 設計原則

### 1. 分離された関心事

各モジュールは明確な責任を持ち、疎結合を保つ。

- UI 層: ユーザーインターフェースのみに集中
- API 層: ビジネスロジックとデータアクセス
- データ層: データの永続化と整合性

### 2. 契約による設計

- OpenAPI 仕様: API の契約を明確に定義
- 共有型定義: フロントエンド・バックエンド間の型契約
- バリデーション: Pydantic による自動バリデーション

### 3. 開発者体験の最適化

- ホットリロード: 開発時の高速フィードバック
- 型チェック: コンパイル時のエラー検出
- 自動フォーマット: 一貫したコードスタイル
- 統合テスト: 全スタックでの品質保証

## パフォーマンス設計

### フロントエンド最適化

- Vite: 高速なビルドと HMR
- Tree Shaking: 不要コードの除去
- Code Splitting: 必要な時に必要なコードのみ読み込み
- TypeScript: 最適化された JavaScript 生成

### バックエンド最適化

- FastAPI: 高性能な ASGI フレームワーク
- Pydantic: C 拡張による高速バリデーション
- 非同期処理: async/await による並行処理
- 依存性注入: メモリ使用量と処理速度を最適化したリソース管理

### データベース設計

- SQLAlchemy: ORM による型安全なデータアクセス
- 接続プール: データベース接続コストを削減し、レスポンス速度を向上
- マイグレーション: スキーマ変更の管理
- インデックス: クエリパフォーマンスの最適化

## セキュリティアーキテクチャ

### 認証・認可

- JWT トークン: ステートレスな認証
- RBAC: ロールベースのアクセス制御
- CORS 設定: クロスオリジンリクエストの制御
- 入力検証: Pydantic による自動バリデーション

### 開発環境セキュリティ

- DevContainer: 隔離された開発環境
- ファイアウォール: ネットワークアクセス制限
- 秘密情報管理: 環境変数による分離
- 権限制限: 最小権限の原則

## 拡張性とメンテナンス

### モジュール設計

- プラグインアーキテクチャ: 機能の追加が容易
- 依存性逆転: テスタブルな設計
- 設定外部化: 環境ごとの設定分離
- ログ管理: 構造化ログによる監視

### CI/CD 対応

- 自動テスト: 品質の継続的保証
- 自動デプロイ: 信頼性の高いリリース
- Docker 化: 環境の一貫性
- モニタリング: 運用時の可観測性

## 関連ドキュメント

- [API開発ガイド](api-development.md)
- [DevContainer完全ガイド](../environment/devcontainer.md)
- [セキュリティ設定](../environment/security.md)
- [MCPサーバー統合](../environment/mcp-servers.md)
