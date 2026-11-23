#!/bin/sh
# Starts the GitHub MCP Server (loopback only) and Caddy in front of it.
# If either process stops, the container exits non-zero so Railway restarts it.
set -eu

: "${PORT:=8080}"
export PORT

if [ -z "${MCP_AUTH_TOKEN:-}" ] || [ "${#MCP_AUTH_TOKEN}" -lt 24 ]; then
  echo "MCP_AUTH_TOKEN must be set (at least 24 characters); the template generates one." >&2
  exit 1
fi
case "$MCP_AUTH_TOKEN" in
  *[!A-Za-z0-9_-]*) echo "MCP_AUTH_TOKEN may only use letters, digits, '-' and '_'." >&2; exit 1 ;;
esac
if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  echo "GITHUB_PERSONAL_ACCESS_TOKEN is empty: create a GitHub token and set it on this service." >&2
  exit 1
fi
case "$GITHUB_PERSONAL_ACCESS_TOKEN" in
  *[!A-Za-z0-9_]*) echo "GITHUB_PERSONAL_ACCESS_TOKEN has unexpected characters (spaces or quotes?)." >&2; exit 1 ;;
esac

# The MCP server itself listens on loopback only; Caddy is the only way in.
github-mcp-server http --listen-host 127.0.0.1 --port 8082 &
MCP_PID=$!
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!

trap 'kill "$MCP_PID" "$CADDY_PID" 2>/dev/null; exit 0' TERM INT

# BusyBox `wait -n` does not return on the first child exit, so poll.
while kill -0 "$MCP_PID" 2>/dev/null && kill -0 "$CADDY_PID" 2>/dev/null; do
  sleep 2
done
echo "A process stopped unexpectedly; exiting so Railway restarts the service." >&2
kill "$MCP_PID" "$CADDY_PID" 2>/dev/null || true
exit 1
