.PHONY: all clean
all: results/metrics.yml

data/processed/merged.csv: data/raw/sclp_sample.csv data/raw/cld_sample.csv R/01_prepare.R
	./scripts/run_r.sh R/01_prepare.R

results/metrics.yml: data/processed/merged.csv R/02_model.R
	./scripts/run_r.sh R/02_model.R

clean:
	rm -f data/processed/*.csv results/*.yml
