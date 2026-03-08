#!/bin/sh
set -eu

export CONFIG_PATH="/share/searxng/config"
export DATA_PATH="/share/searxng/data"
export SEARXNG_SETTINGS_PATH="${CONFIG_PATH}/settings.yml"

mkdir -p "$CONFIG_PATH" "$DATA_PATH"

exec /usr/local/searxng/entrypoint.sh
