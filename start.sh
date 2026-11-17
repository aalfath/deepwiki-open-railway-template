#!/bin/bash
# Starts the DeepWiki API (uvicorn on 127.0.0.1:8001), the Next.js UI (3000)
# and Caddy on $PORT. Exits when any of them stops, so Railway restarts it.
set -euo pipefail

PUBLIC_PORT="${PORT:-8080}"
export BASIC_AUTH_USERNAME="${BASIC_AUTH_USERNAME:-admin}"

if [ -z "${BASIC_AUTH_PASSWORD:-}" ]; then
  echo "BASIC_AUTH_PASSWORD is empty. Refusing to start DeepWiki without a login." >&2
  exit 1
fi
if ! [[ "$BASIC_AUTH_USERNAME" =~ ^[A-Za-z0-9._@-]+$ ]]; then
  echo "BASIC_AUTH_USERNAME may only contain letters, digits, . _ @ and -." >&2
  exit 1
fi
if [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${GOOGLE_API_KEY:-}" ]; then
  echo "Warning: neither OPENAI_API_KEY nor GOOGLE_API_KEY is set; wiki generation will fail." >&2
fi

# Upstream's default chat model is Google Gemini. With only an OpenAI key, make
# OpenAI the default so the first wiki works without changing the model picker.
if [ -z "${GOOGLE_API_KEY:-}" ] && [ -n "${OPENAI_API_KEY:-}" ] && [ -z "${DEEPWIKI_CONFIG_DIR:-}" ]; then
  mkdir -p /app/railway-config
  python - <<'PY'
import json
src = "/app/api/config/generator.json"
cfg = json.load(open(src))
cfg["default_provider"] = "openai"
json.dump(cfg, open("/app/railway-config/generator.json", "w"), indent=2)
PY
  export DEEPWIKI_CONFIG_DIR=/app/railway-config
fi
# Embeddings default to OpenAI. With only a Google key, embed with Google instead.
if [ -z "${OPENAI_API_KEY:-}" ] && [ -n "${GOOGLE_API_KEY:-}" ] && [ -z "${DEEPWIKI_EMBEDDER_TYPE:-}" ]; then
  export DEEPWIKI_EMBEDDER_TYPE=google
fi

BASIC_AUTH_HASH="$(caddy hash-password --plaintext "$BASIC_AUTH_PASSWORD")"
export BASIC_AUTH_HASH
unset BASIC_AUTH_PASSWORD

mkdir -p /root/.adalflow
cd /app

PORT=8001 python -m uvicorn api.main:app --host 127.0.0.1 --port 8001 &
PORT=3000 HOSTNAME=127.0.0.1 node server.js &
PORT="$PUBLIC_PORT" caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

wait -n
exit $?
