#!/usr/bin/env bash
# Start OpenClaw and show logs.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/config.sh
source "$REPO/scripts/config.sh"

echo "==> Starting OpenClaw ($OC_NAME)..."
oc "systemctl --user start $OC_NAME.service"

echo "==> Waiting for startup..."
sleep 20
oc "systemctl --user status $OC_NAME.service --no-pager" || true
oc "podman logs $OC_NAME 2>&1 | tail -20" || true

echo "==> Done."
