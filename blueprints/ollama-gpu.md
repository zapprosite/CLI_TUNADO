# Ollama + GPU (4090) — Integração recomendada (2025)

Objetivo: usar LLM local como fallback/acelerador para ciclos rápidos (custo/latência), mantendo `gpt-5` para patches críticos.

## Modelos sugeridos
- Código: `qwen2.5-coder:14b` (ou 7b), `deepseek-coder-v2:16b` (ou 7b)
- Geral: `llama3.1:8b-instruct`

## Comandos úteis
- Pull:
  - `ollama pull qwen2.5-coder:14b`
  - `ollama pull deepseek-coder-v2:16b`
  - `ollama pull llama3.1:8b-instruct`
- Teste rápido:
  - `curl -s http://localhost:11434/api/generate -d '{"model":"llama3.1:8b-instruct","prompt":"Say hi"}' | jq -r '.response'`

## Usando no Codex
- Execução local (oss provider):
  - `codex --oss -c model="qwen2.5-coder:14b" exec "<prompt>"`
- Estratégia híbrida:
  - Iterações: `--oss` (local) para explorar/planejar.
  - Patches finais: `gpt-5` para qualidade máxima.

## Assistant (fallback)
- Configurar `agents/assistant/intent` para usar GPT Enterprise primário e Ollama como fallback.
- Variáveis:
  - `OLLAMA_HOST=http://localhost:11434`
  - `ASSISTANT_MODEL_PRIMARY=gpt-5`
  - `ASSISTANT_MODEL_FALLBACK=llama3.1:8b-instruct`

## STT/TTS com GPU
- STT: `faster-whisper` (CUDA) + `webrtcvad`; `ffmpeg` instalado.
- TTS: `piper` com voz pt-BR/en-US.

## Dicas de performance
- `CUDA_VISIBLE_DEVICES=0`
- Fixar temperatura baixa (0.1–0.3) em tarefas de código.
- Preferir quantização adequada (Q4_K_M, etc.) para caber na VRAM sem pageouts.
