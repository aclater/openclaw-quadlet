#!/usr/bin/env bash
# Start OpenClaw and show logs.
set -euo pipefail

oc() { runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw sh -c "cd /home/openclaw && $*"; }

echo "==> Starting OpenClaw..."
oc "systemctl --user start openclaw.service"

echo "==> Waiting for startup..."
sleep 20
oc "systemctl --user status openclaw.service --no-pager" || true
oc "podman logs openclaw 2>&1 | tail -20" || true

echo "==> Done."
