.PHONY: all data explore analyse report clean
all: analyse report

outputs/data/processed.csv: data/raw/sclp_sample.csv data/raw/cld_sample.csv R/01_prepare.R
	./scripts/run_r.sh R/01_prepare.R

outputs/figures/rt_hist.png outputs/results/cleaning.yml: data/raw/sclp_sample.csv R/02_explore.R
	./scripts/run_r.sh R/02_explore.R

outputs/results/metrics.yml: outputs/data/processed.csv R/02_model.R
	./scripts/run_r.sh R/02_model.R

report: outputs/results/metrics.yml reports/analysis.qmd
	./dev/run-in-env.sh quarto render reports/analysis.qmd --output-dir outputs/reports

data: outputs/data/processed.csv

explore: outputs/figures/rt_hist.png

analyse: outputs/results/metrics.yml

clean:
	rm -rf outputs/data outputs/results outputs/figures outputs/reports
