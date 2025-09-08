"""
システムダッシュボード - Streamlit ページ

フルスタックアプリケーションの統合監視ダッシュボード

Features:
- API ヘルスモニタリング
- システムパフォーマンス表示
- リアルタイムデータ更新
- システムログ表示
"""

import streamlit as st
import httpx
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import time
import psutil
import os
from typing import Dict, List, Any

# API設定
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

class SystemMonitor:
    """システム監視クラス"""
    
    @staticmethod
    def get_system_info() -> Dict[str, Any]:
        """システム情報を取得"""
        try:
            import platform
            return {
                "cpu_percent": psutil.cpu_percent(interval=1),
                "memory_percent": psutil.virtual_memory().percent,
                "disk_percent": psutil.disk_usage('/').percent,
                "boot_time": psutil.boot_time(),
                "python_version": platform.python_version(),
                "platform": platform.platform(),
                "processor": platform.processor() or "Unknown",
            }
        except Exception as e:
            st.error(f"システム情報取得エラー: {str(e)}")
            return {}
    
    @staticmethod
    def check_api_health() -> Dict[str, Any]:
        """バックエンドAPIのヘルスチェック"""
        try:
            start_time = time.time()
            response = httpx.get(f"{API_BASE_URL}/health", timeout=5.0)
            response_time = (time.time() - start_time) * 1000  # ms
            
            if response.status_code == 200:
                return {
                    "status": "healthy",
                    "response_time": response_time,
                    "data": response.json()
                }
            else:
                return {
                    "status": "unhealthy",
                    "response_time": response_time,
                    "error": f"HTTP {response.status_code}"
                }
        except Exception as e:
            return {
                "status": "error",
                "response_time": None,
                "error": str(e)
            }
    
    @staticmethod
    def get_mock_api_metrics() -> List[Dict[str, Any]]:
        """モック API メトリクスデータ"""
        import random
        
        # 過去24時間のモックデータを生成
        now = datetime.now()
        metrics = []
        
        for i in range(24):
            timestamp = now - timedelta(hours=i)
            metrics.append({
                "timestamp": timestamp,
                "requests": random.randint(50, 200),
                "response_time": random.uniform(10, 100),
                "errors": random.randint(0, 5),
                "cpu_usage": random.uniform(20, 80),
                "memory_usage": random.uniform(30, 70)
            })
        
        return sorted(metrics, key=lambda x: x["timestamp"])

def create_system_metrics_chart(system_info: Dict[str, Any]):
    """システムメトリクスチャートを作成"""
    if not system_info:
        return
    
    # システムリソース使用率
    metrics = [
        {"Resource": "CPU", "Usage": system_info.get("cpu_percent", 0)},
        {"Resource": "Memory", "Usage": system_info.get("memory_percent", 0)},
        {"Resource": "Disk", "Usage": system_info.get("disk_percent", 0)}
    ]
    
    df = pd.DataFrame(metrics)
    
    fig = px.bar(
        df,
        x="Resource",
        y="Usage",
        title="📊 システムリソース使用率",
        color="Usage",
        color_continuous_scale="RdYlGn_r",
        range_color=[0, 100]
    )
    
    fig.update_layout(
        yaxis_title="使用率 (%)",
        height=300,
        showlegend=False
    )
    
    # 警告ラインを追加
    fig.add_hline(y=80, line_dash="dash", line_color="red", 
                  annotation_text="警告ライン (80%)")
    
    st.plotly_chart(fig, use_container_width=True)

def create_api_metrics_chart(metrics_data: List[Dict[str, Any]]):
    """ＡＰＩメトリクスチャートを作成"""
    if not metrics_data:
        return
    
    df = pd.DataFrame(metrics_data)
    
    # リクエスト数とレスポンスタイム
    fig = go.Figure()
    
    fig.add_trace(
        go.Scatter(
            x=df["timestamp"],
            y=df["requests"],
            mode="lines+markers",
            name="リクエスト数",
            line=dict(color="#3b82f6"),
            yaxis="y"
        )
    )
    
    fig.add_trace(
        go.Scatter(
            x=df["timestamp"],
            y=df["response_time"],
            mode="lines+markers",
            name="レスポンスタイム (ms)",
            line=dict(color="#ef4444"),
            yaxis="y2"
        )
    )
    
    fig.update_layout(
        title="🕰️ API パフォーマンス推移 (24時間)",
        xaxis_title="時刻",
        yaxis=dict(title="リクエスト数", side="left"),
        yaxis2=dict(title="レスポンスタイム (ms)", side="right", overlaying="y"),
        height=400,
        hovermode="x unified"
    )
    
    st.plotly_chart(fig, use_container_width=True)

def create_error_rate_chart(metrics_data: List[Dict[str, Any]]):
    """エラー率チャートを作成"""
    if not metrics_data:
        return
    
    df = pd.DataFrame(metrics_data)
    df["error_rate"] = (df["errors"] / df["requests"]) * 100
    
    fig = px.area(
        df,
        x="timestamp",
        y="error_rate",
        title="⚠️ エラー率推移 (24時間)",
        color_discrete_sequence=["#f59e0b"]
    )
    
    fig.update_layout(
        yaxis_title="エラー率 (%)",
        xaxis_title="時刻",
        height=300
    )
    
    st.plotly_chart(fig, use_container_width=True)

def main():
    """メインアプリケーション"""
    
    st.set_page_config(
        page_title="System Dashboard",
        page_icon="📊",
        layout="wide"
    )
    
    # ヘッダー
    st.title("📊 システムダッシュボード")
    st.markdown("**フルスタックアプリケーションの統合監視**")
    
    # サイドバー: 設定とコントロール
    with st.sidebar:
        st.header("⚙️ 設定")
        
        # 自動更新設定
        auto_refresh = st.checkbox("🔄 自動更新", value=False)
        
        if auto_refresh:
            refresh_interval = st.selectbox(
                "更新間隔",
                [5, 10, 30, 60],
                index=1,
                format_func=lambda x: f"{x}秒"
            )
        
        # 手動更新ボタン
        if st.button("🔄 手動更新", use_container_width=True):
            st.rerun()
        
        st.divider()
        
        # システム情報
        st.subheader("💻 システム情報")
        
        with st.spinner("システム情報取得中..."):
            system_info = SystemMonitor.get_system_info()
        
        if system_info:
            import platform
            st.write(f"**OS:** {platform.system()}")
            st.write(f"**Python:** {system_info.get('python_version', 'Unknown')}")
            st.write(f"**Processor:** {system_info.get('processor', 'Unknown')[:30]}...")
            
            # 稼働時間
            if 'boot_time' in system_info:
                boot_time = datetime.fromtimestamp(system_info['boot_time'])
                uptime = datetime.now() - boot_time
                st.write(f"**Uptime:** {uptime.days}日 {uptime.seconds//3600}時間")
    
    # メインコンテンツ
    # API ヘルスステータス
    st.subheader("🏥 API ヘルスステータス")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with st.spinner("APIヘルスチェック中..."):
        health_status = SystemMonitor.check_api_health()
    
    with col1:
        if health_status["status"] == "healthy":
            st.success("✅ バックエンド API")
        else:
            st.error("❌ バックエンド API")
    
    with col2:
        if health_status.get("response_time"):
            response_time = health_status["response_time"]
            if response_time < 100:
                st.success(f"⚡ {response_time:.1f}ms")
            elif response_time < 500:
                st.warning(f"🔸 {response_time:.1f}ms")
            else:
                st.error(f"🔴 {response_time:.1f}ms")
        else:
            st.error("❌ タイムアウト")
    
    with col3:
        # React フロントエンドのステータス（モック）
        st.info("🟡 React UI")
    
    with col4:
        # Streamlit アプリ自身
        st.success("✅ Streamlit UI")
    
    # システムメトリクス
    st.subheader("📊 システムメトリクス")
    
    col1, col2 = st.columns([1, 1])
    
    with col1:
        if system_info:
            create_system_metrics_chart(system_info)
        
        # メトリクスデータを取得
        metrics_data = SystemMonitor.get_mock_api_metrics()
        create_error_rate_chart(metrics_data)
    
    with col2:
        # API パフォーマンスチャート
        create_api_metrics_chart(metrics_data)
    
    # システムログセクション
    st.subheader("📄 システムログ")
    
    # モックログデータ
    log_data = [
        {"timestamp": datetime.now() - timedelta(minutes=1), "level": "INFO", "message": "Application started successfully"},
        {"timestamp": datetime.now() - timedelta(minutes=2), "level": "INFO", "message": "Database connection established"},
        {"timestamp": datetime.now() - timedelta(minutes=3), "level": "WARN", "message": "High memory usage detected (75%)"},
        {"timestamp": datetime.now() - timedelta(minutes=5), "level": "ERROR", "message": "Failed to connect to external API"},
        {"timestamp": datetime.now() - timedelta(minutes=8), "level": "INFO", "message": "User authentication successful"},
    ]
    
    # ログレベルフィルター
    col1, col2 = st.columns([3, 1])
    
    with col2:
        log_levels = ["ALL", "ERROR", "WARN", "INFO"]
        selected_level = st.selectbox("ログレベル", log_levels)
    
    # フィルタリング
    if selected_level != "ALL":
        log_data = [log for log in log_data if log["level"] == selected_level]
    
    # ログ表示
    for log in log_data:
        timestamp = log["timestamp"].strftime("%H:%M:%S")
        level = log["level"]
        message = log["message"]
        
        if level == "ERROR":
            st.error(f"[{timestamp}] {level}: {message}")
        elif level == "WARN":
            st.warning(f"[{timestamp}] {level}: {message}")
        else:
            st.info(f"[{timestamp}] {level}: {message}")
    
    # 自動更新処理
    if auto_refresh:
        time.sleep(refresh_interval)
        st.rerun()

if __name__ == "__main__":
    main()