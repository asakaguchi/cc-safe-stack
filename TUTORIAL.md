# Claude Code で学ぶフルスタック開発

## Claude Code と一緒に作る株式市場分析プラットフォーム

本チュートリアルでは、**Claude Code** を活用して株式市場分析プラットフォームを構築します。  
従来のような手動コーディングではなく、AI アシスタント Claude Code との対話を通じて、  
データ分析に特化した効率的なフルスタック開発を体験します。

## Claude Code とは

**Claude Code** は、Anthropic が開発した AI 駆動の統合開発環境です。従来の IDE
とは異なり、自然言語での対話を通じて開発を進められます。

### Claude Code の特徴

- 対話的開発: 自然言語で指示を出すだけでコード生成・修正
- タスク管理: TodoWrite ツールによる自動タスク管理
- 並列実行: 複数の作業を同時並行で実行
- インテリジェント検索: Grep/Glob による高速コード検索
- 自動化: テスト・リント・フォーマットを自動実行
- Git 統合: コミット・プルリクエスト作成を自動化

### なぜ Claude Code を使うのか

**従来の開発:**

```text
1. 要件を理解
2. アーキテクチャを設計
3. ファイル構造を作成
4. 各ファイルを手動で実装
5. 手動でテスト・デバッグ
6. 手動でコミット作成
```

**Claude Code での開発:**

```text
あなた: 「株式市場分析プラットフォームを作って」
Claude Code: 全自動で↓
- 金融データ分析タスクを分解・管理
- yfinance統合ファイル構造を作成
- 株価データ・テクニカル指標 API を実装
- ポートフォリオ管理 UI を実装
- Streamlitで高度な分析ダッシュボードを構築
- 金融データ処理テスト・リント・フォーマット
- Git コミット作成
```

## 作成するアプリケーション

Claude Code と一緒に、次の機能を持つ株式市場分析プラットフォームを構築します。

- **リアルタイム株価データ**: yfinance API による価格データ取得・更新
- **3つのフロントエンド**: React (ポートフォリオ管理)、Streamlit (分析ダッシュボード)、FastAPI Docs (API)
- **高度なデータ可視化**: Plotlyによるローソク足チャート、テクニカル分析、リスク分析
- **型安全性**: TypeScript と Python Pydantic による型安全な開発
- **WebSocketリアルタイム通信**: 価格データの即座更新
- **金融工学機能**: ポートフォリオ最適化、バックテスト、VaR計算
- **モダンツール**: uv・bun による高速パッケージ管理

## 前提条件

### Claude Code 環境

- Claude Code CLI: 最新版がインストール済み
- Docker: DevContainer または Docker Compose 環境

### リポジトリのクローン

```bash
git clone <このリポジトリ>
cd claude-code-polyglot-starter
```

## Claude Code との開発開始

### 基本的な対話パターン

Claude Code との効果的な対話方法を学びましょう。

#### 良い指示の例

```text
「shared/types/stock.ts に株式・ポートフォリオ用の型定義を作成して。
 Stock 型には symbol, name, price, volume, sector を含めて」
```

#### 曖昧な指示の例

```text
「何か作って」
```

#### プロフェッショナルな指示の例

```text
「株式市場分析プラットフォームのバックエンド API を実装して。
 yfinance統合、株価データ取得、テクニカル指標計算、
 WebSocketリアルタイム価格配信、テストも含めて」
```

## Claude Code との対話的実装

### Step 1: プロジェクトの初期化と理解

まず、Claude Code にプロジェクト構造を理解してもらいましょう。

#### Claude Code との対話

**あなた:**

```text
このプロジェクトの構造を調査して、
株式市場分析プラットフォーム開発環境として何ができるか教えて
```

**Claude Code:**

- Glob/Grep ツールでファイル構造を分析
- TodoWrite でタスクリストを作成
- 🔍 既存の設定ファイルを確認（yfinance、plotly対応確認）
- 金融データ分析に必要なライブラリの確認
- プロジェクトの特徴を報告

## Streamlit統合開発

### なぜStreamlitも使うのか

**React (フロントエンド)**
- プロダクション向けUI
- 高度なインタラクティブ性
- カスタムデザイン

**Streamlit (データアプリ)**  
- Pythonのみで完結
- 迅速なプロトタイピング
- データ可視化に特化
- 内部ツール・管理画面に最適

### Claude Codeとの対話例

**あなた:**
```text
StreamlitでTODOアプリのダッシュボードを作って。
DataFrameとチャートで統計も表示して
```

**Claude Code:**
- streamlit/ディレクトリ作成
- マルチページアプリ構築
- FastAPI統合
- Plotlyでインタラクティブチャート
- セッション状態管理

### Step 2: 開発環境の起動

**あなた:**

```text
開発環境を起動して、
バックエンド、フロントエンド、Streamlitが正常に動作するか確認して
```

**Claude Code が自動実行:**

```bash
# 依存関係のインストール
bun install
cd backend && uv sync && uv sync --group streamlit && cd -

# 3つのサーバー同時起動
bun run dev
```

**起動確認:**
- 🌐 React: http://localhost:3000
- 🐍 FastAPI: http://localhost:8000
- 🎈 Streamlit: http://localhost:8501

### Step 3: 株式・ポートフォリオ型定義の作成

**あなた:**

```text
shared/types/ 以下に株式分析用の型定義を作成して：
- Stock 型（symbol, name, sector, price_data）
- Portfolio 型（holdings, transactions, performance）
- TechnicalIndicator 型（sma, ema, rsi, macd）
- Python Pydantic と互換性のある形式で
```

**Claude Code の応答:**

- 金融データ用 TypeScript interface を生成
- 時系列データ型（価格、出来高）の定義
- テクニカル指標用の複雑な型構造
- Python との互換性を考慮
- JSDoc で金融用語の説明を追加
- エクスポート設定を完了

### Step 4: 株式分析 API の実装

**あなた:**

```text
backend/src/ 以下に株式分析 API を実装して：
- models/stock.py: 株式データ用 Pydantic モデル
- services/market_data.py: yfinance統合サービス
- routers/stocks.py: 価格データ・テクニカル指標API
- routers/portfolio.py: ポートフォリオ管理API
- WebSocketエンドポイントでリアルタイム価格配信
- 金融計算ロジック（リターン、ボラティリティ計算）
```

**Claude Code が実行:**

1. TodoWrite でサブタスクを管理
2. 金融データ用ディレクトリ構造を作成
3. **yfinance統合とデータキャッシング**
4. **テクニカル指標計算機能**
5. **WebSocketでリアルタイム価格配信**
6. Pydantic モデルを実装
7. FastAPI ルーターを実装
8. main.py にルーターを統合
9. 型チェック・リントを実行

### Step 5: React ポートフォリオ管理UI実装

**あなた:**

```text
React コンポーネントを実装して：
- components/Portfolio.tsx: ポートフォリオ概要表示
- components/StockWatchlist.tsx: ウォッチリスト管理
- components/TransactionForm.tsx: 取引記録フォーム
- components/PriceChart.tsx: 簡易価格チャート
- hooks/useStocks.ts: 株式データ用カスタムフック
- hooks/useWebSocket.ts: リアルタイム価格用フック
- api/stocks.ts: API 通信ロジック
```

**Claude Code の並列実行:**

- 複数ファイルを同時作成
- **WebSocketフック実装**
- **リアルタイム価格更新機能**
- 金融データ表示用コンポーネント
- React ベストプラクティスを適用
- CSS modules と responsive design を適用
- TypeScript で API の型安全な通信
- Jest と React Testing Library でテスト

### Step 6: Streamlit 分析ダッシュボードの実装

**あなた:**

```text
Streamlit で株式分析ダッシュボードを作成して：
- **ローソク足チャート（OHLCV）とテクニカル指標オーバーレイ**
- **ポートフォリオパフォーマンス分析（損益、リターン）**
- **リスク分析ツール（VaR、シャープレシオ、最大ドローダウン）**
- **セクター別パフォーマンス比較**
- **バックテストシミュレーター**
- **相関マトリックス・ヒートマップ**
- FastAPIとのリアルタイムデータ統合
```

**Claude Code の実行:**

1. **多機能金融分析ダッシュボード構築**
2. **マルチページ構成（チャート分析・ポートフォリオ・リスク分析・バックテスト）**
3. **Plotlyでインタラクティブな金融チャート**
4. **pandas/numpyによる高度な金融計算**
5. **streamlit-autorefreshでリアルタイム更新**
6. API との統合とエラーハンドリング

### Step 7: 統合と動作確認

**あなた:**

```text
3つのフロントエンド（React・Streamlit・FastAPI Docs）を
統合して株式分析プラットフォームの動作確認とテストを実行して
```

**Claude Code の自動実行:**

```bash
# 金融ライブラリ依存関係インストール
uv add yfinance plotly pandas numpy scipy
bun run build:streamlit

# 型チェック（全体）
bun run type-check

# リント・フォーマット（全体）
bun run lint:fix

# 金融データ処理テスト実行
bun run test

# 3つのサーバー同時起動
bun run dev
```

**起動後のアクセスポイント:**
- 🌐 **React ポートフォリオ管理**: http://localhost:3000
- 🎈 **Streamlit 分析ダッシュボード**: http://localhost:8501  
- 📚 **FastAPI 株式データAPI**: http://localhost:8000/docs
- 📊 **リアルタイム価格WebSocket**: ws://localhost:8000/ws/prices

## Claude Code の高度な機能

### 並列実行による効率化

**従来の逐次開発:**

```text
1. バックエンド実装 → 完了まで待機
2. フロントエンド実装 → 完了まで待機
3. テスト → 完了まで待機
```

**Claude Code の並列実行:**

```text
あなた: 「バックエンドとフロントエンドを並行して実装して」

Claude Code: 同時実行 ↓
🐍 Python FastAPI 実装
⚛️ React コンポーネント実装  
🎈 Streamlit ダッシュボード実装
🧪 テストファイル作成
📝 型定義の同期
📊 データ可視化チャート作成
```

### Task Tool による自動化

**あなた:**

```text
TODO アプリの実装を一括自動化して。
段階的に進捗を報告しながら
```

**Claude Code:**

- Task tool で専用エージェントを起動
- 複雑なタスクを自動分解
- バックグラウンドで並列実行
- リアルタイム進捗報告

### インテリジェントな検索と分析

**あなた:**

```text
「このプロジェクトで株式分析に使用される金融ライブラリを調査して」
```

**Claude Code:**

```bash
# Glob で設定ファイルを検索
**/package.json
**/pyproject.toml

# Grep で金融ライブラリパターンを検索
"yfinance"
"plotly"
"pandas"
"streamlit"
"numpy"

# 金融データ処理環境の分析とレポート
```

## デバッグと問題解決

### エラーが発生したとき

**あなた:**

```text
TypeScript でエラーが出てる。修正して：
[エラーメッセージをペースト]
```

**Claude Code:**

- 🔍 エラー内容を分析
- 📁 関連ファイルを特定
- 🔧 修正案を複数提示
- 修正後の動作確認

### パフォーマンス問題

**あなた:**

```text
TODO リストのレンダリングが遅い。最適化して
```

**Claude Code:**

- パフォーマンスボトルネックを分析
- React.memo や useMemo を提案
- 不要な再レンダリングを最適化
- 改善効果を測定

### コード品質の向上

**あなた:**

```text
コード全体のリファクタリングとクリーンアップをして
```

**Claude Code:**

- 🧹 リント・フォーマット実行
- アーキテクチャ改善提案
- コメントとドキュメント追加
- 🧪 テストカバレッジ向上

## Git 統合機能

### 変更のコミット

**あなた:**

```text
株式分析プラットフォームの実装をコミットして
```

**Claude Code:**

```bash
# 変更ファイルを確認
git status
git diff

# 適切なコミットメッセージで自動コミット
git add .
git commit -m "feat: implement stock market analysis platform

- Add stock/portfolio TypeScript types with financial data models
- Implement FastAPI backend with yfinance integration
- Create WebSocket real-time price streaming
- Add technical indicator calculation (SMA, EMA, RSI, MACD)
- Implement React portfolio management UI
- Create Streamlit advanced analysis dashboard with Plotly charts
- Add risk analysis tools (VaR, Sharpe ratio, drawdown)
- Include comprehensive error handling for financial data

🤖 Generated with Claude Code"
```

### プルリクエストの作成

**あなた:**

```text
この株式市場分析プラットフォームのプルリクエストを作成して
```

**Claude Code:**

```bash
# ブランチ作成・プッシュ
git checkout -b feature/stock-analysis-platform
git push -u origin feature/stock-analysis-platform

# プルリクエスト作成
gh pr create --title "Add stock market analysis platform" \
  --body "## Summary
- Complete stock data API with yfinance integration
- Real-time price streaming via WebSocket
- Advanced Streamlit dashboard with Plotly charts
- Technical analysis tools (SMA, EMA, RSI, MACD)
- Portfolio management and risk analysis
- Type-safe financial data communication
- Responsive multi-frontend architecture

## Test plan
- All financial data TypeScript types validated
- Stock API endpoints tested with real market data
- WebSocket real-time streaming tested
- Streamlit dashboard charts validated
- Technical indicator calculations verified
- Integration tests across all three frontends passed

🤖 Generated with Claude Code"
```

## テスト駆動開発

### テストファースト開発

**あなた:**

```text
TDD でテストから開始して株価取得 API を実装して
```

**Claude Code:**

1. 🧪 テストケースを先に作成

```python
def test_get_stock_price():
    response = client.get("/api/stocks/AAPL/price")
    assert response.status_code == 200
    data = response.json()
    assert "symbol" in data
    assert "current_price" in data
    assert data["symbol"] == "AAPL"
    assert isinstance(data["current_price"], float)

def test_technical_indicators():
    response = client.get("/api/stocks/AAPL/indicators?period=20")
    assert response.status_code == 200
    indicators = response.json()
    assert "sma" in indicators
    assert "rsi" in indicators
```

1. テストが失敗することを確認
2. yfinance統合で テストを通すための最小限の実装
3. リファクタリングで品質向上

### 自動テスト実行

**あなた:**

```text
コード変更時に自動でテストを実行して
```

**Claude Code:**

- 👀 ファイル変更を監視
- 関連テストを自動実行
- 結果をリアルタイム報告
- 🚨 失敗時は即座に通知

## 実践的な開発フロー

### 新機能の追加

**あなた:**

```text
株式にセクター分析機能を追加して
```

**Claude Code の実行フロー:**

1. TodoWrite でタスクを分解
2. **株式セクターデータスキーマ更新**
3. **yfinanceセクター情報取得API拡張**
4. **Streamlitセクター別パフォーマンス分析チャート追加**
5. **React UIにセクターフィルター機能**
6. **セクター相関マトリックス実装**
7. テストケース追加
8. ドキュメント更新
9. Git コミット作成

### バグ修正

**あなた:**

```text
株価データが正しく更新されないバグを修正して
```

**Claude Code:**

1. 🔍 Grep で株価更新関連コードを検索
2. 🐛 **yfinanceキャッシュ・WebSocket更新のバグの原因を特定**
3. 🧪 **株価データ更新バグを再現するテストを作成**
4. 🔧 **リアルタイム価格配信とキャッシング修正を実装**
5. テストが通ることを確認
6. 📦 修正をコミット

## 発展的な機能

### Streamlit 金融分析専用機能

**あなた:**

```text
Streamlit ダッシュボードに高度な金融分析機能を追加して：
- ポートフォリオ効率的フロンティア計算・表示
- モンテカルロシミュレーションによるリスク分析
- 異なる期間でのバックテスト比較
- オプション価格計算（ブラック・ショールズ）
- 銘柄間相関のネットワーク図表示
```

**Claude Code:**

- 📊 **高度な金融Plotlyチャート作成（効率的フロンティア、3Dリスク面）**
- 📈 **複雑な時系列金融データ分析（GARCH、VaR計算）**
- 🎛️ **インタラクティブなポートフォリオ最適化ツール**
- 🧮 **モンテカルロシミュレーション可視化**
- 📋 **金融レポート・データエクスポート機能**
- 🌐 **ネットワーク図での銘柄相関可視化**

### データベース統合

**あなた:**

```text
株価データストレージをSQLiteに変更して時系列データベースとして最適化して
```

**Claude Code:**

- 📁 **株価・ポートフォリオ用 SQLAlchemy モデル作成**
- **時系列データに最適化されたテーブル設計**
- **株価データの効率的なクエリ（インデックス最適化）**
- マイグレーション設定
- 🔌 データベース接続設定
- **🧪 金融時系列データのデータベーステスト追加**
- 🎈 Streamlit での データベース統合

### 認証システム

**あなた:**

```text
ポートフォリオごとの個人認証をJWTで実装して
```

**Claude Code:**

- 🔐 JWT トークン生成・検証
- 👤 **投資家ユーザーモデル作成**
- 🚪 ログイン・サインアップ機能
- **🏦 ポートフォリオベースのアクセス制御**
- 認証ミドルウェア実装
- 🎈 Streamlit セッション管理

### リアルタイム機能

**あなた:**

```text
WebSocket で株価変更をリアルタイム同期して
```

**Claude Code:**

- 🔌 **株価専用 WebSocket エンドポイント**
- 📡 **リアルタイム株価・ポートフォリオ価値通信**
- **価格データ高頻度更新の状態同期ロジック**
- **大量データストリーミングの最適化とエラーハンドリング**
- 🎈 **Streamlit チャートのauto-refresh 統合**

## 学習リソース

### Claude Code 公式

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/claude-code)
- [Claude Code コマンドリファレンス](https://docs.anthropic.com/claude-code/commands)

### 技術スタック

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://reactjs.org/docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [yfinance Documentation](https://pypi.org/project/yfinance/)
- [Plotly Python Documentation](https://plotly.com/python/)

### 開発ツール

- [uv Python Package Manager](https://github.com/astral-sh/uv)
- [Bun JavaScript Runtime](https://bun.sh/)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [Plotly Python Documentation](https://plotly.com/python/)

## まとめ

### Claude Code で変わる開発体験

**従来の開発:**

- 時間のかかる手動作業
- 頻繁なミスとバグ
- ドキュメント検索に時間消費
- 繰り返し作業の負担

**Claude Code での開発:**

- 爆速での実装完了
- 高品質なコード生成
- 専門知識を即座に活用
- 面倒な作業は全自動

### 習得したスキル

- AI との協働: Claude Code を使った自動化された開発手法
- プロンプトエンジニアリング: 効果的な指示の出し方
- 並列開発: 複数タスクの同時進行
- 自動化: テスト・リント・Git を含む開発フロー自動化
- フルスタック: 型安全なエンドツーエンド開発
- **金融データ分析**: yfinance統合、テクニカル指標計算、リスク分析
- **ハイブリッドUI開発**: React（ポートフォリオ管理）+ Streamlit（分析ダッシュボード）の組み合わせ
- **高度なデータ可視化**: Streamlit + Plotly による金融チャート・分析ツール作成
- **リアルタイムデータ処理**: WebSocketによる株価ストリーミング
- **金融工学実装**: ポートフォリオ最適化、VaR計算、バックテスト

### 次のステップ

1. **本格運用**: 実際の金融プロジェクトで Claude Code を活用
2. **アルゴリズム取引**: 自動取引ボット開発
3. **機械学習統合**: 株価予測モデルのStreamlit統合
4. チーム開発: 金融チームでの Claude Code 活用方法を学習
5. CI/CD: GitHub Actions と Claude Code の統合
6. デプロイ: 本番金融データ処理環境への自動デプロイ
7. 監視: リアルタイム金融データ処理の本番モニタリング設定

## おめでとうございます

Claude Code を使った**金融データ分析に特化したフルスタック開発**をマスターしました。

この新しい開発スタイルで、**複雑な金融計算とデータ可視化を10倍の生産性向上**で体験してください。

**Next Steps**: [README.md](./README.md) で他の機能も探索してみましょう。

---

## このチュートリアルについて

このチュートリアル全体が Claude Code で生成されました。
