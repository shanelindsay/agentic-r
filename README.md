# Agentic R Lexical-Decision Demo (scripts + Quarto)

A minimal, R-focused, agent-friendly pipeline for a **lexical decision** demo:
- **Task:** character-level lexical decision (RT/accuracy).
- **Data:** Simplified Chinese Lexicon Project (SCLP; trial-level) and the Chinese Lexical Database (CLD; predictors).
- **Pipeline:** `make` orchestrates scripts for a report → writes **diffable** (text based, i.e. not .rds) machine and human readable outputs under `outputs/` (for example `outputs/results/base_lm.yml`).

## Why this repo?
Agents (e.g., Codex/Claude Code/Cursor) behave like new lab members arriving cold. A tidy repo + Makefile + small scripts gives them structure; you stay in control by running scripts deterministically and reviewing diffs.

## Quick start (local)
```bash
make          # or: make data && make analyse && make report
```
Inspect the outputs:
- `outputs/data/processed.csv`
- `outputs/results/cleaning.yml`
- `outputs/results/base_lm.yml`
- `outputs/reports/results.{html,pdf,docx,md}`

Add a new analysis
1. Create `scripts/NN_slug.R` that reads `outputs/data/processed.csv` and writes `outputs/results/slug.yml` with summary numbers.
2. In the Makefile, add `outputs/results/slug.yml` to the `ANALYSES` list and an explicit rule that runs your script.
3. In `reports/results.qmd`, add a new section that reads `slug.yml` and prints the relevant fields.
4. Run `make analyse report` and review the new section.

### Optional: run scripts manually (inside project env)
The Makefile calls `./dev/run-in-env.sh` automatically when available. You can also invoke steps yourself:
```bash
./dev/run-in-env.sh Rscript scripts/01_prepare.R
./dev/run-in-env.sh Rscript scripts/02_base_lm.R
./dev/run-in-env.sh quarto render reports/results.qmd --output-dir outputs/reports
```

To iterate quickly with lighter HTML defaults, enable the Quarto `local` profile:
```bash
QUARTO_PROFILE=local make report
# or: ./dev/run-in-env.sh quarto render reports/results.qmd --profile local --output-dir outputs/reports
```
The profile configuration lives at `reports/_quarto-profile-local.yaml`.

## Data

See licences and fetch locations in `docs/data-sources.md`.

* **SCLP trial-level data**: trial-level lexical decision for 8,105 characters + 4,864 pseudocharacters. Download the full data from OSF (see paper). (See [sclp-doi])

* **CLD predictors**: lexical variables for simplified Mandarin words. Download from the CLD website, variables such as  `char`, `log_freq`, `strokes`. (See [cld-paper])

## How it works

* `configs/cleaning.yml`: shared parameters for trimming + file sources (full SCLP + CLD).
* `scripts/01_prepare.R`: applies trimming once, writes `outputs/data/trials_filtered.csv`, aggregates to per-character `outputs/data/processed.csv`, and emits cleaning summary + histogram.
* `scripts/02_base_lm.R`: fits `lm(mean_log_rt ~ log_freq + strokes)`, then writes a small, **diffable** `outputs/results/base_lm.yml`.
* `reports/results.qmd`: reads YAML and figure, renders to `outputs/reports/`.

## Scientific thinking skills library

This repo bundles the **scientific-thinking** skill cards from K-Dense AI’s [Claude Scientific Skills](https://github.com/K-Dense-AI/claude-scientific-skills) collection. The content lives in `skills/scientific-thinking/` and includes detailed guidance for:

- literature reviews, hypothesis generation, exploratory data analysis
- critical review, peer review, scholar evaluation, and scientific brainstorming
- statistical analysis, visualization, writing, and document-format skills (PDF, DOCX, PPTX, XLSX)

The skill content is licensed under MIT per `skills/scientific-thinking/LICENSE.md`, and each document skill subfolder carries additional notices where provided by the source project.

## Attribution

* SCLP: Wang, Y., Wang, Y., Chen, Q., & Keuleers, E. (2025). Simplified Chinese lexicon project: A lexical decision database with 8,105 characters and 4,864 pseudocharacters. Behavior Research Methods. [DOI][sclp-doi]
* CLD: Sun, C. C., Hendrix, P., Ma, J. Q., & Baayen, R. H. (2018). Chinese Lexical Database (CLD): A large-scale lexical database for simplified Chinese. Behavior Research Methods. [DOI][cld-paper]

[sclp-doi]: https://doi.org/10.3758/s13428-025-02701-7
[cld-paper]: https://doi.org/10.3758/s13428-018-1038-3
