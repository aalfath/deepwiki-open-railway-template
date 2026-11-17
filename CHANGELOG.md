# Changelog

## 2026-11-17: first release

- DeepWiki-Open `sha-9c28366` (upstream `main` at 9c28366, 2026-11-15), official image pinned by digest `sha256:d16868c1c4dc17b471128afc2275318a6a806c73fc204927d75c51ee67c03582`.
- Caddy 2.11.9 in front: basic-auth login on everything except `/health`, `/ws/*` and `/codemap/file` routed to the API so chat and codemap work on Railway's single domain.
- The browser bundle connects WebSockets to the page's own port instead of `:8001`.
- With only an OpenAI key, OpenAI is the default chat provider; with only a Google key, embeddings use Google.
- Volume on `/root/.adalflow` (repositories, embeddings, wiki cache).
