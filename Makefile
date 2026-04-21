# Capture the current value of the version of the package in DESCRIPTION
VERSION := $(shell grep Version DESCRIPTION | sed -e 's/Version: //')

help:
	@echo "Makefile commands:"
	@echo "  check     Check the built package"
	@echo "  install   Install the built package"
	@echo "  debug     Build and run a debug Docker container"
	@echo "  docs      Generate documentation with roxygen2"
	@echo "  website   Build the pkgdown website"
	@echo "  data-raw  Run the Rscripts in data-raw to regenerate datasets"


debug: clean
	docker run --rm -ti -w/mnt -v $(PWD):/mnt uofuepibio/epiworldr:debug make docker-debug

docker-debug:
	EPI_CONFIG="-DEPI_DEBUG -Wall -pedantic -g" R CMD INSTALL \
		--no-docs --build .

install:
	Rscript --vanilla -e 'devtools::install()'

README.md: README.qmd
	quarto render README.qmd

check:
	Rscript --vanilla -e 'devtools::check()'

docs:
	Rscript -e 'devtools::document()'

website:
	Rscript -e 'pkgdown::build_site()'

data-raw: data-raw/*.R
	for f in data-raw/*.R; do \
		R CMD BATCH $$f && rm -f $$f.Rout; \
	done

clean:
	Rscript -e 'devtools::clean_dll()'

EPIWORLD_BRANCH ?= master

update: clean-update
	git clone --depth=1 -b $(EPIWORLD_BRANCH) https://github.com/UofUEpiBio/epiworld tmp_epiworld && \
	rsync -avz --delete tmp_epiworld/include/measles inst/include/. && \
	rm -f inst/include/measles/*.mmd && \
	rsync -avz --delete tmp_epiworld/docs/assets/img/measles*png man/figures && \
	rm -rf tmp_epiworld

clean-update:
	rm -rf tmp_epiworld

.PHONY: build update check clean docs docker-debug dev website install install-dev help local-update local-update-diagrams checkv debug clean-update
