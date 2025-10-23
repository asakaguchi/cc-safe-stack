#!/bin/bash
set -euo pipefail

echo "🧹 Cleaning project artifacts..."

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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

# Function to safely remove directory/file
safe_remove() {
    local path=$1
    local description=$2
    
    if [ -e "$path" ]; then
        log_info "Removing $description..."
        rm -rf "$path"
        log_success "$description removed"
    fi
}

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/apps/backend/pyproject.toml" ]; then
    echo "❌ Could not find project files in $PROJECT_ROOT"
    exit 1
fi

# Clean Backend (Python)
log_info "Cleaning Python backend artifacts..."
cd "$PROJECT_ROOT/apps/backend"

# Remove Python cache and build artifacts
safe_remove "__pycache__" "Python cache"
safe_remove ".pytest_cache" "pytest cache"
safe_remove ".mypy_cache" "mypy cache"
safe_remove ".ruff_cache" "Ruff cache"
safe_remove "dist" "Python build artifacts"
safe_remove "build" "Python build directory"
safe_remove "*.egg-info" "egg-info directories"

# Find and remove all __pycache__ directories
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true

# Clean Frontend (TypeScript/React)
log_info "Cleaning TypeScript frontend artifacts..."
cd "$PROJECT_ROOT/apps/frontend"

safe_remove "node_modules" "Node.js modules"
safe_remove "dist" "Frontend build artifacts"
safe_remove ".vite" "Vite cache"
safe_remove "coverage" "test coverage reports"
safe_remove ".eslintcache" "ESLint cache"

# Clean root level artifacts
log_info "Cleaning root level artifacts..."
cd "$PROJECT_ROOT"
safe_remove "node_modules" "root Node.js modules"
safe_remove ".pnpm-store" "pnpm store"
safe_remove "build-info.json" "build information file"
safe_remove "package.json.tmp" "temporary package.json"

# Clean common cache directories
safe_remove ".cache" "general cache directory"
safe_remove ".temp" "temporary files"
safe_remove ".tmp" "temp directory"

# Clean log files
find . -name "*.log" -type f -delete 2>/dev/null || true
find . -name "npm-debug.log*" -type f -delete 2>/dev/null || true
find . -name "yarn-debug.log*" -type f -delete 2>/dev/null || true
find . -name "yarn-error.log*" -type f -delete 2>/dev/null || true

# Clean OS generated files
find . -name ".DS_Store" -type f -delete 2>/dev/null || true
find . -name "Thumbs.db" -type f -delete 2>/dev/null || true

log_success "🎉 Project cleaned successfully!"
echo ""
echo "💡 To restore the project:"
echo "  📦 Install dependencies: pnpm run setup"
echo "  🔧 Start development:   pnpm run dev"
echo "  🏗️  Build project:       pnpm run build"
echo ""
echo "⚠️  Note: You'll need to run 'pnpm run setup' to reinstall dependencies."
