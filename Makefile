EXTRA_PLAYBOOK_OPTS ?=
INVENTORY ?= ~/inventory_agof

.PHONY: help
help: ## This help message
	@echo "Pattern: $(NAME)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

check: ## Validate that all required variables are set and provide guidance for missing ones
	ANSIBLE_CALLBACK_RESULT_FORMAT=yaml ansible-playbook check_vars.yml $(EXTRA_PLAYBOOK_OPTS)

preinit: ## Setup ansible environemnt - configure ansible.cfg and download collections
	ansible-playbook pre_init/main.yml $(EXTRA_PLAYBOOK_OPTS)

fix_aws_dns: ## Update public DNS for AWS - needed when a VM cold starts
	ansible-playbook init_env/aws/fix_aws_dns.yml $(EXTRA_PLAYBOOK_OPTS)

install: preinit ## Install the pattern - including bootstrapping an AWS environment to run it in
	ansible-playbook site.yml $(EXTRA_PLAYBOOK_OPTS)

aws_uninstall: ## Uninstall the AWS environment for the pattern, including its DNS entries
	ansible-playbook init_env/aws/teardown.yml $(EXTRA_PLAYBOOK_OPTS)

from_os_install: preinit ## Install on registered RHEL VM(s), using the containerized installer
	ansible-playbook -i $(INVENTORY) containerized_install/main.yml $(EXTRA_PLAYBOOK_OPTS)

api_install: preinit ## Install assuming *just* an AAP endpoint
	ansible-playbook -i $(INVENTORY) configure_aap.yml $(EXTRA_PLAYBOOK_OPTS)

openshift_vp_preinit: ## Install credentials and overrides as part of OpenShift Validated Patterns framework
	ansible-playbook pre_init/openshift_vp_preinit.yml $(EXTRA_PLAYBOOK_OPTS)

openshift_api_install: ## Just API install using inventory
	ansible-playbook -i $(INVENTORY) configure_aap.yml $(EXTRA_PLAYBOOK_OPTS) -e @~/agof_overrides.yml

openshift_vp_install: openshift_vp_preinit ## Single-target install for OpenShift Validated Patterns Framework
	ansible-playbook -i ~/inventory_agof pre_init/main.yml $(EXTRA_PLAYBOOK_OPTS) -e @~/agof_overrides.yml
	ansible-playbook -i ~/inventory_agof configure_aap.yml $(EXTRA_PLAYBOOK_OPTS) -e @~/agof_overrides.yml
