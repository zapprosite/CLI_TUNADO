# Plano Perfeito Full‑Stack — Replit‑like + Agent (DEVOPS Senior)

Objetivo: iniciar um projeto full‑stack do zero, sem escrever código manualmente, operando como humano líder (DEVOPS Senior) com apoio de um tutor GPT‑o3. O tutor produz PRD e prompts; o Codex (com MCPs) implementa, gera PRs e executa smokes. O foco é um devloop “Replit‑like”: editar/rodar instantâneo, com DX elevada e o mínimo necessário para PRs sólidos.

— Não codar; apenas orquestrar —

## Princípios
- Edit → Run instantâneo: levantar e validar em segundos.
- Automação via agente: gerar código, testes, docs e PRs.
- Lean first: começar mínimo; adicionar só quando medido/necessário.
- Observabilidade pragmática: logs estruturados e healthchecks desde o dia 1.
- Portabilidade: tudo roda local e em container.
- Segurança básica: segredos fora de VCS; variáveis por ambiente.

## Alvo técnico (MVP 1)
- Backend: Node 20 LTS, TypeScript, Fastify, Pino, Zod, Dotenv. Endpoints: `/healthz`, `/api/todos` (CRUD em memória v1, SQLite via Prisma no v2).
- Frontend: Vite + React + TS, UI mínima (lista/adiciona TODOs).
- DB (v2): SQLite + Prisma (migrate + seed).
- Testes: Vitest (unit), Playwright (e2e smoke).
- DevLoop: Makefile + npm scripts, DevContainer com Playwright, Codex CLI + MCPs (filesystem, ripgrep, memory, playwright).
- CI mínimo (v2): lint+build+test em pull_request.

## Estrutura de diretórios (proposta)
- apps/
  - api/ (Fastify, TS)
  - web/ (Vite React TS)
- .codex/ (config Codex + MCP)
- .devcontainer/ (Node 20 + setup Playwright)
- .vscode/ (settings + tasks)
- docs/ (painel de atalhos + PRD)
- Makefile
- README.md

## Perfis e portas
- API: porta 3300
- WEB: porta 5173
- NODE_ENV: development por padrão

## Fluxo operacional (Orquestrador full‑auto 2025)
- Modo base (seguro): aprovação on‑request; patches mínimos; sanity + smoke.
- Modo full‑auto (autorizado): `codex --dangerously-bypass-approvals-and-sandbox` com guardrails (archive/; sem deleções permanentes).

1) PRD curto (ou TASK) é fornecido ao orquestrador (prompts/orquestrador-system.md).
2) Orquestrador mapeia (Ripgrep), aplica patches (Filesystem), registra decisões (Memory → docs/decisions.md).
3) Valida: `make sanity` e, se houver UI, `make codex-smoke` (Playwright MCP).
4) Documenta: README + docs/painel.html + decisions log.
5) Full‑auto noturno: `make codex-orq-nightly` cria branch, executa rodada, salva logs e (opcional) notifica.

## Definição de Pronto (DoD) por fase
- Código e configs presentes e mínimos para rodar localmente.
- `make sanity` passa; `/healthz` responde 200.
- README atualizado com como rodar.
- E2E smoke básico (Playwright) verde.
- PR com título, descrição e checklist de verificação.

---

# Fase 0 — Bootstrap do Workspace (sem código de produto)
Objetivo: preparar ambiente Replit‑like + Agent.

Entregáveis:
- .devcontainer (Node 20 + postCreate Playwright)
- .vscode (settings + tasks: App Start, MCP status)
- .codex/config.toml (filesystem, ripgrep, memory, playwright)
- Makefile com alvos essenciais: api, web, dev, sanity, codex-*.
- docs/painel.html com atalhos (copiar em 1 clique)

Aceitação:
- `make sanity` mostra Node/npm e `/healthz` OK após fases 1/2.
- `make codex-mcp` lista MCPs do workspace.

Prompt Pack (para Codex):
- “Crie .devcontainer/devcontainer.json (Node 20, common-utils), postCreate executa .devcontainer/setup.sh com `npx playwright install --with-deps`.
- Crie .vscode/settings.json e tasks.json com tasks: App: Start (make dev), Codex: MCP status, Codex: Abrir chat.
- Crie .codex/config.toml com mcp_servers: filesystem, ripgrep, memory, playwright; profile 2025.
- Crie Makefile com alvos: api, api-bg, api-stop, api-log; web, web-bg, web-stop, web-log; dev (concurrently api+web); sanity; codex-mcp/smoke/plan/patch.
- Crie docs/painel.html com categorias Makefile, Codex, VS Code, Git, Ripgrep e ‘Outro Repo’. Preencha comandos de uso rápido. Não adicionar CI/infra nesta fase.”

---

# Fase 1 — Backend API mínima (Fastify + TS)
Objetivo: API com `/healthz` e esqueleto `/api/todos` (in-memory).

Entregáveis:
- apps/api/ com Fastify + TS
- Scripts npm: dev, build, start
- Logger Pino, validação Zod
- Roteadores: GET /healthz, CRUD básico /api/todos (em memória)
- Testes Vitest unitários (1–2 specs) e Playwright smoke contra `/healthz`

Aceitação:
- `make api` sobe em 3300
- `curl :3300/healthz` → 200 { ok: true }
- Vitest verde; smoke Playwright verde

Prompt Pack:
- “Gerar projeto em apps/api com TypeScript, tsconfig strict, Fastify, Pino, Zod e Dotenv. Endpoints: GET /healthz (ok:true); CRUD em memória /api/todos {id, title, done}. Incluir scripts npm: dev (tsx), build (tsc), start (node dist). Incluir `npm i -D vitest tsx @types/node` e testes básicos. Exportar `APP_PORT=3300`. Atualizar Makefile com alvo api que executa `npm run dev` dentro de apps/api.”

---

# Fase 2 — Frontend Web mínima (Vite + React + TS)
Objetivo: UI consumindo `/api/todos`.

Entregáveis:
- apps/web/ com Vite React TS
- Página única: lista e adiciona TODOs (fetch API)
- Scripts npm: dev, build, preview
- Proxy dev para API em 3300

Aceitação:
- `make web` sobe em 5173
- UI carrega e chama API
- Smoke Playwright: visitar /, validar título e elemento principal

Prompt Pack:
- “Criar apps/web com `npm create vite@latest` (template react-ts). Configurar proxy Vite para `/api` → http://localhost:3300. Implementar página com fetch de `/api/todos` e formulário de inclusão. Scripts dev/build/preview. Adicionar teste e2e mínimo Playwright (opcional nesta fase). Ajustar Makefile: alvo web roda `npm run dev` em apps/web.”

---

# Fase 3 — Persistência (Prisma + SQLite)
Objetivo: trocar memória por SQLite via Prisma.

Entregáveis:
- Prisma schema (Todo)
- Migrations e seed
- Repositório em apps/api refatorado para Prisma Client
- Scripts: `prisma migrate dev`, `db:seed`

Aceitação:
- CRUD persistente funcionando
- Seeds inseridos em `make dev` inicial

Prompt Pack:
- “Adicionar Prisma no monorepo (apps/api): schema Todo {id Int @id @default(autoincrement), title String, done Boolean}. Configurar datasource sqlite file:./dev.db. Implementar repositório Prisma. Ajustar rotas CRUD para usar Prisma. Incluir scripts migrate/seed e invocar seed no start de dev. Atualizar README e Makefile com `db:reset`.”

---

# Fase 4 — Testes, Qualidade e Smokes
Objetivo: padronizar testes e lint.

Entregáveis:
- Vitest configurado para api e web
- Playwright E2E (smoke /, e CRUD básico)
- ESLint + Prettier (config leve)

Aceitação:
- `npm test` verde em ambas apps
- `make sanity` e `make codex-smoke` verdes

Prompt Pack:
- “Configurar Vitest (tsx) em apps/api e apps/web com 1–2 testes. Configurar Playwright com spec que abre http://localhost:5173, valida título e fluxo simples. Adicionar ESLint e Prettier com configs padrão. Atualizar Makefile: alvo test, e2e.”

---

# Fase 5 — CI mínimo (opcional no MVP local)
Objetivo: garantir PRs com qualidade.

Entregáveis:
- .github/workflows/ci.yml: node 20, cache deps, lint, build, test
- Badge de status no README

Aceitação:
- CI executa em pull_request e main

Prompt Pack:
- “Adicionar workflow GitHub Actions com jobs: install, lint, build, test para api e web. Habilitar cache de node_modules. Adicionar badge no README.”

---

# Fase 6 — Observabilidade pragmática
Objetivo: logs estruturados e health.

Entregáveis:
- Pino logger com request id
- /metrics (placeholder) ou logs de métricas simples

Aceitação:
- Logs JSON por request, conteudo mínimo de performance

Prompt Pack:
- “Configurar Pino no Fastify com requestId e serializers. Adicionar middleware de tempo de resposta. Não incluir stack de Prometheus/Grafana nesta fase; apenas preparar ganchos.”

---

# Fase 7 — DX extra (Painel + Makefile + Orquestrador)
Objetivo: experiência Replit‑like com atalhos.

Entregáveis:
- docs/painel.html completo com categorias e copiar, incluindo cartões de orquestração (base/PRO/nightly)
- Makefile consistente para api/web/dev/test/e2e/sanity + codex‑mcp/mcp‑pro + orq/orq‑nightly

Aceitação:
- Painel facilita uso sem decorar comandos

Prompt Pack:
- “Atualizar painel com atalhos para api/web/dev/test/e2e/sanity/codex, incluir cartões ‘Codex: Orquestrador (full‑auto)’ e ‘MCPs (PRO)’. Garantir 100% de correspondência com Makefile.”

---

# Fase 8 — Entrega/Run remoto (opcional) e Notificações
Objetivo: preview remoto simples.

Opções (escolher 1):
- Docker Compose local + Nginx (reverse proxy)
- Fly.io (procfile) ou Render
- GitHub Codespaces (porta publicada)

Prompt Pack:
- “Containerizar api e web com Dockerfiles leves, Compose para dev. Não adicionar banco remoto nesta fase. Adicionar script `scripts/notify.sh` para Slack/Discord (via SLACK_WEBHOOK/DISCORD_WEBHOOK no .env) e Makefile chamando notificação ao final de `codex-orq-nightly`.”

---

# Segurança e Segredos (baseline)
- `.env` local, `.env.example` versionado
- Nunca commitar `.env` real
- Validar variáveis obrigatórias na inicialização (Zod)

---

# Branching, PRs e Revisão
- Branch naming: `feat/`, `fix/`, `chore/`, `docs/`
- Commits convencionais (conventional commits)
- PR template: descrição, checklist, screenshots, como testar
- Critérios de merge: CI verde, smokes ok, revisão 1+ pessoa

PR Checklist (copiar para descrição):
- [ ] `make dev` ok (api 3300, web 5173)
- [ ] `/healthz` 200
- [ ] `npm test` verde
- [ ] Smoke Playwright verde
- [ ] README atualizado

---

# Scripts/Comandos esperados (Makefile)
- `make api` / `make api-bg` / `make api-stop` / `make api-log`
- `make web` / `make web-bg` / `make web-stop` / `make web-log`
- `make dev` (api+web em paralelo)
- `make test` / `make e2e` / `make sanity`
- `make codex-mcp` / `make codex-mcp-pro` / `make codex-smoke`
- `make codex-orq` (TASK="...") / `make codex-orq-nightly`

---

# Como usar o Tutor GPT‑o3 / Orquestrador de forma eficiente
- Sempre forneça PRD curto, objetivo e com critérios claros.
- Peça “patches mínimos”, mantenha o estilo existente e atualize README.
- Exija smokes automáticos e instruções de verificação manual.
- Proíba deleções perigosas sem aprovação.

Exemplo de PRD curto (para Fase 1 – API):
- Problema: precisamos de API mínima com `/healthz` e CRUD `/api/todos` (memória) em Node 20 + TS.
- Resultado: Fastify + TS, Pino, Zod; scripts dev/build/start; testes Vitest; Makefile atualizado (api, sanity).
- Critérios: `make api` e `curl :3300/healthz` retornam 200; `npm test` verde; README com “Como rodar”.
- Constraint: sem banco, sem CI por enquanto.

Prompt ao Codex (exemplo, full‑auto):
“Use os MCPs do workspace para implementar a Fase 1. Faça patches mínimos, atualize README, crie testes Vitest e um smoke Playwright. Valide com `make sanity`. Anexe logs no sumário. Se houver remoções, use archive/<data>-poda/. Abra commit com conventional message. PRD: <colar PRD curto>.”

---

# Verificação rápida (antes de abrir PR)
- `make dev` → abrir http://localhost:5173 (web) e `curl :3300/healthz`
- `npm test` em apps/api e apps/web
- `make codex-smoke` (Playwright MCP) — retorna TITLE/URL
- `make codex-orq` (TASK de validação) — sumário da rodada
- Conferir painel em `docs/painel.html`

---

# Próximos passos (Roadmap após MVP)
- Auth (JWT ou session) + usuários
- Feature flags (env)
- Telemetria opcional (OpenTelemetry) com export OTLP
- Deploy contínuo (CI/CD) e ambientes (dev/stg/prod)
- Banco real (Postgres) e migração de dados

---

# TL;DR (coloque no topo do README do novo projeto)
- Requisitos: Node 20+, Codex CLI
- Rodar local: `make dev` (api:3300, web:5173)
- Smokes: `make sanity` e `make codex-smoke`
- Agente: `codex mcp list`
- Painel: abrir `docs/painel.html`
