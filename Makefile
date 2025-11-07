
.PHONY: all data analyse report clean slides talk

# Prefer the env wrapper, fall back gracefully if it is not available
RUNNER  ?= ./dev/run-in-env.sh
RSCRIPT ?= Rscript
QUARTO  ?= quarto

ifeq (,$(wildcard $(RUNNER)))
R_CMD := $(RSCRIPT)
Q_CMD := $(QUARTO)
else
R_CMD := $(RUNNER) Rscript --vanilla
Q_CMD := $(RUNNER) $(QUARTO)
endif

all: analyse report

outputs/data/processed.csv outputs/data/trials_filtered.csv outputs/results/cleaning.yml outputs/figures/rt_hist.png: scripts/01_prepare.R configs/cleaning.yml
	$(R_CMD) scripts/01_prepare.R

# Analyses: explicit list in display order
ANALYSES := \
	outputs/results/base_lm.yml
# append new analyses here:
# 	outputs/results/neighbour_density.yml \
# 	outputs/results/interaction_rt_accuracy.yml

analyse: $(ANALYSES)

# One clear rule per analysis
outputs/results/base_lm.yml: outputs/data/processed.csv scripts/02_base_lm.R
	$(R_CMD) scripts/02_base_lm.R
# When you add an analysis, add a matching rule:
# outputs/results/neighbour_density.yml: outputs/data/processed.csv scripts/03_neighbour_density.R
# 	$(R_CMD) scripts/03_neighbour_density.R

# Results document depends on named analyses and cleaning artefacts
report: $(ANALYSES) outputs/results/cleaning.yml outputs/figures/rt_hist.png reports/results.qmd
	$(Q_CMD) render reports/results.qmd --output-dir $(CURDIR)/outputs/reports

data: outputs/data/processed.csv

clean:
	rm -rf outputs/data outputs/results outputs/figures outputs/reports

# ---- Slides (Quarto) ----
slides: outputs/deliverables/agentic-ai-concrete/agentic-ai-concrete.pptx
talk: slides

outputs/deliverables/agentic-ai-concrete/agentic-ai-concrete.pptx: slides/agentic-ai-concrete.qmd talk/nord-theme.potx dev/run-in-env.sh
	$(Q_CMD) render slides/agentic-ai-concrete.qmd
	mkdir -p outputs/deliverables/agentic-ai-concrete
	mv -f slides/agentic-ai-concrete.pptx outputs/deliverables/agentic-ai-concrete/
