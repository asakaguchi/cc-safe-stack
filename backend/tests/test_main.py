"""Tests for the main FastAPI application."""

from __future__ import annotations

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


class TestHealthEndpoint:
    """Tests for health check endpoint."""

    def test_health_endpoint_returns_ok_status(self) -> None:
        """Health endpoint should return OK status."""
        response = client.get("/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert data["message"] == "Backend is running"


class TestAPIEndpoints:
    """Tests for API endpoints."""

    def test_api_health_endpoint(self) -> None:
        """API health endpoint should be accessible."""
        # Note: There's no /api/health endpoint in main.py, only /health
        # Testing the actual endpoint that exists
        response = client.get("/health")

        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "message" in data

    def test_hello_name_endpoint(self) -> None:
        """Hello name endpoint should return personalized greeting."""
        test_name = "Alice"
        response = client.get(f"/api/hello/{test_name}")

        assert response.status_code == 200
        data = response.json()
        assert data["message"] == f"Hello, {test_name}!"
        assert "timestamp" in data

    def test_hello_name_with_special_characters(self) -> None:
        """Hello name endpoint should handle special characters."""
        test_name = "山田太郎"
        response = client.get(f"/api/hello/{test_name}")

        assert response.status_code == 200
        data = response.json()
        assert data["message"] == f"Hello, {test_name}!"


class TestRootEndpoint:
    """Tests for root endpoint."""

    def test_root_endpoint(self) -> None:
        """Root endpoint should return welcome message."""
        response = client.get("/")

        assert response.status_code == 200
        data = response.json()
        assert data["message"] == "Welcome to the Backend API!"
        assert "timestamp" in data
