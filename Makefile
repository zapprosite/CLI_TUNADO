SHELL := /bin/bash
.DEFAULT_GOAL := help

# Configs
APP_PORT ?= 3300
PID_FILE ?= /tmp/hello-app.pid

.PHONY: help ## Lista os atalhos disponíveis
help:
	@echo "Targets disponíveis:"; \
	awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_\-]+:.*##/ {printf "  \033[36m%-28s\033[0m %s\n", $1, $2}' $(MAKEFILE_LIST)

# ============ App (Hello) ============
.PHONY: app app-bg app-stop app-log
app: ## Sobe o hello-app em foreground (CTRL+C para sair)
	PORT=$(APP_PORT) node apps/hello-app/server.cjs

app-bg: ## Sobe o hello-app em background e salva PID
	PORT=$(APP_PORT) node apps/hello-app/server.cjs > /tmp/hello-app.log 2>&1 & echo $! > $(PID_FILE); \
	echo "[hello-app] PID=$(cat $(PID_FILE)) log=/tmp/hello-app.log"

app-stop: ## Para o hello-app (se rodando em bg)
	@[ -f $(PID_FILE) ] && kill $(cat $(PID_FILE)) 2>/dev/null && rm -f $(PID_FILE) && echo "[hello-app] stopped" || echo "[hello-app] not running"

app-log: ## Mostra as últimas linhas do log do hello-app
	@tail -n 50 -f /tmp/hello-app.log || true

# ============ Live (auto-reload com Node --watch) ============
.PHONY: live live-bg live-stop live-log
live: ## Sobe o hello-app com --watch (auto-reload)
	PORT=$(APP_PORT) node --watch apps/hello-app/server.cjs

live-bg: ## Sobe o hello-app --watch em background
	PORT=$(APP_PORT) node --watch apps/hello-app/server.cjs > /tmp/hello-app-live.log 2>&1 & echo $! > /tmp/hello-app-live.pid; \
	echo "[live] PID=$(cat /tmp/hello-app-live.pid) log=/tmp/hello-app-live.log"

live-stop: ## Para o live server (se rodando)
	@[ -f /tmp/hello-app-live.pid ] && kill $(cat /tmp/hello-app-live.pid) 2>/dev/null && rm -f /tmp/hello-app-live.pid && echo "[live] stopped" || echo "[live] not running"

live-log: ## Mostra logs do live server
	@tail -n 50 -f /tmp/hello-app-live.log || true

# (Infra removida para foco Replit/Agent)

# ============ API (Fastify TS) ============
.PHONY: api api-bg api-stop api-log
api: ## Sobe a API em dev (tsx watch)
	cd apps/api && npm run dev

api-bg: ## Sobe a API em background
	cd apps/api && npm run dev > /tmp/api.log 2>&1 & echo $$! > /tmp/api.pid; \
	echo "[api] PID=$$(cat /tmp/api.pid) log=/tmp/api.log"

api-stop: ## Para a API (bg)
	@[ -f /tmp/api.pid ] && kill $$(cat /tmp/api.pid) 2>/dev/null && rm -f /tmp/api.pid && echo "[api] stopped" || echo "[api] not running"

api-log: ## Logs da API
	@tail -n 50 -f /tmp/api.log || true

# ============ Web (Vite React TS) ============
.PHONY: web web-bg web-stop web-log
WEB_PORT ?= 5173
web: ## Sobe o web (Vite) em dev
	cd apps/web && npm run dev -- --port $(WEB_PORT)

web-bg: ## Sobe o web em background
	cd apps/web && npm run dev -- --port $(WEB_PORT) > /tmp/web.log 2>&1 & echo $$! > /tmp/web.pid; \
	echo "[web] PID=$$(cat /tmp/web.pid) log=/tmp/web.log"

web-stop: ## Para o web (bg)
	@[ -f /tmp/web.pid ] && kill $$(cat /tmp/web.pid) 2>/dev/null && rm -f /tmp/web.pid && echo "[web] stopped" || echo "[web] not running"

web-log: ## Logs do web
	@tail -n 50 -f /tmp/web.log || true

# ============ Codex (repo) ============
.PHONY: codex-mcp codex-smoke codex-plan codex-patch codex-pr

codex-mcp: ## Lista MCPs (workspace .codex/config.toml)
	codex -C ./.codex/config.toml exec --skip-git-repo-check "/mcp" || true

codex-mcp-pro: ## Lista MCPs (PRO) usando .codex/config.pro.toml
	codex -C ./.codex/config.pro.toml exec --skip-git-repo-check "/mcp" || true

codex-smoke: ## Abre http://localhost:$(APP_PORT) e retorna TITLE/URL (Playwright MCP)
	@PORT=$(APP_PORT) node apps/hello-app/server.cjs > /tmp/hello-app-smoke.log 2>&1 & echo $! > $(PID_FILE); \
	sleep 0.8; \
	codex exec --skip-git-repo-check "Using Playwright MCP only, open http://localhost:$(APP_PORT) and return one line: TITLE=<document.title> URL=<page.url>." || true; \
	kill $(cat $(PID_FILE)) 2>/dev/null || true; rm -f $(PID_FILE)

codex-plan: ## Plano granular (tarefas ≤ 15 min)
	npm run -s codex:plan || true

codex-patch: ## Aplicar diffs mínimos (com aprovação)
	npm run -s codex:patch || true

codex-pr: ## Cria branch/commit para PR (abra PR na UI)
	npm run -s codex:pr || true

codex-orq: ## Orquestrador (full-auto) com prompt do repo (use TASK="...")
	@TASK_MSG=$${TASK:-"Demonstre orquestração mínima: valide sanity e resuma estado."}; \
	PROMPT=$$(cat prompts/orquestrador-system.md; echo; echo "Tarefa: $$TASK_MSG"); \
	codex --dangerously-bypass-approvals-and-sandbox -C ./.codex/config.toml exec "$$PROMPT"

codex-orq-nightly: ## Orquestrador noturno (full-auto) com logs e branch
	@mkdir -p reports/orchestrator; \
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { git init && git add -A && git commit -m 'chore(init): repo bootstrap' >/dev/null 2>&1 || true; }; \
	BR=$${BRANCH:-feat/orq-nightly-$$(date +%Y%m%d-%H%M%S)}; \
	git switch -c $$BR 2>/dev/null || git switch $$BR; \
	PROMPT=$$(cat prompts/orquestrador-system.md; echo; echo; cat prompts/orquestrador-nightly.md); \
	codex --dangerously-bypass-approvals-and-sandbox -C ./.codex/config.toml exec "$$PROMPT" | tee reports/orchestrator/$$BR.log; \
	MSG="Orquestrador finalizado: branch=$$BR log=reports/orchestrator/$$BR.log"; \
	( set -a; [ -f .env ] && . ./.env || true; set +a; SLACK_WEBHOOK=$$SLACK_WEBHOOK DISCORD_WEBHOOK=$$DISCORD_WEBHOOK ./scripts/notify.sh "$$MSG" >/dev/null || true ); \
	echo "[orq] $$MSG"

codex-orq-target: ## Orquestrador (full-auto) em outro repo (TARGET=/caminho)
	@TARGET_DIR=$${TARGET:-}; test -n "$$TARGET_DIR" || { echo "Defina TARGET=/caminho/do/repo"; exit 1; }; \
	if [ ! -d "$$TARGET_DIR/.codex" ]; then ln -s "$(PWD)/.codex" "$$TARGET_DIR/.codex" || true; fi; \
	PROMPT=$$(cat prompts/orquestrador-system.md; echo; echo "Tarefa: $${TASK:-Padronizar repo e garantir sanity+smoke}" ); \
	codex --dangerously-bypass-approvals-and-sandbox -C "$$TARGET_DIR" exec "$$PROMPT"

codex-orq-nightly-target: ## Orquestrador nightly em outro repo (TARGET=/caminho)
	@TARGET_DIR=$${TARGET:-}; test -n "$$TARGET_DIR" || { echo "Defina TARGET=/caminho/do/repo"; exit 1; }; \
	if [ ! -d "$$TARGET_DIR/.codex" ]; then ln -s "$(PWD)/.codex" "$$TARGET_DIR/.codex" || true; fi; \
	git -C "$$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { git -C "$$TARGET_DIR" init && git -C "$$TARGET_DIR" add -A && git -C "$$TARGET_DIR" commit -m 'chore(init): repo bootstrap' >/dev/null 2>&1 || true; }; \
	BR=$${BRANCH:-feat/orq-nightly-$$(date +%Y%m%d-%H%M%S)}; \
	git -C "$$TARGET_DIR" switch -c $$BR 2>/dev/null || git -C "$$TARGET_DIR" switch $$BR; \
	PROMPT=$$(cat prompts/orquestrador-system.md; echo; echo; cat prompts/orquestrador-nightly.md); \
	mkdir -p "$$TARGET_DIR/reports/orchestrator"; \
	codex --dangerously-bypass-approvals-and-sandbox -C "$$TARGET_DIR" exec "$$PROMPT" | tee "$$TARGET_DIR/reports/orchestrator/$$BR.log"; \
	MSG="Orquestrador finalizado: target=$$TARGET_DIR branch=$$BR log=reports/orchestrator/$$BR.log"; \
	( set -a; [ -f .env ] && . ./.env || true; set +a; SLACK_WEBHOOK=$$SLACK_WEBHOOK DISCORD_WEBHOOK=$$DISCORD_WEBHOOK ./scripts/notify.sh "$$MSG" >/dev/null || true ); \
	echo "[orq-target] $$MSG"

.PHONY: notify-test
notify-test: ## Envia notificação de teste (Slack/Discord via .env)
	@MSG=$${MSG:-"Zappro notify test $$(date +%F\ %T)"}; \
	( set -a; [ -f .env ] && . ./.env || true; set +a; SLACK_WEBHOOK=$$SLACK_WEBHOOK DISCORD_WEBHOOK=$$DISCORD_WEBHOOK ./scripts/notify.sh "$$MSG" );

# (Extensões via Codex removidas — foco lean)

# ============ Sanity ============
.PHONY: sanity
sanity: ## Verificações: Node/npm e app /healthz
	@echo "Node:"; node -v
	@echo "npm:"; npm -v
	@echo "App smoke (/healthz):"; \
	PORT=$(APP_PORT) node apps/hello-app/server.cjs > /tmp/hello-app-smoke.log 2>&1 & echo $$! > $(PID_FILE); \
	sleep 0.8; \
	curl -sSf http://localhost:$(APP_PORT)/healthz || true; echo; \
	kill $$(cat $(PID_FILE)) 2>/dev/null || true; rm -f $(PID_FILE)

# ============ Assistant (voz/IA) ============
.PHONY: assistant-check assistant-dev assistant-venv
ASSIST_VENV=agents/assistant/.venv

assistant-venv:
	@test -d $(ASSIST_VENV) || python3 -m venv $(ASSIST_VENV)
	@$(ASSIST_VENV)/bin/python -m pip install --upgrade pip >/dev/null 2>&1 || true
	@test -f agents/assistant/requirements.txt && $(ASSIST_VENV)/bin/pip install -r agents/assistant/requirements.txt >/dev/null 2>&1 || true

assistant-check: ## Diagnóstico do assistant (versões e variáveis)
	$(MAKE) assistant-venv >/dev/null 2>&1 || true
	@$(ASSIST_VENV)/bin/python agents/assistant/check.py || true

assistant-dev: ## Inicia o assistant em modo CLI (texto)
	$(MAKE) assistant-venv >/dev/null 2>&1 || true
	@$(ASSIST_VENV)/bin/python agents/assistant/assistant.py

# ============ VS Code ============
.PHONY: code-list code-open
code-list: ## Lista extensões VS Code (direto pelo code CLI)
	code --list-extensions | sort || true

code-open: ## Abre o workspace no VS Code
	code .

# ============ Observability (OSS opcional) ============
# (Observability removida — foco lean)
