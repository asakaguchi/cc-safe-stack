---
id: specs-guide
title: 仕様書作成ガイド（Claude Code 協創用）
owner: Tech Lead / Product Manager
status: ready
version: 1.0.0
---

# 仕様書作成ガイド

## 🎯 このガイドの目的

Claude Code と効率的に協創するための**仕様書作成のベストプラクティス**を提供しま
す。適切な仕様書があることで、Claude Code は高品質なアプリケーションを自律的に実
装できます。

## 📁 ディレクトリ構成

```
specs/
├── README.md                    # このファイル（書き方ガイド）
├── templates/                   # テンプレート集
│   ├── mvd/                    # 最小文書セット（必須）
│   │   ├── project-charter.md  # プロジェクト・チャーター
│   │   ├── prd.md              # プロダクト要件定義
│   │   ├── user-story.md       # ユーザーストーリー
│   │   ├── acceptance-criteria.feature  # 受入基準（Gherkin）
│   │   └── api-spec.yaml       # API仕様（OpenAPI）
│   ├── extended/               # 拡張文書（必要時）
│   └── agent/                  # Claude Code用
│       ├── claude-code-contract.md  # エージェント契約
│       └── prompt-templates.md      # プロンプト集
└── examples/                   # 実装例
    ├── stock-analysis-platform.spec.md  # 複雑な例
    └── todo-app.spec.md                 # シンプルな例
```

## 🚀 クイックスタート

### 最速で始める（5分）

1. **テンプレート選択**: `templates/mvd/` から必要なテンプレートをコピー
2. **基本情報入力**: プロジェクト名・目的・成功指標を記入
3. **機能要件定義**: Must/Should/Could/Won't で機能を整理
4. **Claude Code実行**: 「specs/[あなたの仕様書].md で実装して」

### おすすめ実装例

- **初回利用**: `todo-app.spec.md` をベースに小さく始める
- **本格開発**: `stock-analysis-platform.spec.md` を参考に本格仕様書作成

## 📋 MVD（最小文書セット）の使い方

### なぜMVDが重要なのか？

- **曖昧さ排除**: 明確な仕様により実装の手戻りを防止
- **品質担保**: TDD/BDDによる自動品質チェック
- **効率化**: 段階的対話から一括実装への転換

### 5つの必須文書

#### 1. 📊 Project Charter（プロジェクト・チャーター）

**目的**: プロジェクトの Why/What/Who を明確化

```markdown
✅ 記入例:

- プロジェクト名: TODOアプリ
- 目的: 個人タスク管理の効率化
- 成功指標: 操作習得5分以内、レスポンス500ms以内
- ステークホルダー: プロダクトオーナー、開発者
```

**Claude Code への効果**:

- 実装の方向性・優先度を自動判断
- 成功指標に基づく品質基準設定

#### 2. 📝 PRD（プロダクト要件定義）

**目的**: 機能要件・非機能要件の詳細化

```markdown
✅ 記入例:

## Must Have

- F-001: タスクCRUD操作（作成・表示・更新・削除）
- F-002: ステータス管理（未完了/完了）

## Should Have

- F-101: 優先度設定
- F-102: カテゴリ分類

## Won't Have（重要）

- ユーザー認証機能（V1では単一ユーザー想定）
```

**Claude Code への効果**:

- 実装すべき機能の自動抽出
- 優先度に基づく実装順序決定

#### 3. 📖 User Story（ユーザーストーリー）

**目的**: ユーザー視点での価値定義

```markdown
✅ 記入例:

### US-001: タスク作成

タスク管理者として、効率的にタスクを記録するために、素早くタスクを作成したい。

受入基準:

- [ ] タイトル入力でタスク作成できる
- [ ] 必須項目未入力時はエラー表示
- [ ] 作成後に一覧に即座反映
```

**Claude Code への効果**:

- ユーザー価値に基づくUI/UX自動設計
- 受入基準から自動テスト生成

#### 4. 🧪 Acceptance Criteria（受入基準・Gherkin）

**目的**: テスト駆動開発の基盤

```gherkin
✅ 記入例:
シナリオ: タスク作成から完了まで
  前提 ユーザーがアプリにアクセスしている
  もし 「買い物に行く」というタスクを作成する
  ならば タスク一覧に新しいタスクが表示される
  かつ 未完了ステータスになっている
```

**Claude Code への効果**:

- TDD実装（テストファースト）
- 品質ゲートの自動設定

#### 5. 🔌 API Spec（API仕様・OpenAPI）

**目的**: バックエンド・フロントエンド間の契約定義

```yaml
? ✅ 記入例
paths:
  /api/tasks:
    post:
      summary: 'タスク作成'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [title]
              properties:
                title:
                  type: string
                  maxLength: 100
```

**Claude Code への効果**:

- フロント・バック同時実装
- 型安全性の自動担保

## 💡 効果的な仕様書作成のコツ

### ✅ Good Examples

#### 具体的で測定可能な要件

```markdown
❌ 悪い例: 「レスポンスが早いこと」✅ 良い例: 「API レスポンス時間 95%ile <
200ms」
```

#### 制約の明示

```markdown
❌ 悪い例: 「ユーザー管理機能」✅ 良い例: 「ユーザー管理機能（ただしV1では単一
ユーザー、認証なし）」
```

#### 技術選択の理由

```markdown
❌ 悪い例: 「React使用」✅ 良い例: 「React使用（理由：既存チームスキル、コンポー
ネント再利用）」
```

### ❌ 避けるべきパターン

#### 曖昧な表現

```markdown
❌ 「いい感じのUI」❌ 「なるべく早く」❌ 「適当にエラーハンドリング」
```

#### 実装詳細の過指定

```markdown
❌ 「useState使ってuseEffectの中でaxios.getして...」✅ 「ユーザー一覧表示機能
（既存パターンに従って）」
```

#### 矛盾する要件

```markdown
❌ Must Have: 「高度な分析機能」+ Won't Have: 「複雑な処理」
```

## 🎯 Claude Code 向け最適化ポイント

### 1. **Doc-as-Code** 対応

```markdown
---
id: project-name # 機械可読ID
title: プロジェクト名 # 人間可読タイトル
owner: Product Manager # 責任者
status: ready # ステータス
version: 1.0.0 # バージョン
tags: [web-app, crud] # タグ（検索用）
---
```

**効果**: Claude Code が仕様書を構造化データとして処理可能

### 2. **並列実行**を意識した設計

```markdown
✅ 推奨:「FastAPI バックエンド、React フロントエンド、Streamlit ダッシュボードを
並列実装」

❌ 非推奨:「まずAPIを作って、次にフロントを作って」（逐次実行）
```

**効果**: Claude Code の並列実行能力を最大活用

### 3. **TDD/BDD** ファースト

```markdown
実装順序:

1. Gherkin 受入基準定義
2. 失敗するテスト作成
3. 最小実装でテスト合格
4. リファクタリング
```

**効果**: 品質担保と開発速度の両立

### 4. **型安全性**の重視

```markdown
必須: TypeScript ↔ Pydantic の型定義一致推奨: OpenAPI schema からの自動型生成
```

**効果**: 実行時エラーの大幅削減

## 📊 成功事例・パターン集

### パターン1: MVPアプローチ

```markdown
Phase 1: 最小限（Must Have のみ）Phase 2: 価値向上（Should Have 追加）  
Phase 3: 差別化（Could Have 追加）
```

### パターン2: マルチフロントエンド

```markdown
- React: メイン操作UI（ユーザー向け）
- Streamlit: 分析ダッシュボード（管理者向け）
- FastAPI Docs: API仕様書（開発者向け）
```

### パターン3: Real-time アプリ

```markdown
必須技術: WebSocket / Server-Sent Events必須要件: 接続管理、自動再接続、差分更新
```

## 🔧 実装指示のベストプラクティス

### 基本フォーマット

```
「specs/examples/[プロジェクト名].spec.md の仕様に基づいて、
[アプリケーションの説明]を実装してください。

要件:
- TDDでGherkinテストから開始
- [技術スタック]構成
- 並列実行で効率的に開発
- 品質ゲート（テスト80%カバレッジ、リント合格）必須」
```

### 段階的品質向上

```
フェーズ1: 「基本機能実装」
フェーズ2: 「パフォーマンス最適化」
フェーズ3: 「セキュリティ強化」
```

## 📈 効果測定・改善

### 仕様書品質の指標

- **完成度**: Claude Code が一発で理解できた機能の割合
- **正確性**: 想定通りの実装ができた機能の割合
- **効率性**: 段階的指示 vs 一括実装の時間比較

### 継続改善のサイクル

1. **実装結果の振り返り**: 期待と実際のギャップ分析
2. **仕様書の改善**: 曖昧だった部分の明確化
3. **テンプレートの更新**: 学んだベストプラクティスを反映

---

## 🎉 まとめ

**良い仕様書 = Claude Code の能力を最大化する鍵**

1. **MVD（最小文書セット）**で曖昧さを排除
2. **具体的・測定可能**な要件定義
3. **TDD/BDD**による品質担保
4. **並列実行**を意識した設計
5. **継続改善**による精度向上

これらのベストプラクティスに従うことで、Claude Code との協創効率が劇的に向上
し、**従来の10倍の開発速度**と**高い品質**を両立できます。

---

**Next Steps**:

- 📊 `examples/todo-app.spec.md` でシンプルな例を確認
- 🚀 `examples/stock-analysis-platform.spec.md` で本格的な仕様書を参考
- 🤖 `templates/agent/prompt-templates.md` で効果的な指示方法を学習
