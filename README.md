[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/deepwiki-open-1?utm_medium=integration&utm_source=button&utm_campaign=deepwiki-open)

# DeepWiki-Open on Railway

Railway template for [DeepWiki-Open](https://github.com/AsyncFuncAI/deepwiki-open) (MIT), the open-source AI wiki generator for GitHub, GitLab and Bitbucket repositories.

## What it deploys

One service built from this repo:

- the official image `ghcr.io/asyncfuncai/deepwiki-open:sha-9c28366` (upstream `main` at commit [`9c28366`](https://github.com/AsyncFuncAI/deepwiki-open/commit/9c28366cf43345e570a2440e008942b29dba9a20), 2026-11-15), pinned by digest. Upstream publishes no release tags, so the template follows the commit-tagged images its CI builds;
- [Caddy](https://caddyserver.com/) 2.11.9 on Railway's `PORT`: a login (HTTP basic auth) on everything except `/health`, and routing so the UI, the API and the chat WebSockets all work on the one HTTPS domain;
- a volume on `/root/.adalflow` that keeps cloned repositories, embeddings and generated wikis across redeploys.

The API (port 8001) and the Next.js UI (port 3000) listen only inside the container.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `OPENAI_API_KEY` | prompt | OpenAI key. Used for embeddings and, unless a Google key is set, for wiki generation (default model `gpt-5-nano`). Leave it empty only if you set `GOOGLE_API_KEY`. |
| `GOOGLE_API_KEY` | empty, optional | Google AI Studio key. When set, Gemini becomes the default model; with no OpenAI key, embeddings use Google too. |
| `BASIC_AUTH_USERNAME` | `admin` | Login name. |
| `BASIC_AUTH_PASSWORD` | generated | Login password (`${{secret(32)}}`). Read it in the service's Variables tab. The container refuses to start without it. |
| `PORT` | `8080` | Port Caddy listens on. |

Other upstream settings (`OPENROUTER_API_KEY`, `OLLAMA_HOST`, `DEEPWIKI_EMBEDDER_TYPE`, `DEEPWIKI_AUTH_MODE`, `OPENAI_BASE_URL`, …) can be added as service variables; see the upstream [`api/config.py`](https://github.com/AsyncFuncAI/deepwiki-open/blob/main/api/config.py). Changing the embedder means re-indexing existing repositories.

Private repositories: paste a personal access token in the UI when you generate a wiki.

## Updates

Every change to this template lands on `main` with an entry in [`CHANGELOG.md`](CHANGELOG.md) (breaking changes first). Railway then shows an "update available" notice on projects deployed from the template, and you choose when to apply it. Your data on the volume is kept.

## Local test

```sh
docker build -t deepwiki-railway .
docker run --rm -p 8080:8080 -e BASIC_AUTH_PASSWORD=change-me -e OPENAI_API_KEY=sk-... -v deepwiki:/root/.adalflow deepwiki-railway
```

Then open http://localhost:8080 and log in as `admin`.
