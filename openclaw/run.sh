#!/bin/sh
set -eu

OPTIONS_FILE="/data/options.json"
STATE_DIR="/share/openclaw"
CONFIG_PATH="${STATE_DIR}/openclaw.json"
ENV_FILE="${STATE_DIR}/.env"
TOKEN_FILE="${STATE_DIR}/gateway.token"
WORKSPACE_DIR="${STATE_DIR}/workspace"
SSH_DIR="${STATE_DIR}/.ssh"

mkdir -p "$STATE_DIR" "$WORKSPACE_DIR" "$SSH_DIR"
chmod 700 "$SSH_DIR"

gateway_bind="$(jq -r '.gateway_bind // "lan"' "$OPTIONS_FILE")"
gateway_port="$(jq -r '.gateway_port // 18789' "$OPTIONS_FILE")"
gateway_token="$(jq -r '.gateway_token // empty' "$OPTIONS_FILE")"
log_level="$(jq -r '.log_level // "info"' "$OPTIONS_FILE")"

if [ -z "$gateway_token" ]; then
  if [ -f "$TOKEN_FILE" ]; then
    gateway_token="$(tr -d '\r\n' < "$TOKEN_FILE")"
  else
    gateway_token="$(bun -e 'console.log(Array.from(crypto.getRandomValues(new Uint8Array(32))).map((b) => b.toString(16).padStart(2, "0")).join(""))')"
    printf '%s\n' "$gateway_token" > "$TOKEN_FILE"
  fi
fi

if [ ! -f "$CONFIG_PATH" ]; then
  cp /etc/openclaw/openclaw.template.json5 "$CONFIG_PATH"
fi

if [ ! -f "$ENV_FILE" ]; then
  cat > "$ENV_FILE" <<'EOF'
# OpenClaw global environment file
# Add provider keys here as needed, for example:
# OPENAI_API_KEY=...
# ANTHROPIC_API_KEY=...
# OPENROUTER_API_KEY=...
# GEMINI_API_KEY=...
EOF
fi

export HOME="$STATE_DIR"
export OPENCLAW_HOME="$STATE_DIR"
export OPENCLAW_STATE_DIR="$STATE_DIR"
export OPENCLAW_CONFIG_PATH="$CONFIG_PATH"
export OPENCLAW_GATEWAY_TOKEN="$gateway_token"
export OPENCLAW_LOG_LEVEL="$log_level"

set -a
. "$ENV_FILE"
set +a

exec openclaw gateway --allow-unconfigured --port "$gateway_port" --bind "$gateway_bind"
