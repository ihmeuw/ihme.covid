SHELL := /bin/bash

# R executable path; defaults to R_EXEC if set by parent environment
# --slave is even quieter than --quiet
R_EXEC ?= singularity exec --bind /snfs1:/snfs1 --bind /tmp:/tmp /share/singularity-images/lbd/releases/lbd_full_20200128.simg R --no-save --slave

# %p and %V expand to e.g., "~/R-site/x86_64-pc-linux-gnu/3.6.1"
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/libPaths.html
export R_LIBS_SITE = ~/R-site/%p/%V
# this is the expanded form of R_LIBS_SITE
EXPANDED_R_LIBS_SITE := $(shell $(R_EXEC) -e 'cat(sprintf("~/R-site/%s/%s.%s", R.version$$platform, R.version$$major, R.version$$minor))')


install-package: make-R_LIBS_SITE
	@# It's necessary to use withr as R_LIBS_SITE is *postpended* to .libPaths() by default
	@# build defaults to !quick, which is not what we want here
	@$(R_EXEC) -e "withr::with_libpaths('$(EXPANDED_R_LIBS_SITE)', devtools::install('.', quick = TRUE, build = TRUE, upgrade = 'never'))"


style: export R_LIBS_USER = ~/R/x86_64-pc-linux-gnu-library/3.6.1geo/
style:
	@$(R_EXEC) -e "styler::style_pkg('.')"


test:
	@$(R_EXEC) -e "suppressMessages(suppressWarnings(devtools::test('.')))"

test-package:
	@$(R_EXEC) -e "devtools::document(); devtools::check()"


.PHONY: make-R_LIBS_SITE
make-R_LIBS_SITE:
	@# manually expand site
	@if [[ ! -d $(EXPANDED_R_LIBS_SITE) ]]; then mkdir -p $(EXPANDED_R_LIBS_SITE); fi
