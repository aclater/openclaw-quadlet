#!/usr/bin/env bash
# Shared configuration for OpenClaw management scripts.
# Override any variable in the environment before sourcing to customise the instance.
#
# Second instance example:
#   OC_USER=openclaw2 OC_NAME=openclaw2 OC_PORT=18790 sudo -E bash scripts/install.sh

OC_USER="${OC_USER:-openclaw}"
OC_NAME="${OC_NAME:-openclaw}"
OC_PORT="${OC_PORT:-18789}"

# Derived — set automatically from OC_USER; override only if you know what you're doing.
OC_UID=$(id -u "$OC_USER")
OC_GID=$(id -g "$OC_USER")
OC_HOME=$(getent passwd "$OC_USER" | cut -d: -f6)
OC_DATA="${OC_DATA:-$OC_HOME/.openclaw}"
OC_XDG="/run/user/$OC_UID"

# Run a command as the OpenClaw user with the correct environment.
oc() { runuser -u "$OC_USER" -- env XDG_RUNTIME_DIR="$OC_XDG" HOME="$OC_HOME" sh -c "cd \"$OC_HOME\" && $*"; }
