# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-10-23

### Added

- **marimo ダッシュボード体験**
  - `pnpm run enable:marimo` → `pnpm run dev:marimo` / `pnpm run dev:all` でサン
    プルダッシュボードを起動可能
  - `extensions/marimo/app.py` に管理ビューの雛形を同梱
- **移行ドキュメントとガイド**
  - `MIGRATION.md` に Streamlit から marimo への切り替え手順を掲載
  - README / docs 一式を marimo + FastAPI + React 構成に合わせて全面更新

### Changed

- **ディレクトリ構成の再編**
  - アプリコードを `apps/backend`, `apps/frontend`, 共有型を `packages/shared`
    へ整理
  - 新しい構成に合わせてスクリプト・CI・設定ファイルを刷新
- **開発体験のシンプル化**
  - `pnpm run dev`（React + FastAPI）と `pnpm run dev:all`（React + FastAPI +
    marimo）を整備
  - Docker Compose / DevContainer を Node 公式イメージベースに一本化し、セット
    アップを短縮

### Removed

- **Streamlit ベースのダッシュボード**（`streamlit/` 配下）を廃止し、marimo に置
  き換え
- **テンプレート外サンプルコード**（`examples/python-sample/` など）を削除し、配
  布物をスリム化

## [0.1.4] - 2025-10-06

### Added

- **Web ダッシュボードのウェルカムページ**
  - プロジェクト概要とクイックスタートガイド
  - 各パネルの使い方説明
  - よく使うコマンド一覧
  - トラブルシューティング情報
  - VS Code 風のダークテーマデザイン
  - レスポンシブ対応（モバイルでも見やすい）

### Changed

- **dashboard/assets/dashboard.js**
  - アプリプレビューの初期 URL を `/api/docs` から `/welcome.html` に変更
  - バックエンド未起動時でもエラー画面が表示されない
  - 絶対パスを使用して UI 表示とローカルストレージの値を適切に保持

### Fixed

- **アプリプレビューの初期表示エラー**
  - バックエンド未起動時に `/api/docs` でエラー画面が表示される問題を解消
  - ウェルカムページで開発環境の使い方をガイド
  - 再帰的読み込みによる負荷増大を回避（相対パスの問題を修正）

## [0.1.3] - 2025-10-06

### Added

- **Google Cloud 認証マウント機能**
  - ホスト側の gcloud 認証情報を DevContainer と Docker 環境にマウント
  - トークン自動更新のため書き込み可能でマウント（約 1 時間で失効）
  - Linux/Mac/WSL2 環境のデフォルト対応（`${HOME}/.config/gcloud`）
  - Windows PowerShell 認証のサポート（`${APPDATA}/gcloud`）
  - `.devcontainer/devcontainer.local.jsonc.gcloud-powershell` テンプレート追加

### Changed

- **compose.yml**

  - gcloud マウントパスを `GCLOUD_CONFIG_PATH` 環境変数で設定可能に
  - デフォルト値: `${HOME}/.config/gcloud` (Linux/Mac/WSL2)
  - PowerShell 用: `.env` で `GCLOUD_CONFIG_PATH=%APPDATA%/gcloud` を設定

- **.env.example**

  - Google Cloud 認証の詳細な手順を追加
  - Linux/Mac/WSL2 と Windows PowerShell の両方のケースを説明
  - トークン自動更新の仕組みを明記

- **docs/environment/security.md**

  - Google Cloud Platform 認証セクションを大幅拡充
  - Docker 環境と DevContainer 環境の設定手順を追加
  - トークン更新の仕組みとセキュリティ上の利点を詳細に説明
  - Windows PowerShell 認証の手順を追加

- **README.md**
  - Google Cloud Platform の簡易セットアップガイドを追加
  - ホスト側での `gcloud auth login` 実行を案内

### Fixed

- **DevContainer の gcloud マウント**

- ネスト展開未対応の問題を修正し、`${localEnv:HOME:${localEnv:USERPROFILE}}` →
  `${localEnv:HOME}` の形式へ統一

  - Windows 環境でのパス連結問題を解決
  - PowerShell 認証時のパス不一致を解決（APPDATA 環境変数を使用）

- **mounts 配列の上書き問題**

- テンプレートが既存のマウント（claude-code-config, python-cache）を削除する問題
  を修正

  - ベースの全マウントを含めた完全な配列に修正

- **ドキュメントの矛盾**
  - 「read-only でマウント」という誤った記述を「書き込み可能」に統一
  - トークン更新のため書き込み権限が必須であることを明記

## [0.1.2] - 2025-10-06

### Fixed

- **Docker ビルドエラーの修正**
  - `@anthropic-ai/claude-code` インストール時の権限設定エラーを修正
  - インストール先ディレクトリが存在しない場合のビルド失敗を解決
  - `|| true` によるエラー握りつぶしを削除し、権限設定失敗を確実に検出
- `if` 文でインストール結果を明示的に評価し、失敗時は即座にビルドを停止するよう
  処理を変更（エラーを握りつぶさず記録）

## [0.1.1] - 2025-10-03

### Added

- **Web Dashboard 改善**

  - デフォルトプレビュー URL を `/preview/` から `/api/docs` (FastAPI Swagger
    UI) に変更
  - タブ UI の改善: レスポンシブデザイン、水平スクロール対応、アクセシビリティ向
    上

- **Google Cloud Platform サポート**

  - gcloud CLI を DevContainer と Docker 環境の両方にインストール
  - 約 30 個の Google Cloud ドメイン
    (SDK、Console、Storage、Logging、Monitoring、主要サービス) をファイアウォー
    ル許可リストに追加
  - `.env.example` に GCP 設定ガイドを追加

- **Claude Code 使用ガイド**
  - README に初回起動時の重要な注意事項を追加
  - `--dangerously-skip-permissions` オプションの正しい使用方法を文書化

### Fixed

- **Claude Code 更新権限の修正**
  - Docker 環境で vscode ユーザーが
    `npm install -g @anthropic-ai/claude-code@latest` を実行できるように権限を修
    正
- `/usr/local/lib/node_modules/@anthropic-ai`、`/usr/local/bin`、`/usr/local/share`
  に sudo グループの書き込み権限 (775) を設定した。
  - vscode ユーザーが `npm install -g` でグローバルモジュールを更新できる状態を
    保証

### Changed

- README.md のプレビュー URL 説明を `/api/docs` に更新

## [0.1.0] - 2025-09-27

### Added

- 初回リリース
- Python (FastAPI) + TypeScript (React) フルスタックテンプレート
- Streamlit 管理ダッシュボード
- DevContainer セキュア環境
- Docker Compose 開発環境
- Web Dashboard (4 分割レイアウト)
- Claude Code 統合 (Context7 MCP, Chrome DevTools MCP)
- セキュアモード (ファイアウォール機能)
- TDD/BDD サポート
- 型安全性 (TypeScript ↔ Pydantic)

[0.2.0]: https://github.com/your-username/cc-safe-stack/compare/v0.1.4...v0.2.0
[0.1.4]: https://github.com/your-username/cc-safe-stack/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/your-username/cc-safe-stack/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/your-username/cc-safe-stack/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/your-username/cc-safe-stack/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/your-username/cc-safe-stack/releases/tag/v0.1.0
