#!/usr/bin/env bash
set -euo pipefail
LOG="/home/aclater/openclaw-diag-$(date +%s).log"
exec > "$LOG" 2>&1
OC="runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw"

ANTHROPIC_KEY=$(cat /home/aclater/.anthropic.key)
GOOGLE_KEY=$(cat /home/aclater/.youtube.key)
TAVILY_KEY=$(cat /home/aclater/.tavily.key)

echo "==> Adding API keys to .env..."
sed -i '/^ANTHROPIC_API_KEY=/d' /home/openclaw/.openclaw/.env
sed -i '/^GEMINI_API_KEY=/d' /home/openclaw/.openclaw/.env
sed -i '/^TAVILY_API_KEY=/d' /home/openclaw/.openclaw/.env
echo "ANTHROPIC_API_KEY=${ANTHROPIC_KEY}" >> /home/openclaw/.openclaw/.env
echo "GEMINI_API_KEY=${GOOGLE_KEY}" >> /home/openclaw/.openclaw/.env
echo "TAVILY_API_KEY=${TAVILY_KEY}" >> /home/openclaw/.openclaw/.env
chmod 600 /home/openclaw/.openclaw/.env
chown 1002:1003 /home/openclaw/.openclaw/.env
echo "    Done."

echo "==> Writing openclaw.json..."
$OC tee /home/openclaw/.openclaw/openclaw.json > /dev/null << EOF
{
  "gateway": {
    "mode": "local",
    "controlUi": {
      "allowedOrigins": ["http://127.0.0.1:18789"],
      "allowInsecureAuth": true,
      "dangerouslyDisableDeviceAuth": true
    }
  },
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.anthropic.com",
        "apiKey": "${ANTHROPIC_KEY}",
        "models": []
      }
    }
  },
  "tools": {
    "web": {
      "search": {
        "provider": "gemini"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-haiku-4-5-20251001"
      }
    }
  }
}
EOF
chmod 600 /home/openclaw/.openclaw/openclaw.json
chown 1002:1003 /home/openclaw/.openclaw/openclaw.json
echo "    Done."

echo "==> Installing Vibe Kingdom dashboard to canvas..."
mkdir -p /home/openclaw/.openclaw/canvas
cp /home/aclater/openclaw-skills/vibe-kingdom-openclaw/dashboard/index.html \
   /home/openclaw/.openclaw/canvas/vibe-kingdom.html
chown -R 1002:1003 /home/openclaw/.openclaw/canvas
echo "    Done. Available at: http://127.0.0.1:18789/__openclaw__/canvas/vibe-kingdom.html"

echo "==> Restarting openclaw..."
$OC systemctl --user restart openclaw.service
sleep 10

echo "==> OpenClaw logs:"
journalctl _SYSTEMD_USER_UNIT=openclaw.service --since "12 seconds ago" --no-pager 2>/dev/null \
  | grep -v "container\|podman\|image pull\|PODMAN" | tail -15

echo "==> Done: $LOG"
