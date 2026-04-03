# Credential-free variable validations (see README Tests section).
TF_TEST_DIR := tests/variables-only

.PHONY: test
test:
	terraform -chdir=$(TF_TEST_DIR) init -backend=false -input=false
	terraform -chdir=$(TF_TEST_DIR) test
