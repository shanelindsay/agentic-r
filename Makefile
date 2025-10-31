.PHONY: all data explore analyse report clean
all: analyse report

outputs/data/trials_filtered.csv outputs/results/cleaning.yml: R/01_prepare.R configs/cleaning.yml
	./scripts/run_r.sh R/01_prepare.R

outputs/data/processed.csv: outputs/data/trials_filtered.csv R/01_prepare.R configs/cleaning.yml
	./scripts/run_r.sh R/01_prepare.R

outputs/figures/rt_hist.png: outputs/data/trials_filtered.csv R/02_explore.R
	./scripts/run_r.sh R/02_explore.R

outputs/results/metrics.yml: outputs/data/processed.csv R/03_model.R
	./scripts/run_r.sh R/03_model.R

report: outputs/results/metrics.yml outputs/results/cleaning.yml outputs/figures/rt_hist.png reports/analysis.qmd
	./dev/run-in-env.sh quarto render reports/analysis.qmd --output-dir $(CURDIR)/outputs/reports

data: outputs/data/processed.csv

explore: outputs/figures/rt_hist.png

analyse: outputs/results/metrics.yml

clean:
	rm -rf outputs/data outputs/results outputs/figures outputs/reports
