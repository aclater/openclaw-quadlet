# openclaw-quadlet

Podman quadlet and custom container image for running [OpenClaw](https://openclaw.dev) on Fedora/RHEL with rootless Podman.

## What's here

| File | Purpose |
|------|---------|
| `openclaw.container.tmpl` | Quadlet unit template — `scripts/install.sh` fills in variables and writes the real unit |
| `Containerfile` | Custom image extending `ghcr.io/openclaw/openclaw:slim` |
| `scripts/config.sh` | Shared instance configuration (user, name, port, derived uid/gid) |
| `scripts/install.sh` | One-time setup: generate quadlet, reload systemd, deploy canvas |
| `scripts/build.sh` | Build the custom image and restart OpenClaw |
| `scripts/fix-config.sh` | Write `openclaw.json` and `.env` from host key files |
| `scripts/start.sh` | Start OpenClaw and tail logs |
| `scripts/test.sh` | Smoke-test the running instance |

## Prerequisites

- Fedora/RHEL with rootless Podman
- A dedicated `openclaw` user (any uid/gid — scripts derive both automatically)
- The [openclaw-skills](https://github.com/aclater/openclaw-skills) repo cloned to `/home/aclater/openclaw-skills`
- API keys stored at:
  - `/home/aclater/.anthropic.key`
  - `/home/aclater/.tavily.key`
  - `/home/aclater/.youtube.key` (Google/Gemini)

## First-time install

```bash
sudo bash scripts/install.sh
sudo bash scripts/fix-config.sh
sudo bash scripts/build.sh
```

## Updating

**After changes to `Containerfile`** (e.g. adding npm packages):
```bash
sudo bash scripts/build.sh
```

**After rotating API keys:**
```bash
sudo bash scripts/fix-config.sh
```

**After changes to `openclaw.container.tmpl`** (quadlet config):
```bash
sudo bash scripts/install.sh
```

## Testing

```bash
sudo bash scripts/test.sh
```

Checks: service active, container running, gateway HTTP, canvas URL, vibe-kingdom script installed and functional.

## Second instance

All scripts read instance settings from `scripts/config.sh` with overridable defaults. To deploy a second OpenClaw on a different port:

1. Create a second system user (e.g. `openclaw2`).
2. Run the scripts with overrides:

```bash
OC_USER=openclaw2 OC_NAME=openclaw2 OC_PORT=18799 sudo -E bash scripts/install.sh
OC_USER=openclaw2 OC_NAME=openclaw2 OC_PORT=18799 sudo -E bash scripts/fix-config.sh
OC_USER=openclaw2 OC_NAME=openclaw2 OC_PORT=18799 sudo -E bash scripts/build.sh
```

This creates an independent `openclaw2.service` with its own data directory at `~openclaw2/.openclaw/`.

## Custom image

The `Containerfile` extends `ghcr.io/openclaw/openclaw:slim` with:

- `sonos-cli` — Sonos speaker control via the OpenClaw agent

## Networking

The container runs with `Network=host` so the OpenClaw agent can discover Sonos devices via SSDP multicast. OpenClaw is accessible on the host at the configured port (default: 18789).

## Canvas

The OpenClaw canvas is served at `http://127.0.0.1:18789/__openclaw__/canvas/`.
Custom apps are deployed by placing HTML files in `~openclaw/.openclaw/canvas/`.
`scripts/install.sh` deploys the Vibe Kingdom dashboard there as `vibe-kingdom.html`.
