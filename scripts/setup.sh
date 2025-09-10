#!/bin/bash
set -euo pipefail

echo "🚀 Setting up Full-Stack Development Environment..."

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/backend/pyproject.toml" ]; then
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

# Check for Node.js and bun
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed"
    exit 1
fi

if ! command -v bun &> /dev/null; then
    log_warning "bun is not installed. Installing..."
    curl -fsSL https://bun.sh/install | bash
fi

log_success "All required tools are available"

# Setup Backend (Python)
log_info "Setting up Python backend..."
cd "$PROJECT_ROOT/backend"

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
cd "$PROJECT_ROOT/frontend"

# Install Node.js dependencies
log_info "Installing Node.js dependencies with bun..."
bun install

log_success "Frontend setup completed"

# Install root dependencies
log_info "Installing root workspace dependencies..."
cd "$PROJECT_ROOT"
bun install

# Create .env files if they don't exist
if [ ! -f "$PROJECT_ROOT/backend/.env" ]; then
    log_info "Creating backend .env file..."
    cat > "$PROJECT_ROOT/backend/.env" << EOF
# Backend Environment Variables
DEBUG=true
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=["http://localhost:3000"]
EOF
fi

if [ ! -f "$PROJECT_ROOT/frontend/.env" ]; then
    log_info "Creating frontend .env file..."
    cat > "$PROJECT_ROOT/frontend/.env" << EOF
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
  "python.defaultInterpreterPath": "./backend/.venv/bin/python",
  "eslint.workingDirectories": ["frontend"],
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
echo "  📦 Install dependencies: bun run setup (already done)"
echo "  🔧 Start development:   bun run dev"
echo "  🏗️  Build project:       bun run build"
echo "  🧹 Lint & format:      bun run lint && bun run format"
echo "  🧪 Run tests:          bun run test"
echo ""
echo "Development servers:"
echo "  🐍 Backend:  http://localhost:8000"
echo "  ⚛️  Frontend: http://localhost:3000"
echo ""
echo "Happy coding! 🚀"