

```md
# Agents Guide

This document defines how agents work in this repo. It is **policy**: follow it unless a task explicitly says otherwise. Goals: clarity, reproducibility, auditable steps.

---

## 1. Context

- User:
- Work:
- Priorities: reproducibility, clarity, well-documented workflows.
- Default approach: prefer simple, auditable steps over clever automation.

### 1.1 Directory contract

- `R/` → reusable functions only; no side effects on import; no top-level I/O.
- `scripts/` → orchestration, CLI entry points, diagnostics helpers (small, no heavy compute).
- `reports/` → Quarto views that **read** pipeline outputs (QC, diagnostics, inference stubs).
- `outputs/` → all rendered artefacts (figures, tables, MD/HTML from reports).

### 1.2 Non-negotiables

1. Do not add new compute into QMDs. If a report needs data that does not exist, add a script step and a function.
2. Do not put rendered artefacts under `reports/`. QMDs must render into `outputs/...`.
3. Prefer plain-text, diffable artefacts (CSV, MD, YAML) in `outputs/`.
4. Use `here::here()` for all paths. No relative `../` or `getwd()` assumptions.

---

## 2. Platforms and general rules

- Cloud: expect containerised tools and fixed resources. Long jobs may time out.
- Laptop: respect limited resources and mixed OS quirks (Windows or Linux).
- Parallel agents may run locally and in the cloud. Sync often and separate concerns.
- Prefer tidyverse coding in general.

---

## 3. Environment wrapper (mandatory)

- Always execute R and Quarto via `./dev/run-in-env.sh`.
- Shared environment families: `r-core` (analysis, Quarto) and `r-bayes` (adds Stan toolchain). Select via `RUN_ENV_NAME` or `env/STACK`.
- Use per-project R packages via `R_LIBS_USER=$PWD/.rlib`.

### 3.1 Quick start

```bash
# Run R scripts deterministically
./dev/run-in-env.sh Rscript scripts/01_prepare.R
./dev/run-in-env.sh Rscript scripts/02_model.R

# Render a Quarto document
./dev/run-in-env.sh quarto render reports/analysis.qmd --output-dir outputs/reports

# Start an interactive R session
./dev/run-in-env.sh R
```

---

## 4. Git and PR workflow

We use GitHub for code, manuscript preparation, and project management. When you see “issue”, assume a GitHub Issue. Use `gh` CLI where convenient.

### 4.1 Branching and commits

- Work on `main`. Do not create long-lived feature branches unless agreed. If you suggest a branch, get approval.
- Be clear which branch you are on. Pull regularly so `main` stays in sync.
- Commit small, logical changes frequently. Push or pull often.
- Keep the working tree tidy. Avoid untracked files. Default to tracking files; if unsure, ask.
- Track **generated outputs under `outputs/`** (CSV, MD, HTML, PNG, and similar) so reviewers see what changed.
- Do not delete generated files in `outputs/` unless explicitly requested or they are superseded by a rename in the same PR. Call this out in the PR body.

### 4.2 Commit rules

- Keep commits frequent to keep the remote current.
- Reference Issues in commit titles when relevant, for example `fix: handle null IDs #123`.
- Keep commits atomic. Commit only the files you changed and list each path explicitly.  
  `git commit -m "<scoped message>" -- "path/to/file1" "path/to/file2"`
- For brand-new files:  
  `git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- "path/to/file1" "path/to/file2"`
- Always double-check `git status` before committing.
- Delete unused or obsolete files when your changes make them irrelevant. Revert files only when the change is yours or explicitly requested.
- Coordinate with other agents before removing their in-progress edits. Do not revert or delete work you did not author without agreement.
- Never run destructive Git operations such as `git reset --hard`, `rm` of tracked files, or checking out older commits to overwrite the working tree unless the user gives explicit written instruction here.
- Before deleting a file to resolve a local failure, stop and ask.
- Do not amend commits unless you have explicit written approval in the task thread.
- Moving, renaming, and restoring files is allowed.
- Quote paths containing brackets or parentheses when staging or committing.
- When running `git rebase`, avoid opening editors. Use `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` or pass `--no-edit`.

### 4.3 Code review and approval

- CI is not assumed.
- Use Pull Requests for review. You can ask for reviews on commits.
- Reference the driving Issue in the PR description. Include a closing keyword, for example `Closes #123`.

---

## 5. Development workflow

Prefer text-based, diffable artefacts and keep compute in the pipeline.

### 5.1 WRI cycle

1. **Write**: Report code in `reports/*.qmd`.
2. **Run**: build with `make` and render QMD to `outputs/reports/...`.
3. **Inspect**: review rendered MD or HTML in `outputs/...`.
4. **Iterate**: refine; commit both code and updated `outputs/`.

### 5.2 Principles for documents and code

- Separate interpretation from intermediate steps. `manuscript.qmd` presents final results in publication-ready format via apaquarto and consumes figures and tables generated earlier.
- The data processing and analysis pipeline should be simple, reproducible, and shareable on OSF.
- Readers care about the finished result. Avoid historical comments unless they aid understanding.
- Do not create ad hoc `v2` files. Use Git for versioning.
- Use Makefiles where helpful to automate the pipeline.
- QMDs are views and logs. Heavy compute belongs in scripts and `R/`.
- Do not mix computation and interpretation. Interpretive prose is based on QMD outputs. Inline numbers when helpful.
- YAML side outputs generated mid-pipeline may be read by `manuscript.qmd`. Prefer YAML over `.rds` for diffability.
- Heavy R objects, for example Bayesian mixed models, can be saved as `.rds`.
- Exploratory reports sit outside the core reproducible pipeline.
- Quarto defaults: `freeze: true`, `echo: true`. See the freeze policy.

### 5.3 Path management

- Use `here()` for all file paths. Include a `.here` file if needed.

### 5.4 Tests

- QMDs must render.
- Outputs must be free from errors and unexpected `NA`s. Always check the rendered Markdown.
- Add other tests as necessary.

### 5.5 Quarto freeze policy

Quarto writes cached renders into `_freeze/` directories adjacent to each QMD, for example `outputs/reports/exp1/_freeze/06_exp1_report/`. These directories are ignored by Git but must remain in place for deterministic rebuilds.

- Production or stable runs: prefer `freeze: true` for exact outputs and deterministic rebuilds.
- Local development: use the `local` profile (`configs/profiles/local.yaml`) with `reports: { freeze: auto }` to re-render only changed chunks.
- Before tagging outputs, restore `freeze: true` or remove the local profile and confirm the corresponding `_freeze/` directories are populated.

### 5.6 Core implementation principles

- Fail fast and surface errors early.
- Do not use defensive programming that hides missing data. Fix root causes.
- Assume a deterministic pipeline. If data is missing, fix upstream.
- Keep the file system organised. Use `scratch/` or `tmp/` for temporary work.
- Keep debugging work separate or avoid committing it once fixed.
- Implement the simplest solution that works. Avoid over-engineering.
- Favour clarity and explainability over performance or terseness. Assume the code will be shared. Avoid obvious comments.
- Avoid unnecessary intermediate data structures.

### 5.7 Long-running tooling and stuck runs

- Long-running tooling such as tests, Docker Compose, or migrations must use sensible timeouts or run in non-interactive batch mode. Never leave a shell command waiting indefinitely.
- If a Codex run is too long or stuck on tool calling, apply the same rule. Use non-interactive batch, explicit timeouts, or exit and resume with log inspection.

---
