# Plano Perfeito Full-Stack — Replit-like + Agent (DEVOPS Senior) + PyGPT (voz/IA/computer-use)

Objetivo: iniciar um projeto full-stack do zero, sem escrever código manualmente, operando como humano líder (DEVOPS Senior) com apoio de um tutor GPT‑o3. O tutor produz PRD e prompts; o Codex (com MCPs) implementa, gera PRs e executa smokes. O foco é um devloop “Replit-like”: editar/rodar instantâneo, com DX elevada e o mínimo necessário para PRs sólidos.
Extensão: incorporar PyGPT-like (STT→LLM→Ação) para controlar o SO por voz, com anti-alucinação (Context7), memória (Memory-Bank) e orquestração via MCPs (Filesystem, Ripgrep, Playwright, GitHub, CircleCI; opcional Kubernetes; opcional Qdrant).

— Não codar; apenas orquestrar —

## Princípios
- Edit → Run instantâneo: levantar e validar em segundos.
- Automação via agente: gerar código, testes, docs, PRs e ações de computador por voz.
- Lean first: começar mínimo; adicionar só quando medido/necessário.
- Observabilidade pragmática: logs estruturados e healthchecks desde o dia um.
- Portabilidade: tudo roda local e em container.
- Segurança básica: segredos fora de VCS; variáveis por ambiente.
- Anti-alucinação obrigatória: sempre consultar Context7 ao usar APIs/libs.

## Alvo técnico (MVP 1)
- Backend: Node 20 LTS, TypeScript, Fastify, Pino, Zod, Dotenv. Endpoints: `/healthz`, `/api/todos` (CRUD memória v1, SQLite+Prisma v2).
- Frontend: Vite + React + TS (lista/adiciona TODOs).
- DB (v2): SQLite + Prisma (migrate+seed).
- Testes: Vitest (unit), Playwright (e2e smoke).
- DevLoop: Makefile + npm scripts, DevContainer com Playwright, Codex CLI + MCPs (filesystem, ripgrep, memory, playwright).
- CI mínimo (v2): lint+build+test em pull_request.
- PyGPT-like (voz/IA):
  - STT: Vosk ou Whisper local.
  - TTS: Piper.
  - LLM: GPT Enterprise (primário) com fallback Ollama.
  - Executores: PyAutoGUI/xdotool (computer-use).
  - Memória: Memory-Bank por projeto (decisões/rotas/credenciais de teste).
  - RAG opcional: Qdrant (documentos do repo).

## Estrutura de diretórios (proposta)
- apps/
  - api/ (Fastify, TS)
  - web/ (Vite React TS)
- agents/
  - assistant/ (PyGPT-like: stt/, tts/, intent/, orchestrator/, executors/)
- .codex/ (config Codex + MCP)
- .devcontainer/ (Node 20 + setup Playwright; python toolchain para assistant)
- .vscode/ (settings + tasks)
- docs/ (painel de atalhos + PRD + voice/README_assistant.md)
- Makefile
- README.md

## Perfis e portas
- API: porta 3300
- WEB: porta 5173
- NODE_ENV: development por padrão

## Fluxo operacional (Orquestrador full-auto 2025)
- Modo base (seguro): aprovação on-request; patches mínimos; sanity + smoke.
- Modo full-auto (autorizado): `codex --dangerously-bypass-approvals-and-sandbox` com guardrails (archive/; sem deleções permanentes).
- Integrações MCP: Filesystem, Ripgrep, Memory-Bank, Playwright, Context7, GitHub MCP, CircleCI MCP; (opcional) Kubernetes MCP; (opcional) Qdrant.

Passos:
- 1) PRD curto (ou TASK) é fornecido ao orquestrador (`prompts/orquestrador-system.md`).
- 2) Orquestrador mapeia (Ripgrep), aplica patches (Filesystem), registra decisões (Memory → `docs/decisions.md`).
- 3) Valida: `make sanity` e, se houver UI, `make codex-smoke` (Playwright MCP).
- 4) Documenta: README + `docs/painel.html` + decisions log.
- 5) Full-auto noturno: `make codex-orq-nightly` cria branch, executa rodada, salva logs e (opcional) notifica.

## Provedores LLM (primário + fallback local GPU)
- Primário: `gpt-5` (alta qualidade para plano/patch críticos).
- Fallback/local (4090 + Ollama): usar modelos otimizados para código e raciocínio rápido.
  - Sugestões (2025, ajustar ao seu host):
    - `qwen2.5-coder:14b` (ou 7b) — bom em código; cabe em 4090 com quantização.
    - `deepseek-coder-v2:16b` (ou 7b) — foco em coding; avaliar latência.
    - `llama3.1:8b-instruct` — rápido para tarefas gerais.
  - Uso no Codex (oss provider):
    - `codex --oss -c model="qwen2.5-coder:14b" exec "<prompt>"`
    - Híbrido: usar `gpt-5` para patchs finais e `--oss` para iterações rápidas.
  - Assistant: configurar Ollama como fallback no módulo `agents/assistant/intent`.

## GPU STT/TTS (baixa latência)
- STT: `faster-whisper` (CTRanslate2 com CUDA) ou `whisper-cpp` com CUDA; VAD (webrtcvad) e cache incremental.
- TTS: `piper` (pt-BR/en-US) com pré-carregamento do modelo.
- Dependências típicas (devcontainer/host): `ffmpeg`, `portaudio`, `libasound2-dev`, `pulseaudio`

## Definição de Pronto (DoD) por fase
- Código e configs presentes e mínimos para rodar localmente.
- `make sanity` passa; `/healthz` responde 200.
- README atualizado com como rodar.
- E2E smoke básico (Playwright) verde.
- PR com título, descrição e checklist de verificação.
- Para assistant: comando de voz básico reconhecido e executado com confirmação.

---

# Fase 0 — Bootstrap do Workspace (sem código de produto)

Objetivo: preparar ambiente Replit-like + Agent e base do assistant.

Entregáveis:
- .devcontainer (Node 20 + postCreate Playwright; Python eportaudio/libs para STT/TTS).
- .vscode (settings + tasks: App Start, MCP status, Assistant Start).
- `.codex/config.toml` (filesystem, ripgrep, memory, playwright, context7, github, circleci; k8s e qdrant opcionais).
- Makefile com alvos essenciais: api, web, dev, sanity, codex-*.
- `docs/painel.html` (atalhos em um clique).
- `agents/assistant` esqueleto vazio (poetry/requirements.txt, `assistant.py` placeholder).

Aceitação:
- `make sanity` mostra Node/npm e `/healthz` OK após fases 1/2.
- `make codex-mcp` lista MCPs do workspace.
- `make assistant-check` imprime versões de STT/TTS/LLM configuráveis (sem rodar pipeline).

Prompt Pack (para Codex):
- “Crie `.devcontainer/devcontainer.json` (Node 20 + common-utils) e `postCreate` executa `.devcontainer/setup.sh` com `npx playwright install --with-deps` e instala dependências Python (vosk/whisper-cpp opcional, piper, pyautogui, xdotool).
- Crie `.vscode/settings.json` e `tasks.json` com tasks: App: Start (make dev), Codex: MCP status, Assistant: Start (python agents/assistant/assistant.py), Codex: Abrir chat.
- Atualize `.codex/config.toml` incluindo MCPs: filesystem, ripgrep, memory, playwright, context7, github, circleci (k8s e qdrant opcionais).
- Crie Makefile com alvos: api, api-bg, api-stop, api-log; web, web-bg, web-stop, web-log; dev (concurrently api+web); sanity; codex-mcp/smoke/plan/patch; assistant-check/assistant-dev.
- Crie `docs/painel.html` com categorias Makefile, Codex, VS Code, Git, Ripgrep, Assistant e ‘Outro Repo’. Não adicionar CI/infra nesta fase.”

---

# Fase 1 — Backend API mínima (Fastify + TS)

(igual ao plano base)

---

# Fase 2 — Frontend Web mínima (Vite + React + TS)

(igual ao plano base)

---

# Fase 3 — Persistência (Prisma + SQLite)

(igual ao plano base)

---

# Fase 4 — Testes, Qualidade e Smokes

(igual ao plano base)

---

# Fase 5 — CI mínimo (opcional no MVP local)

(igual ao plano base)

---

# Fase 6 — Assistant (PyGPT-like) Voz→LLM→Ação

Objetivo: habilitar controle por voz com confirmação e anti-alucinação.

Entregáveis (em `agents/assistant/`):
- `stt/` (Vosk ou Whisper local) + hotword/ativação simples.
- `tts/` (Piper).
- `intent/` (roteamento → ação; LLM GPT Enterprise primário com fallback Ollama).
- `orchestrator/` (pipeline voz→texto→intenção→Context7→ação; confirmação antes de operações destrutivas).
- `executors/` (PyAutoGUI/xdotool: abrir app, focar janela, digitar, clicar; macros básicas).
- `config/` (`assistant.yaml` com thresholds, microfone, idioma).
- `voice/README_assistant.md` (setup+uso).
- Integração Memory-Bank (decisões, rotas, presets de teste).
- (Opcional) Qdrant para RAG de manuais do projeto.

Aceitação:
- Rodar `make assistant-dev`: reconhecer comando de voz “abrir navegador”, perguntar confirmação, abrir app e registrar no Memory-Bank.
- Comando ambíguo → pergunta de esclarecimento.
- Qualquer uso de API/lib → citando doc via Context7 (log no console).

Prompt Pack:
- “Criar `agents/assistant/` com módulos `stt/`, `tts/`, `intent/`, `orchestrator/`, `executors/`, `config/assistant.yaml`.
- STT: Vosk por padrão; Whisper local opcional (flag).
- TTS: Piper com voz en-US ou pt-BR (config).
- Intent/LLM: GPT Enterprise (primário) com fallback via Ollama (modelo leve).
- Orquestrador: sempre consultar Context7 quando a ação envolver APIs/libs; se risco, solicitar confirmação por voz; registrar decisões/rotas em Memory-Bank.
- Executors: expor ações `open_app`, `focus_window`, `type_text`, `click(x,y)`, `shortcut(meta,…)`; usar PyAutoGUI/xdotool.
- Adicionar `make assistant-dev` (roda o assistant em modo dev) e `make assistant-check` (diagnóstico).
- Atualizar `docs/voice/README_assistant.md` com setup, exemplos de comandos e troubleshooting.”

---

# Fase 7 — DX extra (Painel + Makefile + Orquestrador)

(igual ao plano base; acrescente cartões do Assistant no painel e tasks no Makefile)

---

# Fase 8 — Entrega/Run remoto (opcional) e Notificações

(igual ao plano base)

---

## Segurança e Segredos (baseline)
- `.env` local, `.env.example` versionado; nunca commitar `.env`.
- Validar variáveis obrigatórias na inicialização (Zod).
- Assistant: confirmar por voz antes de ações críticas; sem auto-approve para operações destrutivas.

## Branching, PRs e Revisão
- Branch naming: `feat/`, `fix/`, `chore/`, `docs/`.
- Commits convencionais.
- PR template: descrição, checklist, screenshots, como testar (inclua “voz”).
- Merge: CI verde, smokes ok, teste de voz básico ok, revisão 1+ pessoa.

PR Checklist (expandido):
- [ ] `make dev` ok (api 3300, web 5173)
- [ ] `/healthz` 200
- [ ] `npm test` verde
- [ ] Smoke Playwright verde
- [ ] Assistant: `make assistant-dev` executa comando “abrir navegador” com confirmação e log em Memory-Bank
- [ ] README atualizado

## Scripts/Comandos esperados (Makefile)
- `make api` / `api-bg` / `api-stop` / `api-log`
- `make web` / `web-bg` / `web-stop` / `web-log`
- `make dev` (api+web em paralelo)
- `make test` / `make e2e` / `make sanity`
- `make codex-mcp` / `make codex-mcp-pro` / `make codex-smoke`
- `make codex-orq` (TASK="...") / `make codex-orq-nightly`
- `make assistant-check` / `make assistant-dev`

## Como usar o Tutor GPT‑o3 / Orquestrador
- PRD curto, objetivo, com critérios claros.
- Pedir patches mínimos, manter estilo existente, atualizar README.
- Exigir smokes automáticos, instruções de verificação manual e demonstração de voz.
- Proibir deleções perigosas sem aprovação.

Exemplo de PRD curto (Fase 6 – Assistant):
- Problema: habilitar controle por voz com confirmação e anti-alucinação.
- Resultado: STT (Vosk), TTS (Piper), LLM (GPT Enterprise + fallback Ollama), Context7, executores PyAutoGUI/xdotool, Memory-Bank.
- Critérios: `make assistant-dev` reconhece “abrir navegador”, confirma e executa; logs citam doc de API via Context7; grava decisão no Memory-Bank.
- Constraint: tudo local; sem nuvem para STT/TTS.

Prompt ao Codex (full-auto para Fase 6):
“Implemente a Fase 6 (Assistant) usando MCPs do workspace. Patches mínimos. Para cada uso de API/lib, chame Context7 e cite versão/trecho. Orquestrador deve confirmar por voz antes de ações destrutivas. Exponha `make assistant-check` e `make assistant-dev`. Registre decisões/rotas no Memory-Bank. Valide com um comando de voz (‘abrir navegador’) e devolva logs + passos de verificação.”

---

## Verificação rápida (antes de abrir PR)
- `make dev` → abrir http://localhost:5173 e `curl :3300/healthz`
- `npm test` em apps/api e apps/web
- `make codex-smoke` (Playwright) — retorna TITLE/URL
- `make assistant-dev` — comando de voz básico com confirmação e log
- `make codex-orq` (TASK de validação) — sumário da rodada
- Conferir painel em `docs/painel.html`

## Próximos passos (Roadmap após MVP)
- Auth (JWT ou session) + usuários
- Feature flags (env)
- Telemetria opcional (OpenTelemetry) com export OTLP
- Deploy contínuo (CI/CD) e ambientes (dev/stg/prod)
- Banco real (Postgres) e migração de dados

## TL;DR (README topo)
- Requisitos: Node 20+, Codex-CLI, Python (para assistant)
- Rodar local: `make dev` (api:3300, web:5173)
- Smokes: `make sanity` e `make codex-smoke`
- Assistant: `make assistant-dev`
- Agente: `codex -C ./.codex/config.toml exec "/mcp"`
- Painel: `docs/painel.html`
