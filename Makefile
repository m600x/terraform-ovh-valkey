TF_TEST_DIR := tests/variables-only

.DEFAULT_GOAL := help

.PHONY: help test validate lint docs install

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

test: ## Run variable-validation tests (no OVH credentials needed)
	terraform -chdir=$(TF_TEST_DIR) init -backend=false -input=false
	terraform -chdir=$(TF_TEST_DIR) test

validate: ## Run terraform validate (credential-free, variables only)
	terraform -chdir=$(TF_TEST_DIR) init -backend=false -input=false
	terraform -chdir=$(TF_TEST_DIR) validate

lint: ## Check formatting (terraform fmt) and lint (tflint)
	terraform fmt -check -recursive
	tflint

docs: ## Regenerate README between BEGIN_TF_DOCS / END_TF_DOCS
	terraform-docs --config .terraform-docs.yml .

install: ## Install dev tools via Homebrew (tflint, terraform-docs, pre-commit)
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Homebrew not found. Install https://brew.sh then re-run, or install manually:"; \
		echo "  - tflint: https://github.com/terraform-linters/tflint"; \
		echo "  - terraform-docs: https://terraform-docs.io/user-guide/installation/"; \
		exit 1; \
	fi
	brew list tflint >/dev/null 2>&1 || brew install tflint
	brew list terraform-docs >/dev/null 2>&1 || brew install terraform-docs
	brew list pre-commit >/dev/null 2>&1 || brew install pre-commit
	tflint --init
	@echo "Installed: tflint, terraform-docs, pre-commit. Run: pre-commit install"
