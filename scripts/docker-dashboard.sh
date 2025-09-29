#!/bin/bash
set -euo pipefail

USER_ID=${USER_ID:-$(id -u)}
GROUP_ID=${GROUP_ID:-$(id -g)}
USER_NAME=${USER_NAME:-$(id -un)}

export USER_ID GROUP_ID USER_NAME

# pnpm run xxx -- -d のように渡された先頭の "--" を取り除き、Composeのオプションとして扱う
SANITIZED_ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--" ]]; then
    continue
  fi
  SANITIZED_ARGS+=("$arg")
done

if [ ${#SANITIZED_ARGS[@]} -eq 0 ]; then
  exec docker compose up proxy
else
  exec docker compose up "${SANITIZED_ARGS[@]}" proxy
fi
