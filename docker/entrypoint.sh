#!/usr/bin/env sh
set -e

# Start Node MCP server on internal port 3000 (hardcode PORT to avoid Railway override)
CLOUD_SERVICE=true PORT=3000 node dist/index.js &

# Start oauth2-proxy on port 4180 — validates Google tokens, proxies to Node on 3000
oauth2-proxy \
  --provider=google \
  --client-id="${GOOGLE_CLIENT_ID}" \
  --client-secret="${GOOGLE_CLIENT_SECRET}" \
  --cookie-secret="${OAUTH2_PROXY_COOKIE_SECRET}" \
  --email-domain="${OAUTH2_PROXY_EMAIL_DOMAIN:-*}" \
  --upstream="http://localhost:3000" \
  --http-address="0.0.0.0:4180" \
  --redirect-url="${OAUTH2_PROXY_REDIRECT_URL}" \
  --skip-jwt-bearer-tokens=true \
  --skip-provider-button=true \
  --cookie-secure=true \
  --pass-authorization-header=true \
  --pass-access-token=true \
  --force-https=true \
  --reverse-proxy=true &

# Start NGINX in foreground (proxies :8080 → oauth2-proxy :4180)
nginx -g 'daemon off;'
