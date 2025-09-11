# 貢献ガイド

このガイドでは、プロジェクトへの貢献方法、Git 運用、コードレビューのプロセスにつ
いて説明します。

## 貢献の流れ

### 1. 準備

1. **プロジェクトをフォーク**: GitHub でプロジェクトをフォーク
2. **ローカルに複製**: フォークしたリポジトリをクローン
3. **開発環境の構築**:
   [セットアップガイド](../getting-started/installation.md)に従って環境を構築

```bash
git clone https://github.com/<your-username>/<your-repository-name>.git
cd <your-repository-name>
bun run setup
```

### 2. 機能ブランチの作成

```bash
# main ブランチから最新の変更を取得
git checkout main
git pull upstream main

# 機能ブランチを作成
git checkout -b feature/new-feature
```

### 3. 開発

1. **コードの実装**: 機能を実装
2. **テストの作成**: 新機能に対するテストを作成
3. **品質チェック**: リンティング・フォーマットを実行

```bash
# 開発サーバーの起動
bun run dev

# コード品質チェック
bun run lint
bun run format
bun run test
```

### 4. コミット

```bash
# 変更をステージング
git add .

# コミット（Conventional Commits 形式）
git commit -m "feat(backend): add user authentication API"
```

### 5. プッシュとプルリクエスト

```bash
# ブランチをプッシュ
git push origin feature/new-feature

# GitHub でプルリクエストを作成
```

## Git運用

### ブランチ戦略

プロジェクトでは **Git Flow** ベースのブランチ戦略を採用しています。

#### ブランチの種類

- **main**: 本番デプロイ可能状態
- **develop**: 開発統合ブランチ
- **feature/\***: 機能開発ブランチ
- **fix/\***: バグ修正ブランチ
- **hotfix/\***: 緊急修正ブランチ
- **release/\***: リリース準備ブランチ

#### ブランチ命名規則

```bash
# 機能開発
feature/user-authentication
feature/dashboard-ui
feature/api-optimization

# バグ修正
fix/login-form-validation
fix/memory-leak-issue

# 緊急修正
hotfix/security-vulnerability
hotfix/production-error

# リリース準備
release/v1.2.0
release/v2.0.0-beta
```

### コミットメッセージ

#### Conventional Commits 形式

プロジェクトでは [Conventional Commits](https://www.conventionalcommits.org/) 形
式を採用しています。

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

#### 基本的な型（type）

- **feat**: 新機能の追加
- **fix**: バグ修正
- **docs**: ドキュメントの変更
- **style**: コードスタイルの変更（機能に影響しない）
- **refactor**: リファクタリング（機能変更なし）
- **test**: テストの追加・修正
- **chore**: ビルドプロセスやツールの変更

#### スコープ（scope）の例

- **backend**: バックエンド（Python/FastAPI）
- **frontend**: フロントエンド（React/TypeScript）
- **streamlit**: Streamlit アプリケーション
- **shared**: 共有リソース
- **docs**: ドキュメント
- **ci**: CI/CD 設定

#### コミットメッセージの例

```bash
# 機能追加
feat(backend): add user authentication API
feat(frontend): implement dashboard component
feat(streamlit): add data visualization charts

# バグ修正
fix(backend): resolve CORS configuration issue
fix(frontend): fix login form validation error

# ドキュメント更新
docs(readme): update installation instructions
docs(api): add authentication endpoints documentation

# リファクタリング
refactor(backend): optimize database query performance
refactor(frontend): extract common UI components

# テスト
test(backend): add integration tests for user API
test(frontend): add unit tests for dashboard component

# 設定・ツール変更
chore(deps): update FastAPI to version 0.104.0
chore(ci): add automated testing workflow
```

### コードレビュー

#### プルリクエストの要件

1. **必須チェック**:

   - [ ] 全テストがパス
   - [ ] リンティングエラーなし
   - [ ] 型チェックエラーなし
   - [ ] コンフリクトの解決済み

2. **コード品質**:

   - [ ] 適切なテストが含まれている
   - [ ] ドキュメントが更新されている
   - [ ] 既存機能への影響を確認済み

3. **セキュリティ**:
   - [ ] 秘密情報の漏洩なし
   - [ ] 適切な入力検証
   - [ ] セキュリティベストプラクティスの遵守

#### プルリクエストテンプレート

```markdown
## 変更の概要

<!-- 変更内容を簡潔に説明 -->

## 変更の種類

- [ ] バグ修正
- [ ] 新機能
- [ ] 破壊的変更
- [ ] ドキュメント更新

## 影響範囲

- [ ] バックエンド
- [ ] フロントエンド
- [ ] Streamlit
- [ ] 共有リソース
- [ ] ドキュメント

## テスト

- [ ] 新しいテストを追加
- [ ] 既存のテストを更新
- [ ] 手動テストを実施

## チェックリスト

- [ ] コードがプロジェクトの規約に従っている
- [ ] 自分でコードレビューを実施済み
- [ ] 必要に応じてドキュメントを更新
- [ ] 変更が既存機能に影響しないことを確認
```

## 開発規約

### パッケージ管理

#### Python（backend/）

- **必須**: uv パッケージマネージャーのみ使用
- **禁止**: `pip`、`uv pip install`、`@latest`構文

```bash
# 推奨
uv add fastapi
uv add --dev pytest

# 非推奨
pip install fastapi
uv pip install fastapi
```

#### TypeScript/JavaScript（frontend/）

- **必須**: bun パッケージマネージャーのみ使用
- **禁止**: `npm install`、`yarn`、`pnpm`

```bash
# 推奨
bun add react
bun add -D @types/node

# 非推奨
npm install react
yarn add react
```

### コード品質基準

#### 共通要件

- すべてのコードに型定義必須
- 関数・クラスには docstring/JSDoc 必須
- 既存のコードパターンに厳密に従う
- エラーハンドリング必須

#### Python固有

- **Docstring**: Google スタイル
- **モデル**: Pydantic Base モデル使用
- **規約**: FastAPI 規約準拠
- **型ヒント**: 厳格モード対応（mypy）

```python
def create_user(user_data: CreateUserRequest) -> User:
    """
    新しいユーザーを作成します。

    Args:
        user_data: ユーザー作成に必要なデータ

    Returns:
        作成されたユーザー情報

    Raises:
        ValidationError: 入力データが無効な場合
        DatabaseError: データベースエラーが発生した場合
    """
    pass
```

#### TypeScript固有

- **コメント**: JSDoc 形式
- **コンポーネント**: React 関数コンポーネント優先
- **設定**: 厳密 TypeScript 設定準拠
- **リンティング**: ESLint 設定完全対応

```typescript
/**
 * ユーザー一覧を表示するコンポーネント
 *
 * @param props - コンポーネントのプロパティ
 * @returns ユーザー一覧のJSX要素
 */
export const UserList: React.FC<UserListProps> = ({ users, onUserClick }) => {
  // 実装
}
```

### API契約管理

- **型定義**: shared/types/ 配下で TypeScript 型定義を管理
- **一致保証**: Pydantic モデルと TypeScript 型の一致を保証
- **同時更新**: API 変更時は両方同時更新必須
- **破壊的変更**: スキーマ破壊的変更は事前協議

## テスト要件

### テスト戦略

#### Python バックエンドのテスト

- **フレームワーク**: pytest
- **カバレッジ**: エッジケースとエラー処理必須
- **新機能**: テストコード必須
- **バグ修正**: リグレッションテスト必須

```python
# backend/tests/test_users.py
import pytest
from fastapi.testclient import TestClient

def test_create_user_success():
    """ユーザー作成の正常系テスト"""
    response = client.post("/api/users/", json={
        "name": "Test User",
        "email": "test@example.com"
    })
    assert response.status_code == 201
    assert response.json()["name"] == "Test User"

def test_create_user_invalid_email():
    """ユーザー作成の異常系テスト（無効なメール）"""
    response = client.post("/api/users/", json={
        "name": "Test User",
        "email": "invalid-email"
    })
    assert response.status_code == 422
```

#### TypeScript（frontend/）

- **フレームワーク**: Vitest + React Testing Library
- **コンポーネント**: ユニットテストとインテグレーションテスト
- **型テスト**: TypeScript コンパイル確認

```typescript
// frontend/src/components/__tests__/UserList.test.tsx
import { render, screen } from '@testing-library/react'
import { UserList } from '../UserList'

describe('UserList', () => {
  it('renders user list correctly', () => {
    const users = [
      { id: 1, name: 'John', email: 'john@example.com' }
    ]

    render(<UserList users={users} />)

    expect(screen.getByText('John')).toBeInTheDocument()
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })
})
```

### CI/CD要件

#### 自動チェック

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Python テスト
      - name: Run Python tests
        run: |
          cd backend
          uv run pytest

      # TypeScript テスト
      - name: Run TypeScript tests
        run: |
          bun test

      # リンティング
      - name: Run linting
        run: |
          bun run lint
          uv run ruff check .
```

## リリースプロセス

### バージョニング

プロジェクトでは [Semantic Versioning](https://semver.org/) を採用しています。

- **MAJOR**: 破壊的変更
- **MINOR**: 後方互換性のある機能追加
- **PATCH**: 後方互換性のあるバグ修正

### リリース手順

1. **リリースブランチの作成**

```bash
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0
```

1. **バージョン更新**

```bash
# package.json のバージョン更新
# pyproject.toml のバージョン更新
# CHANGELOG.md の更新
```

1. **最終テスト**

```bash
bun run test
bun run build
```

1. **マージとタグ作成**

```bash
git checkout main
git merge release/v1.2.0
git tag v1.2.0
git push origin main --tags

git checkout develop
git merge release/v1.2.0
git push origin develop
```

## コミュニティガイドライン

### 行動規範

- **尊重**: 他の貢献者を尊重し、建設的なフィードバックを提供
- **包摂**: 多様性を尊重し、包摂的な環境を維持
- **協力**: チームワークを重視し、知識を共有
- **学習**: 継続的な学習と改善を心がける

### コミュニケーション

- **Issue**: バグ報告や機能要求は GitHub Issues を使用
- **Discussion**: 設計に関する議論は GitHub Discussions を使用
- **コードレビュー**: プルリクエストでの建設的なフィードバック

### サポート

問題や質問がある場合は、以下の方法でサポートを受けられます：

1. **ドキュメント**: まず関連ドキュメントを確認
2. **Issue 検索**: 既存の Issue で同様の問題がないか確認
3. **新しい Issue**: 新しい問題の場合は詳細な情報と共に Issue を作成

## 参考・クレジット

本プロジェクトは、以下の記事およびリポジトリをもとに作成されています：

- **記事**:

  - [Python プロジェクトのためのテンプレート](https://zenn.dev/mjun0812/articles/0ae2325d40ed20)
  - [Claude Code DevContainer](https://docs.anthropic.com/en/docs/claude-code/devcontainer)

- **リポジトリ**:
  - [Python Project Template](https://github.com/mjun0812/python-project-template)
  - [Claude Code DevContainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

## ライセンス

MIT License - 詳細は [LICENSE](../../LICENSE) ファイルを参照してください。
