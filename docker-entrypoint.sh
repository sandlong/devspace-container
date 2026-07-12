#!/bin/sh
set -eu

config_dir="${DEVSPACE_CONFIG_DIR:-$HOME/.devspace}"
defaults_dir=/usr/local/share/devspace/defaults

mkdir -p "$config_dir" "${DEVSPACE_STATE_DIR:-$config_dir/state}" "${DEVSPACE_WORKTREE_ROOT:-$config_dir/worktrees}"

if [ ! -e "$config_dir/config.json" ]; then
  cp "$defaults_dir/config.json" "$config_dir/config.json"
fi

if [ ! -e "$config_dir/auth.json" ]; then
  if [ -n "${DEVSPACE_OAUTH_OWNER_TOKEN:-}" ]; then
    owner_token=$DEVSPACE_OAUTH_OWNER_TOKEN
  else
    owner_token=$(node -e "process.stdout.write(require('node:crypto').randomBytes(32).toString('base64url'))")
  fi
  jq --arg token "$owner_token" '.ownerToken = $token' "$defaults_dir/auth.json" > "$config_dir/auth.json"
  chmod 600 "$config_dir/auth.json"
  if [ -z "${DEVSPACE_OAUTH_OWNER_TOKEN:-}" ]; then
    printf '\nDevSpace first-run owner password: %s\nStored in: %s/auth.json\n\n' "$owner_token" "$config_dir"
  fi
fi

if [ "$(id -u)" = 0 ]; then
  chown -R devspace:devspace "$config_dir"
  exec gosu devspace "$@"
fi

exec "$@"
