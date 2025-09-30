#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}
USER_NAME=${USER_NAME:-developer}
GROUP_NAME=${GROUP_NAME:-$USER_NAME}

# Ensure group exists with desired GID
if ! getent group "${GROUP_NAME}" >/dev/null 2>&1; then
  echo "Creating group ${GROUP_NAME} with GID ${GROUP_ID}"
  groupadd -g "${GROUP_ID}" "${GROUP_NAME}" 2>&1 || {
    echo "Warning: Failed to create group, checking for existing GID..."
    # If group creation failed, try to find group by GID
    EXISTING_GROUP=$(getent group "${GROUP_ID}" | cut -d: -f1 || true)
    if [ -n "$EXISTING_GROUP" ]; then
      echo "Using existing group: $EXISTING_GROUP"
      GROUP_NAME="$EXISTING_GROUP"
    fi
  }
fi

# If a user with the target name exists, adjust it; otherwise create a new one
if id -u "${USER_NAME}" >/dev/null 2>&1; then
  echo "Modifying existing user ${USER_NAME}"
  usermod -u "${USER_ID}" -g "${GROUP_NAME}" "${USER_NAME}" 2>&1 || echo "Warning: Failed to modify user"
else
  echo "Creating user ${USER_NAME} with UID ${USER_ID} in group ${GROUP_NAME}"
  useradd -u "${USER_ID}" -g "${GROUP_NAME}" -o -m -s /bin/bash "${USER_NAME}" 2>&1 || {
    echo "Warning: Failed to create user with group ${GROUP_NAME}"
    # Try with GID directly
    useradd -u "${USER_ID}" -g "${GROUP_ID}" -o -m -s /bin/bash "${USER_NAME}" 2>&1 || echo "ERROR: Failed to create user"
  }
fi

# Verify user was created
if ! id -u "${USER_NAME}" >/dev/null 2>&1; then
  echo "ERROR: User ${USER_NAME} does not exist after creation attempt"
  exit 1
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
