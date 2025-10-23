#!/bin/bash
set -euo pipefail

USER_ID=${USER_ID:-$(id -u)}
GROUP_ID=${GROUP_ID:-$(id -g)}
USER_NAME=${USER_NAME:-$(id -un)}

export USER_ID GROUP_ID USER_NAME

# pnpm run xxx -- ... 形式の先頭 "--" を除去して docker compose に渡す
SANITIZED_ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--" ]]; then
    continue
  fi
  SANITIZED_ARGS+=("$arg")
done

COMMAND="up"
if [[ ${#SANITIZED_ARGS[@]} -gt 0 ]]; then
  case "${SANITIZED_ARGS[0]}" in
    up|down|logs|restart)
      COMMAND="${SANITIZED_ARGS[0]}"
      SANITIZED_ARGS=("${SANITIZED_ARGS[@]:1}")
      ;;
    *)
      COMMAND="up"
      ;;
  esac
fi

case "$COMMAND" in
  up)
    exec docker compose up "${SANITIZED_ARGS[@]}" proxy
    ;;
  down)
    exec docker compose down "${SANITIZED_ARGS[@]}"
    ;;
  logs)
    if [[ ${#SANITIZED_ARGS[@]} -eq 0 ]]; then
      SANITIZED_ARGS=(-f proxy)
    fi
    exec docker compose logs "${SANITIZED_ARGS[@]}"
    ;;
  restart)
    docker compose down
    exec docker compose up "${SANITIZED_ARGS[@]}" proxy
    ;;
  *)
    echo "Unsupported command: $COMMAND" >&2
    echo "Usage: $0 [up|down|logs|restart] [docker compose options]" >&2
    exit 1
    ;;
esac
