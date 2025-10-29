# Agentic R Lexical-Decision Demo (Makefile pipeline)

A minimal, R-focused, agent-friendly pipeline for a **lexical decision** demo:
- **Task:** character-level lexical decision (RT/accuracy).
- **Data:** tiny slices from the Simplified Chinese Lexicon Project (SCLP; trial-level) and the Chinese Lexical Database (CLD; predictors).
- **Pipeline:** `make` orchestrates two small R scripts → writes a **diffable** results file (`results/metrics.yml`).

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
   make          # or: Rscript R/01_prepare.R && Rscript R/02_model.R
   ```
4. Inspect the output:
   `results/metrics.yml` (intercept/slope(s)/R², plus N and timestamp).

### Optional: micromamba wrapper

If you use micromamba:

```bash
./scripts/run_r.sh R/01_prepare.R
./scripts/run_r.sh R/02_model.R
```

The wrapper runs `Rscript` inside a named environment.

## Data (tiny, curated slices)

* **SCLP trial-level data**: trial-level lexical decision for 8,105 characters + 4,864 pseudocharacters. Download full data from OSF (see paper), then use `scripts/build_raw_samples.R` to create a small slice and commit it as `data/raw/sclp_sample.csv`. ([PMC][1])
* **CLD predictors**: lexical variables for simplified Mandarin words. Download from the CLD website and create a small slice `data/raw/cld_sample.csv` with at least `char`, `log_freq`, `strokes`. ([SpringerLink][2])

> We **do not** redistribute the full datasets here. Please follow the providers’ terms when creating the tiny samples.

## How it works

* `R/01_prepare.R`: trims trials, aggregates to per-character `mean_log_rt` (ms on log scale) and `acc_rate`, joins to CLD predictors → writes `data/processed/merged.csv`.
* `R/02_model.R`: fits `lm(mean_log_rt ~ log_freq + strokes)`, then writes a small, **diffable** `results/metrics.yml`.

## Suggested agent use

* Ask the agent to **add one predictor** or **change trimming**, but keep runs scripted: “Edit `R/02_model.R` to add `+ neighbors` and update `results/metrics.yml`.”
* Commit on a branch; raise a PR so the diff shows only what changed.

## Attribution

* SCLP: Wang et al., 2025. Trial-level data on OSF; paper open access. ([PMC][1])
* CLD: Sun, Hendrix, Ma, & Baayen, 2018 (download & documentation at chineselexicaldatabase.com). ([SpringerLink][2])

[1]: https://pmc.ncbi.nlm.nih.gov/articles/PMC12185670/
[2]: https://link.springer.com/article/10.3758/s13428-018-1038-3?utm_source=chatgpt.com
