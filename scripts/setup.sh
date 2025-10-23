#!/bin/bash
set -euo pipefail

echo "🚀 Setting up Full-Stack Development Environment..."

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"

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
if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/apps/backend/pyproject.toml" ]; then
    log_error "Could not find project files in $PROJECT_ROOT"
    exit 1
fi

# Check for required tools
log_info "Checking for required tools..."

# Check for Python and uv
if ! command -v python3 &> /dev/null; then
    log_error "Python 3 is not installed"
    exit 1
fi

if ! command -v uv &> /dev/null; then
    log_error "uv is not installed. Please install it from: https://github.com/astral-sh/uv"
    exit 1
fi

# Check for Node.js and pnpm
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    log_warning "pnpm is not installed. Enabling via corepack..."
    if command -v corepack &> /dev/null; then
        corepack enable pnpm || {
            log_warning "corepack enable failed. Falling back to npm global install..."
            npm install -g pnpm
        }
    else
        log_warning "corepack is unavailable. Installing pnpm globally via npm..."
        npm install -g pnpm
    fi
fi

log_success "All required tools are available"

# Setup Backend (Python)
log_info "Setting up Python backend..."
cd "$PROJECT_ROOT/apps/backend"

# Install Python dependencies
log_info "Installing Python dependencies with uv..."
uv sync

# Install pre-commit hooks if available
if [ -f "$PROJECT_ROOT/.pre-commit-config.yaml" ]; then
    log_info "Installing pre-commit hooks..."
    uv run pre-commit install
fi

log_success "Backend setup completed"

# Setup Frontend (TypeScript/React)
log_info "Setting up TypeScript frontend..."

# Install Node.js dependencies for all workspaces
cd "$PROJECT_ROOT"
log_info "Installing Node.js dependencies with pnpm (workspace)..."
pnpm install --recursive

log_success "Frontend setup completed"

# Create .env files if they don't exist
if [ ! -f "$PROJECT_ROOT/apps/backend/.env" ]; then
    log_info "Creating backend .env file..."
    cat > "$PROJECT_ROOT/apps/backend/.env" << EOF
# Backend Environment Variables
DEBUG=true
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=["http://localhost:3000"]
EOF
fi

if [ ! -f "$PROJECT_ROOT/apps/frontend/.env" ]; then
    log_info "Creating frontend .env file..."
    cat > "$PROJECT_ROOT/apps/frontend/.env" << EOF
# Frontend Environment Variables
VITE_API_URL=http://localhost:8000
VITE_DEV_PORT=3000
EOF
fi

# Setup VS Code settings
if [ ! -d "$PROJECT_ROOT/.vscode" ]; then
    log_info "Creating VS Code workspace settings..."
    mkdir -p "$PROJECT_ROOT/.vscode"
    
    cat > "$PROJECT_ROOT/.vscode/settings.json" << EOF
{
  "python.defaultInterpreterPath": "./apps/backend/.venv/bin/python",
  "eslint.workingDirectories": ["apps/frontend"],
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "files.associations": {
    "*.json": "jsonc"
  }
}
EOF
fi

log_success "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "  📦 Install dependencies: pnpm run setup (already done)"
echo "  🔧 Start development:   pnpm run dev"
echo "  🚀 Full stack (with marimo): pnpm run dev:all  # 初回は pnpm run enable:marimo"
echo "  🧮 Marimo dashboard:   pnpm run dev:marimo  # 初回は pnpm run enable:marimo"
echo "  🏗️  Build project:       pnpm run build"
echo "  🧹 Lint & format:      pnpm run lint && pnpm run format"
echo "  🧪 Run tests:          pnpm run test"
echo ""
echo "Development servers:"
echo "  🐍 Backend:  http://localhost:8000"
echo "  ⚛️  Frontend: http://localhost:3000"
echo "  🧮 Marimo:   http://localhost:2718"
echo ""
echo "Happy coding! 🚀"
