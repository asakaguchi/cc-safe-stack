# cc-safe-stack シンプル化プラン

## 🎯 プロジェクトの再定義

**新しい位置づけ:** 「セキュアでモダンな Python+TypeScript 開発環境テンプレー
ト」

- Claude Code 初心者とセキュリティ重視開発者向け
- 3 つの UI: React + **marimo** + FastAPI Docs
- Web Dashboard 必須（ブラウザから開発可能）
- 元テンプレートの「シンプルさ」の哲学を取り戻す

---

## 📋 実装ステップ

### Phase 1: Streamlit → marimo 置き換え

1. **streamlit/ ディレクトリをmarimo/に変換**

   - `streamlit/app.py` → サンプル marimo ノートブック作成
   - `streamlit/pages/` → marimo 用ノートブック例
   - marimo の特徴を活かしたデータ分析・管理画面の例を提供

2. **依存関係の更新**

   - `backend/pyproject.toml`: streamlit 削除、marimo 追加
   - `streamlit/requirements.txt`削除（不要）

3. **compose.yml更新**

   - streamlit サービス → marimo サービスに変更
   - ポート: 8501 → 2718（marimo デフォルト）

4. **package.json コマンド更新**

   - `dev:streamlit` → `dev:marimo`
   - `build:streamlit` → `build:marimo`
   - `lint:streamlit` → `lint:marimo`

5. **docker/Caddyfile更新**

   - `/streamlit` → `/marimo` パス変更
   - リバースプロキシ設定調整

6. **dashboard/ 更新**
   - `index.html`: Streamlit タブ → marimo タブ
   - `assets/dashboard.js`: URL 更新

---

### Phase 2: Docker構成の最適化

**開発環境テンプレートの特性を考慮した構成:**

1. **Dockerfile.frontend を削除**

   - frontend は開発環境でビルド（node_modules マウント）
   - 本番用は別途 Dockerfile を用意する設計（テンプレートには含めない）

2. **Dockerfile を簡素化**

   - 本番用ビルド例として残すが、開発では使わない設計
   - Python 環境のみ（FastAPI + marimo）
   - 約 60-70 行に削減

3. **Dockerfile.dev を開発環境の主役に**

   - Python + Node.js + セキュアモード
   - Claude Code 統合
   - 現状維持（180 行は妥当）

4. **entrypoint-frontend.sh を削除**

   - 開発環境では npm スクリプトで直接実行

5. **compose.yml を整理**
   - サービス数を 5 から 4 へ削減（app、frontend、marimo、workspace/dev、proxy
     を残す）
   - frontend サービス: Dockerfile.frontend ではなく、シンプルな node:20 イメー
     ジから起動
   - 約 150-160 行に削減

---

### Phase 3: スクリプトの整理

**28個 → 約20個に削減**

1. **削除するスクリプト**

   - `verify-setup.sh`: README に手順を明記すれば不要
   - `allow-additional-domain.sh`: ドキュメント化で代替

2. **統合するスクリプト**

   - `docker-dashboard.sh` + `docker-dashboard-down.sh` →
     `docker-dashboard.sh`に統合（引数で up/down/logs 切り替え）

3. **リファクタリング**
   - 各スクリプトの冗長なコメント削減
   - エラーハンドリング統一

---

### Phase 4: ドキュメントの整理・改善

**docs/ は現状維持しつつ、内容を改善:**

1. **README.md の構造改善**

   - 長大な説明を削減（451 行 → 約 300 行目標）
   - セキュリティ詳細 → SECURITY.md に分離
   - クイックスタートを最上部に
   - marimo 情報を追加

2. **docs/ の各ファイルをリファクタ**

   - 重複削除
   - 古い情報（Streamlit 言及）を marimo 更新
   - DevContainer/Docker 環境の説明を明確化

3. **SECURITY.md 新設**

   - README から移動（CVE 情報、セキュアモード詳細）
   - より詳細なファイアウォール設定ガイド

4. **CHANGELOG.md 更新**
   - v0.2.0: 破壊的変更（Streamlit → marimo）

---

### Phase 5: specs/ の現状維持とmarimo対応

**テンプレート・例は現状維持、marimo言及を追加:**

1. **specs/README.md 更新**

   - 「3 つのインターフェース」に marimo 追加
   - marimo 用仕様書の書き方ガイド追加

2. **specs/examples/ 更新**

   - 既存例を marimo 対応に更新
   - Streamlit 言及 → marimo 言及

3. **specs/templates/ 現状維持**
   - MVD、拡張テンプレートはそのまま
   - marimo 統合の考慮事項を追加

---

### Phase 6: その他の調整

1. **.env.example 更新**

   - Streamlit 関連 → marimo 関連
   - ポート番号更新

2. **GitHub Actions（存在する場合）**

   - Streamlit lint → marimo lint

3. **テストの更新**

   - Streamlit 関連テスト削除
   - marimo 統合テスト追加

4. **CLAUDE.md 更新**
   - 3 つのインターフェース: React + marimo + API Docs
   - marimo の説明追加

---

## 📊 削減効果（見込み）

| 項目             | 現状  | After  | 削減率 |
| ---------------- | ----- | ------ | ------ |
| Dockerファイル数 | 3個   | 2個    | 33%    |
| Docker総行数     | 498行 | ~350行 | 30%    |
| compose.yml      | 195行 | ~155行 | 20%    |
| スクリプト数     | 28個  | ~20個  | 29%    |
| README.md        | 451行 | ~300行 | 33%    |
| 学習コスト       | 高    | 中     | 30-40% |

---

## 🎁 marimoによる付加価値

### Streamlitからの改善点

1. **開発者体験を向上させる要素**

   - Git-friendly な.py ファイル形式
   - Vim keybindings、GitHub Copilot 統合
   - リアクティブ実行で状態管理の自動化を実現

2. **Claude Codeとの親和性**

   - 純粋な Python ファイル（AI が理解しやすい）
   - 明確なセル依存関係
   - コードレビューしやすい

3. **モダンさ**
   - Stanford, OpenAI 等で採用
   - SQL 統合（DuckDB, PostgreSQL）
   - インタラクティブな Dataframe GUI

---

## 🔄 移行ガイド（ユーザー向け）

v0.1.x → v0.2.0 への移行手順を以下に整理します。

1. **既存Streamlitアプリの移行**

   ```bash
   # Streamlitコードをmarimoに移行する手順
   pip install marimo
   marimo convert streamlit_app.py -o marimo_notebook.py
   ```

2. **ポート変更**

   - 8501 → 2718

3. **コマンド変更**
   - `pnpm run dev:streamlit` → `pnpm run dev:marimo`

---

## ⚠️ リスクと対策

### リスク

1. **既存ユーザーの混乱**: Streamlit 削除
2. **marimoの学習コスト**: 新しいツール
3. **後方互換性なし**: 破壊的変更

### 対策

1. **ブランチ戦略**

   - `main`: marimo 版（v0.2.0+）
   - `streamlit-legacy`: Streamlit 版（v0.1.x）保守

2. **移行ガイド充実**

   - MIGRATION.md 新設
   - 具体的なコード例

3. **セマンティックバージョニング**
   - v0.2.0（メジャー変更）として明示

---

## 📝 実装の優先順位

**Phase 1（最優先）: marimo置き換え**

- 機能的な価値が最も高い
- 他の Phase から独立

**Phase 2: Docker最適化**

- 開発環境として本質的な改善

**Phase 3-4: スクリプト・ドキュメント整理**

- 段階的に実施可能

**Phase 5-6: その他調整**

- 仕上げ

---

## 🎯 期待される成果

このプランにより、次の成果を得られます。

1. **シンプルさの回復**

   - 元テンプレートの「シンプルで自由度の高い」哲学に回帰
   - 学習コスト 30-40%削減

2. **モダンさの向上**

   - marimo による最新の開発体験
   - Claude Code との親和性向上

3. **独自価値の維持**

   - Python+TypeScript フルスタック
   - セキュアモード（ファイアウォール）
   - Web Dashboard
   - 3 つの UI（より洗練された構成）

4. **メンテナンス性向上**
   - ファイル数削減
   - 重複コード削減
   - ドキュメント整理

---

**より現代的で、よりシンプルな開発環境テンプレート**へ進化します。
