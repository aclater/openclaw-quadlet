#!/usr/bin/env bash
# One-time setup: generate and deploy the quadlet, reload systemd, deploy canvas.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/config.sh
source "$REPO/scripts/config.sh"

# Path to the openclaw-skills repo. Override if yours is elsewhere.
OC_SKILLS="${OC_SKILLS:-/home/aclater/openclaw-skills}"

echo "==> Deploying quadlet for '$OC_USER' (uid=$OC_UID, port=$OC_PORT)..."
mkdir -p "$OC_HOME/.config/containers/systemd"
sed \
  -e "s|%%OC_NAME%%|$OC_NAME|g" \
  -e "s|%%OC_UID%%|$OC_UID|g" \
  -e "s|%%OC_GID%%|$OC_GID|g" \
  -e "s|%%OC_DATA%%|$OC_DATA|g" \
  -e "s|%%OC_PORT%%|$OC_PORT|g" \
  "$REPO/openclaw.container.tmpl" \
  > "$OC_HOME/.config/containers/systemd/$OC_NAME.container"
chown "$OC_UID:$OC_GID" "$OC_HOME/.config/containers/systemd/$OC_NAME.container"
oc "systemctl --user daemon-reload"

echo "==> Deploying canvas..."
mkdir -p "$OC_DATA/canvas"
cp "$OC_SKILLS/vibe-kingdom-openclaw/dashboard/index.html" \
   "$OC_DATA/canvas/vibe-kingdom.html"
chown -R "$OC_UID:$OC_GID" "$OC_DATA/canvas"

echo "==> Done."
echo "    Next: run scripts/fix-config.sh to write API keys, then scripts/build.sh to build the image."
