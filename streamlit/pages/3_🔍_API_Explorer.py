"""
API Explorer - Streamlit ページ

FastAPI バックエンドのAPIをインタラクティブに探索・テスト

Features:
- API エンドポイントのインタラクティブテスト
- リクエスト/レスポンスの詳細表示
- API スキーマの可視化
- パフォーマンス測定
"""

import streamlit as st
import httpx
import json
import time
from datetime import datetime
from typing import Dict, Any, Optional
import os

# API設定
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

class APIExplorer:
    """ＡＰＩ探索クラス"""
    
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
        self.client = httpx.Client(timeout=10.0)
    
    def call_api(self, method: str, endpoint: str, params: Optional[Dict] = None, 
                 data: Optional[Dict] = None, headers: Optional[Dict] = None) -> Dict[str, Any]:
        """ＡＰＩを呼び出し、結果を返す"""
        full_url = f"{self.base_url}{endpoint}"
        
        start_time = time.time()
        
        try:
            if method.upper() == 'GET':
                response = self.client.get(full_url, params=params, headers=headers)
            elif method.upper() == 'POST':
                response = self.client.post(full_url, json=data, params=params, headers=headers)
            elif method.upper() == 'PUT':
                response = self.client.put(full_url, json=data, params=params, headers=headers)
            elif method.upper() == 'DELETE':
                response = self.client.delete(full_url, params=params, headers=headers)
            else:
                return {
                    "success": False,
                    "error": f"サポートされていないメソッド: {method}",
                    "response_time": 0
                }
            
            response_time = (time.time() - start_time) * 1000  # ms
            
            # レスポンスの解析
            try:
                response_data = response.json()
            except:
                response_data = response.text
            
            return {
                "success": True,
                "status_code": response.status_code,
                "response_time": response_time,
                "headers": dict(response.headers),
                "data": response_data,
                "request_url": str(response.url),
                "request_method": method.upper()
            }
            
        except Exception as e:
            response_time = (time.time() - start_time) * 1000  # ms
            return {
                "success": False,
                "error": str(e),
                "response_time": response_time,
                "request_url": full_url,
                "request_method": method.upper()
            }

def get_predefined_endpoints():
    """事前定義されたAPIエンドポイント一覧を取得"""
    return {
        "GET /": {
            "method": "GET",
            "endpoint": "/",
            "description": "ルートエンドポイント",
            "params": {},
            "body": {}
        },
        "GET /health": {
            "method": "GET",
            "endpoint": "/health",
            "description": "ヘルスチェックエンドポイント",
            "params": {},
            "body": {}
        },
        "GET /api/hello/{name}": {
            "method": "GET",
            "endpoint": "/api/hello/{name}",
            "description": "指定した名前で挨拶",
            "params": {"name": "Claude Code"},
            "body": {}
        },
        "GET /docs": {
            "method": "GET",
            "endpoint": "/docs",
            "description": "FastAPI 自動生成ドキュメント",
            "params": {},
            "body": {}
        }
    }

def format_response_time(response_time: float) -> tuple:
    """レスポンスタイムをフォーマットして色と一緒に返す"""
    if response_time < 100:
        return f"{response_time:.1f}ms", "success"
    elif response_time < 500:
        return f"{response_time:.1f}ms", "warning"
    else:
        return f"{response_time:.1f}ms", "error"

def main():
    """メインアプリケーション"""
    
    st.set_page_config(
        page_title="API Explorer",
        page_icon="🔍",
        layout="wide"
    )
    
    # ヘッダー
    st.title("🔍 API Explorer")
    st.markdown("**FastAPI バックエンドのAPIをインタラクティブに探索**")
    
    # API Explorer インスタンスを作成
    api_explorer = APIExplorer(API_BASE_URL)
    
    # サイドバー: エンドポイント選択
    with st.sidebar:
        st.header("🎯 エンドポイント選択")
        
        # 事前定義されたエンドポイント
        predefined_endpoints = get_predefined_endpoints()
        
        endpoint_option = st.selectbox(
            "事前定義エンドポイント",
            ["カスタム"] + list(predefined_endpoints.keys())
        )
        
        if endpoint_option != "カスタム":
            selected_endpoint = predefined_endpoints[endpoint_option]
            st.info(f"📝 {selected_endpoint['description']}")
        else:
            selected_endpoint = None
        
        st.divider()
        
        # APIベースURL設定
        st.subheader("⚙️ 設定")
        st.code(f"API Base URL: {API_BASE_URL}", language="text")
        
        # リクエスト履歴
        if 'request_history' not in st.session_state:
            st.session_state.request_history = []
        
        st.subheader("📄 リクエスト履歴")
        
        if st.session_state.request_history:
            for i, req in enumerate(reversed(st.session_state.request_history[-5:])):
                status_color = "green" if req.get('success', False) else "red"
                st.markdown(
                    f"<p style='color: {status_color}; font-size: 12px;'>"
                    f"{req['method']} {req['endpoint']} "
                    f"({req.get('status_code', 'Error')})</p>",
                    unsafe_allow_html=True
                )
        else:
            st.info("リクエスト履歴はありません")
        
        if st.button("🗑️ 履歴クリア", use_container_width=True):
            st.session_state.request_history = []
            st.rerun()
    
    # メインエリア: APIリクエストフォーム
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.subheader("📝 リクエスト設定")
        
        # HTTPメソッド選択
        method = st.selectbox(
            "HTTP メソッド",
            ["GET", "POST", "PUT", "DELETE"],
            index=0 if not selected_endpoint else ["GET", "POST", "PUT", "DELETE"].index(selected_endpoint['method'])
        )
        
        # エンドポイント入力
        endpoint = st.text_input(
            "エンドポイント (/ から始まるパス)",
            value=selected_endpoint['endpoint'] if selected_endpoint else "/",
            placeholder="例: /api/hello/world"
        )
        
        # パラメータ入力
        st.subheader("🔗 クエリパラメータ")
        
        # パラメータの動的入力
        if 'api_params' not in st.session_state:
            st.session_state.api_params = {}
        
        # {name} のようなパスパラメータを検出
        import re
        path_params = re.findall(r'\{(\w+)\}', endpoint)
        
        for param in path_params:
            param_value = st.text_input(
                f"パスパラメータ: {param}",
                value=selected_endpoint['params'].get(param, '') if selected_endpoint else '',
                key=f"path_param_{param}"
            )
            if param_value:
                endpoint = endpoint.replace(f'{{{param}}}', param_value)
        
        # クエリパラメータ入力
        param_key = st.text_input("クエリパラメータキー", placeholder="例: limit")
        param_value = st.text_input("クエリパラメータ値", placeholder="例: 10")
        
        col_add, col_clear = st.columns(2)
        with col_add:
            if st.button("➕ パラメータ追加"):
                if param_key and param_value:
                    st.session_state.api_params[param_key] = param_value
                    st.success(f"パラメータ '{param_key}' を追加")
                    st.rerun()
        
        with col_clear:
            if st.button("🗑️ パラメータクリア"):
                st.session_state.api_params = {}
                st.rerun()
        
        # 現在のパラメータ表示
        if st.session_state.api_params:
            st.write("現在のパラメータ:")
            st.json(st.session_state.api_params)
        
        # リクエストボディ入力 (POST/PUTの場合)
        request_body = {}
        if method in ['POST', 'PUT']:
            st.subheader("📝 リクエストボディ (JSON)")
            body_text = st.text_area(
                "JSON データ",
                value=json.dumps(selected_endpoint['body'] if selected_endpoint else {}, indent=2),
                height=150,
                placeholder='{\n  "key": "value"\n}'
            )
            
            try:
                request_body = json.loads(body_text) if body_text.strip() else {}
            except json.JSONDecodeError as e:
                st.error(f"JSON フォーマットエラー: {str(e)}")
                request_body = {}
        
        # リクエスト実行ボタン
        if st.button("🚀 API リクエスト実行", type="primary", use_container_width=True):
            with st.spinner("リクエスト実行中..."):
                result = api_explorer.call_api(
                    method=method,
                    endpoint=endpoint,
                    params=st.session_state.api_params or None,
                    data=request_body if method in ['POST', 'PUT'] else None
                )
            
            # 履歴に追加
            history_entry = {
                "method": method,
                "endpoint": endpoint,
                "success": result['success'],
                "status_code": result.get('status_code'),
                "response_time": result['response_time'],
                "timestamp": datetime.now()
            }
            st.session_state.request_history.append(history_entry)
            
            # 結果をセッションに保存
            st.session_state.api_result = result
            st.rerun()
    
    with col2:
        st.subheader("📊 レスポンス結果")
        
        # 結果表示
        if 'api_result' in st.session_state:
            result = st.session_state.api_result
            
            # ステータスとレスポンスタイム
            col_status, col_time = st.columns(2)
            
            with col_status:
                if result['success']:
                    status_code = result['status_code']
                    if 200 <= status_code < 300:
                        st.success(f"✅ {status_code} OK")
                    elif 300 <= status_code < 400:
                        st.info(f"🔄 {status_code} Redirect")
                    elif 400 <= status_code < 500:
                        st.warning(f"⚠️ {status_code} Client Error")
                    else:
                        st.error(f"❌ {status_code} Server Error")
                else:
                    st.error(f"❌ リクエスト失敗")
            
            with col_time:
                if result['response_time']:
                    time_text, time_type = format_response_time(result['response_time'])
                    if time_type == "success":
                        st.success(f"⚡ {time_text}")
                    elif time_type == "warning":
                        st.warning(f"🔸 {time_text}")
                    else:
                        st.error(f"🔴 {time_text}")
            
            # リクエスト情報
            with st.expander("🔗 リクエスト詳細", expanded=False):
                st.write(f"**URL:** `{result['request_url']}`")
                st.write(f"**Method:** `{result['request_method']}`")
            
            # レスポンスヘッダー
            if result['success'] and 'headers' in result:
                with st.expander("📜 レスポンスヘッダー", expanded=False):
                    for key, value in result['headers'].items():
                        st.code(f"{key}: {value}")
            
            # レスポンスボディ
            st.subheader("📝 レスポンスデータ")
            
            if result['success']:
                if isinstance(result['data'], dict):
                    st.json(result['data'])
                else:
                    st.code(str(result['data']))
            else:
                st.error(f"エラー: {result.get('error', '不明なエラー')}")
        
        else:
            st.info("🚀 上のフォームからAPIリクエストを実行してください")
    
    # フッター: APIドキュメントリンク
    st.divider()
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("📚 FastAPI Docs", use_container_width=True):
            st.markdown(f"[FastAPI ドキュメントを開く]({API_BASE_URL}/docs)")
    
    with col2:
        if st.button("🔍 OpenAPI Schema", use_container_width=True):
            st.markdown(f"[OpenAPI スキーマを開く]({API_BASE_URL}/openapi.json)")
    
    with col3:
        if st.button("🔄 ページリフレッシュ", use_container_width=True):
            # セッションデータをクリアしてリフレッシュ
            if 'api_result' in st.session_state:
                del st.session_state.api_result
            st.rerun()

if __name__ == "__main__":
    main()