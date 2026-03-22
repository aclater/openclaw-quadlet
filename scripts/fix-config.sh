#!/usr/bin/env bash
# Write openclaw.json and .env from host key files, then restart.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/config.sh
source "$REPO/scripts/config.sh"

# Directory containing .anthropic.key, .tavily.key, .youtube.key. Override if needed.
KEYS_DIR="${KEYS_DIR:-/home/aclater}"

ANTHROPIC_KEY=$(cat "$KEYS_DIR/.anthropic.key")
GOOGLE_KEY=$(cat "$KEYS_DIR/.youtube.key")
TAVILY_KEY=$(cat "$KEYS_DIR/.tavily.key")

echo "==> Writing .env..."
mkdir -p "$OC_DATA"
cat > "$OC_DATA/.env" <<EOF
ANTHROPIC_API_KEY=${ANTHROPIC_KEY}
GEMINI_API_KEY=${GOOGLE_KEY}
TAVILY_API_KEY=${TAVILY_KEY}
EOF
chmod 600 "$OC_DATA/.env"
chown "$OC_UID:$OC_GID" "$OC_DATA/.env"

echo "==> Writing openclaw.json..."
cat > "$OC_DATA/openclaw.json" <<EOF
{
  "gateway": {
    "mode": "local",
    "controlUi": {
      "allowedOrigins": ["http://127.0.0.1:${OC_PORT}"],
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
chmod 600 "$OC_DATA/openclaw.json"
chown "$OC_UID:$OC_GID" "$OC_DATA/openclaw.json"

echo "==> Restarting OpenClaw ($OC_NAME)..."
oc "systemctl --user restart $OC_NAME.service"
sleep 10
journalctl _SYSTEMD_USER_UNIT="$OC_NAME.service" --since "12 seconds ago" --no-pager 2>/dev/null \
  | grep -v "container\|podman\|PODMAN" | tail -10

echo "==> Done."
