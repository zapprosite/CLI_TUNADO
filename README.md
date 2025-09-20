# Zappro — DevLoop mínimo (Replit‑like + Agent) — Set/2025

Stack enxuta para “codar como Replit” no VS Code, com Codex CLI + MCP essenciais. Sem infra, sem observability, sem CI/CD — foco em editar/rodar rápido.
Observação: o Assistant (voz/áudio) foi separado do DevLoop principal — é opcional.

## Pastas
- `apps/hello-app`: app mínimo Node com `/` e `/healthz`
- `docs/`: painel local (desktop) em `docs/painel.html`
  - Opcional (Assistant): `docs/painel_assistant.html`
- `.devcontainer/` e `.vscode/`: ambiente editor padronizado

## Requisitos
- Node 20+, Git e Codex CLI

## Quick Start
- VS Code: `code /data/ide-zappro`
- DevContainer: “Rebuild and Reopen in Container” → `node -v && npm -v`
- Painel de Atalhos (desktop): abra `docs/painel.html`
- Tutorial da equipe (passo a passo): `docs/guia-equipe.md`
- Codex (repo): listar MCPs → `codex -C ./.codex/config.toml exec --skip-git-repo-check "/mcp"`
- Start app: `make app` e abra http://localhost:3300
- Full‑stack v2: `make dev` (hello 3300, api 3400, web 5173)
- Sanidade profunda: `make sanity-deep`
 - VS Code (Claude Code): instale com `make code-install-claude` (ou pack `make code-install-pack`)
## Notificações (Slack/Discord)
- Configure webhooks no `.env` (copie de `.env.example`).
- Teste: `make notify-test`.
- Orquestrador nightly notifica ao finalizar se `SLACK_WEBHOOK`/`DISCORD_WEBHOOK` estiverem definidos.

### Outro repositório (sem mover nada)
- Usar Codex: `codex mcp list` (a partir da raiz do repo alvo)
- Opcional (reaproveitar config deste repo):
  - Symlink: `ln -s /data/ide-zappro/.codex ./.codex`
  - Copiar: `mkdir -p ./.codex && cp /data/ide-zappro/.codex/config.toml ./.codex/config.toml`

## Fluxo recomendado
1) Abra o DevContainer (ou Node 20 no host)
2) Edite e rode o app: `make app` (ou `make live`)
   - API v2 (SQLite/Prisma): `make api-setup` e `make api`
   - Web: `cd apps/web && cp .env.local.example .env.local` (ajuste `VITE_API_URL=http://localhost:3400` se necessário)
3) Use o painel `docs/painel.html` para atalhos e copiar comandos
4) Opcional: use Codex CLI com MCPs do repo (`/mcp`)

## Codex CLI & MCP
- Config global: `~/.codex/config.toml` (perfil 2025: `model=gpt-5`, `approval_policy=on-request`, `sandbox_mode=workspace-write`).
- Config do repo: `.codex/config.toml` (workspace scope):
  - Essenciais: `filesystem` (raiz do repo), `ripgrep`, `memory`, `@playwright/mcp` (smokes)
- Exemplos de uso:
  - Listar MCPs: `codex -C ./.codex/config.toml exec --skip-git-repo-check "/mcp"`
  - Smoke web (via Makefile): `make codex-smoke APP_PORT=3300`
- Evitar estouro de contexto: use Ripgrep com exclusões (`.rgignore` já criado: node_modules/, dist/, build/, .git/, **/*.min.*). 

## VS Code (RTX 4090, GPU ON) — extensões e configurações
- Como abrir (aceleração de GPU): `code /data/ide-zappro` (atalho aponta para `code-accel` com console seguro).
- Extensões recomendadas (leves):
  - Claude Code (oficial): `anthropic.claude-dev`
  - Qualidade: `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `yzhang.markdown-all-in-one`
- Configs do workspace: `.vscode/settings.json`
  - `editor.formatOnSave=true`, `files.trimTrailingWhitespace=true`, `files.insertFinalNewline=true`
  - `eslint.validate` para JS/TS/React; schemas YAML para `.github/workflows/*.yml` e `.gitlab-ci.yml`
- Tasks VS Code: `.vscode/tasks.json`
  - `Codex: MCP status` e `Codex: Abrir chat`
- Instalar extensões:
  - VS Code UI (Extensions) ou CLI: `code --install-extension <publisher.id>`
  - Instalar Claude Code via Makefile: `make code-install-claude`

## Dev Container
- Base Node 20 com `common-utils`
- PostCreate: `.devcontainer/setup.sh` instala navegadores Playwright

## Assistant (opcional, separado)
- O assistant não faz mais parte do DevLoop padrão (VS Code + Node).
- DevContainer padrão é “enxuto” (não instala libs de áudio). Para usar o assistant:
  - Terminal: `make assistant-check` e `make assistant-dev`
  - Painel opcional: abra `docs/painel_assistant.html`
  - DevContainer com áudio: use o container alternativo em `.devcontainer.assistant/`

## Scripts úteis
- `npm run codex:plan` — plano granular (dry‑run) usando Codex do repo
- `npm run codex:patch` — aplicar diffs mínimos (pedir aprovação em deleções)
- `npm run codex:pr` — cria branch/commit (abra PR via UI)
- `npm run codex:hc` — healthcheck rápido do combo

## Comandos
- Rodar app: `make app` (porta 3300)

## IA (Codex CLI + MCP)
- Use Ripgrep para localizar (com exclusões), Filesystem para editar, Playwright para smokes.
- Exemplo: `codex -C ./.codex/config.toml exec --skip-git-repo-check "/mcp"`
