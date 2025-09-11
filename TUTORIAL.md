# Claude Code 実践ガイド

## 🎯 Claude Code とは

**Claude Code** は仕様書から自律的にコードを生成・実装する AI 開発パートナーで
す。従来の段階的コーディングではなく、**一括実装による効率的な開発**を実現しま
す。

### 基本コンセプト

- 仕様書駆動により明確な仕様から品質の高い実装を生成
- TDD/BDD でテストファーストによる品質担保
- バックエンド・フロントエンド・テストの同時並行実装
- リント・テスト・フォーマットの自動実行

## 🚀 使い方

### 1. 仕様書を用意する

```text
specs/examples/から参考例を選択：
- todo-app.spec.md      # シンプルなCRUDアプリ
- stock-platform.spec.md  # 高度な分析プラットフォーム
```

### 2. Claude Code に実装を依頼する

```text
「specs/examples/todo-app.spec.md の仕様で実装してください」
```

### 3. 品質確認・デプロイ

```text
# 自動実行される項目：
- TDD テスト作成・実行
- リント・フォーマット
- 型チェック
- 統合テスト
```

## 💡 実装例

### 最小例（5分で完了）

```text
「TODOアプリを FastAPI + React + SQLite で実装して。
 基本的なCRUD操作とStreamlit分析ダッシュボード付きで」
```

**結果**:

- FastAPI バックエンド（CRUD API）
- React フロントエンド（タスク管理 UI）
- Streamlit ダッシュボード（進捗可視化）
- 型安全性（TypeScript ↔ Pydantic）
- テスト（80%カバレッジ）

#### ⚠️ 外部APIを使用する場合

株式分析プラットフォーム等で外部 API（Yahoo Finance など）を使用する場合、セキュ
アモードで追加設定が必要です。詳細は
[セキュリティ設定ガイド](docs/environment/security.md) を参照してください。

**簡単な手順:**

```bash
# 事前設定（推奨）
cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json
# VS Code で「Rebuild and Reopen in Container」

# または実行時追加（一時的）
./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com
```

### 本格例（30分で完了）

```text
「specs/examples/stock-analysis-platform.spec.md の仕様で
 株式市場分析プラットフォームを実装してください：

 - yfinance API統合でリアルタイムデータ取得
 - WebSocketでライブ価格配信
 - Plotlyによるインタラクティブチャート
 - テクニカル指標計算（SMA, RSI, MACD等）
 - ポートフォリオ管理とリスク分析
 - TDDでGherkinテストから開始」
```

**結果**:

- 🌐 React ポートフォリオ管理 (localhost:3000)
- 🎈 Streamlit 高度分析 (localhost:8501)
- 📚 FastAPI 仕様書 (localhost:8000/docs)
- WebSocket によるリアルタイム配信

## 🔧 開発環境

### セットアップ

```bash
# 依存関係インストール
bun install
cd backend && uv sync && cd -

# 開発サーバー起動（3つ同時）
bun run dev
```

### アクセス先

- React: <http://localhost:3000>
- FastAPI: <http://localhost:8000>
- Streamlit: <http://localhost:8501>

## 📚 仕様書の書き方

詳細は [specs/README.md](specs/README.md) を参照。

### MVD（最小文書セット）

1. **Project Charter** - プロジェクトの目的・成功指標
2. **PRD** - 機能要件（Must/Should/Could/Won't）
3. **User Story** - ユーザー価値の定義
4. **Acceptance Criteria** - Gherkin 受入テスト
5. **API Spec** - OpenAPI 仕様

### 効果的な指示のコツ

```text
✅ 良い例: 「リアルタイム株価配信機能。1秒以内の更新、WebSocket使用」
❌ 悪い例: 「株価の表示をいい感じに」
```

## 🎯 Claude Code の強み

### 従来の開発 vs Claude Code

```text
従来（2-3時間）:
要件理解 → 設計 → 実装 → テスト → デバッグ → 修正...

Claude Code（30分）:
仕様書提示 → 自動実装（並列） → 品質チェック → 完了
```

### 並列実行の威力

```text
あなた: 「バックエンドとフロントエンドを同時に実装して」

Claude Code:
🐍 FastAPI ルーター ← 同時実行
⚛️ React コンポーネント ← 同時実行
🧪 テストスイート ← 同時実行
📝 型定義同期 ← 同時実行
```

## 🚀 次のステップ

1. **まずは試す**: `「specs/examples/todo-app.spec.md で実装して」`
2. **仕様書を学ぶ**: [specs/README.md](specs/README.md) で書き方をマスター
3. **本格プロジェクト**: 自分の要件で仕様書を作成
4. **チーム活用**: [specs/templates/agent/](specs/templates/agent/) で効率的な指
   示方法を学習

## 🔗 関連ドキュメント

- **[セットアップガイド](docs/getting-started/installation.md)** - 環境構築の詳
  細
- **[セキュリティ設定](docs/environment/security.md)** - 外部 API 利用時の設定
- **[DevContainer完全ガイド](docs/environment/devcontainer.md)** - 開発環境の詳
  細
- **[API開発ガイド](docs/development/api-development.md)** - FastAPI/React 開発
  手法

---

実際の開発では、このような仕様書をもとに Claude Code と協働することで、従来と比
較して大幅に短縮された時間で高品質なアプリケーションを構築できます。
