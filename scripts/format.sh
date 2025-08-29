#!/bin/bash
set -euo pipefail

echo "✨ Formatting code..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "backend/pyproject.toml" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Format Backend (Python)
log_info "Formatting Python backend..."
cd backend

# Run Ruff formatting
log_info "Running Ruff formatter..."
uv run ruff format .
log_success "Python code formatted"

cd ..

# Format Frontend (TypeScript/React)
log_info "Formatting TypeScript frontend..."
cd frontend

# Run Prettier
log_info "Running Prettier..."
prettier --write .
log_success "TypeScript code formatted"

cd ..

# Format root level files
log_info "Formatting root configuration files..."
prettier --write "*.json" "*.md" ".eslintrc.js" ".prettierrc" 2>/dev/null || true

log_success "🎉 All code has been formatted!"
echo ""
echo "💡 Next steps:"
echo "  🔍 Run 'bun run lint' to check for issues"
echo "  🧪 Run 'bun run test' to ensure tests still pass"