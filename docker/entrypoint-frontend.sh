#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}
USER_NAME=${USER_NAME:-developer}
GROUP_NAME=${GROUP_NAME:-$USER_NAME}

# Ensure group exists with desired GID
if ! getent group "${GROUP_NAME}" >/dev/null 2>&1; then
  groupadd -g "${GROUP_ID}" "${GROUP_NAME}" 2>/dev/null || true
fi

# If a user with the target name exists, adjust it; otherwise create a new one
if id -u "${USER_NAME}" >/dev/null 2>&1; then
  usermod -u "${USER_ID}" -g "${GROUP_NAME}" "${USER_NAME}" >/dev/null 2>&1 || true
else
  useradd -u "${USER_ID}" -g "${GROUP_NAME}" -o -m -s /bin/bash "${USER_NAME}" >/dev/null 2>&1 || true
fi

target_dirs=(/app/node_modules /app/frontend/node_modules /app/.pnpm-store)
for dir in "${target_dirs[@]}"; do
  if [ -e "$dir" ]; then
    chown -R "${USER_ID}:${GROUP_ID}" "$dir" || true
  fi
done

if [[ $# -eq 0 ]]; then
  exec gosu "${USER_NAME}" bash
else
  exec gosu "${USER_NAME}" "$@"
fi
