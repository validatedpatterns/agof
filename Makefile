EXTRA_PLAYBOOK_OPTS ?=
INVENTORY ?= ~/inventory_agof

.PHONY: help
help: ## This help message
	@echo "Pattern: $(NAME)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

preinit: ## Setup ansible environemnt - configure ansible.cfg and download collections
	ansible-playbook init_env/pre_init_env.yml $(EXTRA_PLAYBOOK_OPTS)

fix_aws_dns: ## Update public DNS for AWS - needed when a VM cold starts
	ansible-playbook init_env/aws/fix_aws_dns.yml $(EXTRA_PLAYBOOK_OPTS)

install: preinit ## Install the pattern - including bootstrapping an AWS environment to run it in
	ansible-playbook site.yml $(EXTRA_PLAYBOOK_OPTS)

aws_uninstall: ## Uninstall the AWS environment for the pattern, including its DNS entries
	ansible-playbook init_env/aws/teardown.yml $(EXTRA_PLAYBOOK_OPTS)

from_os_install: preinit ## Install assuming registered RHEL VM(s)
	ansible-playbook -i $(INVENTORY) hosts/main.yml $(EXTRA_PLAYBOOK_OPTS)
	ansible-playbook -i $(INVENTORY) configure_aap.yml $(EXTRA_PLAYBOOK_OPTS)

api_install: preinit ## Install assuming *just* an AAP endpoint
	ansible-playbook configure_aap.yml $(EXTRA_PLAYBOOK_OPTS)
