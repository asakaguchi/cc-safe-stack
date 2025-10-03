# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
    に適切なグループ権限 (775) を設定

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

[0.1.1]: https://github.com/your-username/cc-safe-stack/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/your-username/cc-safe-stack/releases/tag/v0.1.0
