#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

APP_PORT=${APP_PORT:-3300}
WEB_PORT=${WEB_PORT:-5173}
WEB_PREVIEW_PORT=${WEB_PREVIEW_PORT:-5174}

echo "[auto] preflight: Node=$(node -v) npm=$(npm -v)"

# Ensure API deps and DB
if [ ! -d apps/api/node_modules ]; then
  echo "[auto] installing API deps"; (cd apps/api && npm install)
fi
echo "[auto] prisma generate/migrate (SQLite)"
(cd apps/api && npm run -s prisma:generate >/dev/null 2>&1 || true)
(cd apps/api && DATABASE_URL=file:./prisma/dev.db npm run -s prisma:migrate >/dev/null 2>&1 || true)

# Ensure Web deps and env
if [ ! -d apps/web/node_modules ]; then
  echo "[auto] installing Web deps"; (cd apps/web && npm install)
fi
if [ ! -f apps/web/.env.local ] && [ -f apps/web/.env.local.example ]; then
  cp apps/web/.env.local.example apps/web/.env.local
fi

echo "[auto] starting services (bg): hello, api, web"
make -s app-bg
sleep 0.3
make -s api-bg
sleep 0.6
make -s web-bg WEB_PORT=$WEB_PORT
sleep 1.2

echo "[auto] checks"
echo -n " - hello /healthz: "; (curl -sSf "http://localhost:${APP_PORT}/healthz" && echo) || echo "ERR"
echo -n " - api /healthz: ";   (curl -sSf "http://localhost:3400/healthz" && echo) || echo "ERR"
echo -n " - web /: ";           (curl -sSf "http://localhost:${WEB_PORT}" >/dev/null && echo OK) || echo "ERR"

echo
echo "[auto] logs hints: make auto-log | stop: make auto-stop"
echo "[auto] done"

