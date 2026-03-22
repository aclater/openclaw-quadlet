#!/usr/bin/env bash
LOG="/home/aclater/openclaw-diag-$(date +%s).log"
exec > "$LOG" 2>&1
OC="sudo runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw"

echo "==> Ollama status"
$OC systemctl --user status ollama.service --no-pager || true

echo "==> Starting OpenClaw"
$OC systemctl --user start openclaw.service

echo "==> Waiting 20s..."
sleep 20

echo "==> OpenClaw status"
$OC systemctl --user status openclaw.service --no-pager || true

echo "==> OpenClaw logs"
$OC podman logs openclaw 2>&1 | tail -30 || true

echo "==> Done: $LOG"
