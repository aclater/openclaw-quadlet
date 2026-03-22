#!/usr/bin/env bash
# Write openclaw.json and .env from host key files, then restart.
set -euo pipefail

oc() { runuser -u openclaw -- env XDG_RUNTIME_DIR=/run/user/1002 HOME=/home/openclaw sh -c "cd /home/openclaw && $*"; }

ANTHROPIC_KEY=$(cat /home/aclater/.anthropic.key)
GOOGLE_KEY=$(cat /home/aclater/.youtube.key)
TAVILY_KEY=$(cat /home/aclater/.tavily.key)

echo "==> Writing .env..."
cat > /home/openclaw/.openclaw/.env <<EOF
ANTHROPIC_API_KEY=${ANTHROPIC_KEY}
GEMINI_API_KEY=${GOOGLE_KEY}
TAVILY_API_KEY=${TAVILY_KEY}
EOF
chmod 600 /home/openclaw/.openclaw/.env
chown 1002:1003 /home/openclaw/.openclaw/.env

echo "==> Writing openclaw.json..."
cat > /home/openclaw/.openclaw/openclaw.json <<EOF
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

echo "==> Restarting OpenClaw..."
oc "systemctl --user restart openclaw.service"
sleep 10
journalctl _SYSTEMD_USER_UNIT=openclaw.service --since "12 seconds ago" --no-pager 2>/dev/null \
  | grep -v "container\|podman\|PODMAN" | tail -10

echo "==> Done."
