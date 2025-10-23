#!/bin/bash
set -euo pipefail

# React + FastAPI + marimo を同時起動するヘルパー
# WITH_MARIMO=1 をセットして既存 dev.sh を再利用する
export WITH_MARIMO=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "$SCRIPT_DIR/dev.sh" "$@"
