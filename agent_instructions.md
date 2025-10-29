# Agent instructions (read before making changes)

- Always run R scripts via `make` (or `Rscript`) rather than running code inline.
- Do **not** edit files in `data/raw/`.
- Write derived tables to `data/processed/` and final numbers to `results/metrics.yml`.
- If you add a predictor, update `R/02_model.R` and preserve the YAML schema.
- Keep changes small; write clear commit messages with a 1–2 line rationale.
