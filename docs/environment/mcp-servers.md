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

- リアルタイム情報: トレーニングデータではなく、リアルタイムの公式ドキュメントを
  参照
- 正確なコード例: 使用中のライブラリバージョンに対応した正確なコード例を提供
- 効率的な開発: 手動でのドキュメント検索が不要

### 使用方法

プロンプトに「use context7」を追加するだけで、最新情報を取得できます。

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

- FastAPI: Web API フレームワーク
- Pydantic: データバリデーション
- SQLAlchemy: ORM
- Pandas: データ分析
- その他多数: 主要な Python ライブラリに対応

#### TypeScript/JavaScript

- React: UI ライブラリ
- Next.js: フルスタックフレームワーク
- Vite: ビルドツール
- Express: Node.js フレームワーク
- その他多数: 主要な JS/TS ライブラリに対応

詳細は [Context7 公式サイト](https://context7.com) を参照してください。

## Chrome DevTools - ブラウザデバッグ＆パフォーマンス分析

### Chrome DevTools の概要

Chrome DevTools MCP サーバーにより、ブラウザの自動操作、デバッグ、パフォーマンス
分析が可能になります。Google Chrome の開発者ツール機能を AI から直接利用できま
す。

### Chrome DevTools の主な機能

- ブラウザ自動操作: クリック、入力、ナビゲーション、フォーム送信
- パフォーマンス分析: Core Web Vitals (CWV) の測定、トレース記録、最適化提案
- デバッグ機能: コンソールログ確認、ネットワークリクエスト分析、エラー検出
- スクリーンショット: ページやDOM要素の状態を視覚的に記録
- 複数ブラウザチャンネル対応: Stable、Canary、Beta、Dev
- JavaScript実行: ページ内でのカスタムスクリプト実行

### Chrome DevTools の使用方法

Chrome DevTools MCP は自動的に利用可能になります。ブラウザ操作やデバッグが必要な
タスクを指示してください。

#### パフォーマンス分析の例

```text
「このページのパフォーマンスを分析して、Core Web Vitalsのスコアを教えて」
```

#### ネットワーク分析の例

```text
「https://example.com にアクセスして、APIリクエストの応答時間を確認して」
```

#### UI要素の操作例

```text
「ログインフォームに情報を入力してテストして」
```

### Chrome DevTools の設定

プロジェクトルートの `.mcp.json` に Chrome DevTools の設定を記載済みです。

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--isolated"],
      "env": {}
    }
  }
}
```

#### 設定オプションの説明

- `--isolated`: 一時的なユーザーデータディレクトリを使用（クリーンな環境）
- Docker開発環境に最適化された設定
- 初回使用時に自動でインストールされます

### 活用事例

#### 1. フロントエンドのパフォーマンス最適化

```text
「ダッシュボードページのパフォーマンスを分析して：
- LCP、FID、CLSの値を測定
- ボトルネックを特定
- 改善提案を提示」
```

#### 2. API通信のデバッグ

```text
「ログイン処理のネットワークリクエストを確認して：
- リクエストヘッダーの内容
- レスポンスステータス
- エラーの有無」
```

#### 3. UI動作テスト

```text
「ヘッダーナビゲーションの動作をテスト：
- 各メニューリンクが正しく動作するか
- コンソールにエラーが出ていないか
- スクリーンショットを撮影」
```

#### 4. フォーム操作の自動化

```text
「ユーザー登録フォームの動作を確認：
1. フォームに情報を入力
2. バリデーションをテスト
3. 送信後の挙動を確認
4. コンソールログをチェック」
```

## MCP設定ファイル

### .mcp.json の構成

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {}
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--isolated"],
      "env": {}
    }
  }
}
```

#### Chrome DevTools 利用可能オプション

- `--isolated`: 一時的なユーザーデータディレクトリを使用（推奨）
- `--headless`: UIなしでブラウザを実行（CI/CD環境向け）
- `--channel`: Chromeチャンネルを指定（stable/canary/beta/dev）
- `--executablePath`: カスタムChrome実行パスを指定
- `--logFile`: デバッグログの出力先を指定

### 設定の管理

- 自動インストール: 初回使用時に必要なパッケージが自動インストール。
- チーム共有: プロジェクトルートの設定をチーム全体で共有。
- 環境変数: 必要に応じて環境変数で設定を調整。

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

### Chrome DevTools 活用のコツ

#### 1. 目的を明確にする

```text
✅ 良い例: 「ログインページのパフォーマンスを測定してLCPを改善して」
❌ 悪い例: 「ページを速くして」
```

#### 2. ステップを分けて指示

```text
✅ 良い例:
「以下の手順でテスト：
1. https://example.com にアクセス
2. ログインフォームに入力
3. コンソールエラーを確認
4. ネットワークリクエストを分析」

❌ 悪い例:
「ログインをテストして」
```

#### 3. 具体的な要素を指定

```text
「#submit-button をクリックして、.error-message が表示されるか確認」
```

## トラブルシューティング

### Context7 関連

#### 問題: ドキュメントが見つからない

原因: ライブラリ名の誤記やバージョン指定の問題。

解決策:

- 正確なライブラリ名を確認
- 公式ドキュメント URL で確認
- バージョン情報を省いて再試行

#### 問題: 古い情報が表示される

原因: キャッシュされた情報が表示される可能性。

解決策:

- より具体的なバージョンを指定
- 「最新版」「latest」などのキーワードを追加

### Chrome DevTools 関連

#### 問題: ブラウザが起動しない

原因: Chrome がシステムにインストールされていない、またはDocker環境でディスプレ
イが利用できない。

解決策:

```bash
# Chromeの確認
google-chrome --version

# Docker環境の場合、X11フォワーディング確認
echo $DISPLAY
```

#### 問題: 要素が見つからない

原因: セレクターの誤りやページの読み込み待ち不足。

解決策:

- ページスナップショット機能でDOM構造を確認
- より具体的なセレクター（ID、クラス、データ属性）を使用
- ページ読み込み完了を明示的に待つ

#### 問題: パフォーマンス測定が不正確

原因: キャッシュやネットワーク状態の影響。

解決策:

- `--isolated` オプションでクリーンな環境を使用（設定済み）
- ネットワークスロットリングを適用
- 複数回測定して平均値を取る

#### 問題: スクリーンショットが撮れない

原因: ディスプレイ設定やファイル権限の問題。

解決策:

```bash
# 保存ディレクトリの権限確認
chmod 755 screenshots/

# Docker環境でヘッドレスモードに切り替え
# .mcp.json に --headless オプション追加
```

## セキュリティ考慮事項

### Context7

- API 制限: レート制限や API キーの管理
- データプライバシー: 機密情報を含むコードの取り扱い注意

### Chrome DevTools

- 認証情報: ログイン情報の適切な管理
- セッション管理: `--isolated` オプションで一時的な環境を使用（設定済み）
- データ保護: スクリーンショットやログに機密情報が含まれないよう注意
- クッキー・ストレージ: 一時環境のため、セッション終了時に自動削除

### 推奨事項

- 機密情報は環境変数で管理
- テスト用の専用アカウントを使用
- スクリーンショットやログファイルの共有時は情報を確認

## パフォーマンス最適化

### Context7 の最適化

- 必要な情報のみを要求
- 複数のライブラリを同時に指定して効率化
- キャッシュされた情報の活用

### Chrome DevTools の最適化

- `--isolated` オプション: クリーンな環境で一貫した結果を取得（設定済み）
- ヘッドレスモード: CI/CD環境やリソース制約時に `--headless` を追加
- ネットワークスロットリング: リアルな条件でパフォーマンステスト
- 複数タブ操作: 並列でのテスト実行も可能

```text
「複数のページのパフォーマンスを並列で測定して」
```

## 関連リンク

- [Context7 公式サイト](https://context7.com)
- [Chrome DevTools MCP GitHub](https://github.com/ChromeDevTools/chrome-devtools-mcp)
- [Chrome DevTools 公式ブログ](https://developer.chrome.com/blog/chrome-devtools-mcp)
- [MCP 公式ドキュメント](https://modelcontextprotocol.io/)

## 関連ドキュメント

- [DevContainer完全ガイド](devcontainer.md)
- [Docker環境](docker.md)
- [セキュリティ設定](security.md)
