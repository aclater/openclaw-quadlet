#!/usr/bin/env bash
LOG="/home/aclater/openclaw-diag-$(date +%s).log"
exec > "$LOG" 2>&1
OC="sudo runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw"
echo "=== user@1002 full status ==="
sudo systemctl status user@1002.service --no-pager
echo "=== run generator manually ==="
sudo runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw \
  /usr/lib/systemd/user-generators/podman-user-generator \
  /run/user/1002/systemd/generator \
  /run/user/1002/systemd/generator.early \
  /run/user/1002/systemd/generator.late 2>&1 || true
echo "=== generator output ==="
sudo ls -la /run/user/1002/systemd/generator/ 2>/dev/null || echo "none"
echo "=== podman info as openclaw ==="
$OC podman info 2>&1 | head -5 || true
echo "=== done ==="
