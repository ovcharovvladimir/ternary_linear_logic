export TERM ?= linux
export OPAMSOLVERTIMEOUT = 120

PKGS := $(shell darcs show files | grep '.*\.opam' |  sed -e 's|^|./|')

AT_NIX_DEF = at_nix() { \
	INTERACTIVE="$$1" ; \
	shift ; \
	RUN="$$*" ; \
	\
	if [ -n "$$INTERACTIVE" ] ; then \
		if [ ! -t 1 ] ; then \
	   		RUN="unbuffer $$RUN" ; \
		fi ; \
	\
		echo "$$RUN" ; \
	fi ; \
	\
	if $$(CMD=`command -v nix-shell` && [ -x $$CMD ]) ; then \
		nix-shell $(NIX_ARGS) --pure --quiet --run "$$RUN" ; \
	else \
		eval $$RUN ; \
	fi \
}
AT_NIX = $(AT_NIX_DEF); at_nix "interactive"
AT_NIX_NI = $(AT_NIX_DEF); at_nix ""
DONE = @printf "  🛠️  \033[33m%s\033[0m\n" "[$@] done"

.PHONY: default repl repl-lite console format test-format build watch setup sync \
	lock update upgrade install uninstall test run clean erase index docs subdirs

default: all

subdirs:
	@find -L [a-z]* -name "*.ml" -exec bash scripts/subdirs.sh {} \;
	@find -L [a-z]* -name "*.ml" -exec bash scripts/subdirs.sh {} \;
	@find -L [a-z]* -name "*.ml" -exec bash scripts/subdirs.sh {} \;
	@find . -name ".submodules" -type d -exec sh -c "find -L {} -mindepth 1 -maxdepth 1 -name '*__*' -type d -exec rm -Rf \{\} \;" \;

repl: ## Project utop
	@$(AT_NIX) opam config exec -- dune utop "$(LIB)"
	$(DONE)

repl-lite: ## Project utop without libraries loading
	@$(AT_NIX) opam config exec -- dune exec utop
	$(DONE)

console: ## Nix sandbox development environment
	nix-shell --pure
	$(DONE)

format: ## Reformat sources
	@($(AT_NIX) opam config exec -- dune build @fmt --auto-promote \
		--display=quiet --no-buffer -j 1 --diff-command \
		\"colordiff -y --suppress-common-lines\" || echo)
	$(DONE)

test-format: ## Check is sources formatted
	@$(AT_NIX) opam config exec -- dune build @fmt \
		--display=quiet --no-buffer -j 1 --diff-command \
		\"colordiff -y --suppress-common-lines\"
	$(DONE)

build: subdirs ## Build project
	@$(AT_NIX) opam config exec -- dune build "$(LIB)"
	$(DONE)

watch: ## Continuous project building
	@printf "  🛠️  \033[33m%s\033[0m\n" "Building..."
	@$(AT_NIX) opam config exec -- dune build -w
	$(DONE)

buildfix:
	@($(AT_NIX) opam remove -y httpaf; true)
	@($(AT_NIX) opam unpin httpaf; true)

all: subdirs format build

setup: ## Setup environment
	@$(AT_NIX_NI) command -v opam \
		| { read OPAM_CMD ; \
			if [ "$$OPAM_CMD" = "" ] ; then \
				echo "Executable opam not found" ; \
				exit 2 ; \
			fi ; }
	@$(AT_NIX_NI) opam --version \
		| { read OPAM_VER ; \
			if ! [ `printf "$$OPAM_VER" | head -c 2` = "2." ] ; then \
				printf "Unexpected version of opam (requires 2.x.x): " ; \
				echo "$$OPAM_VER" ; \
				exit 1 ; \
			fi ; }
	@$(AT_NIX) opam init -a --bare
	@$(AT_NIX) opam update
	@$(AT_NIX) opam switch create -yw --unlock-base --deps-only . --locked \
		--with-doc --with-test --empty
	@$(MAKE) sync
	$(DONE)

sync: buildfix ## Synchronize dependencies
	@$(AT_NIX) opam install -yw --unlock-base --deps-only $(PKGS) --locked \
		--with-doc --with-test
	$(DONE)

lock: ## Lock current dependencies versions
	@$(AT_NIX) opam lock $(PKGS)
	$(DONE)

update: ## Update dependencies
	@$(AT_NIX) opam install -yw --unlock-base --deps-only $(PKGS) \
		--with-doc --with-test
	@$(MAKE) lock
	$(DONE)

upgrade: ## Upgrade dependencies
	@$(AT_NIX) opam update
	@$(AT_NIX) opam install -yw --unlock-base --deps-only $(PKGS) \
		--with-doc --with-test
	@$(AT_NIX) opam upgrade -yw
	@$(MAKE) lock
	$(DONE)

install: ## Install project as package
	@if git describe --always --dirty > /dev/null 2>&1 ; then \
		$(AT_NIX) opam config exec -- dune subst ; \
	fi
	@$(MAKE) build
	@$(AT_NIX) opam config exec -- dune install
	$(DONE)

uninstall: ## Uninstall project's package
	@$(AT_NIX) opam config exec -- dune uninstall
	$(DONE)

test: ## Run tests
	@$(AT_NIX) opam config exec -- dune runtest -f \
		--no-buffer -j 1 \
		--diff-command \"colordiff -y --suppress-common-lines\"
	$(DONE)

run: ## Run project's executable with arguments
	@$(AT_NIX) opam config exec -- dune exec "$(RUN)"
	$(DONE)

clean: ## Clean build
	@$(AT_NIX) opam config exec -- dune clean
	@if $$(CMD=`command -v nix-shell` && [ -x $$CMD ]) ; then \
		nix-collect-garbage ; \
	fi
	$(DONE)

erase: clean ## Erase all extra files
	@$(AT_NIX) opam switch remove -y .
	git clean -dfXq
	@if $$(CMD=`command -v nix-shell` && [ -x $$CMD ]) ; then \
		nix-collect-garbage -d ; \
	fi
	$(DONE)

index: ## Browse interfaces & documentation
	@$(AT_NIX) ocp-browser

docs: ## Generate project documentation
	@echo 'TODO: Yeah, it would be nice to have `odocs` generation.'
	@exit 1
	$(DONE)

help: ## List rules
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk \
	'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
