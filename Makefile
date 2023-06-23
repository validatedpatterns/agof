EXTRA_PLAYBOOK_OPTS ?=

.PHONY: help
help: ## This help message
	@echo "Pattern: $(NAME)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install: ## Install the pattern - including bootstrapping an AWS environment to run it in
	ansible-playbook site.yml $(EXTRA_PLAYBOOK_OPTS)

uninstall: ## Uninstall the AWS environment for the pattern, including its DNS entries
	ansible-playbook init_env/aws/teardown.yml $(EXTRA_PLAYBOOK_OPTS)
