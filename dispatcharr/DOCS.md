# Dispatcharr

Dispatcharr is an IPTV, EPG, and VOD management platform with HDHomeRun emulation and multi-source stream handling.

This add-on packages the upstream all-in-one container and uses Home Assistant's built-in add-on data storage at `/data`.

## Access

After starting the add-on, open `http://homeassistant.local:9191` or use your Home Assistant host IP on port `9191`.

## Add-on options

```yaml
log_level: info
```

- `log_level`: Dispatcharr runtime log level

## Persistent files

- Application data: `/data`
- Add-on options file: `/data/options.json`

## Notes

- This add-on runs Dispatcharr in upstream `aio` mode.
- Dispatcharr uses its own internal services in this image, so no extra Redis or Postgres containers are required here.
- Dispatcharr now uses the native Home Assistant add-on data directory instead of trying to remap `/data`.
- For Plex, Emby, or Jellyfin integration, complete setup inside the Dispatcharr web UI after first start.
- If you plan to use advanced transcoding or hardware acceleration, the add-on may need extra device access beyond this initial scaffold.
