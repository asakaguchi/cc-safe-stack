#!/bin/bash
set -euo pipefail

echo "🚀 Starting Full-Stack Development Servers..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Function to cleanup background processes
cleanup() {
    log_info "Shutting down development servers..."
    jobs -p | xargs -r kill
    exit 0
}

# Trap SIGINT and SIGTERM to cleanup
trap cleanup SIGINT SIGTERM

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "backend/pyproject.toml" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Check if dependencies are installed
if [ ! -d "backend/.venv" ]; then
    log_warning "Backend dependencies not found. Running setup..."
    ./scripts/setup.sh
fi

if [ ! -d "frontend/node_modules" ]; then
    log_warning "Frontend dependencies not found. Running setup..."
    ./scripts/setup.sh
fi

log_info "Starting backend server (Python/FastAPI)..."
cd backend
VIRTUAL_ENV= uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ..

log_info "Starting frontend server (TypeScript/React)..."
cd frontend
bun dev &
FRONTEND_PID=$!
cd ..

log_success "Development servers started!"
echo ""
echo "🌐 Frontend: http://localhost:3000"
echo "🐍 Backend:  http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for background processes
wait