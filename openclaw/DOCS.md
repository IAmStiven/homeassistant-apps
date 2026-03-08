# OpenClaw

OpenClaw is a personal AI assistant gateway. This add-on installs OpenClaw with Bun and stores its persistent state under `/share/openclaw/`.

The image also includes `ssh`, `git`, `curl`, and `bash` so OpenClaw can use SSH tunnels, remote Git operations, and common shell-based workflows.

## Important

- The upstream OpenClaw docs describe Bun support as experimental.
- Upstream specifically does not recommend Bun for production WhatsApp or Telegram gateway usage.

## Access

After starting the add-on, open `http://homeassistant.local:18789` or use your Home Assistant host IP on port `18789`.

The dashboard is an admin surface. Authenticate with the gateway token.

- If you set `gateway_token` in the add-on options, use that value.
- If you leave it empty, the add-on generates one on first boot and stores it in `/share/openclaw/gateway.token`.

## Add-on options

```yaml
gateway_bind: lan
gateway_port: 18789
gateway_token: ""
log_level: info
```

- `gateway_bind`: use `lan` for normal Home Assistant access, or `loopback` for stricter local-only binding.
- `gateway_port`: dashboard and gateway port.
- `gateway_token`: optional static token. If blank, one is generated and persisted.
- `log_level`: OpenClaw runtime log level.

## Persistent files

- Config: `/share/openclaw/openclaw.json`
- Global env file: `/share/openclaw/.env`
- SSH keys and known hosts: `/share/openclaw/.ssh`
- Generated token: `/share/openclaw/gateway.token`
- Workspace: `/share/openclaw/workspace`

## Provider configuration

Add provider keys to `/share/openclaw/.env`, for example:

```sh
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
OPENROUTER_API_KEY=...
GEMINI_API_KEY=...
```

Then customize `/share/openclaw/openclaw.json` to match your preferred providers, channels, and agent settings.

The add-on loads `/share/openclaw/.env` on startup, so values placed there are available to OpenClaw automatically.

## SSH

The add-on includes OpenSSH client tooling for OpenClaw's remote SSH workflows.

- Put SSH keys, config, and `known_hosts` under `/share/openclaw/.ssh`
- Keep private keys permissioned appropriately, for example `chmod 600 /share/openclaw/.ssh/id_ed25519`
- OpenClaw can then use SSH tunnels and remote targets described in the upstream remote access docs

Example tunnel from inside the add-on environment:

```sh
ssh -N -L 18789:127.0.0.1:18789 user@host
```

That is useful when you want OpenClaw to reach a loopback-bound remote gateway over SSH.

## Notes

- The add-on seeds a minimal `openclaw.json` on first start and then leaves it user-managed.
- This package runs `openclaw gateway` directly instead of using the interactive onboarding wizard.
- Review the upstream docs before exposing the dashboard outside your trusted network.
