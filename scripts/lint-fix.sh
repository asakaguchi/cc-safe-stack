#!/bin/bash
set -euo pipefail

echo "🔧 Auto-fixing lint issues..."

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

export UV_CACHE_DIR="${PROJECT_ROOT}/.cache/uv"
mkdir -p "$UV_CACHE_DIR"

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
if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/apps/backend/pyproject.toml" ]; then
    echo "❌ Could not find project files in $PROJECT_ROOT"
    exit 1
fi

# Fix Backend (Python)
log_info "Auto-fixing Python backend issues..."
cd "$PROJECT_ROOT/apps/backend"

# Run Ruff auto-fix
log_info "Running Ruff auto-fix..."
uv run ruff check . --fix
log_success "Python linting issues fixed"

# Fix Frontend (TypeScript/React)
log_info "Auto-fixing TypeScript frontend issues..."
cd "$PROJECT_ROOT/apps/frontend"

# Run ESLint auto-fix
log_info "Running ESLint auto-fix..."
pnpm run lint:fix
log_success "TypeScript linting issues fixed"

# Fix Documentation (Textlint)
log_info "Auto-fixing documentation issues..."
cd "$PROJECT_ROOT"

# Run textlint auto-fix
log_info "Running textlint auto-fix..."
pnpm exec textlint --fix '**/*.{md,html}' || true
log_success "Documentation issues fixed"

log_success "🎉 Auto-fix completed!"
echo "💡 Run 'pnpm run format' to fix formatting issues"
echo "💡 Run 'pnpm run lint' to check for remaining issues"
