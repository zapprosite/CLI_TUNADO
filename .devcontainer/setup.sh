#!/usr/bin/env bash
set -euo pipefail

echo "[setup] Node: $(node -v), npm: $(npm -v)"

# Playwright browsers + deps (safe if absent)
if command -v npx >/dev/null 2>&1; then
  npx playwright install --with-deps || true
fi

# Python toolchain + audio/X helpers for Assistant (best-effort)
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y || true
  sudo apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    ffmpeg portaudio19-dev libasound2-dev \
    xdg-utils xdotool || true
fi

if command -v python3 >/dev/null 2>&1; then
  python3 -m pip install --upgrade pip || true
  if [ -f agents/assistant/requirements.txt ]; then
    python3 -m pip install -r agents/assistant/requirements.txt || true
  fi
fi

echo "[setup] Done."
