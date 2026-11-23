[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/github-mcp-server-1?utm_medium=integration&utm_source=button&utm_campaign=github-mcp-server)

# GitHub MCP Server on Railway

One-click Railway template for [GitHub MCP Server](https://github.com/github/github-mcp-server) **v2.2.0** (`ghcr.io/github/github-mcp-server:v2.2.0@sha256:040c4e99810076035eb1d9beb4b4a96fcf589c43cefed6ff51a46a553eb4e174`), GitHub's official MCP server, running remotely over streamable HTTP.

## What it deploys

One service built from this repo's `Dockerfile`:

- the official `github-mcp-server` binary (copied from the pinned upstream image), started with `github-mcp-server http` on `127.0.0.1:8082`;
- [Caddy](https://caddyserver.com) 2.11.9 on Railway's `PORT`, which lets a request through only with `Authorization: Bearer $MCP_AUTH_TOKEN` and then replaces that header with your GitHub token. `/healthz` answers 200 without a token (Railway's health check).

`start.sh` exits non-zero when either process stops, so Railway's restart policy brings the service back. The server is stateless: no volume, no database. Idle RAM is about 40 MB; it runs on Railway's smallest plan (0.5 GB).

## Variables

| Variable | Set by | What it is |
|---|---|---|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | you | GitHub token the server uses for every tool call. Create one at <https://github.com/settings/personal-access-tokens/new> with only the repositories and permissions the agent needs. |
| `MCP_AUTH_TOKEN` | generated | Bearer token your MCP client must send. Copy it from the service's Variables tab. |

Optional: `GITHUB_TOOLSETS`, `GITHUB_READ_ONLY`, `GITHUB_HOST`, `GITHUB_MCP_SERVER_MRTR_STATE_KEY` (see the upstream [server configuration guide](https://github.com/github/github-mcp-server/blob/v2.2.0/docs/server-configuration.md) and [streamable HTTP docs](https://github.com/github/github-mcp-server/blob/v2.2.0/docs/streamable-http.md)).

## Client config

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://YOUR-DOMAIN.up.railway.app/",
      "headers": { "Authorization": "Bearer YOUR-MCP_AUTH_TOKEN" }
    }
  }
}
```

Claude Code: `claude mcp add --transport http github https://YOUR-DOMAIN.up.railway.app/ --header "Authorization: Bearer YOUR-MCP_AUTH_TOKEN"`

Other paths: `/readonly`, `/x/<toolset>` (for example `/x/actions`), `/insiders`.

## Updates

The upstream image is pinned by version and digest in the `Dockerfile`. When this repo's `main` changes, Railway shows deployers an "update available" notice; read `CHANGELOG.md` first, breaking changes are listed at the top of each entry.

## Template overview

The marketplace overview is in [`OVERVIEW.md`](OVERVIEW.md).
