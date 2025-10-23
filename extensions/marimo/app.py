"""marimo 管理ダッシュボードのサンプルアプリ。

FastAPI バックエンドのヘルスチェックと簡単な API 呼び出しを
ブラウザから行えるミニマルな UI を提供する。
"""

from __future__ import annotations

import os
from datetime import datetime
from typing import Any

import httpx
import marimo

API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

app = marimo.App(width="wide")


def fetch_health() -> tuple[bool, dict[str, object]]:
    """FastAPI の /health を呼び出し状態を返す。"""
    try:
        response = httpx.get(f"{API_BASE_URL}/health", timeout=3.0)
        response.raise_for_status()
        return True, response.json()
    except httpx.HTTPError as error:
        return False, {"error": str(error)}


def call_greeting(name: str) -> dict[str, object] | None:
    """サンプル挨拶 API を呼び出す。"""
    if not name:
        return None
    response = httpx.get(f"{API_BASE_URL}/api/hello/{name}", timeout=3.0)
    response.raise_for_status()
    return response.json()


@app.cell
def __(mo: Any) -> None:  # type: ignore[misc]
    mo.md("# 🚀 cc-safe-stack ダッシュボード")
    mo.md(
        """
        **FastAPI + React + marimo** で構成されたフルスタック開発テンプレート。
        - バックエンド: `http://localhost:8000`
        - React UI: `http://localhost:3000`
        - marimo ダッシュボード: `http://localhost:2718`
        """
    )


@app.cell
def __(mo: Any) -> bool:  # type: ignore[misc]
    health_ok, health_payload = fetch_health()
    status = "✅ バックエンド接続 OK" if health_ok else "❌ バックエンド接続エラー"
    tone = "success" if health_ok else "danger"

    mo.callout(status, tone=tone)
    if health_ok:
        mo.json(health_payload)
    else:
        mo.code(str(health_payload.get("error", "unknown error")))

    mo.md(
        f"**API BASE URL:** `{API_BASE_URL}`\n"
        f"**最終確認:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    )

    return health_ok


@app.cell
def __(mo: Any, health_ok: bool) -> tuple[Any, Any]:  # type: ignore[misc]
    name_input = mo.ui.text(label="挨拶する相手", value="Claude Code")
    call_button = mo.ui.button(label="挨拶 API を呼び出す", disabled=not health_ok)

    with mo.box(mo.hstack([name_input, call_button], gap="1rem")):
        mo.md("### 🔗 API 呼び出し")
        mo.md("`/api/hello/{name}` を呼び出してレスポンスを表示します。")

    if call_button.value and name_input.value:
        try:
            result = call_greeting(name_input.value)
            if result is not None:
                mo.alert(
                    title="API レスポンス",
                    description=f"`{result['message']}`\n\n⏱ {result['timestamp']}",
                    tone="success",
                )
        except httpx.HTTPError as error:  # pylint: disable=broad-except
            mo.alert(
                title="API 呼び出しに失敗しました",
                description=str(error),
                tone="danger",
            )

    return name_input, call_button


@app.cell
def __(mo: Any) -> None:  # type: ignore[misc]
    mo.md(
        """
        ## 🧭 開発フロー

        1. `pnpm run dev` で React + FastAPI を起動
        2. `pnpm run enable:marimo` で marimo を有効化
        3. `pnpm run dev:marimo` でこのノートブックを起動
        """
    )


if __name__ == "__main__":
    app.run()
