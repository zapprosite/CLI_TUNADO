#!/usr/bin/env bash
set -euo pipefail

MSG=${1:-"[notify] Execução concluída"}

if [[ -n "${SLACK_WEBHOOK:-}" ]]; then
  curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MSG\"}" "$SLACK_WEBHOOK" >/dev/null || true
fi

if [[ -n "${DISCORD_WEBHOOK:-}" ]]; then
  curl -s -H 'Content-Type: application/json' -d "{\"content\":\"$MSG\"}" "$DISCORD_WEBHOOK" >/dev/null || true
fi

echo "$MSG"
