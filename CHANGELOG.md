# Changelog

## 2026-11-23: GitHub MCP Server v2.2.0 (first release)

- Breaking changes: none (first release).
- GitHub MCP Server v2.2.0, `ghcr.io/github/github-mcp-server:v2.2.0@sha256:040c4e99810076035eb1d9beb4b4a96fcf589c43cefed6ff51a46a553eb4e174`.
- Caddy 2.11.9 (`caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0`) in front, checking the generated `MCP_AUTH_TOKEN`.
- Health check `/healthz`; the container exits non-zero if the server or Caddy stops.
