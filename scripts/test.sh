#!/bin/bash
set -euo pipefail

echo "🧪 Running Full-Stack Tests..."

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"
export UV_NO_SYNC=1
export UV_PROJECT_ENVIRONMENT="${PROJECT_ROOT}/.venv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

ERRORS=0

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/apps/backend/pyproject.toml" ]; then
    log_error "Could not find project files in $PROJECT_ROOT"
    exit 1
fi

# Test Backend (Python)
log_info "Testing Python backend..."
cd "$PROJECT_ROOT/apps/backend"

if [ ! -d ".venv" ]; then
    log_info "Backend virtual environmentが見つかりません。依存関係を同期します..."
    uv sync --frozen || log_warning "uv sync に失敗しました (キャッシュ未整備の可能性があります)"
fi

if [ -d "tests" ] && [ "$(ls -A tests)" ]; then
    log_info "Running pytest..."
    if uv run pytest -v; then
        log_success "Backend tests passed"
    else
        log_error "Backend tests failed"
        ERRORS=$((ERRORS + 1))
    fi
else
    log_warning "No backend tests found. Creating sample test structure..."
    mkdir -p tests
    cat > tests/test_main.py << 'EOF'
"""Sample tests for the backend API."""

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_root_endpoint():
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "timestamp" in data


def test_health_endpoint():
    """Test the health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"


def test_hello_endpoint():
    """Test the hello endpoint."""
    name = "TestUser"
    response = client.get(f"/api/hello/{name}")
    assert response.status_code == 200
    data = response.json()
    assert f"Hello, {name}!" in data["message"]
    assert "timestamp" in data
EOF

    # Add httpx to test dependencies
    if ! grep -q "httpx" pyproject.toml; then
        log_info "Adding httpx to test dependencies..."
        # This is a simple addition - in practice, you'd want to manage this more carefully
        echo "Note: Please add 'httpx>=0.25.0' to your [dependency-groups].dev in pyproject.toml"
    fi

    log_info "Running newly created tests..."
    if uv run pytest -v; then
        log_success "Sample backend tests created and passed"
    else
        log_warning "Sample tests created but some failed"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Test Frontend (TypeScript/React)
log_info "Testing TypeScript frontend..."
cd "$PROJECT_ROOT/apps/frontend"

# Check if test scripts exist
if grep -q '"test"' package.json && [ -d "src" ]; then
    log_info "Running frontend tests..."
    if pnpm exec vitest run; then
        log_success "Frontend tests passed"
    else
        log_error "Frontend tests failed"
        ERRORS=$((ERRORS + 1))
    fi
else
    log_warning "No frontend tests configured. Consider adding Vitest or Jest."
    log_info "Creating sample test setup..."
    
    # Add basic test dependencies and script suggestion
    cat >> package.json.tmp << 'EOF'
{
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^6.1.5",
    "@testing-library/user-event": "^14.5.1",
    "vitest": "^1.0.4",
    "@vitejs/plugin-react": "^4.2.1"
  },
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui"
  }
}
EOF
    log_info "Test configuration suggestions created in package.json.tmp"
fi

# Run linting as part of test suite
log_info "Running linting checks as part of test suite..."
if "$PROJECT_ROOT/scripts/lint.sh" > /dev/null 2>&1; then
    log_success "Linting checks passed"
else
    log_warning "Linting checks failed (run: pnpm run lint for details)"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    log_success "🎉 All tests passed!"
    echo ""
    echo "✅ Backend tests: PASSED"
    echo "✅ Frontend tests: PASSED (or not configured)"
    echo "✅ Code quality: PASSED"
else
    log_error "❌ Found $ERRORS issue(s)"
    echo ""
    echo "💡 To fix issues:"
    echo "  🔧 Auto-fix: pnpm run lint:fix"
    echo "  ✨ Format:   pnpm run format"
    echo "  🧪 Re-test:  pnpm run test"
    exit 1
fi

echo ""
echo "🚀 Ready for deployment!"
