# AGENTS.md — このリポジトリでの作業ルール

あなた（Codex）がこのコードベースで作業するときの約束事です。**複雑な作業では、
まず `PLANS.md`（Exec Plan）を開き、計画を更新してから実行してください。**

## 1) 最初にやること

- リポジトリの README、`PLANS.md` を読み込み、`PLANS.md` の「進捗」と「意思決定
  ログ」を更新してから着手する。
- 重要語：**Exec Plan**＝`PLANS.md`。計画の参照・更新先は常にここ。
- このリポジトリでは**常に日本語で記述・報告**すること。

## 2) 実行と検証（基本サイクル）

1. 計画 → 実装 → 検証 → 要約の順で進める。検証は自動テストと目視の両方を実施。
2. 代表コマンド：
   - Lint/Test（TypeScript）：`pnpm run lint` / `pnpm run test`
   - Python テスト：`uv run pytest -q`
   - marimo 拡張確認：`pnpm run enable:marimo` → `pnpm run dev:marimo`
   - Dev サーバ：`pnpm run dev`
3. テストが 30 分以上赤のままなら `PLANS.md` に記録し、方針転換案を提示。

## 3) 変更の提出

- 変更は PR としてまとめ、サマリに目的／完了の定義／検証結果（テストログ）／リス
  ク・ロールバックを含める。
- 提出後は **`/review`** を実行し、指摘があれば自動修正→再レビューを繰り返す。

## 4) 安全と権限

- デフォルトはサンドボックス実行。高リスク操作（秘密情報アクセス、外部書き込み）
  は明示承認が必要。
- 環境変数や秘密鍵には触れない。必要ならダミーデータで代替し、`PLANS.md` に要件
  を記録。

## 5) ツール接続（MCP）

- 追加ツールやドキュメントは MCP（Model Context Protocol）経由で利用する。
  - 例：`docs-server`（社内設計書）、`browser`（社内サイト検索）、`figma`（デザ
    イン確認）
  - MCP の詳細は公式ドキュメントを参照。

## 6) 人へのエスカレーション

- 要件の矛盾・法務/セキュリティ判断・仕様未確定など不確実性が高い場合は人に確認
  し、`PLANS.md` の「未解決事項」に記録。

## 付録：このリポジトリの固有情報（必要に応じて更新）

- 主要コマンド：`pnpm run dev` / `pnpm run lint` / `pnpm run test` /
  `uv run pytest`
- marimo 拡張の切り替え：`pnpm run enable:marimo` / `pnpm run disable:marimo`
- Docker 利
  用：`docker compose -f compose.yml -f docker-compose.marimo.yml up`（スクリプ
  トから呼び出し）
- テストレポート出力：`./artifacts/test/`、スナップショッ
  ト：`./artifacts/snapshots/`
- ブランチ戦略：`feature/*` → PR → `main`
- CI 必須チェック：ユニットテスト緑、`/review` の P0/P1 指摘ゼロ。
