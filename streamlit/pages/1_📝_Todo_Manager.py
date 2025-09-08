"""
TODO Manager - Streamlit ページ

FastAPI バックエンドと統合したTODO管理アプリケーション

Features:
- TODO の CRUD 操作
- リアルタイムデータ可視化
- DataFrameでの一覧表示
- 統計チャート表示
"""

import streamlit as st
import httpx
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import os
from typing import Dict, List, Any

# API設定
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

class TodoAPI:
    """TODO API クライアント"""
    
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
        self.client = httpx.Client(timeout=10.0)
    
    def get_todos(self) -> List[Dict[str, Any]]:
        """全てのTODOを取得"""
        try:
            # 実際のAPI実装まではモックデータを使用
            return [
                {
                    "id": 1,
                    "title": "Streamlit統合を完了する",
                    "completed": False,
                    "created_at": "2024-01-15T10:00:00",
                    "updated_at": "2024-01-15T10:00:00"
                },
                {
                    "id": 2,
                    "title": "FastAPI エンドポイントをテストする",
                    "completed": True,
                    "created_at": "2024-01-14T09:00:00",
                    "updated_at": "2024-01-15T14:30:00"
                },
                {
                    "id": 3,
                    "title": "React UIの最適化",
                    "completed": False,
                    "created_at": "2024-01-13T11:30:00",
                    "updated_at": "2024-01-13T11:30:00"
                }
            ]
        except Exception as e:
            st.error(f"TODO取得エラー: {str(e)}")
            return []
    
    def create_todo(self, title: str) -> Dict[str, Any]:
        """新しいTODOを作成"""
        # モック実装
        new_todo = {
            "id": len(st.session_state.get('todos', [])) + 1,
            "title": title,
            "completed": False,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
        return new_todo
    
    def update_todo(self, todo_id: int, completed: bool) -> Dict[str, Any]:
        """TODOのステータスを更新"""
        # モック実装
        return {
            "id": todo_id,
            "completed": completed,
            "updated_at": datetime.now().isoformat()
        }
    
    def delete_todo(self, todo_id: int) -> bool:
        """TODOを削除"""
        # モック実装
        return True

def init_session_state():
    """セッション状態を初期化"""
    if 'todos' not in st.session_state:
        api = TodoAPI(API_BASE_URL)
        st.session_state.todos = api.get_todos()
    
    if 'filter_status' not in st.session_state:
        st.session_state.filter_status = 'All'

def filter_todos(todos: List[Dict], status: str) -> List[Dict]:
    """ステータスでTODOをフィルタリング"""
    if status == 'Active':
        return [todo for todo in todos if not todo['completed']]
    elif status == 'Completed':
        return [todo for todo in todos if todo['completed']]
    else:
        return todos

def create_todo_dataframe(todos: List[Dict]) -> pd.DataFrame:
    """TODO データをDataFrameに変換"""
    if not todos:
        return pd.DataFrame()
    
    df = pd.DataFrame(todos)
    df['created_at'] = pd.to_datetime(df['created_at'])
    df['updated_at'] = pd.to_datetime(df['updated_at'])
    df['status'] = df['completed'].apply(lambda x: '✅ 完了' if x else '⏳ 進行中')
    
    return df

def create_statistics_charts(df: pd.DataFrame):
    """統計チャートを作成"""
    if df.empty:
        st.warning("📊 チャート表示用のデータがありません")
        return
    
    # ステータス別円グラフ
    status_counts = df['status'].value_counts()
    
    fig_pie = px.pie(
        values=status_counts.values,
        names=status_counts.index,
        title="📊 TODO ステータス分布",
        color_discrete_sequence=['#10b981', '#f59e0b']
    )
    fig_pie.update_layout(height=300)
    st.plotly_chart(fig_pie, use_container_width=True)
    
    # 日別作成数
    df['date'] = df['created_at'].dt.date
    daily_counts = df.groupby('date').size().reset_index(name='count')
    
    fig_bar = px.bar(
        daily_counts,
        x='date',
        y='count',
        title="📅 日別TODO作成数",
        color='count',
        color_continuous_scale='Blues'
    )
    fig_bar.update_layout(height=300)
    st.plotly_chart(fig_bar, use_container_width=True)

def main():
    """メインアプリケーション"""
    
    st.set_page_config(
        page_title="TODO Manager",
        page_icon="📝",
        layout="wide"
    )
    
    # セッション状態初期化
    init_session_state()
    
    # ヘッダー
    st.title("📝 TODO Manager")
    st.markdown("**FastAPI バックエンド統合 TODO 管理アプリ**")
    
    # サイドバー: フィルターとアクション
    with st.sidebar:
        st.header("🔧 操作パネル")
        
        # フィルター
        st.subheader("📋 フィルター")
        filter_status = st.selectbox(
            "ステータス",
            ['All', 'Active', 'Completed'],
            index=['All', 'Active', 'Completed'].index(st.session_state.filter_status)
        )
        st.session_state.filter_status = filter_status
        
        # 新規TODO作成
        st.subheader("➕ 新規TODO作成")
        new_todo_title = st.text_input("TODOタイトル", placeholder="新しいタスクを入力...")
        
        if st.button("📝 TODO追加", type="primary", use_container_width=True):
            if new_todo_title.strip():
                api = TodoAPI(API_BASE_URL)
                new_todo = api.create_todo(new_todo_title.strip())
                st.session_state.todos.append(new_todo)
                st.success(f"✅ '{new_todo_title}' を追加しました")
                st.rerun()
            else:
                st.warning("⚠️ TODOタイトルを入力してください")
        
        # 統計情報
        st.subheader("📊 統計")
        todos = st.session_state.todos
        total = len(todos)
        completed = len([t for t in todos if t['completed']])
        active = total - completed
        
        col1, col2 = st.columns(2)
        with col1:
            st.metric("総数", total)
            st.metric("完了", completed)
        with col2:
            st.metric("進行中", active)
            if total > 0:
                completion_rate = (completed / total) * 100
                st.metric("完了率", f"{completion_rate:.1f}%")
    
    # メインエリア
    # フィルタリング済みTODO
    filtered_todos = filter_todos(st.session_state.todos, filter_status)
    df = create_todo_dataframe(filtered_todos)
    
    # レイアウト
    col1, col2 = st.columns([3, 2])
    
    with col1:
        st.subheader(f"📋 TODO一覧 ({filter_status})")
        
        if df.empty:
            st.info("📝 該当するTODOがありません")
        else:
            # インタラクティブなTODO一覧
            for i, todo in enumerate(filtered_todos):
                with st.container():
                    todo_col1, todo_col2, todo_col3, todo_col4 = st.columns([0.5, 3, 1, 0.5])
                    
                    with todo_col1:
                        # ステータス変更チェックボックス
                        current_status = todo['completed']
                        new_status = st.checkbox(
                            "",
                            value=current_status,
                            key=f"todo_status_{todo['id']}",
                            label_visibility="collapsed"
                        )
                        
                        if new_status != current_status:
                            # ステータス更新
                            api = TodoAPI(API_BASE_URL)
                            api.update_todo(todo['id'], new_status)
                            
                            # セッション状態更新
                            for t in st.session_state.todos:
                                if t['id'] == todo['id']:
                                    t['completed'] = new_status
                                    t['updated_at'] = datetime.now().isoformat()
                                    break
                            st.rerun()
                    
                    with todo_col2:
                        # タイトル表示（完了済みは取り消し線）
                        title_style = "text-decoration: line-through; color: #9ca3af;" if todo['completed'] else ""
                        st.markdown(f"<p style='{title_style}'>{todo['title']}</p>", unsafe_allow_html=True)
                    
                    with todo_col3:
                        # 作成日時
                        created = datetime.fromisoformat(todo['created_at'])
                        st.caption(f"🕒 {created.strftime('%m/%d %H:%M')}")
                    
                    with todo_col4:
                        # 削除ボタン
                        if st.button("🗑️", key=f"delete_{todo['id']}", help="削除"):
                            api = TodoAPI(API_BASE_URL)
                            if api.delete_todo(todo['id']):
                                st.session_state.todos = [
                                    t for t in st.session_state.todos 
                                    if t['id'] != todo['id']
                                ]
                                st.success(f"✅ '{todo['title']}' を削除しました")
                                st.rerun()
                    
                    st.divider()
    
    with col2:
        st.subheader("📊 統計・可視化")
        
        # 統計チャート表示
        if not df.empty:
            create_statistics_charts(df)
        
        # データテーブル表示（オプション）
        with st.expander("📋 データテーブル表示"):
            if not df.empty:
                display_df = df[['title', 'status', 'created_at']].copy()
                display_df['created_at'] = display_df['created_at'].dt.strftime('%Y-%m-%d %H:%M')
                st.dataframe(
                    display_df,
                    use_container_width=True,
                    hide_index=True,
                    column_config={
                        "title": "タイトル",
                        "status": "ステータス",
                        "created_at": "作成日時"
                    }
                )
            else:
                st.info("表示するデータがありません")

if __name__ == "__main__":
    main()