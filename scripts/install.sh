#!/usr/bin/env bash
# One-time setup: deploy the quadlet and canvas, reload systemd.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
oc() { runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw sh -c "cd /home/openclaw && $*"; }

echo "==> Deploying quadlet..."
cp "$REPO/openclaw.container" /home/openclaw/.config/containers/systemd/openclaw.container
chown 1002:1003 /home/openclaw/.config/containers/systemd/openclaw.container
oc "systemctl --user daemon-reload"

echo "==> Deploying canvas..."
mkdir -p /home/openclaw/.openclaw/canvas
cp /home/aclater/openclaw-skills/vibe-kingdom-openclaw/dashboard/index.html \
   /home/openclaw/.openclaw/canvas/vibe-kingdom.html
chown -R 1002:1003 /home/openclaw/.openclaw/canvas

echo "==> Done."
echo "    Next: run scripts/fix-config.sh to write API keys, then scripts/build.sh to build the image."
