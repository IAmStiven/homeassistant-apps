# Threadfin

Threadfin is an M3U proxy for Plex DVR, Emby, and Jellyfin Live TV.

This add-on stores its persistent data under `/share/threadfin/`.

## Access

After starting the add-on, open `http://homeassistant.local:34400` or use your Home Assistant host IP on port `34400`.

## Add-on options

```yaml
bind_address: 0.0.0.0
port: 34400
branch: main
debug: 0
timezone: UTC
```

- `bind_address`: network bind address for the Threadfin web server
- `port`: web UI and API port
- `branch`: `main` for stable or `beta` for newer upstream changes
- `debug`: Threadfin debug level from `0` to `3`
- `timezone`: container timezone for logs and scheduled behavior

## Persistent files

- Config and database files: `/share/threadfin/conf`
- Temporary files: `/share/threadfin/temp`

## Notes

- This add-on builds Threadfin from source during the Home Assistant add-on image build.
- Threadfin's upstream project can auto-update itself. For managed add-on usage, it is usually better to update through add-on releases instead of relying on in-app self-updates.
- For Plex, Emby, or Jellyfin setup guidance, refer to the upstream Threadfin and xTeVe documentation.
