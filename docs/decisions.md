# Decisions Log

Este arquivo registra decisões relevantes do projeto (DX, padrões, tooling) para dar contexto futuro.

## 2025-09-20 — Poda segura (vestígios na raiz)
- Decisão: mover itens não-essenciais/vestigiais da raiz para `archive/20250920-poda/` (sem deleções), mantendo apenas o devloop mínimo (hello-app), full‑stack em `apps/` (api/web), MCPs e Assistant.
- Itens movidos: `infra/`, `observability/`, `reports/`, `src/` (vazio) e `sys` (arquivo grande).
- Sanidade revalidada: `make sanity` OK após a poda.
- Próximo: manter Prompt de Poda seguro no repo (`prompts/poda-segura-voz.md`) e alinhar voice assistant (Ubuntu, mic) com STT/TTS opcionais.

## 2025-09-19 — Poda segura e unificação de MCPs
- Decisão: MCPs definidos apenas no workspace `.codex/config.toml` (fonte única). `codex mcp list` pode não refletir MCPs do workspace; usamos `codex -C ./.codex/config.toml exec "/mcp"` para listar.
- Poda: itens vazios/non-essenciais movidos para `archive/20250919-poda/` (sem deleções).
- Sanidade: `make sanity` passa; `/healthz` ok.
- Painel/Docs: alinhados ao Makefile; remoção de atalhos órfãos.

## 2025-09-19 — Servidor Node (CJS vs ESM)
- Decisão: entrada do hello-app em `.cjs` para compatibilidade com `"type": "module"` no package.json.
- Impacto: Makefile atualizado para `server.cjs` em app/live/codex-smoke/sanity.

## 2025-09-19 — Orquestrador PRO
- Documento `orquestrador-pro.md` criado: políticas de memória, ferramentas MCP e prompts de sistema/execução.
- Próximos MCPs (opcionais, workspace): Git/HTTP após avaliação.

## 2025-09-19 — Config PRO e Orquestração
- Adicionado `.codex/config.pro.toml` (PRO) com MCPs essenciais iguais ao base e entradas OPCIONAIS comentadas (git/http/sqlite).
- Makefile: novos alvos `codex-mcp-pro` e `codex-orq` (full-auto com prompt `prompts/orquestrador-system.md`).
- Painel: cartões para MCPs PRO e Orquestrador full-auto.
