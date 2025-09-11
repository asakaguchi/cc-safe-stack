# MCPサーバー統合ガイド

このガイドでは、Claude Code の MCP（Model Context Protocol）サーバーを活用した開
発効率向上について説明します。

## 概要

本プロジェクトでは、Claude Code の MCP サーバーを活用して、開発効率を向上させて
います。MCP サーバーにより、AI の文脈に直接最新の情報やツールを統合できます。

## Context7 - 最新ドキュメント統合

### Context7 の概要

Context7 MCP サーバーにより、常に最新のライブラリドキュメントとコード例を AI の
文脈に直接取り込むことができます。

### 主な利点

- **リアルタイム情報**: トレーニングデータではなく、リアルタイムの公式ドキュメン
  トを参照
- **正確なコード例**: 使用中のライブラリバージョンに対応した正確なコード例を提供
- **効率的な開発**: 手動でのドキュメント検索が不要

### 使用方法

プロンプトに「**use context7**」を追加するだけで、最新情報を取得できます。

#### FastAPI の例

```text
「FastAPIでWebSocketを実装する方法を教えて use context7」
```

#### React の例

```text
「React 19のServer Componentsの使い方を説明して use context7」
```

#### Next.js の例

```text
「Next.js 15のApp Routerでミドルウェアを設定する方法は？ use context7」
```

### 設定

プロジェクトルートの `.mcp.json` に Context7 の設定を記載済みです。初回使用時に
自動でインストールされ、チーム全体で同じ設定を共有できます。

### 対応ライブラリ

#### Python

- **FastAPI**: Web API フレームワーク
- **Pydantic**: データバリデーション
- **SQLAlchemy**: ORM
- **Pandas**: データ分析
- **その他多数**: 主要な Python ライブラリに対応

#### TypeScript/JavaScript

- **React**: UI ライブラリ
- **Next.js**: フルスタックフレームワーク
- **Vite**: ビルドツール
- **Express**: Node.js フレームワーク
- **その他多数**: 主要な JS/TS ライブラリに対応

詳細は [Context7 公式サイト](https://context7.com) を参照してください。

## Playwright - ブラウザ自動化

### Playwright の概要

Playwright MCP サーバーにより、ブラウザの自動操作や Web スクレイピング、E2E テス
トの実行が可能になります。

### Playwright の主な機能

- **Web ページの自動操作**: クリック、入力、ナビゲーション
- **スクリーンショット**: ページの状態を視覚的に記録
- **PDF 生成**: Web ページからの PDF 出力
- **複数ブラウザ対応**: Chromium、Firefox、WebKit
- **フォーム自動入力**: フォームデータの自動入力とファイルアップロード
- **JavaScript 実行**: ページ要素の操作とカスタムスクリプト実行

### Playwright の使用方法

プロンプトに「**playwright mcp**」を含めて指示します。

#### Webスクレイピングの例

```text
「playwright mcpを使って https://example.com から情報を取得して」
```

#### E2Eテストの例

```text
「playwright mcpでログインフォームのテストを実行して」
```

#### スクリーンショットの例

```text
「playwright mcpでページのスクリーンショットを撮って」
```

### Playwright の設定

プロジェクトルートの `.mcp.json` に Playwright の設定を記載済みです。初回使用時
に自動でインストールされます。

### 活用事例

#### 1. フォーム操作の自動化

```text
「playwright mcpで以下の操作を自動化して：
1. ログインページにアクセス
2. ユーザー名とパスワードを入力
3. ログインボタンをクリック
4. ダッシュボードのスクリーンショットを撮影」
```

#### 2. データ収集

```text
「playwright mcpで商品一覧ページから以下の情報を収集して：
- 商品名
- 価格
- 在庫状況
結果をCSVファイルで出力」
```

#### 3. UIテスト

```text
「playwright mcpでヘッダーナビゲーションのテストを実行：
- 各メニューリンクが正しく動作するか
- レスポンシブデザインが適切に表示されるか」
```

## MCP設定ファイル

### .mcp.json の構成

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["context7-mcp"],
      "env": {}
    },
    "playwright": {
      "command": "npx",
      "args": ["playwright-mcp"],
      "env": {}
    }
  }
}
```

### 設定の管理

- **自動インストール**: 初回使用時に必要なパッケージが自動インストール
- **チーム共有**: プロジェクトルートの設定をチーム全体で共有
- **環境変数**: 必要に応じて環境変数で設定を調整

## ベストプラクティス

### Context7 活用のコツ

#### 1. 具体的なライブラリ名を指定

```text
✅ 良い例: 「FastAPI use context7でWebSocketの実装方法」
❌ 悪い例: 「Pythonでリアルタイム通信 use context7」
```

#### 2. バージョン情報を含める

```text
✅ 良い例: 「React 18のuseEffectフック use context7」
❌ 悪い例: 「ReactのuseEffectフック use context7」
```

#### 3. 複数ライブラリの組み合わせ

```text
「FastAPI + SQLAlchemy + Pydantic use context7でユーザー管理API」
```

### Playwright 活用のコツ

#### 1. ステップを明確に分ける

```text
✅ 良い例:
「playwright mcpで以下を順番に実行：
1. ページにアクセス
2. フォームに入力
3. 送信ボタンをクリック
4. 結果を確認」

❌ 悪い例:
「playwright mcpでフォーム送信をテストして」
```

#### 2. 期待値を明確にする

```text
「playwright mcpでログインテスト：
- 成功時: ダッシュボードにリダイレクト
- 失敗時: エラーメッセージが表示される」
```

#### 3. セレクターを具体的に指定

```text
「playwright mcpで #login-form の username フィールドに入力」
```

## トラブルシューティング

### Context7 関連

#### 問題: ドキュメントが見つからない

**原因**: ライブラリ名の誤記やバージョン指定の問題

**解決策**:

- 正確なライブラリ名を確認
- 公式ドキュメント URL で確認
- バージョン情報を省いて再試行

#### 問題: 古い情報が表示される

**原因**: キャッシュされた情報が表示される可能性

**解決策**:

- より具体的なバージョンを指定
- 「最新版」「latest」などのキーワードを追加

### Playwright 関連

#### 問題: ブラウザが起動しない

**原因**: ブラウザの依存関係が不足

**解決策**:

```bash
# 必要な依存関係をインストール
npx playwright install-deps
npx playwright install
```

#### 問題: 要素が見つからない

**原因**: セレクターの誤りやページの読み込み待ち不足

**解決策**:

- より具体的なセレクターを使用
- 明示的な待機処理を追加
- ページの読み込み完了を待つ

#### 問題: 権限エラー

**原因**: ファイルアクセス権限の問題

**解決策**:

```bash
# スクリーンショット保存ディレクトリの権限確認
chmod 755 screenshots/
```

## セキュリティ考慮事項

### Context7

- **API制限**: レート制限や API キーの管理
- **データプライバシー**: 機密情報を含むコードの取り扱い注意

### Playwright

- **認証情報**: ログイン情報の適切な管理
- **スクレイピング倫理**: robots.txt の遵守
- **セッション管理**: ブラウザセッションの適切なクリーンアップ

### 推奨事項

- 機密情報は環境変数で管理
- 認証が必要なサイトでは、最初にブラウザを表示して手動でログイン
- セッション中はクッキーが保持されるため、継続的な操作が可能

## パフォーマンス最適化

### Context7 の最適化

- 必要な情報のみを要求
- 複数のライブラリを同時に指定して効率化
- キャッシュされた情報の活用

### Playwright の最適化

- ヘッドレスモードの活用
- 並列実行による処理時間短縮
- 不要なリソース読み込みの無効化

```text
「playwright mcpでヘッドレスモードで複数ページを並列処理」
```

## 関連リンク

- [Context7 公式サイト](https://context7.com)
- [Playwright MCP GitHub](https://github.com/microsoft/playwright-mcp)
- [MCP 公式ドキュメント](https://modelcontextprotocol.io/)

## 関連ドキュメント

- [DevContainer完全ガイド](devcontainer.md)
- [Docker環境](docker.md)
- [セキュリティ設定](security.md)
