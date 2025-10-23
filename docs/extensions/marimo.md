# marimo 拡張ガイド

marimo は Python 製のインタラクティブノートブックで、FastAPI バックエンドと連携
した管理ダッシュボードを提供します。本ドキュメントではテンプレートに含まれる
`extensions/marimo` の使い方を解説します。

## 構成

```
extensions/marimo/
├── app.py           # メインノートブック
└── README (本書)
```

- `app.py` は FastAPI の `/health` と `/api/hello/{name}` を呼び出すサンプルセル
  で構成されています。セルを追加して管理画面をカスタマイズしてください。

## 有効化 / 無効化

marimo サービスを Docker Compose に組み込む場合は、以下のスクリプトを利用しま
す。

```bash
# 有効化（docker-compose.override.yml を marimo 用に作成）
pnpm run enable:marimo

# 無効化（marimo 用 override を削除）
pnpm run disable:marimo
```

> 既に `docker-compose.override.yml` を利用している場合は上書きされないため、手
> 動で `docker-compose.marimo.yml` を追加してください。

## ローカル起動

```bash
# FastAPI / React を起動
pnpm run dev

# 3 サービスをまとめて起動（初回は enable:marimo）
pnpm run dev:all

# marimo ダッシュボードを単独で起動（http://localhost:2718）
pnpm run dev:marimo
```

初回は `pnpm run enable:marimo` を実行して marimo 拡張依存を同期してください。

## Docker 起動

```
pnpm run docker:marimo -- up -d marimo
pnpm run docker:marimo -- logs -f marimo
pnpm run docker:marimo -- down
```

`docker-compose.marimo.yml` では `marimo:2718` のサービスを追加し、Caddy リバー
スプロキシから `/marimo/` でアクセスできます。

## カスタマイズのヒント

- 追加パッケージが必要な場合は `apps/backend/pyproject.toml` の
  `marimo-extensions` グループに追記し、`uv sync --group marimo-extensions` を実
  行してください。
- セルを増やす場合は `@app.cell` デコレータを使って関数を定義します。詳細は
  [公式ドキュメント](https://marimo.app/docs/) を参照してください。
- marimo サービスのポートを変更する場合は `docker-compose.marimo.yml` と
  `scripts/dev-marimo.sh` の `--port` 引数を揃えてください。
