# Guia da Equipe — Zappro (Set/2025)

Este guia resume como usar o DevLoop “Replit‑like” deste repositório, como rodar localmente, validar, usar o painel de atalhos, e (opcional) trabalhar com o Assistant de voz. No final há um passo‑a‑passo para separar em 2 repositórios e publicar no GitHub.

## O que é
- DevLoop mínimo focado em editar/rodar rápido no VS Code.
- Apps:
  - Hello (Node): `apps/hello-app/server.cjs` (porta 3300, `/healthz`).
  - API v2 (Fastify + Prisma/SQLite): `apps/api` (porta 3400, CRUD `/api/todos`).
  - Web (Vite/React): `apps/web` (porta 5173, usa `VITE_API_URL`).
- Painel de atalhos (desktop): abra `docs/painel.html`.
- Assistant de voz (opcional): `agents/assistant` (CLI texto; STT/TTS opcionais).

## Pré‑requisitos
- Node 20+, Git e VS Code.
- Opcional: Codex CLI (para MCPs), Playwright instalado (o DevContainer instala os browsers best‑effort).

## Comece em 3 passos (CLI_TUNADO)
1) VS Code: abra a pasta `CLI_TUNADO`. Se puder, use DevContainer (Rebuild and Reopen in Container).
2) Hello (3300): `make app` e teste `curl http://localhost:3300/healthz`.
3) Painel: abra `docs/painel.html` para atalhos rápidos.

## Fluxos comuns
- Apenas Hello (3300):
  - `make app` (foregroud) ou `make live` (auto‑reload) ou `make app-bg`/`app-stop` (bg).
- API (3400) + Web (5173):
  - `make api-setup` (deps + Prisma/SQLite), `make api`.
  - `cd apps/web && cp .env.local.example .env.local` (ajuste `VITE_API_URL=http://localhost:3400` se preciso), `make web`.
  - Tudo junto em bg: `make dev` (hello+api+web); parar: `make kill-all`.
- Validação rápida: `make sanity` (Node/npm + `/healthz`).
- Validação completa: `make sanity-deep` (API CRUD, web preview, hello health, assistant check).
- Codex/MCP (workspace `.codex/config.toml`):
  - Listar MCPs: `make codex-mcp`.
  - Smoke web com Playwright MCP: `make codex-smoke APP_PORT=3300`.

## Assistant (repo separado)
- Repositório: https://github.com/zapprosite/Ubuntu_Alexa
- Local: `/data/Ubuntu_Alexa` (ou clone onde preferir)
- Comandos:
  - `make install` — cria `.venv` e instala dependências
  - `make assistant-check` — diagnóstico de ambiente/pacotes/env
  - `make assistant-dev` — inicia o assistant em modo texto
  - STT/TTS opcionais via `config/assistant.yaml`

## Notificações (opcional)
- Configure webhooks no `.env` (copie de `.env.example`).
- Teste: `make notify-test`.

## Solução de problemas
- Porta em uso: ajuste `APP_PORT`, `WEB_PORT`, `WEB_PREVIEW_PORT` nos alvos do Make.
- API falha na migração: rode `make api-db-reset` (DANGER: apaga dados locais), depois `make api-setup`.
- Playwright MCP reclama de browsers: rode `npx playwright install --with-deps`.

---

## (Histórico) Como foi separado em 2 repositórios
O assistant foi extraído via `git subtree split` para manter histórico, e os dois repos foram publicados no GitHub. Use este procedimento apenas como referência futura.

Nomes sugeridos
- DevLoop: `zappro-devloop`
- Assistant: `zappro-assistant`

Pré‑passos (GitHub)
- Crie os repositórios vazios no GitHub e anote as URLs (ex.: `git@github.com:sua-org/zappro-assistant.git` e `git@github.com:sua-org/zappro-devloop.git`).

### Opção A — Recomendado (preserva histórico do Assistant) com git subtree
Executar a partir da raiz deste repo:

1) Criar branch com histórico apenas de `agents/assistant`:
```
git fetch --all --prune
git branch -D assistant-split 2>/dev/null || true
git subtree split --prefix=agents/assistant -b assistant-split
```
2) Criar repo local do Assistant e puxar o histórico split:
```
mkdir -p ../zappro-assistant && cd ../zappro-assistant
git init
git pull ../ide-zappro assistant-split
```
3) Ajustes mínimos e push:
```
# (opcional) Atualize README para contexto próprio
git remote add origin git@github.com:sua-org/zappro-assistant.git
git branch -M main
git push -u origin main
```
4) Volte ao repo original e remova a pasta do Assistant em um commit dedicado (para o DevLoop):
```
cd -  # volta ao repo original
git checkout -b chore/split-assistant
git rm -r agents/assistant
git commit -m "chore(split): extrai assistant para repo próprio"
```
5) Configure o remoto do DevLoop e faça push:
```
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:sua-org/zappro-devloop.git
git branch -M main
git push -u origin main
```
Notas
- O DevLoop preserva todo o histórico (incluindo commits antigos do assistant). Se quiser remover o histórico do assistant do DevLoop, use a Opção B.

### Opção B — Avançada (remove histórico do Assistant do DevLoop) com git filter-repo
Requer `git filter-repo` instalado (não vem por padrão). Use somente se você precisa excluir o histórico do `agents/assistant` no DevLoop.

1) Faça um clone novo para não arriscar o original:
```
cd ..
git clone --no-local /data/ide-zappro zappro-devloop
cd zappro-devloop
```
2) Rode o filtro para remover `agents/assistant` do histórico:
```
git filter-repo --path agents/assistant --invert-paths
```
3) Configure remoto e push:
```
git remote add origin git@github.com:sua-org/zappro-devloop.git
git branch -M main
git push -u origin main
```
O repositório do Assistant você cria pela Opção A (subtree) ou com `git filter-repo --path agents/assistant` em outro clone.

### Opção C — Rápida (sem histórico granular do Assistant)
1) Crie uma pasta fora do repo, copie `agents/assistant/` para lá, `git init`, `git add -A && git commit -m "init"`, e faça push para `zappro-assistant`.
2) No repo original, remova `agents/assistant` numa branch e faça push para `zappro-devloop`.

### Checklist pós‑split
- DevLoop (repo novo)
  - Remover referências ao assistant em README/painel/Makefile se existirem.
  - Validar `make sanity` e `make sanity-deep`.
  - CI: `apps/api` e `apps/web` continuam buildando.
- Assistant (repo novo)
  - Garantir `make assistant-check` funciona (ou scripts equivalentes).
  - Ajustar README e, se quiser, mover somente o necessário do Makefile.

Dica: mantenha ambos os READMEs com “Como rodar agora”, “Sanidade”, “MCPs/Dependências” e links cruzados.
