.PHONY: restore test pipeline refresh docs sync publish

restore:
	Rscript -e 'renv::restore()'

test:
	Rscript tests/run_tests.R

pipeline:
	Rscript scripts/run_pipeline.R --refresh=false --write-csv=false

refresh:
	Rscript scripts/run_pipeline.R --refresh=true --write-csv=false

docs:
	quarto render

sync:
	scripts/sync_branch.sh

publish:
	scripts/publish_branch.sh
