.PHONY: all clean
all: results/metrics.yml

data/processed/merged.csv: data/raw/sclp_sample.csv data/raw/cld_sample.csv R/01_prepare.R
	./scripts/run_r.sh R/01_prepare.R

results/metrics.yml: data/processed/merged.csv R/02_model.R
	./scripts/run_r.sh R/02_model.R

clean:
	rm -f data/processed/*.csv results/*.yml

# ---- Slides (Quarto) ----
.PHONY: slides talk
slides: outputs/deliverables/agentic-ai-concrete/agentic-ai-concrete.pptx
talk: slides

outputs/deliverables/agentic-ai-concrete/agentic-ai-concrete.pptx: slides/agentic-ai-concrete.qmd talk/nord-theme.potx dev/run-in-env.sh
	./dev/run-in-env.sh quarto render slides/agentic-ai-concrete.qmd
	mkdir -p outputs/deliverables/agentic-ai-concrete
	mv -f slides/agentic-ai-concrete.pptx outputs/deliverables/agentic-ai-concrete/
