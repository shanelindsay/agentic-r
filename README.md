# Agentic R Lexical-Decision Demo (scripts + Quarto)

A minimal, R-focused, agent-friendly pipeline for a **lexical decision** demo:
- **Task:** character-level lexical decision (RT/accuracy).
- **Data:** tiny slices from the Simplified Chinese Lexicon Project (SCLP; trial-level) and the Chinese Lexical Database (CLD; predictors).
- **Pipeline:** `make` orchestrates 3 tiny steps + a report → writes **diffable** outputs under `outputs/` (e.g., `outputs/results/metrics.yml`).

## Why this repo?
Agents (e.g., Codex/Claude Code/Cursor) behave like new lab members arriving cold. A tidy repo + Makefile + small scripts gives them structure; you stay in control by running scripts deterministically and reviewing diffs.

## Quick start (local)
1. Install R (≥ 4.2) and `make`.
2. Clone:  
   ```bash
   git clone <your-repo-url> agentic-r-lexdec-demo
   cd agentic-r-lexdec-demo
   ```
3. Run the pipeline:

   ```bash
   make          # or: make data && make analyse && make report
   ```
4. Inspect the outputs:
   - `outputs/data/processed.csv`
   - `outputs/results/cleaning.yml`
   - `outputs/results/metrics.yml` (intercept/slope(s)/R², plus `n_obs` and timestamp)
   - `outputs/reports/analysis.{html,pdf,docx,md}`

### Optional: micromamba wrapper

If you use micromamba:

```bash
./scripts/run_r.sh R/01_prepare.R
./scripts/run_r.sh R/02_model.R
```

The wrapper runs `Rscript` inside a named environment.

## Data (tiny, curated slices)

See the slide‑ready cheat‑sheet with talk‑safe claims, licences, and fetch locations: `docs/data-sources.md`.

* **SCLP trial‑level data**: trial‑level lexical decision for 8,105 characters + 4,864 pseudocharacters. Download full data from OSF (linked in the article), then use `scripts/build_raw_samples.R` to create a small slice and commit it as `data/raw/sclp_sample.csv`. See Wang et al., 2025. [DOI][sclp-doi]
* **CLD predictors**: lexical variables for simplified Mandarin words. Download from the Tübingen repository or use the online interface, then create a small slice `data/raw/cld_sample.csv` with at least `char`, `log_freq`, `strokes`. See Sun et al., 2018. [DOI][cld-paper]

> We **do not** redistribute the full datasets here. Please follow the providers’ terms when creating the tiny samples.

## How it works

* `configs/cleaning.yml`: shared parameters for trimming + file sources (full SCLP + CLD).
* `R/01_prepare.R`: applies trimming once, writes `outputs/data/trials_filtered.csv`, aggregates to per-character `outputs/data/processed.csv`, and emits cleaning summary + histogram.
* `R/02_model.R`: fits `lm(mean_log_rt ~ log_freq + strokes)`, then writes a small, **diffable** `outputs/results/metrics.yml`.
* `reports/analysis.qmd`: reads YAML and figure, renders to `outputs/reports/`.

## Suggested agent use

* Ask the agent to **add one predictor** or **change trimming**, but keep runs scripted: “Edit `R/02_model.R` to add `+ neighbors` and update `results/metrics.yml`.”
* Commit on a branch; raise a PR so the diff shows only what changed.

## Scientific thinking skills library

This repo now bundles the **scientific-thinking** skill cards from K-Dense AI’s [Claude Scientific Skills](https://github.com/K-Dense-AI/claude-scientific-skills) collection. The content lives in `skills/scientific-thinking/` and includes detailed guidance for:

- literature reviews, hypothesis generation, exploratory data analysis
- critical review, peer review, scholar evaluation, and scientific brainstorming
- statistical analysis, visualization, writing, and document-format skills (PDF, DOCX, PPTX, XLSX)

The skill content is licensed under MIT per `skills/scientific-thinking/LICENSE.md`, and each document skill subfolder carries additional notices where provided by the source project.

## Attribution

* SCLP: Wang, Y., Wang, Y., Chen, Q., & Keuleers, E. (2025). Simplified Chinese lexicon project: A lexical decision database with 8,105 characters and 4,864 pseudocharacters. Behavior Research Methods. [DOI][sclp-doi]
* CLD: Sun, C. C., Hendrix, P., Ma, J. Q., & Baayen, R. H. (2018). Chinese Lexical Database (CLD): A large‑scale lexical database for simplified Chinese. Behavior Research Methods. [DOI][cld-paper]

[sclp-doi]: https://doi.org/10.3758/s13428-025-02701-7
[cld-paper]: https://doi.org/10.3758/s13428-018-1038-3
