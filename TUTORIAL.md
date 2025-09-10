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

#### ⚠️ 外部APIを使用する際の事前設定

株式分析プラットフォーム等で外部API（Yahoo Finance など）を使用する場合、セキュ
アモードで追加設定が必要です。

##### 方法1: 事前設定（推奨）

1. **設定ファイルの作成**

   必要なドメイン用の設定ファイルをコピー：

   ```bash
   # Yahoo Finance用（株式分析の場合）
   cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json

   # カスタム設定の場合
   cp .devcontainer/devcontainer.local.json.clean-sample .devcontainer/devcontainer.local.json
   ```

2. **必要に応じて設定を編集**

   ```json
   {
     "containerEnv": {
       "SECURE_MODE": "true",
       "ADDITIONAL_ALLOWED_DOMAINS": "example.com, api.example.com"
     }
   }
   ```

3. **DevContainer の再ビルド**

   VS Code で「Rebuild and Reopen in Container」を実行

##### 方法2: 実行時追加（簡易）

DevContainer 起動後に追加のドメインを許可：

```bash
# Yahoo Finance の場合
./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com query2.finance.yahoo.com

# 任意のドメインの場合
./scripts/allow-additional-domain.sh your-api-domain.com
```

**注意**: 方法2は一時的な解決策です。恒久的な設定には方法1を推奨します。

#### 📁 設定ファイルについて

`.devcontainer/` フォルダ内の設定ファイル：

- `devcontainer.json`: メインの設定（リポジトリにコミット済み）
- `devcontainer.local.json`: **ユーザー固有の設定（.gitignore に含まれる）**
- `.json.clean-*` ファイル: 標準 JSON 形式のテンプレート（推奨）
- `.jsonc.*` ファイル: コメント付き JSONC 形式のテンプレート（参考用）

**重要**: `devcontainer.local.json` は個人用設定のため、リポジトリにはコミットさ
れません。

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

---

## 🔧 トラブルシューティング

### 外部API接続エラー

**症状**: Yahoo Finance 等の外部APIに接続できない

**原因**: セキュアモードでドメインが許可されていない

**解決策**:

1. **設定確認**

   ```bash
   # 現在の環境変数を確認
   echo $ADDITIONAL_ALLOWED_DOMAINS

   # 許可されているIPを確認
   sudo ipset list allowed-domains | grep -E "(yahoo|finance)"
   ```

2. **即座に修正**

   ```bash
   # 必要なドメインを追加
   ./scripts/allow-additional-domain.sh fc.yahoo.com query1.finance.yahoo.com
   ```

3. **恒久的な修正**
   ```bash
   # 設定ファイルを作成
   cp .devcontainer/devcontainer.local.json.clean-yfinance .devcontainer/devcontainer.local.json
   # VS Code で DevContainer を再ビルド
   ```

### DevContainer 設定が反映されない

**症状**: `devcontainer.local.json` を作成したが環境変数が設定されない

**原因**: DevContainer の再ビルドまたは再起動が必要

**解決策**:

- VS Code: `Ctrl+Shift+P` → `Dev Containers: Rebuild Container`
- または、設定後に `./scripts/allow-additional-domain.sh` を使用

### 権限エラー

**症状**: `ipset` コマンドで権限エラー

**解決策**:

```bash
# スクリプト経由で実行（推奨）
./scripts/allow-additional-domain.sh your-domain.com

# 手動実行の場合は sudo を使用
sudo ipset add allowed-domains 1.2.3.4
```

---

実際の開発では、このような仕様書をもとに Claude Code と協働することで、従来と比
較して大幅に短縮された時間で高品質なアプリケーションを構築できます。
