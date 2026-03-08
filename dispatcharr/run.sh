#!/bin/sh
set -eu

OPTIONS_FILE="/data/options.json"
STATE_DIR="/share/dispatcharr"
DATA_DIR="${STATE_DIR}/data"
LOG_LEVEL="$(jq -r '.log_level // "info"' "$OPTIONS_FILE")"

mkdir -p "$DATA_DIR"

export DISPATCHARR_ENV="aio"
export DISPATCHARR_LOG_LEVEL="$LOG_LEVEL"

rm -rf /data
ln -s "$DATA_DIR" /data

exec /app/docker/entrypoint.sh
