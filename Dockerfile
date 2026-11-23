# GitHub MCP Server for Railway: the official server binary behind a small Caddy front
# that checks a generated bearer token and swaps in the deployer's GitHub token.
FROM ghcr.io/github/github-mcp-server:v2.2.0@sha256:040c4e99810076035eb1d9beb4b4a96fcf589c43cefed6ff51a46a553eb4e174 AS mcp

FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0
COPY --from=mcp /server/github-mcp-server /usr/local/bin/github-mcp-server
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh /usr/local/bin/github-mcp-server \
 && github-mcp-server --version
ENV PORT=8080 GOMAXPROCS=1 GOMEMLIMIT=200MiB
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/start.sh"]
