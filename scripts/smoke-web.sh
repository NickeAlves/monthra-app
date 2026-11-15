#!/usr/bin/env bash
# Smoke test of the web image: routing, CSP nonce, security headers, bundled
# engine. Usage: scripts/smoke-web.sh [base URL]  (default http://127.0.0.1:8080)
set -euo pipefail

base=${1:-http://127.0.0.1:8080}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
header() { grep -i "^$1:" | head -1 | cut -d' ' -f2- | tr -d '\r'; }
page_nonce() { grep -o 'nonce="[0-9a-f]\{32\}"' "$1" | cut -d'"' -f2; }

curl -sSf "$base/nginx-health" | grep -qx ok || fail "health check"

curl -sS -D "$tmp/headers" -o "$tmp/index.html" "$base/"
nonce=$(page_nonce "$tmp/index.html")
[ -n "$nonce" ] || fail "index.html has no nonce"
! grep -q __CSP_NONCE__ "$tmp/index.html" || fail "nonce placeholder left in index.html"
csp=$(header content-security-policy < "$tmp/headers")
[[ "$csp" == *"'nonce-$nonce'"* ]] || fail "CSP does not carry the page nonce: $csp"
[[ "$csp" == *"connect-src 'self'"* ]] || fail "CSP connect-src: $csp"
# 'none' would void <base href="/">, and deep routes would resolve the assets wrong.
[[ "$csp" == *"base-uri 'self'"* ]] || fail "CSP base-uri: $csp"
[[ "$csp" != *"'unsafe-inline'"* && "$csp" != *"'unsafe-eval'"* ]] || fail "CSP allows inline code or eval: $csp"
[ "$(header cache-control < "$tmp/headers")" = no-cache ] || fail "index.html must not be cached"
for h in strict-transport-security x-content-type-options x-frame-options referrer-policy \
         permissions-policy cross-origin-opener-policy cross-origin-resource-policy; do
  [ -n "$(header "$h" < "$tmp/headers")" ] || fail "missing header $h"
done
! grep -qi '^server: nginx/' "$tmp/headers" || fail "nginx version exposed"

curl -sS -o "$tmp/second.html" "$base/"
[ "$(page_nonce "$tmp/second.html")" != "$nonce" ] || fail "the nonce must change on every response"

curl -sS "$base/verify-email" | grep -q 'flutter_bootstrap.js' || fail "app routes must serve index.html"
[ "$(curl -sS -o /dev/null -w '%{http_code}' "$base/missing.js")" = 404 ] || fail "a missing file must be a 404"

curl -sSf "$base/flutter_bootstrap.js" | grep -q '"useLocalCanvasKit":true' || fail "CanvasKit must be bundled"
[ "$(curl -sS -o /dev/null -w '%{content_type}' "$base/canvaskit/canvaskit.wasm")" = application/wasm ] \
  || fail "wasm content type"
curl -sS -H 'Accept-Encoding: gzip' -D - -o /dev/null "$base/main.dart.js" | grep -qi '^content-encoding: gzip' \
  || fail "main.dart.js must be served compressed"

echo "smoke test passed ($base)"
