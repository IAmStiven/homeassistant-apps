# Build Home Assistant Addon

Use this skill when creating, reviewing, or publishing a Home Assistant app/add-on in this repository.

## Purpose

Produce a Home Assistant app that is:

- aligned with current Home Assistant app/add-on repository conventions
- practical for local testing in Supervisor
- reproducible enough for releases
- documented for end users
- ready for multi-architecture publishing to GHCR

This skill should be used for both brand-new apps and major updates to existing ones.

## Expected input

Before making changes, gather or infer as many of these as possible:

- app name
- slug
- upstream project name and URL
- upstream image name and tag, or source repository and version
- short and long description
- default port bindings
- required volumes or persistent paths
- supported CPU architectures
- startup model: service, application, once, or system
- whether the app is local-only, LAN-facing, ingress-oriented, or public-facing
- whether the app needs authentication, rate limiting, TLS, or reverse proxy support
- environment variables, secrets, tokens, or generated keys
- whether user-configurable options belong in Home Assistant `options`/`schema` or in upstream config files

If some of this is missing, inspect the upstream docs, Docker image, compose files, and example configs before deciding.

## Repository assumptions

This repository uses a simple one-app-per-directory structure.

- root `repository.yaml` describes the repository
- each app lives in a top-level directory like `searxng/`
- each app should generally contain:
  - `config.yaml`
  - `Dockerfile`
  - `README.md`
  - `DOCS.md`
  - `CHANGELOG.md`
- add `run.sh` and/or `rootfs/` when Home Assistant-specific startup behavior is required

Repository defaults for this repo:

- GitHub owner: `IAmStiven`
- repository URL: `https://github.com/IAmStiven/homeassistant-apps`
- image naming pattern: `ghcr.io/iamstiven/{arch}-addon-<slug>`

## Design principles

### 1. Prefer stable releases over moving targets

- avoid `latest` for published builds when a version tag or digest is available
- pin upstream versions when possible
- make version bumps explicit in `config.yaml` and `CHANGELOG.md`

### 2. Keep Home Assistant integration thin

- prefer wrapping a well-maintained upstream image instead of rebuilding the whole project from source unless necessary
- only add Home Assistant-specific glue for storage paths, environment adaptation, permissions, startup, and docs
- let the upstream entrypoint do upstream initialization when it is safe and predictable

### 3. Persist the right things

- store durable config and data under `/share/<slug>/` unless a different mapped path is clearly required
- do not store important state in ephemeral container paths
- preserve user-managed files across upgrades and restarts

### 4. Expose only necessary configuration

- use Home Assistant `options` and `schema` only for settings users should actually change from the UI
- avoid duplicating every upstream setting into addon options
- if the upstream config file is already the best source of truth, document it instead of over-abstracting it

### 5. Bias toward safe defaults

- default to private/local-network operation unless the app clearly targets public exposure
- call out security-sensitive features such as public access, reverse proxy requirements, admin bootstrap, tokens, and rate limiting

## Workflow

### Step 1: Inspect current state

Before editing:

- inspect the repo root files: `README.md` and `repository.yaml`
- inspect the target app directory if it already exists
- inspect upstream docs, example compose files, image docs, and config templates
- identify whether the app is best implemented as:
  - a wrapper around an upstream image
  - a custom image built from source
  - a mostly static config package with a thin runtime script

Output of this step should be a short mental model of:

- what process actually starts the app
- what files must persist
- what network ports matter
- what first-run initialization is required
- what can break if Home Assistant paths differ from upstream defaults

### Step 2: Create or review the directory layout

Typical layout:

```text
<slug>/
  config.yaml
  Dockerfile
  README.md
  DOCS.md
  CHANGELOG.md
  run.sh
  rootfs/
```

Notes:

- `run.sh` is often enough when the upstream image already contains the actual application
- use `rootfs/` if the addon needs multiple scripts, templates, services, or S6 integration
- do not keep dead template files from a copied addon scaffold

### Step 3: Build `config.yaml` correctly

`config.yaml` is the main Home Assistant contract. Validate every field intentionally.

Core fields:

- `name`: human-facing app name
- `version`: release version for the addon
- `slug`: stable machine-facing identifier; should match directory name
- `description`: one-line description for the store
- `url`: repository or app documentation URL

Architecture:

- only list architectures the image actually supports
- if upstream supports `amd64`, `aarch64`, and `armv7`, do not guess additional ones

Lifecycle:

- `startup: application` for long-running web apps or APIs
- `startup: services` for service-oriented daemons when appropriate
- `boot: auto` if the app should restart with Home Assistant
- `init: false` unless the addon specifically needs an init process from the base image design

Networking:

- add `ports` only when the service is meant to be reachable from outside the container
- add `ports_description` for every exposed port
- add `webui` when the app has a browser UI
- add `panel_icon` if it improves discoverability

Storage:

- use `map` for Home Assistant-managed mounts like `share:rw`
- document where inside that mount the app keeps config and data

Options and schema:

- keep them empty if there are no worthwhile user-facing controls yet
- use them when a small set of settings meaningfully improves installation experience
- avoid huge schemas mirroring full upstream config trees

Publishing:

- for published addons, set:

```yaml
image: "ghcr.io/iamstiven/{arch}-addon-<slug>"
```

- for local-only development, `image` can be omitted so Supervisor builds from `Dockerfile`

### Step 4: Build the image strategy

Choose one of these patterns:

#### Pattern A: Wrapper around upstream image

Use this when upstream already publishes a clean image.

- `Dockerfile` starts with upstream `FROM`
- copy only wrapper scripts or Home Assistant-specific config
- preserve the upstream entrypoint whenever possible, or wrap it lightly

Best for:

- mature web apps
- stable upstream images
- projects with their own initialization logic

#### Pattern B: Custom build from source

Use this when upstream has no usable image or when significant packaging is needed.

- base the image on a suitable runtime
- install dependencies explicitly
- copy app code and configuration
- keep image build steps deterministic

Best for:

- niche tools
- source-only projects
- heavy Home Assistant integration needs

### Step 5: Build `Dockerfile` intentionally

Rules:

- prefer pinned upstream tags over `latest`
- keep the file small and readable
- avoid unnecessary package installation
- copy only the needed files
- make wrapper scripts executable

For wrapper-style addons, a good `Dockerfile` often looks like:

```Dockerfile
FROM docker.io/vendor/project:1.2.3

COPY run.sh /usr/local/bin/homeassistant-run.sh

RUN chmod a+x /usr/local/bin/homeassistant-run.sh

ENTRYPOINT ["/usr/local/bin/homeassistant-run.sh"]
```

Questions to answer before finalizing:

- does the upstream image already define required environment variables?
- does the upstream entrypoint depend on fixed config paths?
- does the app need writable directories created before startup?
- will file ownership matter at runtime?

### Step 6: Build runtime scripts carefully

`run.sh` or service scripts should do the minimum required adaptation.

Good responsibilities:

- export Home Assistant-specific paths
- create persistent directories under `/share/<slug>/`
- set or forward environment variables
- hand off to the real upstream entrypoint

Avoid:

- destructive config rewrites on every boot
- replacing the upstream startup flow without a good reason
- silently resetting secrets or user config

Typical wrapper example:

```sh
#!/bin/sh
set -eu

export CONFIG_PATH="/share/<slug>/config"
export DATA_PATH="/share/<slug>/data"

mkdir -p "$CONFIG_PATH" "$DATA_PATH"

exec /upstream/entrypoint.sh
```

When secrets are generated on first boot:

- generate only if missing
- store in persistent config
- document where it lives

### Step 7: Write user-facing docs

Every addon should be understandable to a Home Assistant user without reading upstream source.

`README.md`

- one-line description
- minimal, repository-facing

`DOCS.md`

- what the app does
- how to access it
- which port it uses
- where persistent files live
- what options are available in Home Assistant
- what users must edit manually in config files
- notes for reverse proxy or public exposure
- security considerations and sane warnings

`CHANGELOG.md`

- add a release entry matching `version`
- keep language short and user-relevant

### Step 8: Validate before calling it done

Minimum checks:

- shell syntax check for scripts: `sh -n run.sh`
- verify slug matches directory name
- verify app URL points to the right directory
- verify docs mention the actual port and paths used
- verify `image`, `version`, and release intent line up

If possible, also validate:

- container starts without missing directories
- first boot creates config as expected
- the app remains functional after restart

## Security checklist

Review these for every addon:

- does the app bind to a network port?
- is it intended only for LAN access?
- does upstream recommend TLS or a reverse proxy?
- is authentication enabled by default?
- does public exposure require rate limiting or IP restrictions?
- are secrets generated and persisted safely?
- are any credentials likely to end up in repo files or docs?

If the app is public-facing, mention hardening steps explicitly in `DOCS.md`.

## Publishing checklist

Before release:

- pin the upstream image or source version
- set `image:` in `config.yaml`
- ensure root `repository.yaml` is correct
- ensure the addon `url:` is correct
- ensure `version` matches the intended release
- update `CHANGELOG.md`
- publish multi-arch images to GHCR
- verify all listed architectures actually exist in the registry

Suggested release image pattern:

```yaml
image: "ghcr.io/iamstiven/{arch}-addon-<slug>"
```

## Common mistakes to avoid

- leaving placeholder URLs in `config.yaml`
- leaving `slug` mismatched with the directory name
- publishing with `latest` as the only meaningful version reference
- exposing ports without documenting access or risks
- storing config in ephemeral container paths
- overusing Home Assistant options for settings better left in upstream config files
- replacing upstream startup logic unnecessarily
- forgetting to keep `CHANGELOG.md` aligned with `version`

## Output expectations when using this skill

When applying this skill to a real addon task, the result should include:

- the created or updated files
- the rationale for image/runtime choices
- what persists under `/share`
- what the user still needs to customize
- what was validated locally and what was not
- what remains before publishing, if anything

## Example requests

### New addon

"Using the Build Home Assistant Addon skill, create a new addon for <project> with slug <slug>, persistent storage under `/share/<slug>`, published images on GHCR, and docs suitable for Home Assistant users."

### Existing addon hardening

"Using the Build Home Assistant Addon skill, review `searxng/` for release readiness, pin the upstream image, add missing metadata, and document any security considerations."

### Add configurable options

"Using the Build Home Assistant Addon skill, add a minimal Home Assistant `options`/`schema` layer for `base_url` and `public_mode`, but keep the rest of the upstream config file user-managed."
