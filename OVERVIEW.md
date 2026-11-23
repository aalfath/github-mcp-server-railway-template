# Deploy and Host GitHub MCP Server on Railway

GitHub MCP Server is GitHub's official Model Context Protocol server. It gives AI assistants and agents (Claude, Cursor, VS Code, ChatGPT connectors, your own agents) tools to read and change repositories, issues, pull requests, Actions runs and code search, using your own GitHub token. This template runs it remotely over streamable HTTP.

## About Hosting GitHub MCP Server

This template builds one service from a public repo: GitHub's official `github-mcp-server` v2.2.0 binary, pinned by digest, listening only on loopback, with a small Caddy front on Railway's `PORT`. Caddy lets a request through only when it carries the generated `MCP_AUTH_TOKEN` as a bearer token, then swaps in your GitHub token, so the GitHub token never leaves the server and the public URL is never open. You paste one value at deploy time: a GitHub personal access token. The server keeps no data, so it needs no volume or database. It uses under 100 MB of RAM and fits the 0.5 GB of Railway's smallest plan.

## Common Use Cases

* Give a remote AI client or agent access to your GitHub repos, issues and pull requests without running a local process
* Let an agent triage issues, review pull requests, read Actions logs or search code from a chat
* Run a read-only GitHub endpoint for agents (`/readonly`) or one limited to a single toolset (`/x/issues`)

## Dependencies for GitHub MCP Server Hosting

* A GitHub personal access token (fine-grained or classic) with the access you want the agent to have
* An MCP client that supports remote streamable-HTTP servers with a custom header

### Deployment Dependencies

* [GitHub MCP Server on GitHub](https://github.com/github/github-mcp-server)
* [Release v2.2.0](https://github.com/github/github-mcp-server/releases/tag/v2.2.0)
* [Create a GitHub token](https://github.com/settings/personal-access-tokens/new)
* [Template repo](https://github.com/aalfath/github-mcp-server-railway-template)

### Implementation Details

**Services:** one service, `GitHub MCP Server`: the official server plus a Caddy bearer-token check. Health check: `/healthz`.

**Variables:**

* `GITHUB_PERSONAL_ACCESS_TOKEN` (required): your GitHub token. Create a fine-grained token at github.com/settings/personal-access-tokens/new and give it the repositories and permissions the agent should have (for example Contents, Issues, Pull requests: read and write). Read-only permissions give a read-only agent.
* `MCP_AUTH_TOKEN` (generated): the bearer token your MCP client must send. Copy it from the service's Variables tab after deploy.

**After deploy:** copy the public URL and `MCP_AUTH_TOKEN`, then add the server to your client. For example, VS Code (`.vscode/mcp.json`) or any client that takes this format:

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

Claude Code: `claude mcp add --transport http github https://YOUR-DOMAIN.up.railway.app/ --header "Authorization: Bearer YOUR-MCP_AUTH_TOKEN"`.

**Paths:** `/` (default toolsets: context, repos, issues, pull_requests, users), `/readonly`, `/x/TOOLSET` (for example `/x/actions`), `/insiders`. Clients can also send `X-MCP-Toolsets: repos,issues,actions` or `X-MCP-Readonly: true`.

**Optional settings** (add them as service variables): `GITHUB_TOOLSETS` (for example `default,actions,code_security` or `all`), `GITHUB_READ_ONLY=true` to make the whole server read-only, `GITHUB_HOST` for GitHub Enterprise. The tools that delete repositories or change repository automation stay off unless you set `GITHUB_MCP_SERVER_MRTR_STATE_KEY` (32 random bytes, base64: `openssl rand -base64 32`).

**Security:** anyone with the URL and `MCP_AUTH_TOKEN` can act on GitHub with your token's permissions. To rotate it, change `MCP_AUTH_TOKEN` and redeploy. Give the GitHub token only the access you need.

**Updates:** the service builds from the template repo, which pins the upstream release by version and digest. When we bump it, Railway shows an "update available" notice on your project; read the repo's `CHANGELOG.md` and apply it when you choose.

## Why Deploy GitHub MCP Server on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying GitHub MCP Server on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
