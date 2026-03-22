#!/usr/bin/env bash
set -euo pipefail
LOG="/home/aclater/openclaw-diag-$(date +%s).log"
exec > "$LOG" 2>&1

oc() { runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw sh -c "cd /home/openclaw && $*"; }

echo "==> Stopping OpenClaw..."
oc "systemctl --user stop openclaw.service" || true

echo "==> Stopping and disabling Ollama..."
oc "systemctl --user stop ollama.service" || true
oc "systemctl --user disable ollama.service" || true

echo "==> Updating openclaw.container quadlet..."
QUADLET=/home/openclaw/.config/containers/systemd/openclaw.container
# Remove ollama dependency
sed -i '/^After=.*ollama\.service/s/ ollama\.service//' "$QUADLET"
sed -i '/^After=$\|^After= /d' "$QUADLET"
# Switch to host networking so Sonos SSDP multicast works
sed -i 's/^Network=.*/Network=host/' "$QUADLET"
# Remove PublishPort lines (not valid with host networking)
sed -i '/^PublishPort=/d' "$QUADLET"
oc "systemctl --user daemon-reload"

echo "==> Building custom image..."
oc "podman build -t ghcr.io/openclaw/openclaw:slim - <<'CONTAINEREOF'
FROM ghcr.io/openclaw/openclaw:slim
USER root
RUN npm install -g sonos-cli
USER node
CONTAINEREOF"

echo "==> Removing Ollama container image..."
oc "podman rmi ollama/ollama" 2>/dev/null || true

echo "==> Starting OpenClaw..."
oc "systemctl --user start openclaw.service"

echo "==> Waiting 20s..."
sleep 20

echo "==> Status..."
oc "systemctl --user status openclaw.service --no-pager" || true
oc "podman logs openclaw 2>&1 | tail -20" || true

echo "==> Done: $LOG"
