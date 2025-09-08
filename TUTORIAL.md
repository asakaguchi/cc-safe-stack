# Claude Code で学ぶフルスタック開発

## Claude Code と一緒に作るTODOアプリチュートリアル

本チュートリアルでは、**Claude Code** を活用して TODO アプリケーションを構築しま
す。  
従来のような手動コーディングではなく、AI アシスタント Claude Code との対話を通じ
て、  
効率的なフルスタック開発を体験します。

## Claude Code とは

**Claude Code** は、Anthropic が開発した AI 駆動の統合開発環境です。従来の IDE
とは異なり、自然言語での対話を通じて開発を進められます。

### Claude Code の特徴

- 対話的開発: 自然言語で指示を出すだけでコード生成・修正
- タスク管理: TodoWrite ツールによる自動タスク管理
- 並列実行: 複数の作業を同時並行で実行
- インテリジェント検索: Grep/Glob による高速コード検索
- 自動化: テスト・リント・フォーマットを自動実行
- Git 統合: コミット・プルリクエスト作成を自動化

### なぜ Claude Code を使うのか

**従来の開発:**

```text
1. 要件を理解
2. アーキテクチャを設計
3. ファイル構造を作成
4. 各ファイルを手動で実装
5. 手動でテスト・デバッグ
6. 手動でコミット作成
```

**Claude Code での開発:**

```text
あなた: 「TODOアプリを作って」
Claude Code: 全自動で↓
- タスクを分解・管理
- ファイル構造を作成
- バックエンド API を実装
- フロントエンド UI を実装
- テスト・リント・フォーマット
- Git コミット作成
```

## 作成するアプリケーション

Claude Code と一緒に、次の機能を持つ TODO アプリを構築します。

- CRUD 操作: TODO の作成・読み取り・更新・削除
- **3つのフロントエンド**: React (プロダクション)、Streamlit (データアプリ)、FastAPI Docs (API)
- 型安全性: TypeScript と Python Pydantic による型安全な開発
- REST API: FastAPI による高パフォーマンス API
- データ可視化: Streamlit による統計ダッシュボード
- モダンツール: uv・bun による高速パッケージ管理

## 前提条件

### Claude Code 環境

- Claude Code CLI: 最新版がインストール済み
- Docker: DevContainer または Docker Compose 環境

### リポジトリのクローン

```bash
git clone <このリポジトリ>
cd claude-code-polyglot-starter
```

## Claude Code との開発開始

### 基本的な対話パターン

Claude Code との効果的な対話方法を学びましょう。

#### 良い指示の例

```text
「shared/types/todo.ts に TODO 用の型定義を作成して。
 Todo 型には id, title, completed, created_at, updated_at を含めて」
```

#### 曖昧な指示の例

```text
「何か作って」
```

#### プロフェッショナルな指示の例

```text
「TODO アプリのバックエンド API を実装して。
 FastAPI を使用、CRUD 操作、エラーハンドリング、
 型安全性を重視、テストも含めて」
```

## Claude Code との対話的実装

### Step 1: プロジェクトの初期化と理解

まず、Claude Code にプロジェクト構造を理解してもらいましょう。

#### Claude Code との対話

**あなた:**

```text
このプロジェクトの構造を調査して、
フルスタック開発環境として何ができるか教えて
```

**Claude Code:**

- Glob/Grep ツールでファイル構造を分析
- TodoWrite でタスクリストを作成
- 🔍 既存の設定ファイルを確認
- プロジェクトの特徴を報告

## Streamlit統合開発

### なぜStreamlitも使うのか

**React (フロントエンド)**
- プロダクション向けUI
- 高度なインタラクティブ性
- カスタムデザイン

**Streamlit (データアプリ)**  
- Pythonのみで完結
- 迅速なプロトタイピング
- データ可視化に特化
- 内部ツール・管理画面に最適

### Claude Codeとの対話例

**あなた:**
```text
StreamlitでTODOアプリのダッシュボードを作って。
DataFrameとチャートで統計も表示して
```

**Claude Code:**
- streamlit/ディレクトリ作成
- マルチページアプリ構築
- FastAPI統合
- Plotlyでインタラクティブチャート
- セッション状態管理

### Step 2: 開発環境の起動

**あなた:**

```text
開発環境を起動して、
バックエンド、フロントエンド、Streamlitが正常に動作するか確認して
```

**Claude Code が自動実行:**

```bash
# 依存関係のインストール
bun install
cd backend && uv sync && uv sync --group streamlit && cd -

# 3つのサーバー同時起動
bun run dev
```

**起動確認:**
- 🌐 React: http://localhost:3000
- 🐍 FastAPI: http://localhost:8000
- 🎈 Streamlit: http://localhost:8501

### Step 3: TODO 型定義の作成

**あなた:**

```text
shared/types/todo.ts に以下の型定義を作成して：
- Todo 型（id, title, completed, created_at, updated_at）
- CRUD 操作用のリクエスト・レスポンス型
- Python Pydantic と互換性のある形式で
```

**Claude Code の応答:**

- TypeScript interface と union types を生成
- Python との互換性を考慮
- JSDoc コメントを追加
- エクスポート設定を完了

### Step 4: バックエンド API の実装

**あなた:**

```text
backend/src/ 以下に TODO API を実装して：
- models/todo.py: Pydantic モデル
- routers/todo.py: FastAPI ルーター
- CRUD 操作（GET, POST, PUT, DELETE）
- エラーハンドリング
- インメモリストレージで十分
```

**Claude Code が実行:**

1. TodoWrite でサブタスクを管理
2. 必要なディレクトリ構造を作成
3. Pydantic モデルを実装
4. FastAPI ルーターを実装
5. main.py にルーターを統合
6. 型チェック・リントを実行

### Step 5: フロントエンド実装

**あなた:**

```text
React コンポーネントを実装して：
- components/TodoList.tsx: メインのリスト表示
- components/TodoItem.tsx: 個別の TODO 項目
- components/AddTodo.tsx: 新規追加フォーム
- hooks/useTodos.ts: カスタムフック
- api/todos.ts: API 通信ロジック
```

**Claude Code の並列実行:**

- 複数ファイルを同時作成
- React ベストプラクティスを適用
- CSS modules と responsive design を適用
- TypeScript で API の型安全な通信
- Jest と React Testing Library でテスト

### Step 6: Streamlit データアプリの実装

**あなた:**

```text
Streamlit でTODO管理ダッシュボードを作成して：
- FastAPI と統合した TODO 管理
- DataFrame での一覧表示
- Plotly でのグラフ・統計表示
- リアルタイムデータ更新
```

**Claude Code の実行:**

1. Streamlit アプリケーション構築
2. マルチページ構成（TODO管理・ダッシュボード・API Explorer）
3. データ可視化とチャート作成
4. API との統合とエラーハンドリング

### Step 7: 統合と動作確認

**あなた:**

```text
3つのフロントエンド（React・Streamlit・FastAPI Docs）を
統合して動作確認とテストを実行して
```

**Claude Code の自動実行:**

```bash
# Streamlit依存関係インストール
bun run build:streamlit

# 型チェック（全体）
bun run type-check

# リント・フォーマット（全体）
bun run lint:fix

# テスト実行（全体）
bun run test

# 3つのサーバー同時起動
bun run dev
```

**起動後のアクセスポイント:**
- 🌐 React UI: http://localhost:3000
- 🎈 Streamlit: http://localhost:8501  
- 📚 FastAPI Docs: http://localhost:8000/docs

## Claude Code の高度な機能

### 並列実行による効率化

**従来の逐次開発:**

```text
1. バックエンド実装 → 完了まで待機
2. フロントエンド実装 → 完了まで待機
3. テスト → 完了まで待機
```

**Claude Code の並列実行:**

```text
あなた: 「バックエンドとフロントエンドを並行して実装して」

Claude Code: 同時実行 ↓
🐍 Python FastAPI 実装
⚛️ React コンポーネント実装  
🎈 Streamlit ダッシュボード実装
🧪 テストファイル作成
📝 型定義の同期
📊 データ可視化チャート作成
```

### Task Tool による自動化

**あなた:**

```text
TODO アプリの実装を一括自動化して。
段階的に進捗を報告しながら
```

**Claude Code:**

- Task tool で専用エージェントを起動
- 複雑なタスクを自動分解
- バックグラウンドで並列実行
- リアルタイム進捗報告

### インテリジェントな検索と分析

**あなた:**

```text
「このプロジェクトで使用されているパッケージマネージャーを調査して」
```

**Claude Code:**

```bash
# Glob で設定ファイルを検索
**/package.json
**/pyproject.toml

# Grep で特定パターンを検索
"uv add"
"bun add"

# 結果を分析してレポート
```

## デバッグと問題解決

### エラーが発生したとき

**あなた:**

```text
TypeScript でエラーが出てる。修正して：
[エラーメッセージをペースト]
```

**Claude Code:**

- 🔍 エラー内容を分析
- 📁 関連ファイルを特定
- 🔧 修正案を複数提示
- 修正後の動作確認

### パフォーマンス問題

**あなた:**

```text
TODO リストのレンダリングが遅い。最適化して
```

**Claude Code:**

- パフォーマンスボトルネックを分析
- React.memo や useMemo を提案
- 不要な再レンダリングを最適化
- 改善効果を測定

### コード品質の向上

**あなた:**

```text
コード全体のリファクタリングとクリーンアップをして
```

**Claude Code:**

- 🧹 リント・フォーマット実行
- アーキテクチャ改善提案
- コメントとドキュメント追加
- 🧪 テストカバレッジ向上

## Git 統合機能

### 変更のコミット

**あなた:**

```text
TODO アプリの実装をコミットして
```

**Claude Code:**

```bash
# 変更ファイルを確認
git status
git diff

# 適切なコミットメッセージで自動コミット
git add .
git commit -m "feat: implement TODO app with CRUD operations

- Add shared TypeScript types
- Implement FastAPI backend with Pydantic models
- Create React components with hooks
- Add responsive CSS styling
- Include comprehensive error handling

🤖 Generated with Claude Code"
```

### プルリクエストの作成

**あなた:**

```text
この TODO 機能のプルリクエストを作成して
```

**Claude Code:**

```bash
# ブランチ作成・プッシュ
git checkout -b feature/todo-app
git push -u origin feature/todo-app

# プルリクエスト作成
gh pr create --title "Add TODO app functionality" \
  --body "## Summary
- Complete CRUD operations
- Type-safe API communication
- Responsive UI design
- Comprehensive error handling

## Test plan
- All TypeScript types validated
- Backend API tested
- Frontend components tested
- Integration tests passed

🤖 Generated with Claude Code"
```

## テスト駆動開発

### テストファースト開発

**あなた:**

```text
TDD でテストから開始して TODO API を実装して
```

**Claude Code:**

1. 🧪 テストケースを先に作成

```python
def test_create_todo():
    response = client.post("/api/todos/", json={"title": "Test"})
    assert response.status_code == 200
    assert response.json()["todo"]["title"] == "Test"
```

1. テストが失敗することを確認
2. テストを通すための最小限の実装
3. リファクタリングで品質向上

### 自動テスト実行

**あなた:**

```text
コード変更時に自動でテストを実行して
```

**Claude Code:**

- 👀 ファイル変更を監視
- 関連テストを自動実行
- 結果をリアルタイム報告
- 🚨 失敗時は即座に通知

## 実践的な開発フロー

### 新機能の追加

**あなた:**

```text
TODO にカテゴリ機能を追加して
```

**Claude Code の実行フロー:**

1. TodoWrite でタスクを分解
2. データベーススキーマ更新
3. バックエンド API 拡張
4. フロントエンド UI 更新
5. テストケース追加
6. ドキュメント更新
7. Git コミット作成

### バグ修正

**あなた:**

```text
完了したTODOが削除できないバグを修正して
```

**Claude Code:**

1. 🔍 Grep で関連コードを検索
2. 🐛 バグの原因を特定
3. 🧪 バグを再現するテストを作成
4. 🔧 修正を実装
5. テストが通ることを確認
6. 📦 修正をコミット

## 発展的な機能

### Streamlit 専用機能

**あなた:**

```text
Streamlit ダッシュボードに高度な分析機能を追加して：
- TODO 完了率の時系列分析
- カテゴリ別パフォーマンス比較
- ユーザー行動の可視化
```

**Claude Code:**

- 📊 高度なPlotlyチャート作成
- 📈 時系列データ分析
- 🎛️ インタラクティブフィルタ
- 📋 データエクスポート機能

### データベース統合

**あなた:**

```text
インメモリストレージを SQLite に変更して
```

**Claude Code:**

- 📁 SQLAlchemy モデル作成
- マイグレーション設定
- 🔌 データベース接続設定
- 🧪 データベーステスト追加
- 🎈 Streamlit での データベース統合

### 認証システム

**あなた:**

```text
ユーザー認証を JWT で実装して
```

**Claude Code:**

- 🔐 JWT トークン生成・検証
- 👤 ユーザーモデル作成
- 🚪 ログイン・サインアップ機能
- 認証ミドルウェア実装
- 🎈 Streamlit セッション管理

### リアルタイム機能

**あなた:**

```text
WebSocket で TODO の変更をリアルタイム同期して
```

**Claude Code:**

- 🔌 WebSocket エンドポイント
- 📡 リアルタイム通信
- 状態同期ロジック
- 最適化とエラーハンドリング
- 🎈 Streamlit auto-refresh 統合

## 学習リソース

### Claude Code 公式

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/claude-code)
- [Claude Code コマンドリファレンス](https://docs.anthropic.com/claude-code/commands)

### 技術スタック

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://reactjs.org/docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

### 開発ツール

- [uv Python Package Manager](https://github.com/astral-sh/uv)
- [Bun JavaScript Runtime](https://bun.sh/)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [Plotly Python Documentation](https://plotly.com/python/)

## まとめ

### Claude Code で変わる開発体験

**従来の開発:**

- 時間のかかる手動作業
- 頻繁なミスとバグ
- ドキュメント検索に時間消費
- 繰り返し作業の負担

**Claude Code での開発:**

- 爆速での実装完了
- 高品質なコード生成
- 専門知識を即座に活用
- 面倒な作業は全自動

### 習得したスキル

- AI との協働: Claude Code を使った自動化された開発手法
- プロンプトエンジニアリング: 効果的な指示の出し方
- 並列開発: 複数タスクの同時進行
- 自動化: テスト・リント・Git を含む開発フロー自動化
- フルスタック: 型安全なエンドツーエンド開発
- **ハイブリッドUI開発**: React（プロダクション）+ Streamlit（データアプリ）の組み合わせ
- **データ可視化**: Streamlit + Plotly による統計ダッシュボード作成

### 次のステップ

1. 本格運用: 実際のプロジェクトで Claude Code を活用
2. チーム開発: チームでの Claude Code 活用方法を学習
3. CI/CD: GitHub Actions と Claude Code の統合
4. デプロイ: クラウド環境への自動デプロイ
5. 監視: 本番環境でのモニタリング設定

## おめでとうございます

Claude Code を使ったフルスタック開発をマスターしました。

この新しい開発スタイルで、**10倍の生産性向上**を体験してください。

**Next Steps**: [README.md](./README.md) で他の機能も探索してみましょう。

---

## このチュートリアルについて

このチュートリアル全体が Claude Code で生成されました。
