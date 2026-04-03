# Credential-free test root: only variable definitions (see variables.tf).
# Run: terraform -chdir=tests/variables-only init -backend=false && terraform -chdir=tests/variables-only test
terraform {
  required_version = ">= 1.3"
}
