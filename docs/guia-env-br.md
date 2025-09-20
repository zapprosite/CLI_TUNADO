# Guia do .env — Como criar cada item (BR)

Este guia explica como preencher cada variável do `.env` com links e passos em português (Brasil).

## Portas e runtime
- `APP_PORT`, `WEB_PORT`, `WEB_PREVIEW_PORT`: portas padrão dos serviços locais (hello/api/web). Se estiverem ocupadas, ajuste os valores.
- `NODE_ENV`, `LOG_LEVEL`: modo e nível de logs (ex.: `development`, `info`).

## API (SQLite/Prisma)
- `DATABASE_URL`: normalmente não precisa configurar — o Makefile usa `file:./prisma/dev.db`. Defina aqui apenas se quiser forçar outro caminho/arquivo.

## Web (Vite)
- `VITE_API_URL`: defina em `apps/web/.env.local`. Ex.: `VITE_API_URL=http://localhost:3400`.

## Context7 (pesquisa/grounding de docs)
- Variáveis: `CONTEXT7_BASE_URL`, `CONTEXT7_API_KEY`.
- Criação de conta/token: use o portal da sua empresa/provedor Context7 (interna ou contratada). Se for SaaS, acesse a página de tokens e gere uma chave de API.
- Dicas:
  - Guarde o token com segurança (1Password/Bitwarden).
  - Prefira chaves com validade e escopos mínimos.
  - Teste o token: `curl -H "Authorization: Bearer $CONTEXT7_API_KEY" "$CONTEXT7_BASE_URL" -i`.

## GitHub (GITHUB_TOKEN)
- Criar token (Fine-grained):
  - Acesse: https://github.com/settings/personal-access-tokens/new
  - Dono do recurso: seu usuário
  - Permissões do repositório:
    - Administration: Read and write
    - Contents: Read and write
    - Metadata: Read
  - Expiração: defina uma data e renove periodicamente
- Testar: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | jq .login`

## Autor de commits (GIT_AUTHOR_NAME/EMAIL)
- Defina seu nome e e-mail para padronizar autoria em commits automatizados.
- Ex.: `GIT_AUTHOR_NAME="Seu Nome"`, `GIT_AUTHOR_EMAIL="seu.email@empresa.com"`.

## Webhooks (Slack/Discord)
- Slack:
  - Crie um app em https://api.slack.com/apps
  - Habilite “Incoming Webhooks” e gere um webhook para o canal desejado.
  - Cole em `SLACK_WEBHOOK`.
- Discord:
  - No canal, abra Configurações → Integrações → Webhooks → Novo Webhook.
  - Cole em `DISCORD_WEBHOOK`.
- Testes rápidos:
```
curl -s -X POST -H 'Content-type: application/json' --data '{"text":"Teste do Zappro"}' "$SLACK_WEBHOOK"
curl -s -H 'Content-Type: application/json' -d '{"content":"Teste do Zappro"}' "$DISCORD_WEBHOOK"
```

## Ollama (opcional)
- Instalação: https://github.com/ollama/ollama
- Variável: `OLLAMA_HOST=http://localhost:11434`
- Suba um modelo: `ollama run llama3.1`

## Boas práticas
- Nunca comite seu `.env`.
- Use `.env.example` como referência. Copie para `.env` e edite localmente.
- Rotacione tokens periodicamente e revogue os que não usar mais.

