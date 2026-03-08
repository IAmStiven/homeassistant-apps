# Dispatcharr

Dispatcharr is an IPTV, EPG, and VOD management platform with HDHomeRun emulation and multi-source stream handling.

This add-on packages the upstream all-in-one container and stores persistent data under `/share/dispatcharr/data`.

## Access

After starting the add-on, open `http://homeassistant.local:9191` or use your Home Assistant host IP on port `9191`.

## Add-on options

```yaml
log_level: info
```

- `log_level`: Dispatcharr runtime log level

## Persistent files

- Application data: `/share/dispatcharr/data`

## Notes

- This add-on runs Dispatcharr in upstream `aio` mode.
- Dispatcharr uses its own internal services in this image, so no extra Redis or Postgres containers are required here.
- For Plex, Emby, or Jellyfin integration, complete setup inside the Dispatcharr web UI after first start.
- If you plan to use advanced transcoding or hardware acceleration, the add-on may need extra device access beyond this initial scaffold.
