.DEFAULT_GOAL := help

.PHONY: help lint

help: ## List the available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

lint: ## Scan the working tree for secrets (Flutter targets arrive with the app scaffold)
	gitleaks dir --no-banner --redact .
