# Prompt — Poda Segura de Repositório (padrão DevOps Senior)

Você está dentro DESTE repositório. Seu objetivo é executar uma PODA SEGURA, reduzindo a stack ao essencial “Replit‑like + Agent” para um devloop de editar/rodar instantâneo, sem quebrar o que funciona. Atua como um engenheiro DevOps Senior com foco em minimização, segurança e DX. Não escreva features novas; mantenha o que é essencial para rodar localmente e abrir PR.

Regras de ouro (NÃO QUEBRAR)
- Zero deleções diretas em primeira passada: todo arquivo/pasta não‑essencial deve ser movido para `archive/<data>-poda/` (git mv), com README de contexto.
- Toda remoção lógica deve ter substituto/justificativa e verificação de que não é referenciado por: Makefile, package.json scripts, CI, docs, infra, orquestradores.
- Patches mínimos: preserve estilo do repo; não renomeie arbitrariamente; não altere contratos públicos.
- Deleções permanentes só após comprovar que nada de crítico referencia e após aprovação explícita.
- Sempre manter um “sanity” rodando com healthchecks e um smoke e2e.

Objetivo de estado final (essencial mínimo)
- App exemplo funcional (+/ou api/web) com `/healthz` respondendo.
- `.devcontainer/` leve (Node 20) com postCreate instalando Playwright browsers.
- `.codex/config.toml` com MCPs essenciais: filesystem, ripgrep, memory, playwright.
- Makefile mínimo: app/app-bg/app-stop/app-log, live/*, sanity, codex-* (mcp/plan/patch/pr), code-open/list.
- `docs/painel.html` com atalhos somente para o que existe no Makefile e cmd úteis.
- README enxuto explicando devloop, sanity e MCPs.

Ferramentas e limites (use sempre que possível)
- MCP Filesystem para editar/mover/criar arquivos.
- MCP Ripgrep para inventário de usos e referências.
- MCP Memory para anotações do plano.
- MCP Playwright para smoke (abrir URL e retornar TITLE/URL).
- Peça APROVAÇÃO antes de qualquer deleção permanente ou mudança de contrato.

Plano de execução (mostre antes de agir)
1) Inventário e mapeamento
   - Liste entrypoints, scripts e superfícies: Makefile, package.json scripts, Docker/Compose, CI (GitHub/GitLab), infra (Pulumi/Terraform/K8s), docs e `src/*`/`apps/*`.
   - Identifique o que está realmente referenciado: use ripgrep para achar usos e menções (incluindo no CI e docs).
   - Saída: uma tabela “manter / mover para archive / revisar” com justificativa e evidências (linhas/arquivos que referenciam).
2) Guardrails e sanidade
   - Se não existir, crie/ajuste um alvo `sanity` no Makefile: imprime Node/npm e faz curl no `/healthz` do app.
   - Se houver frontend, smoke com Playwright MCP visitando URL e retornando TITLE/URL.
   - Se “type”: “module” causar atrito, padronize entrada (ex.: renomear server para .cjs OU migrar import/export), mas explique o trade‑off.
3) Poda não destrutiva
   - Mova pastas/arquivos não‑essenciais para `archive/<YYYYMMDD>-poda/` (git mv) com `archive/README.md` listando o que foi movido e por quê.
   - Atualize Makefile, docs/painel.html e README para remover atalhos/menções órfãos.
   - Não toque no que o sanity precisa para passar.
4) Alinhamento do painel e docs
   - Garanta que todos os atalhos do painel existem no Makefile e vice‑versa.
   - Remova categorias que não existem (ex.: Pulumi/Observability/Docker, se ausentes).
   - Adicione seção “Outro Repo” com instruções para reutilizar `.codex/config.toml` via `-C`.
5) Verificações finais
   - Rode sanity e smoke novamente; cole outputs no resumo.
   - Gere um diff resumido por área (app/devcontainer/makefile/codex/docs).
6) PR
   - Crie branch `chore/poda-min-replit-agent`.
   - Prepare PR com título, descrição e checklist de validação.

Critérios de aceitação
- `make sanity` verde (Node/npm + /healthz OK).
- Smoke Playwright verde (se houver UI).
- Painel sem atalhos órfãos, apenas itens presentes no Makefile.
- README com “Como rodar agora”, “Sanidade”, “MCPs”.
- Nada essencial sumiu; tudo removido foi para `archive/` com justificativa.

O que é essencial versus não‑essencial (heurística)
- Essencial: app/api/web mínimos, healthchecks, Makefile lean, DevContainer, Codex/MCP, painel de atalhos e README.
- Não‑essencial (mover p/ archive salvo evidência de uso): infra (Pulumi/Terraform), observability stacks completas, CI/CD complexos, scripts legados não referenciados, ferramentas antigas de orquestração, data/reports/logs gerados.

Comandos e técnicas úteis (execute durante o mapeamento)
- Referências a CI/infra/orquestração:
  - `rg -n "github/workflows|gitlab-ci|pulumi|terraform|docker-compose|kubernetes|helm|grafana|prometheus" -S` 
- Entry points e servers:
  - `rg -n "(node\s+.*server|fastify|express|http\.createServer|vite|next|nuxt)" -S`
- Scripts npm e Makefile alvos:
  - `cat package.json`; `rg -n "^[a-zA-Z0-9_\-]+:.*##" Makefile -n` 
- Menções em docs:
  - `rg -n "make | codex | /healthz | http://localhost" docs -S`

Entrega Esperada (resumos + patches)
- Plano curto com tabela manter/mover/revisar e evidências (linhas citadas).
- Patch com:
  - `archive/<YYYYMMDD>-poda/` contendo itens movidos e `archive/README.md`.
  - Makefile mínimo (app/live/sanity/codex/code-*) consistente.
  - `.codex/config.toml` com MCPs essenciais.
  - `.devcontainer/` leve + setup Playwright.
  - `docs/painel.html` alinhado ao Makefile.
  - README enxuto “Como rodar agora”.
- Comandos de verificação rodados e seus outputs.

Checklist de PR (cole na descrição)
- [ ] `make sanity` OK (log incluído)
- [ ] Smoke Playwright OK (se aplicável)
- [ ] Painel sem atalhos órfãos
- [ ] README atualizado
- [ ] Tudo não‑essencial movido para `archive/` com justificativa
- [ ] Sem deleções irreversíveis nesta PR

Instruções operacionais para você (Codex)
- Mostre primeiro o plano/tabela de decisão em Markdown e aguarde confirmação.
- Ao mover itens para `archive/`, explique cada grupo em 1–2 linhas.
- Solicite aprovação antes de qualquer deleção definitiva ou mudança de contrato.
- Após aplicar patches, rode sanity e (se houver UI) smoke com Playwright MCP e inclua os outputs na resposta.
- Caso algo crítico esteja em risco, pare e peça decisão (“manter como está” vs “migrar com follow‑up”).

Observações
- Se o repo já tiver itens mínimos, reutilize o que existir em vez de criar do zero.
- Se houver múltiplos apps, mantenha apenas 1 exemplar “hello” funcional e mova o restante para `archive/` com sinalização clara.
- Caso `type":"module"` cause erro com require, ajuste entrada (.cjs) ou converta imports, mas documente o motivo.

Saída agora
1) Exiba o plano de poda com a tabela manter/mover/revisar + riscos.
2) Aguarde minha confirmação com “APROVADO: aplicar patch”.
3) Aplique patches mínimos e reporte o diff por seções + logs de sanity/smoke.
