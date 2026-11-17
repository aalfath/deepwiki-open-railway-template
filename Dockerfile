# DeepWiki-Open for Railway.
# Official image (upstream has no releases; this is the image CI built from
# commit 9c28366 on main, 2026-11-15) plus Caddy, which serves the app on
# Railway's single HTTPS domain behind a login.
FROM caddy:2.11.9@sha256:4851e54a46b206517c574821bb5cc67f170d2156041e9fbc4c9193b45e84a75b AS caddy

FROM ghcr.io/asyncfuncai/deepwiki-open:sha-9c28366@sha256:d16868c1c4dc17b471128afc2275318a6a806c73fc204927d75c51ee67c03582

COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy

# The browser opens the chat and codemap WebSockets on <page host>:8001, a port
# Railway doesn't expose. Point them at the page's own port instead, where Caddy
# forwards /ws/* to the API. The build fails if upstream changes this code.
RUN set -eu; \
    files=$(grep -rl 'NEXT_PUBLIC_API_PORT||"8001"' /app/.next/static); \
    test -n "$files"; \
    for f in $files; do \
      sed -i 's/NEXT_PUBLIC_API_PORT||"8001"/NEXT_PUBLIC_API_PORT||window.location.port||("https:"===window.location.protocol?"443":"80")/g' "$f"; \
    done; \
    ! grep -rq 'NEXT_PUBLIC_API_PORT||"8001"' /app/.next/static

COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh

ENV PORT=8080
EXPOSE 8080
CMD ["/usr/local/bin/railway-start.sh"]
