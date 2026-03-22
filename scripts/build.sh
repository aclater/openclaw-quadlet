#!/usr/bin/env bash
# Build the custom OpenClaw image and restart the service.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
oc() { runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw sh -c "cd /home/openclaw && $*"; }

echo "==> Stopping OpenClaw..."
oc "systemctl --user stop openclaw.service" || true

echo "==> Building image..."
runuser -u openclaw -- \
  env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw \
  sh -c "cd /home/openclaw && podman build -t ghcr.io/openclaw/openclaw:slim -" \
  < "$REPO/Containerfile"

echo "==> Starting OpenClaw..."
oc "systemctl --user start openclaw.service"

echo "==> Waiting for startup..."
sleep 15
journalctl _SYSTEMD_USER_UNIT=openclaw.service --since "17 seconds ago" --no-pager 2>/dev/null \
  | grep -v "container\|podman\|PODMAN" | tail -10

echo "==> Done."
