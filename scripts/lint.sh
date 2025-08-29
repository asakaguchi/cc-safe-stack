#!/bin/bash
set -euo pipefail

echo "🔍 Running Code Quality Checks..."

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
if [ ! -f "package.json" ] || [ ! -f "backend/pyproject.toml" ]; then
    log_error "Please run this script from the project root directory"
    exit 1
fi

# Lint Backend (Python)
log_info "Linting Python backend..."
cd backend

# Run Ruff linting
log_info "Running Ruff checks..."
if uv run ruff check .; then
    log_success "Ruff checks passed"
else
    log_error "Ruff checks failed"
    ERRORS=$((ERRORS + 1))
fi

# Run Ruff formatting check
log_info "Checking Python code formatting..."
if uv run ruff format --check .; then
    log_success "Python formatting is correct"
else
    log_warning "Python code needs formatting (run: bun run format:backend)"
    ERRORS=$((ERRORS + 1))
fi

# Run mypy if available
if uv run python -c "import mypy" 2>/dev/null; then
    log_info "Running type checks with mypy..."
    if uv run mypy .; then
        log_success "Type checks passed"
    else
        log_error "Type checks failed"
        ERRORS=$((ERRORS + 1))
    fi
else
    log_warning "mypy not installed, skipping type checks"
fi

cd ..

# Lint Frontend (TypeScript/React)
log_info "Linting TypeScript frontend..."
cd frontend

# Run ESLint
log_info "Running ESLint..."
if bun run lint; then
    log_success "ESLint checks passed"
else
    log_error "ESLint checks failed"
    ERRORS=$((ERRORS + 1))
fi

# Run TypeScript compiler checks
log_info "Running TypeScript checks..."
if bun run type-check; then
    log_success "TypeScript checks passed"
else
    log_error "TypeScript checks failed"
    ERRORS=$((ERRORS + 1))
fi

# Check Prettier formatting
log_info "Checking code formatting..."
if prettier --check .; then
    log_success "Code formatting is correct"
else
    log_warning "Code needs formatting (run: bun run format:frontend)"
    ERRORS=$((ERRORS + 1))
fi

cd ..

# Lint Documentation (Textlint)
log_info "Linting documentation and text files..."

# Run textlint
log_info "Running textlint checks..."
if textlint '**/*.{md,html}'; then
    log_success "Textlint checks passed"
else
    log_warning "Textlint checks failed (run: bun run lint:text:fix to auto-fix)"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    log_success "🎉 All code quality checks passed!"
    echo ""
    echo "✅ Python code quality: PASSED"
    echo "✅ TypeScript code quality: PASSED"
    echo "✅ Code formatting: PASSED"
    echo "✅ Documentation quality: PASSED"
else
    log_error "❌ Found $ERRORS issue(s)"
    echo ""
    echo "💡 To fix issues automatically:"
    echo "  🐍 Backend:  bun run lint:fix:backend && bun run format:backend"
    echo "  ⚛️  Frontend: bun run lint:fix:frontend && bun run format:frontend"
    echo "  🔧 All:     bun run lint:fix && bun run format"
    exit 1
fi