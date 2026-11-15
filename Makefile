.DEFAULT_GOAL := help
SHELL := /bin/bash

NETWORK     := monthra-net
IMAGE       := ghcr.io/nickealves/monthra-app
FLAVOR      ?= dev
ENV_FILE    := env/$(if $(filter dev,$(FLAVOR)),local,$(if $(filter prod,$(FLAVOR)),production,$(FLAVOR))).json
COMPOSE     := docker compose
COMPOSE_STG := docker compose -f docker-compose.yml -f docker-compose.staging.yml
WEB_FLAGS   := --release --csp --no-web-resources-cdn
# Release mobile builds strip symbols into build/symbols (keep them to read crash stacks).
OBFUSCATE   := --obfuscate --split-debug-info=build/symbols

.PHONY: help deps network run-web run fmt gen l10n-check lint analyze test cover goldens-pull outdated \
        icons fonts build-web build-apk build-ios build smoke up down logs ps staging-up staging-down

help: ## List the available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

deps: ## Install the packages pinned in pubspec.lock
	flutter pub get --enforce-lockfile

network: ## Create the shared Docker network used by every Monthra compose file
	@docker network inspect $(NETWORK) >/dev/null 2>&1 || docker network create $(NETWORK) >/dev/null
	@echo "network $(NETWORK) ready"

run-web: ## Run the web app with hot reload on http://localhost:3000 (/api proxied to localhost:8080)
	flutter run -d chrome --dart-define-from-file=env/local.json

run: ## Run on a device or emulator (FLAVOR=dev|staging|prod; dev talks to the local API)
	flutter run --flavor $(FLAVOR) --dart-define-from-file=$(ENV_FILE)

fmt: ## Format the Dart code
	dart format lib test tool

gen: ## Regenerate the committed code: localizations (lib/l10n/generated) and Riverpod providers (*.g.dart)
	flutter gen-l10n
	dart run build_runner build --delete-conflicting-outputs

l10n-check: ## Fail when the ARB files disagree (a missing key, placeholder or description)
	dart run tool/check_l10n.dart

# dart analyze, not flutter analyze: only dart analyze runs the analyzer
# plugins (riverpod_lint).
analyze: l10n-check ## Check the ARB files and formatting, run the analyzer with its plugins (infos fail too)
	dart format --output=none --set-exit-if-changed lib test tool
	dart analyze --fatal-infos

lint: analyze ## Analyzer plus the secret scan
	gitleaks dir --no-banner --redact .

test: ## Run the tests (goldens only run on Linux; see the README)
	flutter test

cover: ## Run the tests with coverage (coverage/lcov.info)
	flutter test --coverage

goldens-pull: ## Copy the goldens CI rendered for this branch into test/ (RUN=<id> optional)
	scripts/pull-goldens.sh $(RUN)

outdated: ## List outdated packages
	flutter pub outdated

fonts: ## Regenerate the Inter subset in assets/fonts/inter
	scripts/subset-inter.sh

icons: ## Regenerate the launcher icons and native splash screens
	dart run flutter_launcher_icons
	dart run flutter_native_splash:create

build-web: ## Build the web app for production (APP_ENV=production) into build/web
	flutter build web $(WEB_FLAGS) --dart-define-from-file=env/production.json --output build/web
	dart run tool/prune_web_fonts.dart build/web

build-apk: ## Build a release APK (FLAVOR=dev|staging|prod)
	flutter build apk --release --flavor $(FLAVOR) --dart-define-from-file=$(ENV_FILE) $(OBFUSCATE)

build-ios: ## Build iOS without code signing (FLAVOR=dev|staging|prod)
	flutter build ios --release --no-codesign --flavor $(FLAVOR) --dart-define-from-file=$(ENV_FILE) $(OBFUSCATE)

build: ## Build the web image (FLUTTER_ENV=local|staging|production)
	docker build --build-arg FLUTTER_ENV=$${FLUTTER_ENV:-local} --build-arg VERSION=$$(git describe --tags --always --dirty 2>/dev/null || echo dev) -t $(IMAGE):$${IMAGE_TAG:-local} .

smoke: ## Smoke test the running web container (make up first): routes, CSP nonce, headers
	scripts/smoke-web.sh http://localhost:3000

up: network ## Serve the local web image on http://localhost:3000
	$(COMPOSE) up -d --build --wait

down: ## Stop the local environment
	$(COMPOSE) down

logs: ## Follow the nginx logs
	$(COMPOSE) logs -f --tail=100

ps: ## Show service status
	$(COMPOSE) ps

staging-up: network ## Serve the staging build locally (production-like)
	$(COMPOSE_STG) up -d --build --wait

staging-down: ## Stop the local staging build
	$(COMPOSE_STG) down
