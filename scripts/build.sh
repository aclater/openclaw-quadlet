#!/usr/bin/env bash
# Build the custom OpenClaw image and restart the service.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/config.sh
source "$REPO/scripts/config.sh"

echo "==> Stopping OpenClaw ($OC_NAME)..."
oc "systemctl --user stop $OC_NAME.service" || true

echo "==> Building image..."
runuser -u "$OC_USER" -- \
  env XDG_RUNTIME_DIR="$OC_XDG" HOME="$OC_HOME" \
  sh -c "cd \"$OC_HOME\" && podman build -t ghcr.io/openclaw/openclaw:slim -" \
  < "$REPO/Containerfile"

echo "==> Starting OpenClaw ($OC_NAME)..."
oc "systemctl --user start $OC_NAME.service"

echo "==> Waiting for startup..."
sleep 15
journalctl _SYSTEMD_USER_UNIT="$OC_NAME.service" --since "17 seconds ago" --no-pager 2>/dev/null \
  | grep -v "container\|podman\|PODMAN" | tail -10

echo "==> Done."
