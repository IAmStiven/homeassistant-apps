# SearXNG

SearXNG is a privacy-focused metasearch engine. This Home Assistant app packages the upstream SearXNG container and stores its persistent files under `/share/searxng/`.

## Access

After starting the app, open `http://homeassistant.local:8080` or use your Home Assistant host IP on port `8080`.

## Configuration

The app does not expose Home Assistant options yet. SearXNG manages its own settings file here:

- `/share/searxng/config/settings.yml`

Cached data is stored here:

- `/share/searxng/data`

On first start, SearXNG creates `settings.yml` automatically and generates a random secret key.

## Notes

- If you run SearXNG behind a reverse proxy, update `server.base_url` in `/share/searxng/config/settings.yml`.
- If you want rate limiting or public internet exposure, review the upstream SearXNG settings before exposing it beyond your local network.
