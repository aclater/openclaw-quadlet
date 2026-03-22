# openclaw-quadlet

Podman quadlet and custom container image for running [OpenClaw](https://openclaw.dev) on Fedora/RHEL with rootless Podman.

## What's here

| File | Purpose |
|------|---------|
| `openclaw.container` | Podman quadlet unit — drop into `~/.config/containers/systemd/` |
| `Containerfile` | Custom image extending `ghcr.io/openclaw/openclaw:slim` |
| `scripts/build.sh` | Build the custom image and restart OpenClaw |
| `scripts/fix-config.sh` | Write `openclaw.json` and `.env` from key files |
| `scripts/start.sh` | Start OpenClaw and tail logs |

## Setup

### Prerequisites

- Fedora/RHEL with rootless Podman
- OpenClaw running as a dedicated `openclaw` user (uid=1002, gid=1003)
- API keys stored at:
  - `~/.anthropic.key`
  - `~/.tavily.key`
  - `~/.youtube.key` (Google/Gemini)

### First-time install

1. Copy the quadlet to the openclaw user's systemd directory:
   ```bash
   sudo cp openclaw.container /home/openclaw/.config/containers/systemd/
   ```

2. Build the custom image and configure OpenClaw:
   ```bash
   sudo bash scripts/build.sh
   sudo bash scripts/fix-config.sh
   ```

## Custom image

The `Containerfile` extends the upstream `openclaw:slim` image with:

- `sonos-cli` — Sonos speaker control via the OpenClaw agent

## Networking

The container runs with `Network=host` so the OpenClaw agent can discover Sonos devices via SSDP multicast. OpenClaw is accessible on the host at ports 18789–18791.

## Canvas

The OpenClaw canvas is served at `http://127.0.0.1:18789/__openclaw__/canvas/`.
Custom canvas apps (e.g. the Vibe Kingdom dashboard) are deployed by placing HTML files
in `/home/openclaw/.openclaw/canvas/` — see `scripts/fix-config.sh` for an example.
