install: ## Installs ts
	install -m 0755 src/tmux-session.pl $(HOME)/.local/bin/ts

uninstall: ## Uninstalls ts
	$(RM) $(HOME)/.local/bin/ts

help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: help install uninstall
