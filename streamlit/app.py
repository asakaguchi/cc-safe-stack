"""
Streamlit フルスタック開発環境 - メインアプリケーション

このアプリケーションは、Python (FastAPI) バックエンドと統合された
Streamlit ベースのデータアプリケーションです。

Features:
- FastAPI バックエンドとの統合
- マルチページアプリケーション
- リアルタイムデータ可視化
- 管理者向けダッシュボード
"""

import streamlit as st
import httpx
import os
from datetime import datetime
from dotenv import load_dotenv

# 環境変数の読み込み
load_dotenv()

# ページ設定
st.set_page_config(
    page_title="フルスタック開発環境",
    page_icon="🚀",
    layout="wide",
    initial_sidebar_state="expanded"
)

# カスタムCSS
st.markdown("""
<style>
.main-header {
    font-size: 2.5rem;
    font-weight: 700;
    color: #1e3a8a;
    text-align: center;
    margin-bottom: 2rem;
}

.status-card {
    background-color: #f8fafc;
    padding: 1rem;
    border-radius: 0.5rem;
    border: 2px solid #e2e8f0;
    margin: 1rem 0;
}

.status-ok {
    border-color: #10b981;
    background-color: #f0fdf4;
}

.status-error {
    border-color: #ef4444;
    background-color: #fef2f2;
}
</style>
""", unsafe_allow_html=True)

# API設定
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

def check_backend_status():
    """バックエンドAPI の接続状態を確認"""
    try:
        response = httpx.get(f"{API_BASE_URL}/health", timeout=3.0)
        if response.status_code == 200:
            return True, response.json()
        else:
            return False, {"error": f"HTTP {response.status_code}"}
    except Exception as e:
        return False, {"error": str(e)}

def main():
    """メインアプリケーション"""
    
    # ヘッダー
    st.markdown('<h1 class="main-header">🚀 フルスタック開発環境</h1>', unsafe_allow_html=True)
    st.markdown("### Python FastAPI + TypeScript React + Streamlit")
    
    # サイドバー
    with st.sidebar:
        st.header("📊 環境情報")
        
        # バックエンドステータスチェック
        st.subheader("🐍 バックエンドステータス")
        
        status_container = st.empty()
        
        with st.spinner("バックエンド接続確認中..."):
            is_ok, result = check_backend_status()
            
        if is_ok:
            status_container.success("✅ バックエンド接続 OK")
            st.json(result)
        else:
            status_container.error("❌ バックエンド接続エラー")
            st.error(f"エラー: {result.get('error', '不明なエラー')}")
        
        # 環境設定情報
        st.subheader("⚙️ 設定")
        st.write(f"**API URL:** `{API_BASE_URL}`")
        st.write(f"**現在時刻:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # メインコンテンツエリア
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.header("🎯 アプリケーション概要")
        
        # 技術スタック
        st.subheader("🛠️ 技術スタック")
        
        tech_col1, tech_col2, tech_col3 = st.columns(3)
        
        with tech_col1:
            st.markdown("""
            **バックエンド**
            - 🐍 Python 3.12+
            - ⚡ FastAPI
            - 🚀 Uvicorn
            - 📝 Pydantic
            - 📦 uv package manager
            """)
        
        with tech_col2:
            st.markdown("""
            **フロントエンド**
            - 📘 TypeScript
            - ⚛️ React 18
            - ⚡ Vite
            - 🎨 ESLint + Prettier
            - 📦 bun package manager
            """)
        
        with tech_col3:
            st.markdown("""
            **データアプリ**
            - 🎈 Streamlit
            - 📊 Plotly
            - 🐼 Pandas
            - 🔍 HTTPX
            - 🐳 Docker対応
            """)
        
        # アクセスポイント
        st.subheader("🌐 アクセスポイント")
        
        access_col1, access_col2, access_col3 = st.columns(3)
        
        with access_col1:
            st.markdown("""
            **React UI**
            - 🌐 http://localhost:3000
            - 顧客向けモダンUI
            - プロダクション対応
            """)
        
        with access_col2:
            st.markdown("""
            **Streamlit UI**
            - 🎈 http://localhost:8501
            - 管理者ダッシュボード
            - データ分析・可視化
            """)
        
        with access_col3:
            st.markdown("""
            **FastAPI Docs**
            - 📚 http://localhost:8000/docs
            - API仕様書
            - インタラクティブテスト
            """)
    
    with col2:
        st.header("📊 クイック統計")
        
        # API呼び出しのデモ
        if is_ok:
            st.subheader("🔗 API テスト")
            
            name = st.text_input("名前を入力", value="Claude Code")
            
            if st.button("挨拶API を呼び出し"):
                try:
                    with st.spinner("APIを呼び出し中..."):
                        response = httpx.get(f"{API_BASE_URL}/api/hello/{name}")
                        if response.status_code == 200:
                            data = response.json()
                            st.success(f"✅ {data['message']}")
                            st.info(f"⏰ {data['timestamp']}")
                        else:
                            st.error(f"❌ エラー: HTTP {response.status_code}")
                except Exception as e:
                    st.error(f"❌ 接続エラー: {str(e)}")
        
        # システム情報
        st.subheader("💻 システム情報")
        
        import platform
        import streamlit
        
        system_info = {
            "OS": platform.system(),
            "Python": platform.python_version(),
            "Streamlit": streamlit.__version__,
        }
        
        for key, value in system_info.items():
            st.metric(key, value)

if __name__ == "__main__":
    main()