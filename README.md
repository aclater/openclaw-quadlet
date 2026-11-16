# openclaw-quadlet

Podman quadlet and custom container image for running [OpenClaw](https://openclaw.dev) on Fedora/RHEL with rootless Podman.

## Quick start

You need Fedora or RHEL with Podman, sudo, an NVIDIA GPU set up for Podman (CDI), and Anthropic, Tavily and Google
(Gemini) API keys. This quick start has not yet been tested end to end on a fresh system.

1. Create the user OpenClaw runs as, and let its services run without a login:

   ```
   sudo useradd openclaw
   sudo loginctl enable-linger openclaw
   ```

2. Get the skills and this repository:

   ```
   sudo git clone https://github.com/aclater/openclaw-skills.git /opt/openclaw-skills
   git clone https://github.com/aclater/openclaw-quadlet.git
   cd openclaw-quadlet
   ```

3. Store the API keys in a folder only root can read. Run each command, paste the key, press Enter, then Ctrl+D:

   ```
   sudo install -d -m 700 /root/openclaw-keys
   sudo sh -c 'cat > /root/openclaw-keys/.anthropic.key'
   sudo sh -c 'cat > /root/openclaw-keys/.tavily.key'
   sudo sh -c 'cat > /root/openclaw-keys/.youtube.key'
   ```

4. Install the quadlet, write the configuration, build the image and start OpenClaw:

   ```
   sudo OC_SKILLS=/opt/openclaw-skills bash scripts/install.sh
   sudo KEYS_DIR=/root/openclaw-keys bash scripts/fix-config.sh
   sudo bash scripts/build.sh
   ```

   On a first install, `fix-config.sh` ends with an error because it cannot start OpenClaw before the image exists;
   `build.sh` builds the image and starts it.

5. Open http://127.0.0.1:18789/.

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
