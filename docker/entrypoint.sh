#!/usr/bin/env sh

echo "Starting Node MCP server on port 3000..."
CLOUD_SERVICE=true HTTP_STREAMABLE_SERVER=true PORT=3000 node dist/index.js &
NODE_PID=$!

echo "Waiting for Node to start..."
sleep 3

echo "Checking if Node is listening..."
netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null || echo "netstat not available"

echo "Starting oauth2-proxy on port 8080..."
exec oauth2-proxy \
  --provider=google \
  --client-id="${GOOGLE_CLIENT_ID}" \
  --client-secret="${GOOGLE_CLIENT_SECRET}" \
  --cookie-secret="${OAUTH2_PROXY_COOKIE_SECRET}" \
  --email-domain="${OAUTH2_PROXY_EMAIL_DOMAIN:-*}" \
  --upstream="http://127.0.0.1:3000" \
  --http-address="0.0.0.0:8080" \
  --redirect-url="${OAUTH2_PROXY_REDIRECT_URL}" \
  --skip-jwt-bearer-tokens=true \
  --skip-provider-button=true \
  --cookie-secure=true \
  --pass-authorization-header=true \
  --pass-access-token=true \
  --force-https=true \
  --reverse-proxy=true
