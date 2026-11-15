# syntax=docker/dockerfile:1
# Web build of the app: Flutter compiles it to static files, nginx serves them.
#   docker build --build-arg FLUTTER_ENV=staging -t monthra-app .
# Android and iOS builds do not use this file (see the README).

# --- build -------------------------------------------------------------------
# No maintained image ships Flutter 3.47 (ghcr.io/cirruslabs/flutter stops at
# 3.44), so the SDK comes from its git tag, checked against the release commit
# (the "hash" of the release in releases_linux.json). Native on amd64 and arm64.
FROM debian:trixie-20261104-slim@sha256:a72b4433de1cf7d6bae0c4cee74d0547f58601a643b3375f070c51600d63b6b2 AS build

ARG FLUTTER_VERSION=3.47.8
ARG FLUTTER_COMMIT=737ba8f885dc774b53b442759999a312c9461e4e

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home --uid 10001 flutter

USER flutter
ENV PATH=/home/flutter/sdk/bin:$PATH

RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /home/flutter/sdk \
 && test "$(git -C /home/flutter/sdk rev-parse HEAD)" = "${FLUTTER_COMMIT}" \
 && flutter config --no-analytics --no-cli-animations \
 && dart --disable-analytics \
 && flutter precache --web --no-android --no-ios

WORKDIR /home/flutter/app
COPY --chown=flutter pubspec.yaml pubspec.lock ./
RUN flutter pub get --enforce-lockfile

COPY --chown=flutter . .

# env/<FLUTTER_ENV>.json: local, staging or production.
ARG FLUTTER_ENV=local
# --no-web-resources-cdn bundles CanvasKit and the fallback fonts (nothing is
# fetched from gstatic.com); --csp keeps the JavaScript free of eval.
# Every compressible file gets a .gz twin for gzip_static, except index.html,
# which nginx rewrites (CSP nonce). Debug symbols stay out of the image.
RUN test -f "env/${FLUTTER_ENV}.json" \
 && flutter build web --release --csp --no-web-resources-cdn \
      --dart-define-from-file="env/${FLUTTER_ENV}.json" \
      --output /home/flutter/app/build/web \
 && find build/web -name '*.symbols' -delete \
 && find build/web -type f \( -name '*.js' -o -name '*.mjs' -o -name '*.wasm' -o -name '*.json' \
      -o -name '*.css' -o -name '*.svg' -o -name '*.otf' -o -name '*.ttf' -o -name 'NOTICES' \) \
      -exec gzip -9 -k {} +

# --- runtime -----------------------------------------------------------------
FROM nginxinc/nginx-unprivileged:1.30.6-alpine3.24@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03 AS runtime

ARG VERSION=dev
LABEL org.opencontainers.image.title="monthra-app" \
      org.opencontainers.image.description="Monthra web app (Flutter) served by nginx" \
      org.opencontainers.image.source="https://github.com/NickeAlves/monthra-app" \
      org.opencontainers.image.version="${VERSION}"

# Alpine fixes land before a new base image does (Trivy fails the build on
# HIGH/CRITICAL ones), and the image's default server goes away: the whole
# configuration is ours.
USER root
RUN apk upgrade --no-cache \
 && rm -f /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/security-headers.conf /etc/nginx/security-headers.conf
# Owned by root: the nginx user can read the site, never change it.
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html
USER 101

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO /dev/null http://127.0.0.1:8080/nginx-health || exit 1
