
.PHONY: all data analyse report clean slides talk

# Prefer the env wrapper, fall back gracefully if it is not available
RUNNER  ?= ./dev/run-in-env.sh
RSCRIPT ?= Rscript
QUARTO  ?= quarto

ifeq (,$(wildcard $(RUNNER)))
R_CMD := $(RSCRIPT)
Q_CMD := $(QUARTO)
else
R_CMD := $(RUNNER) Rscript
Q_CMD := $(RUNNER) $(QUARTO)
endif

all: analyse report

outputs/data/processed.csv outputs/data/trials_filtered.csv outputs/results/cleaning.yml outputs/figures/rt_hist.png: scripts/01_prepare.R configs/cleaning.yml
	$(R_CMD) scripts/01_prepare.R

outputs/results/metrics.yml: outputs/data/processed.csv scripts/02_model.R
	$(R_CMD) scripts/02_model.R

report: outputs/results/metrics.yml outputs/results/cleaning.yml outputs/figures/rt_hist.png reports/analysis.qmd
	$(Q_CMD) render reports/analysis.qmd --output-dir $(CURDIR)/outputs/reports

data: outputs/data/processed.csv

analyse: outputs/results/metrics.yml

clean:
	rm -rf outputs/data outputs/results outputs/figures outputs/reports

# ---- Slides (Quarto) ----
slides: outputs/deliverables/agentic-ai-concrete/agentic-ai-concrete.pptx
talk: slides

outputs/deliverables/agentic-ai-concrete/agentic-ai-concrete.pptx: slides/agentic-ai-concrete.qmd talk/nord-theme.potx dev/run-in-env.sh
	$(Q_CMD) render slides/agentic-ai-concrete.qmd
	mkdir -p outputs/deliverables/agentic-ai-concrete
	mv -f slides/agentic-ai-concrete.pptx outputs/deliverables/agentic-ai-concrete/
