#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR=${WORKSPACE_DIR:-/workspace}
SCRIPT_PATH="$WORKSPACE_DIR/scripts/hamster_daily_update.py"

if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "Missing script at $SCRIPT_PATH"
  exit 1
fi

if [[ "${RUN_MODE:-once}" == "once" ]]; then
  python3 "$SCRIPT_PATH"
  exit 0
fi

# loop mode: run immediately, then every INTERVAL_HOURS
INTERVAL_HOURS=${INTERVAL_HOURS:-24}
while true; do
  echo "[hamster-pipeline] run started at $(date -u +%FT%TZ)"
  python3 "$SCRIPT_PATH" || true
  echo "[hamster-pipeline] sleeping ${INTERVAL_HOURS}h"
  sleep "$((INTERVAL_HOURS*3600))"
done
