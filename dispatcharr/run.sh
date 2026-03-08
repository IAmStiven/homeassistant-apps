#!/bin/sh
set -eu

OPTIONS_FILE="/data/options.json"
LOG_LEVEL="$(jq -r '.log_level // "info"' "$OPTIONS_FILE")"

mkdir -p /data

export DISPATCHARR_ENV="aio"
export DISPATCHARR_LOG_LEVEL="$LOG_LEVEL"

exec /app/docker/entrypoint.sh
