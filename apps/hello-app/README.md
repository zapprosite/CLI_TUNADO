# Hello App (scaffold mínimo)

Servidor HTTP nativo (sem dependências externas) para smoke tests via Playwright MCP.

## Requisitos
- Node.js 18+

## Executar
```sh
PORT=3300 node apps/hello-app/server.js
# Abra:   http://localhost:3300/
# Saúde:  http://localhost:3300/healthz
```

## Smoke (Codex + Playwright MCP)
```sh
codex exec --skip-git-repo-check -s workspace-write \
  "Using Playwright MCP only, open http://localhost:3300 and return one line: TITLE=<document.title> URL=<page.url>."
```

## Estrutura
```
apps/hello-app/
  ├─ public/
  │  └─ index.html   # título "Hello App", main[role=main]
  └─ server.js       # GET /healthz → { ok: true }, serve index.html
```

## Notas
- Porta `3000` está em uso por outro app (Open WebUI); usamos `3300` por padrão.
- Ajuste a porta com `PORT=<n>` ao iniciar.
