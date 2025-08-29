"""Backend API for full-stack application."""

from __future__ import annotations

import json
import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

load_dotenv()

app = FastAPI(
    title="Backend API",
    description="Full-stack application backend",
    version="0.0.1",
)

# Configure CORS from environment (JSON list or comma-separated)
_cors_env = os.getenv("CORS_ORIGINS", '["http://localhost:3000"]')
try:
    allow_origins: list[str] = json.loads(_cors_env)
    if not isinstance(allow_origins, list):
        raise ValueError
except Exception:
    allow_origins = [s.strip() for s in _cors_env.split(",") if s.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins or ["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class HealthResponse(BaseModel):
    """Health check response model."""

    status: str
    message: str


class MessageResponse(BaseModel):
    """Message response model."""

    message: str
    timestamp: str


@app.get("/")
async def root() -> MessageResponse:
    """Root endpoint."""
    from datetime import datetime

    return MessageResponse(
        message="Welcome to the Backend API!",
        timestamp=datetime.now().isoformat(),
    )


@app.get("/health")
async def health() -> HealthResponse:
    """Health check endpoint."""
    return HealthResponse(
        status="ok",
        message="Backend is running",
    )


@app.get("/api/hello/{name}")
async def hello_name(name: str) -> MessageResponse:
    """Greet a specific name."""
    from datetime import datetime

    return MessageResponse(
        message=f"Hello, {name}!",
        timestamp=datetime.now().isoformat(),
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
