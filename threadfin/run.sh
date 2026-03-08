#!/bin/sh
set -eu

OPTIONS_FILE="/data/options.json"
STATE_DIR="/share/threadfin"
CONF_DIR="${STATE_DIR}/conf"
TEMP_DIR="${STATE_DIR}/temp"

mkdir -p "$CONF_DIR" "$TEMP_DIR"

bind_address="$(jq -r '.bind_address // "0.0.0.0"' "$OPTIONS_FILE")"
port="$(jq -r '.port // 34400' "$OPTIONS_FILE")"
branch="$(jq -r '.branch // "main"' "$OPTIONS_FILE")"
debug="$(jq -r '.debug // 0' "$OPTIONS_FILE")"
timezone="$(jq -r '.timezone // "UTC"' "$OPTIONS_FILE")"

export TZ="$timezone"

exec /usr/local/bin/threadfin \
  -port="$port" \
  -bind="$bind_address" \
  -branch="$branch" \
  -debug="$debug" \
  -config="$CONF_DIR"
