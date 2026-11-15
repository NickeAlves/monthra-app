#!/usr/bin/env bash
# Smoke test of the web image: routing, CSP nonce, security headers, bundled
# engine. Usage: scripts/smoke-web.sh [base URL]  (default http://127.0.0.1:8080)
set -euo pipefail

base=${1:-http://127.0.0.1:8080}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
header() { grep -i "^$1:" | head -1 | cut -d' ' -f2- | tr -d '\r'; }
# Every script tag carries the same per-response nonce (boot.js, flutter_bootstrap.js).
page_nonce() { grep -o 'nonce="[0-9a-f]\{32\}"' "$1" | cut -d'"' -f2 | sort -u; }

curl -sSf "$base/nginx-health" | grep -qx ok || fail "health check"

curl -sS -D "$tmp/headers" -o "$tmp/index.html" "$base/"
nonce=$(page_nonce "$tmp/index.html")
[ -n "$nonce" ] || fail "index.html has no nonce"
[ "$(wc -l <<< "$nonce")" -eq 1 ] || fail "index.html scripts carry different nonces"
[ "$(grep -c 'nonce="' "$tmp/index.html")" -ge 2 ] || fail "boot.js and flutter_bootstrap.js must both carry the nonce"
! grep -q __CSP_NONCE__ "$tmp/index.html" || fail "nonce placeholder left in index.html"
# boot.js applies the saved theme before the first paint: a synchronous head script.
grep -q '<script src="boot.js" nonce=' "$tmp/index.html" || fail "index.html must load boot.js"
[ "$(curl -sS -o "$tmp/boot.js" -w '%{content_type}' "$base/boot.js")" = application/javascript ] \
  || fail "boot.js content type"
grep -q "monthra.boot" "$tmp/boot.js" || fail "boot.js must read the monthra.boot hint"
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

[[ "$csp" == *"frame-src 'self'"* ]] || fail "CSP frame-src (the captcha frame): $csp"
[ "$(header x-frame-options < "$tmp/headers")" = DENY ] || fail "the app must not be framed"

# The captcha page: its own policy, framed by this origin only, no inline code.
curl -sS -D "$tmp/captcha-headers" -o "$tmp/turnstile.html" "$base/turnstile.html"
grep -q 'HTTP/[0-9.]* 200' "$tmp/captcha-headers" || fail "turnstile.html must be served"
captcha_csp=$(header content-security-policy < "$tmp/captcha-headers")
[[ "$captcha_csp" == *"script-src 'self' https://challenges.cloudflare.com"* ]] || fail "turnstile.html CSP script-src: $captcha_csp"
[[ "$captcha_csp" == *"frame-src https://challenges.cloudflare.com"* ]] || fail "turnstile.html CSP frame-src: $captcha_csp"
[[ "$captcha_csp" == *"frame-ancestors 'self'"* ]] || fail "turnstile.html CSP frame-ancestors: $captcha_csp"
[[ "$captcha_csp" != *"'unsafe-inline'"* && "$captcha_csp" != *"'unsafe-eval'"* ]] || fail "turnstile.html CSP allows inline code or eval: $captcha_csp"
[ "$(header x-frame-options < "$tmp/captcha-headers")" = SAMEORIGIN ] || fail "turnstile.html X-Frame-Options"
grep -q '<script src="turnstile.js">' "$tmp/turnstile.html" || fail "turnstile.html must load turnstile.js"
[ "$(curl -sS -o /dev/null -w '%{content_type}' "$base/turnstile.js")" = application/javascript ] \
  || fail "turnstile.js content type"

curl -sS -o "$tmp/second.html" "$base/"
[ "$(page_nonce "$tmp/second.html")" != "$nonce" ] || fail "the nonce must change on every response"

curl -sS "$base/verify-email" | grep -q 'flutter_bootstrap.js' || fail "app routes must serve index.html"
[ "$(curl -sS -o /dev/null -w '%{http_code}' "$base/missing.js")" = 404 ] || fail "a missing file must be a 404"

curl -sSf "$base/flutter_bootstrap.js" | grep -q '"useLocalCanvasKit":true' || fail "CanvasKit must be bundled"
[ "$(curl -sS -o /dev/null -w '%{content_type}' "$base/canvaskit/canvaskit.wasm")" = application/wasm ] \
  || fail "wasm content type"
# The UI font is bundled (font-src 'self'), served as a font and compressed.
font="$base/assets/assets/fonts/inter/Inter-Regular.ttf"
[ "$(curl -sS -o /dev/null -w '%{content_type}' "$font")" = font/ttf ] || fail "font content type"
curl -sS -H 'Accept-Encoding: gzip' -D - -o /dev/null "$font" | grep -qi '^content-encoding: gzip' \
  || fail "fonts must be served compressed"
# tool/prune_web_fonts.dart ran: the unused icon font weights are gone.
! curl -sSf "$base/assets/FontManifest.json" | grep -q 'lucide_icons_flutter/Lucide[1-9]00' \
  || fail "unused Lucide weights still in FontManifest.json"
curl -sS -H 'Accept-Encoding: gzip' -D - -o /dev/null "$base/main.dart.js" | grep -qi '^content-encoding: gzip' \
  || fail "main.dart.js must be served compressed"

echo "smoke test passed ($base)"
