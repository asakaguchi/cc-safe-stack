# Exec Plan: cc-safe-stack セキュア簡素化テンプレート刷新

## 0. ねらい（Why / Outcome）

- 目的：Python+TypeScript のセキュアな開発テンプレートを「React + FastAPI」を軸
  に再設計し、marimo を標準サンプルに含めつつもワンコマンドで有効/無効を切り替え
  られるシンプルな構成へ刷新する。
- 完了の定義（Definition of Done）：
  - `apps/backend`、`apps/frontend`、`extensions/marimo` を基盤とする最小構成を
    main ブランチへ統合する。
  - `pnpm run dev` で React + FastAPI を起動でき、`pnpm run enable:marimo` →
    `pnpm run dev:marimo` で marimo ダッシュボードを表示できることを確認する。
  - DevContainer・Docker・CI の各設定で
    `pnpm run lint`、`pnpm run test`、`uv run pytest`、必要時
    `pnpm run test:marimo` が成功し続ける。
  - README、docs/extensions/marimo.md、MIGRATION.md を更新し、移行手順とロール
    バック方法を明文化する。

## 1. 背景と前提

- 背景：現行テンプレートは Python・TypeScript・複数 UI（React/Streamlit/Docs）・
  複数 Dockerfile を取り込み複雑化。marimo を採用しつつ、元テンプレートの「シン
  プルさ」を取り戻したい。
- 既知の制約・前提：
  - DevContainer を継続利用し、セキュアモード（非 root 実行・ファイアウォール設
    定）を温存。
  - pnpm/uv を標準パッケージマネージャとして利用し、bun はオプション位置づけ。
  - 現行 main の破壊的変更は v0.2.0 として扱い、旧 Streamlit 版は legacy ブラン
    チで維持する方針。

## 2. 範囲

- 対象（In scope）：
  - ディレクトリ再編（`apps/`, `packages/`, `extensions/`）と共通スクリプト整
    備。
  - Docker/DevContainer/compose の簡素化と marimo 差分 compose の追加。
  - pnpm スクリプト（enable/disable/dev marimo 等）、shell スクリプト実装。
  - README・docs・MIGRATION・CLAUDE.md 等のドキュメント更新。
  - CI ワークフロー（GitHub Actions 想定）の更新と optional marimo ジョブ追加。
- 非対象（Out of scope）：
  - アプリ固有のビジネスロジック変更。
  - 既存デザインシステムや UI コンポーネントの刷新。
  - Legacy Streamlit ブランチの機能追加（最低限のメンテのみ）。

## 3. 大づかみの設計（Big picture）

- 変更点の要約：
  - ディレクトリとビルド構成: `backend` を `apps/backend` へ、`frontend` を
    `apps/frontend` へ移し、共通型を `packages/shared` に集約す
    る。`extensions/marimo` にはサンプルと Compose 差分を配置する。
  - CLI とスクリプト: `package.json` に marimo 用の enable/disable/dev コマンド
    や bun オプションを追加し、`scripts/*.sh` で Compose 差分適用と依存解決を自
    動化する。
  - DevContainer と Docker: Python + Node を同居させた単一コンテナを維持し、不要
    コンテナを削除する。marimo は `docker-compose.marimo.yml` 経由で任意追加でき
    るようにする。
  - ドキュメントと CI: README をクイックスタート中心に再編し、marimo / bun /
    legacy の移行ガイドを docs 配下に整理する。CI は React + FastAPI を基準と
    し、marimo ジョブをオプションとして追加する。
- ロールバック方針：
  - `streamlit-legacy` ブランチに現行構成を保持し、重大不具合時はそのブランチへ
    切り替え可能。
  - enable/disable スクリプトで marimo を無効化すれば React+FastAPI の最小構成へ
    即復帰。
  - クリティカルな不具合が再現した場合は、`legacy/` ディレクトリに保存した旧設定
    へ差し戻して復旧する。

## 4. 検証計画（Verification）

- テス
  ト：`pnpm run lint`、`pnpm run test`、`uv run pytest -q`、`pnpm run test:marimo`（オ
  プション）。
- 目視検証：`pnpm run dev` で React UI と FastAPI Docs をブラウザ確
  認、`pnpm run enable:marimo` → `pnpm run dev:marimo` で marimo ダッシュボード
  を確認。
- パフォーマンスや監視：ローカル開発でのリソース消費を `docker stats` で確認し、
  コンテナ数削減による 20% 以上のメモリ削減を目標。
- リリース前チェックリスト：PR `/review` 実行、README の手順通りに新規セットアッ
  プ→成功確認、CI 緑（main matrix 全成功）。

## 5. 実行手順（Plan of record）

- スパイク（短時間の試行）：
  - [x] Spike-1: marimo compose 差分 + enable/disable スクリプトの最小実装検証
        （時限 90 分）
- 実装タスク：
  - [x] T1: ディレクトリ再編（apps/packages/extensions）と import/パス修正（担
        当: Codex）
  - [x] T2: DevContainer・Dockerfile・compose の簡素化と marimo 差分ファイル追加
        （担当: Codex）
  - [x] T3: pnpm スクリプト整備と shell スクリプト実装、bun オプション化（担当:
        Codex）
  - [x] T4: README・docs・MIGRATION・CLAUDE.md 更新（担当: Codex）
  - [x] T5: CI ワークフロー更新と検証（担当: Codex）
- マイルストーン：
  - M1: ディレクトリ再編と docker compose 差分のドラフト完了 / 期日: 2025-10-24
  - M2: ドキュメント更新と CI 緑で main 反映準備完了 / 期日: 2025-10-27

## 6. リスクと対策

- R1: pnpm スクリプトでは OS ごとの挙動差が発生しやすい → 対策：POSIX シェルで実
  装し、Windows は DevContainer 利用を前提にドキュメント化。
- R2: marimo と FastAPI のポート競合/リバースプロキシ設定ミス → 対策：compose 差
  分でポートを明示し、Caddy/Nginx 設定を自動適用するスクリプトに含める。
- R3: CI では Python/Node のキャッシュ破損がビルド不安定化を招く → 対
  策：`actions/cache` のキーを新構成に合わせて更新し、フォールバック手順を
  README に追記。

---

## （ここから「生きた」欄：進めながら随時更新）

- [ ] やること（To‑Do）：（次のタスクを定義する）
- [x] 進行中（Doing）：バックエンド／フロントテスト環境の安定化対応。
- [x] 完了（Done）：
  - 2025-10-21 T1 ディレクトリ再編（apps/・packages/・extensions）と関連スクリプ
    ト・コンフィグ更新
  - 2025-10-21 lint 全項目緑化（`pnpm run lint` 成功）
  - 2025-10-23 Spike-1 marimo enable/disable スクリプト検証完了
    （docker-compose.override シンボリックリンク動作確認）
  - 2025-10-23 `pnpm run test` が即時終了するよう Vitest 実行方法を修正
    （`vitest run` を直接呼び出し）
  - 2025-10-23 docker compose ドキュメントを node:20 ベース構成と Caddy 8080
    ルートに合わせて更新
  - 2025-10-23 T2 DevContainer / Dockerfile / compose の再構成を完了（Node 公式
    イメージ移行＋不要ファイル削除を確定）
  - 2025-10-23 dashboard 系スクリプトを `docker-dashboard.sh` に集約
    し、up/down/logs を単一スクリプトで扱えるよう改善
  - 2025-10-23 `verify-setup.sh` を削除し、README のローカル手順をシンプル化
  - 2025-10-23 allow-additional-domain スクリプトの運用ドキュメントを更新
    （security/turorial へ手順追記）
  - 2025-10-23 marimo 置き換えに合わせたドキュメント刷新
    （dashboard/welcome、docs/TUTORIAL.md、specs/README.md、specs/examples/\*.spec.md
    を更新）
  - 2025-10-23 docs/README.md の案内を React + marimo 構成に合わせて更新
  - 2025-10-23 MIGRATION.md を追加し、Streamlit → marimo 移行手順を整理
  - 2025-10-23 CI ワークフローを pnpm / apps 配下構成に合わせて更新（uv + pnpm
    ベースに刷新）

### B. 驚き・発見（Surprises & Discoveries）

- <日時>：<想定外の事実/学び> → 対応

### C. 意思決定ログ（Decision Log）

- 2025-10-21：`pnpm` を標準パッケージマネージャに据え、`bun` はオプションとして
  enable/disable スクリプトで提供する方針を確定（安定性と互換性を優先）
- 2025-10-21：作業用ブランチ `feature/simplify-template` を作成し、新構成の開発
  は当該ブランチで進行する
- 2025-10-21：marimo は標準サンプルとして含めつつ、`docker-compose.marimo.yml` +
  `enable/disable` / `dev` スクリプトでオプション化する方針を実装
- 2025-10-21：テスト実行は `.venv` 共通仮想環境を用い、`UV_NO_SYNC=1` でオフライ
  ン運用する方針に変更（lint は成功、テストは要追跡）
- 2025-10-23：docker-compose の frontend サービスを node:20 ベースのコンテナに切
  り替える方針を確定。 `docker/Dockerfile.frontend` と
  `docker/entrypoint-frontend.sh` を撤廃し、pnpm は起動時にグローバル導入する。
- 2025-10-23：フロントエンドの `/api/health` 呼び出しを `/health` エンドポイント
  に合わせて修正し、MSW ハンドラと marimo 依存シナリオも同一パスで統一する方針を
  確定。API パスは `VITE_API_URL` をもとに組み立てる小さなヘルパーで環境差を吸収
  する。
- 2025-10-23：`pnpm run test` がウォッチモードで待機しないよう、フロントエンドテ
  スト実行を `vitest run` に統一する方針を採用
- 2025-10-23：docker compose ドキュメントを node コンテナ化・Caddy ルーティング
  に合わせて更新する方針を採用
- 2025-10-23：dashboard 用の Docker スクリプトは `docker-dashboard.sh` に集約
  し、引数で up/down/logs を切り替える運用へ移行
- 2025-10-23：`verify-setup` コマンドは廃止し、`pnpm run setup` に一本化する方針
  を採用
- 2025-10-23：GitHub Actions CI を apps/ 配下構成と pnpm 運用に合わせて刷新する
  方針を採用

### D. 未解決事項（Open Questions）

- 現時点では特になし
