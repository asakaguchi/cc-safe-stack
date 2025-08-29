#!/bin/bash
set -euo pipefail

echo "🏗️  Building Full-Stack Application..."

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

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "backend/pyproject.toml" ]; then
    log_error "Please run this script from the project root directory"
    exit 1
fi

# Build Backend (Python)
log_info "Building Python backend..."
cd backend

# Ensure dependencies are up to date
log_info "Syncing Python dependencies..."
uv sync --frozen

# Run type checking with mypy if available
if uv run python -c "import mypy" 2>/dev/null; then
    log_info "Running type checks..."
    uv run mypy . || log_warning "Type checking failed"
fi

# Run tests if they exist
if [ -d "tests" ] && [ "$(ls -A tests)" ]; then
    log_info "Running backend tests..."
    uv run pytest || {
        log_error "Backend tests failed"
        exit 1
    }
else
    log_warning "No backend tests found"
fi

cd ..
log_success "Backend build completed"

# Build Frontend (TypeScript/React)
log_info "Building TypeScript frontend..."
cd frontend

# Install/update dependencies
log_info "Installing frontend dependencies..."
bun install

# Run type checking
log_info "Running TypeScript type checks..."
bun run type-check || {
    log_error "TypeScript compilation failed"
    exit 1
}

# Run linting
log_info "Running frontend linting..."
bun run lint || {
    log_error "Frontend linting failed"
    exit 1
}

# Build the application
log_info "Building frontend application..."
bun run build || {
    log_error "Frontend build failed"
    exit 1
}

cd ..
log_success "Frontend build completed"

# Create build info
log_info "Generating build information..."
BUILD_TIME=$(date -Iseconds)
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
cat > build-info.json << EOF
{
  "buildTime": "$BUILD_TIME",
  "gitCommit": "$GIT_COMMIT",
  "frontend": {
    "framework": "React + TypeScript",
    "buildTool": "Vite",
    "outputDir": "frontend/dist"
  },
  "backend": {
    "framework": "FastAPI + Python",
    "packageManager": "uv",
    "pythonVersion": "$(python3 --version | cut -d' ' -f2)"
  }
}
EOF

log_success "🎉 Build completed successfully!"
echo ""
echo "📦 Build artifacts:"
echo "  🐍 Backend: Dependencies synced and tested"
echo "  ⚛️  Frontend: frontend/dist/"
echo "  📄 Build info: build-info.json"
echo ""
echo "🚀 Ready for deployment!"