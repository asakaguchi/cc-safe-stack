# API開発ガイド

このガイドでは、FastAPI を使った API 開発とフロントエンドとの統合について説明し
ます。

## API開発（Python）

### 基本的なAPIの作成

```python
# apps/backend/main.py
from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime

app = FastAPI()

class MessageResponse(BaseModel):
    message: str
    timestamp: str

@app.get("/api/hello/{name}")
async def hello_name(name: str) -> MessageResponse:
    return MessageResponse(
        message=f"Hello, {name}!",
        timestamp=datetime.now().isoformat(),
    )
```

### RESTful API パターン

#### CRUD操作の実装

```python
# apps/backend/src/api/users.py
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter(prefix="/api/users", tags=["users"])

class User(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

class CreateUserRequest(BaseModel):
    name: str
    email: str

class UpdateUserRequest(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None

@router.post("/", response_model=User)
async def create_user(user_data: CreateUserRequest):
    # ユーザー作成ロジック
    pass

@router.get("/", response_model=List[User])
async def list_users(skip: int = 0, limit: int = 100):
    # ユーザー一覧取得ロジック
    pass

@router.get("/{user_id}", response_model=User)
async def get_user(user_id: int):
    # 特定ユーザー取得ロジック
    pass

@router.put("/{user_id}", response_model=User)
async def update_user(user_id: int, user_data: UpdateUserRequest):
    # ユーザー更新ロジック
    pass

@router.delete("/{user_id}")
async def delete_user(user_id: int):
    # ユーザー削除ロジック
    pass
```

### 非同期処理

```python
# apps/backend/src/api/tasks.py
import asyncio
from fastapi import BackgroundTasks

@router.post("/tasks/")
async def create_task(background_tasks: BackgroundTasks):
    background_tasks.add_task(process_heavy_task)
    return {"message": "Task started"}

async def process_heavy_task():
    # 重い処理を非同期で実行
    await asyncio.sleep(10)
    # 実際の処理ロジック
```

### エラーハンドリング

```python
# apps/backend/src/exceptions.py
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

class CustomException(Exception):
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code

@app.exception_handler(CustomException)
async def custom_exception_handler(request: Request, exc: CustomException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"message": exc.message}
    )

# 使用例
@router.get("/users/{user_id}")
async def get_user(user_id: int):
    user = await find_user(user_id)
    if not user:
        raise CustomException("User not found", 404)
    return user
```

## CORS 設定

バックエンドでは、`.env` の `CORS_ORIGINS` で許可オリジンを制御できます（JSON 配
列またはカンマ区切り）。未設定時は `http://localhost:3000` のみ許可されます。

### 環境変数設定

```env
# apps/backend/.env 例（JSON 配列）
CORS_ORIGINS=["http://localhost:3000", "https://example.com"]

# またはカンマ区切り文字列でも可
CORS_ORIGINS=http://localhost:3000,https://example.com
```

### CORS設定の実装

```python
# apps/backend/main.py
import os
import json
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

def get_cors_origins():
    """環境変数からCORS設定を取得"""
    cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000")

    # JSON配列形式の場合
    if cors_origins.startswith("["):
        try:
            return json.loads(cors_origins)
        except json.JSONDecodeError:
            return ["http://localhost:3000"]

    # カンマ区切り形式の場合
    return [origin.strip() for origin in cors_origins.split(",")]

# CORS設定を適用
app.add_middleware(
    CORSMiddleware,
    allow_origins=get_cors_origins(),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)
```

## フロントエンド開発（TypeScript）

### API クライアントの実装

```typescript
// frontend/src/api/client.ts
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

class ApiClient {
  private baseURL: string

  constructor(baseURL: string = API_BASE_URL) {
    this.baseURL = baseURL
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseURL}${endpoint}`

    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    })

    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`)
    }

    return response.json()
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' })
  }

  async post<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    })
  }

  async put<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    })
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' })
  }
}

export const apiClient = new ApiClient()
```

### 型安全なAPI呼び出し

```typescript
// frontend/src/api/users.ts
import type {
  User,
  CreateUserRequest,
  UpdateUserRequest,
} from '@shared/types/api'
import { apiClient } from './client'

export const userApi = {
  async getUsers(): Promise<User[]> {
    return apiClient.get<User[]>('/api/users')
  },

  async getUser(id: number): Promise<User> {
    return apiClient.get<User>(`/api/users/${id}`)
  },

  async createUser(data: CreateUserRequest): Promise<User> {
    return apiClient.post<User>('/api/users', data)
  },

  async updateUser(id: number, data: UpdateUserRequest): Promise<User> {
    return apiClient.put<User>(`/api/users/${id}`, data)
  },

  async deleteUser(id: number): Promise<void> {
    return apiClient.delete<void>(`/api/users/${id}`)
  },
}
```

### React コンポーネントでの使用

```typescript
// frontend/src/components/UserList.tsx
import React, { useEffect, useState } from 'react'
import type { User } from '@shared/types/api'
import { userApi } from '../api/users'

export const UserList: React.FC = () => {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function fetchUsers() {
      try {
        setLoading(true)
        const userData = await userApi.getUsers()
        setUsers(userData)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      } finally {
        setLoading(false)
      }
    }

    fetchUsers()
  }, [])

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>

  return (
    <div>
      <h2>Users</h2>
      <ul>
        {users.map(user => (
          <li key={user.id}>
            {user.name} ({user.email})
          </li>
        ))}
      </ul>
    </div>
  )
}
```

## 共有型定義

### 型定義の管理

```typescript
// packages/shared/types/api.ts
export interface User {
  id: number
  name: string
  email: string
  created_at: string
}

export interface CreateUserRequest {
  name: string
  email: string
}

export interface UpdateUserRequest {
  name?: string
  email?: string
}

export interface MessageResponse {
  message: string
  timestamp: string
}

export interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
  size: number
}
```

### Pydantic との同期

```python
# apps/backend/src/models/user.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class User(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

    class Config:
        # JSON Schema の生成設定
        json_schema_extra = {
            "example": {
                "id": 1,
                "name": "John Doe",
                "email": "john@example.com",
                "created_at": "2023-01-01T00:00:00Z"
            }
        }

class CreateUserRequest(BaseModel):
    name: str
    email: str

class UpdateUserRequest(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
```

## データベース統合

### SQLAlchemy モデル

```python
# apps/backend/src/models/database.py
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class UserTable(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
```

### データベース操作

```python
# apps/backend/src/services/user_service.py
from sqlalchemy.orm import Session
from typing import List, Optional
from .models.database import UserTable
from .models.user import User, CreateUserRequest, UpdateUserRequest

class UserService:
    def __init__(self, db: Session):
        self.db = db

    async def create_user(self, user_data: CreateUserRequest) -> User:
        db_user = UserTable(**user_data.dict())
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        return User.from_orm(db_user)

    async def get_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        users = self.db.query(UserTable).offset(skip).limit(limit).all()
        return [User.from_orm(user) for user in users]

    async def get_user(self, user_id: int) -> Optional[User]:
        user = self.db.query(UserTable).filter(UserTable.id == user_id).first()
        return User.from_orm(user) if user else None
```

## テスト戦略

### APIテスト

```python
# apps/backend/tests/test_users.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_create_user():
    response = client.post(
        "/api/users/",
        json={"name": "Test User", "email": "test@example.com"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Test User"
    assert data["email"] == "test@example.com"

def test_get_users():
    response = client.get("/api/users/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

### フロントエンドテスト

```typescript
// frontend/src/api/__tests__/users.test.ts
import { describe, it, expect, vi } from 'vitest'
import { userApi } from '../users'

// モックの設定
global.fetch = vi.fn()

describe('userApi', () => {
  it('should fetch users successfully', async () => {
    const mockUsers = [
      {
        id: 1,
        name: 'John',
        email: 'john@example.com',
        created_at: '2023-01-01',
      },
    ]

    ;(fetch as any).mockResolvedValueOnce({
      ok: true,
      json: async () => mockUsers,
    })

    const users = await userApi.getUsers()
    expect(users).toEqual(mockUsers)
  })

  it('should handle API errors', async () => {
    ;(fetch as any).mockResolvedValueOnce({
      ok: false,
      status: 500,
    })

    await expect(userApi.getUsers()).rejects.toThrow('API Error: 500')
  })
})
```

## 開発ワークフロー

### 1. 機能開発の流れ

1. API 仕様の定義: OpenAPI スキーマで API を設計。
2. 型定義の作成: packages/shared/types/ で共有型を定義。
3. バックエンド実装: FastAPI でエンドポイントを実装。
4. フロントエンド実装: React で UI を実装。
5. テスト作成: 単体テストと統合テストを作成。

### 2. 品質保証

```bash
# 開発サーバー起動（React + FastAPI）
pnpm run dev

# React + FastAPI + marimo を一括起動（初回は `pnpm run enable:marimo`）
pnpm run dev:all

# marimo のみ追加起動する場合
pnpm run dev:marimo

# コード品質チェック
pnpm run lint

# フォーマット
pnpm run format

# テスト実行
pnpm run test

# ビルド確認
pnpm run build
```

### 3. APIドキュメント

FastAPI は自動的に OpenAPI ドキュメントを生成します。

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
- OpenAPI JSON: `http://localhost:8000/openapi.json`

## パフォーマンス最適化

### バックエンド最適化

- 非同期処理: async/await を活用。
- データベース最適化: 例として `users.email` にインデックスを追加
  し、`selectinload` で N+1 クエリを解消するなど具体的なクエリ調整を実施する。
- キャッシュ: Redis などのキャッシュシステム。
- バッチ処理: 重い処理はバックグラウンドで実行。

### フロントエンド最適化

- Code Splitting: React.lazy() によるコード分割。
- メモ化: React.memo(), useMemo() の活用。
- 仮想化: 大量データの効率的表示。
- キャッシュ: React Query などのキャッシュライブラリ。

## 関連ドキュメント

- [アーキテクチャガイド](architecture.md)
- [セットアップガイド](../getting-started/installation.md)
- [DevContainer完全ガイド](../environment/devcontainer.md)
