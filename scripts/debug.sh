#!/usr/bin/env bash
# Run openclaw interactively (no --rm, no -d) to capture startup errors
set -euo pipefail
OC="sudo runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw"

# Clean up any leftover container from a prior run
$OC podman rm -f openclaw 2>/dev/null || true

echo "==> Running openclaw interactively (Ctrl-C to stop)..."
$OC podman run \
  --name openclaw \
  --replace \
  --cgroups=split \
  --pull never \
  --network systemd-openclaw-net \
  --security-opt=no-new-privileges \
  --device nvidia.com/gpu=0 \
  --user 1002:1003 \
  --userns keep-id \
  -v /home/openclaw/.openclaw:/home/node/.openclaw:Z \
  --publish 127.0.0.1:18789:18789 \
  --publish 127.0.0.1:18790:18790 \
  --publish 127.0.0.1:18791:18791 \
  --env HOME=/home/node \
  --env TERM=xterm-256color \
  --env-file /home/openclaw/.openclaw/.env \
  ghcr.io/openclaw/openclaw:slim \
  node dist/index.js gateway --bind lan --port 18789
