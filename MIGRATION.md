# MIGRATION ガイド — v0.1.x → v0.2.0

このドキュメントは、Streamlit ベースの v0.1.x テンプレートを利用しているチーム
が、marimo ベースの v0.2.0 へ移行する際に必要な手順を具体的にまとめたものです。
作業範囲・流れ・既知の課題を事前に把握し、安全に移行してください。

## 1. 主要な変更点

- **ディレクトリ構成の刷新**
  - `backend/` → `apps/backend/`
  - `frontend/` → `apps/frontend/`
  - 新たに `extensions/marimo/` を追加
- **ダッシュボードの置き換え**
  - Streamlit 実装を削除し、marimo サンプルノートブックに変更
- **Docker / Compose の簡素化**
  - フロントエンドは `node:20-bullseye` イメージを採用
  - `docker-compose.marimo.yml` を override として利用
- **スクリプト整理**
  - `docker-dashboard.sh` に up / down / logs を集約
  - `verify-setup.sh` を廃止し、`pnpm run setup` に一本化
- **テスト実行の改善**
  - `pnpm run test` は `vitest run` を直接呼び出し、ウォッチ待機を解消

## 2. 既存プロジェクトの移行手順

### 2.1 ブランチ戦略

1. 既存リポジトリを `streamlit-legacy` ブランチとして保全（任意）
2. `main` へ v0.2.0 の変更をマージ
3. marimo 化が不要な場合は `streamlit-legacy` を継続利用

### 2.2 ファイル移動

```bash
git mv backend apps/backend
git mv frontend apps/frontend
mkdir -p extensions/marimo
```

marimo ノートブック（`extensions/marimo/app.py`）を追加し、既存の Streamlit ダッ
シュボードを継続利用する場合は `extensions` 配下にカスタム marimo ノートブックを
用意してください。ダッシュボードを自動生成したい場合は、テンプレートの app.py を
ベースに接続先 API とセル構成を編集します。

### 2.3 依存関係の更新

```bash
# バックエンド（marimo 依存を追加）
cd apps/backend
uv sync --frozen
uv sync --group marimo-extensions

# フロントエンド
cd ../frontend
pnpm install
```

### 2.4 Docker / Compose の調整

- `docker/Dockerfile.frontend` と `docker/entrypoint-frontend.sh` を削除
- `compose.yml` の `frontend` サービスを Node 公式イメージ構成に更新
- marimo を利用する場合は以下を実行

```bash
pnpm run enable:marimo       # docker-compose.override.yml が作成される
pnpm run dev:marimo          # ローカルで marimo 起動
pnpm run docker:marimo -- up -d marimo  # Docker 上で marimo 起動
```

### 2.5 スクリプト利用方法

- `pnpm run dev` : React + FastAPI を起動
- `pnpm run dev:all` : React + FastAPI + marimo を同時起動（初回は
  enable:marimo）
- `pnpm run dev:marimo` : marimo ノートブックをローカル実行
- `pnpm run docker:dashboard` : 4 分割 Web ダッシュボード（marimo を含む）
- `pnpm run docker:dashboard down` : 停止（`docker-dashboard.sh down` と等価）

### 2.6 ドキュメント整合性

テンプレート同梱のドキュメントも marimo 前提に更新しています。カスタムドキュメン
トをお持ちの場合は、Streamlit の記述を marimo に合わせて調整してください。

- `README.md` / `docs/README.md`
- `docs/TUTORIAL.md`
- `docs/environment/security.md`
- `specs/examples/*.spec.md`

## 3. Streamlit プロジェクトを維持したい場合

marimo への移行が難しい場合は、以下の選択肢を検討してください。

1. `streamlit-legacy` ブランチを main と分離
2. `extensions/marimo/` の代わりに独自の Streamlit プロジェクトを配置
3. docker compose の override を Streamlit 用に調整

## 4. トラブルシューティング

| 症状                                         | 原因                              | 対処                                                                |
| -------------------------------------------- | --------------------------------- | ------------------------------------------------------------------- |
| marimo が 2718 ポートで起動しない            | `enable:marimo` 未実行            | `pnpm run enable:marimo` を実行し override を作成                   |
| フロントエンドが `pnpm` 未インストールで失敗 | Node イメージによる               | コンテナ内で `npm install -g pnpm@9` を実行（compose で自動化済み） |
| `pnpm run test` が終了しない                 | 旧コマンド (`pnpm test -- --run`) | 最新版へ更新し `vitest run` を直接呼び出す                          |

## 5. 参考リンク

- marimo 公式ドキュメント: <https://marimo.app/docs/>
- FastAPI 公式ドキュメント: <https://fastapi.tiangolo.com/>
- uv パッケージマネージャー: <https://astral.sh/uv>

---

ご不明な点があれば Issue でお問い合わせください。
