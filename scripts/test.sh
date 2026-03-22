#!/usr/bin/env bash
# Smoke-test the running OpenClaw instance.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/config.sh
source "$REPO/scripts/config.sh"

BASE_URL="http://127.0.0.1:$OC_PORT"
PASS=0
FAIL=0

check() {
  local desc="$1" cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "==> Testing OpenClaw ($OC_NAME) on port $OC_PORT..."
echo ""

check "service is active" \
  "oc 'systemctl --user is-active $OC_NAME.service'"

check "container is running" \
  "oc 'podman ps -q --filter name=$OC_NAME' | grep -q ."

check "gateway responds" \
  "curl -sf --max-time 5 '$BASE_URL/'"

check "canvas vibe-kingdom.html accessible" \
  "curl -sf --max-time 5 '$BASE_URL/__openclaw__/canvas/vibe-kingdom.html' | grep -qi html"

check "vibe-kingdom script installed" \
  "test -f '$OC_DATA/skills/vibe-kingdom-openclaw/scripts/vibe-kingdom.js'"

check "vibe-kingdom show-config" \
  "oc 'node $OC_DATA/skills/vibe-kingdom-openclaw/scripts/vibe-kingdom.js show-config'"

check "vibe-kingdom list-posts" \
  "oc 'node $OC_DATA/skills/vibe-kingdom-openclaw/scripts/vibe-kingdom.js list-posts'"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
