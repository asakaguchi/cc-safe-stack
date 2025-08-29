#!/bin/bash
set -euo pipefail

echo "🔧 Auto-fixing lint issues..."

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

# Fix Backend (Python)
log_info "Auto-fixing Python backend issues..."
cd backend

# Run Ruff auto-fix
log_info "Running Ruff auto-fix..."
uv run ruff check . --fix
log_success "Python linting issues fixed"

cd ..

# Fix Frontend (TypeScript/React)
log_info "Auto-fixing TypeScript frontend issues..."
cd frontend

# Run ESLint auto-fix
log_info "Running ESLint auto-fix..."
bun run lint:fix
log_success "TypeScript linting issues fixed"

cd ..

# Fix Documentation (Textlint)
log_info "Auto-fixing documentation issues..."

# Run textlint auto-fix
log_info "Running textlint auto-fix..."
textlint --fix '**/*.{md,html}' || true
log_success "Documentation issues fixed"

log_success "🎉 Auto-fix completed!"
echo "💡 Run 'bun run format' to fix formatting issues"
echo "💡 Run 'bun run lint' to check for remaining issues"
