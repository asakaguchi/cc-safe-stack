"""Backend API for full-stack application."""

from __future__ import annotations

import json
import os
from collections import deque
from pathlib import Path
from typing import Final

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import PlainTextResponse
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


LOG_DIRECTORY: Final[Path] = (Path(__file__).resolve().parent.parent / ".logs").resolve()
LOG_DIRECTORY.mkdir(parents=True, exist_ok=True)
SERVICE_LOG_FILES: Final[dict[str, Path]] = {
    "backend": LOG_DIRECTORY / "backend.log",
    "frontend": LOG_DIRECTORY / "frontend.log",
    "streamlit": LOG_DIRECTORY / "streamlit.log",
}


def tail_file(path: Path, lines: int) -> str:
    """Return the last ``lines`` of ``path`` as a single string."""

    if not path.exists():
        return ""

    try:
        with path.open("r", encoding="utf-8", errors="replace") as file:
            # deque efficiently keeps only the last N lines in memory
            return "".join(deque(file, maxlen=lines))
    except OSError:
        return ""


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


@app.get("/logs", summary="利用可能なログ一覧")
async def list_available_logs() -> list[str]:
    """Return the list of available log identifiers."""

    return sorted(SERVICE_LOG_FILES.keys())


@app.get("/logs/{service}", response_class=PlainTextResponse)
async def get_service_logs(
    service: str,
    tail: int = Query(200, ge=1, le=2000, description="返却する行数"),
) -> PlainTextResponse:
    """Return recent log lines for the requested service."""

    normalized = service.lower()
    log_path = SERVICE_LOG_FILES.get(normalized)
    if not log_path:
        raise HTTPException(status_code=404, detail="指定されたログ種別は存在しません")

    content = tail_file(log_path, tail)
    return PlainTextResponse(content)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
