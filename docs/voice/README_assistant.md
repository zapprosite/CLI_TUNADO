# Assistant (PyGPT-like) — Voz → LLM → Ação

Este assistant permite controlar o SO por voz (ou texto), com confirmação antes de ações destrutivas e fallback de LLM local via Ollama.

## Requisitos
- Python 3, pip
- ffmpeg, portaudio (para STT/TTS)
- (Opcional) Ollama em GPU 4090 (`OLLAMA_HOST=http://localhost:11434`)

## Instalação (DevContainer)
- Já configurado em `.devcontainer/setup.sh` (best-effort): instala deps do sistema e `agents/assistant/requirements.txt`.

## Comandos
- Diagnóstico: `make assistant-check`
- Iniciar (modo texto): `make assistant-dev`

## Configuração
- Arquivo: `agents/assistant/config/assistant.yaml`
- Variáveis (.env):
  - `ASSISTANT_MODEL_PRIMARY=gpt-5`
  - `ASSISTANT_MODEL_FALLBACK=llama3.1:8b-instruct`
  - `OLLAMA_HOST=http://localhost:11434`

## Fluxo (simulado, seguro por padrão)
- Digite “abrir navegador” e ENTER → assistant pede confirmação → abre URL `http://localhost:3300` (via `xdg-open`) ou simula.

## Próximos passos
- Ativar STT (vosk/whisper-cpp) e TTS (piper).
- Adicionar intents e executores adicionais (atalhos, automação).
- Registrar decisões e rotas no Memory-Bank.
