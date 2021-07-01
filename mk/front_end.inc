define NEWLINE


endef

usage:
	@echo -e "$(subst $(NEWLINE),\n,$(HELP_MESSAGE))"
