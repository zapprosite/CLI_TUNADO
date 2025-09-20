Title: chore/poda — Replit‑like + Agent (mínimo essencial)

Summary
- Descreva em 1–2 frases o objetivo desta PR (poda segura para stack mínima, sem quebrar o que funciona).

Motivação
- Por que esta poda é necessária agora? Qual dor/addressed (DX, velocidade, custo)?

Mudanças (alto nível)
- App/DevLoop: (ex.: hello app, /healthz, Makefile mínimo)
- DevContainer/VS Code: (ex.: Node 20, postCreate Playwright, tasks)
- Codex/MCP: (ex.: filesystem, ripgrep, memory, playwright)
- Docs/Painel: (ex.: atalhos existentes, remoção de órfãos)
- Archive: itens movidos (onde/por quê)

Como testar (passo a passo)
1. make sanity (ver Node/npm e /healthz OK)
2. make app (abrir http://localhost:3300) ou make live
3. codex -C ./.codex/config.toml exec "/mcp" (listar MCPs)
4. Opcional: make codex-smoke APP_PORT=3300 (Playwright MCP retorna TITLE/URL)

Riscos e mitigação
- Riscos identificados e como foram mitigados (ex.: uso de archive/, verificação de referências com ripgrep, sanity antes/depois).

Screenshots/Logs (se aplicável)
- Anexe outputs de sanity e smoke para auditoria rápida.

Checklist (obrigatório)
- [ ] make sanity OK (log incluído)
- [ ] Smoke Playwright OK (se aplicável)
- [ ] Painel sem atalhos órfãos (apenas Makefile/úteis)
- [ ] README atualizado (“Como rodar agora”, “MCPs”)
- [ ] Tudo não‑essencial movido para archive/ com justificativa
- [ ] Sem deleções irreversíveis nesta PR

Compatibilidade / Breaking Changes
- Esta PR introduz breaking changes? Se sim, documente migração.

Referências
- Issues/ADRs/Docs relacionados (links)

