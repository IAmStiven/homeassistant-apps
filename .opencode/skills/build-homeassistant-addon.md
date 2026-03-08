# Build Home Assistant Addon

Use this skill when creating or updating a Home Assistant app/add-on in this repository.

## Goal

Produce a publishable Home Assistant app that follows current Home Assistant app/add-on repository conventions and is ready for local testing plus GHCR publishing.

## Inputs to gather

- App name
- Slug
- Upstream project URL
- Short description
- Exposed ports
- Required persistent storage paths
- Required environment variables or secrets
- Supported architectures
- Whether the app is local-only, ingress-enabled, or public-facing

## Repository conventions

- One app per top-level directory, for example `searxng/`
- Root `repository.yaml` describes the whole repository
- Each app directory should include at least:
  - `config.yaml`
  - `Dockerfile`
  - `README.md`
  - `DOCS.md`
  - `CHANGELOG.md`
- Add `run.sh` or `rootfs/` scripts when startup logic is needed
- Prefer ASCII-only edits unless the file already requires Unicode

## Build workflow

1. Inspect any existing app directory and upstream container/docs before editing.
2. Create or update `config.yaml` with:
   - `name`, `version`, `slug`, `description`, `url`
   - `arch`
   - `startup`, `boot`, `init`
   - `ports` and `ports_description` when needed
   - `map` for persistent storage like `share:rw`
   - `webui` and `panel_icon` when applicable
   - `options` and `schema` only for real user-configurable settings
   - `image` for published addons, using `ghcr.io/<owner>/{arch}-addon-<slug>`
3. Create or update `Dockerfile`:
   - Prefer a pinned upstream base image over `latest`
   - Copy only the files needed for Home Assistant integration
   - Add a lightweight wrapper entrypoint if paths or environment need adaptation
4. Create or update runtime scripts:
   - Persist config and data under `/share/<slug>/`
   - Avoid destructive first-boot behavior
   - Let upstream entrypoints handle initialization when possible
5. Write docs:
   - `README.md`: one-line app description
   - `DOCS.md`: access URL, config paths, options, reverse proxy notes, security notes
   - `CHANGELOG.md`: keep release notes aligned with `version`
6. Validate:
   - Syntax-check shell scripts with `sh -n`
   - Verify file paths and slugs match
   - Confirm `image`, `version`, and published tags line up for releases

## Publishing checklist

- Pin the upstream image or source version
- Set `image:` in `config.yaml`
- Ensure the repository URL is correct in both root and app metadata
- Build and publish multi-arch images to GHCR
- Keep `version` and changelog synchronized
- Document any required post-install configuration

## Example prompt

"Using the Build Home Assistant Addon skill, create a new app for <project> with slug <slug>, publish target GHCR, persistent storage under /share, and docs ready for Home Assistant users."
