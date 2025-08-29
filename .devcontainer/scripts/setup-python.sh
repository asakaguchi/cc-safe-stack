#!/bin/bash
set -euo pipefail

# Python development environment setup script
# This script sets up the Python environment with uv and pre-commit

echo "🐍 Setting up Python development environment..."

# Check if we're in a workspace
if [ ! -f "pyproject.toml" ]; then
    echo "⚠️  No pyproject.toml found. Are you in a Python project directory?"
    exit 1
fi

# Install Python dependencies
echo "📦 Installing Python dependencies with uv..."
uv sync

# Install pre-commit hooks
echo "🔧 Installing pre-commit hooks..."
uv run pre-commit install

# Set up Python interpreter for VS Code
echo "🔍 Setting up Python interpreter..."
PYTHON_PATH=$(uv run which python)
echo "Python interpreter: $PYTHON_PATH"

# Create a simple .vscode/settings.json if it doesn't exist
mkdir -p .vscode
if [ ! -f ".vscode/settings.json" ]; then
    echo "⚙️  Creating VS Code settings..."
    cat > .vscode/settings.json << EOF
{
    "python.defaultInterpreterPath": "$PYTHON_PATH"
}
EOF
fi

echo "✅ Python development environment setup complete!"
echo ""
echo "Next steps:"
echo "  • Run tests: uv run pytest"
echo "  • Format code: uv run ruff format ."
echo "  • Check linting: uv run ruff check ."