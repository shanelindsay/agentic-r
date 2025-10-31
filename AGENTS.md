# Agents Guide

This document defines how agents work in this repo. It is **policy**: follow it unless a task explicitly says otherwise. Goals: clarity, reproducibility, auditable steps.

## 1) Context

* User: 
* Work: 
* Priorities: reproducibility, clarity, well documented workflows.
* Default approach: prefer simple, auditable steps over clever automation.

## 2) Canonical Workflow & Repository Roles

**Single source of truth for compute:** `{targets}` in `_targets.R` and modular functions in `R/`.
**Reports (QMD):** present/diagnose results; they do not own heavy computation.

**Directory contract**

- `R/` -> reusable functions only; no side effects on import; no top-level I/O.
- `scripts/` -> orchestration, CLI entrypoints, Slurm wrappers, diagnostics helpers (tiny, no heavy compute).
- `reports/` -> Quarto "views" that **read** pipeline outputs (QC, diagnostics, inference stubs).
- `outputs/` -> all rendered artefacts (figures, tables, md/html from reports).

**Non-negotiables**
1. Do not add new compute into QMDs. If a report needs data that doesn't exist, add a target + function.
2. Do not put rendered artefacts under `reports/`. QMDs must render into `outputs/...`.
3. Prefer plain-text, diffable artefacts (CSV/MD/YAML) in `outputs/`.
4. Use `here::here()` for all paths; no relative "../" or `getwd()` assumptions.

### 2.1 General rules

* Cloud: expect containerised tools and fixed resources. Long jobs may time out.
* Laptop: respect limited resources and mixed OS quirks (Windows or Linux).
* HPC: use batch schedulers, handle larger data and high memory workloads.
* Parallel agents may be running locally and in the cloud. Sync often and separate concerns.

### 2.2 Environment wrapper (mandatory)

* Always execute R and Quarto via `./dev/run-in-env.sh`.
* Shared environment families: `r-core` (analysis, targets, Quarto) and `r-bayes` (adds Stan toolchain). Select via `RUN_ENV_NAME` or `env/STACK`.
* Use per-project R packages via `R_LIBS_USER=$PWD/.rlib`.

**Quickstart**

```bash
# Run an R script
./dev/run-in-env.sh Rscript scripts/01_data_processing.R

# Render a Quarto document
./dev/run-in-env.sh quarto render manuscript/manuscript.qmd

# Start an interactive R session
./dev/run-in-env.sh R

```

## 3) Git & PR Workflow (Atomic + Frequent)

We use GitHub for code, manuscript preparation, and project management. When you hear "issue" - assume github issue (and interact with gh CLI - you have token to access).

### 3.1 Branching and commits

* Work on `main`, DO NOT USE worktree or switch branches for new tasks. You can suggest it when you think it is a good idea but you should get approval.
* Be clear which branch you are working on. Pull regularly so `main` stays synced.
* Commit small, logical changes frequently. After progress, commit and push or pull frequently.
* Keep the working tree tidy. Avoid untracked files - assume as default files should be tracked. If in doubt about tracking, ask.
* Track **generated outputs under `outputs/`** (CSV, MD, HTML, PNG, etc.) so reviewers see what changed.
* Do not delete generated files in `outputs/` unless explicitly requested or they're superseded by a rename in the same PR (call this out in the PR body).

## Atomic Commits and Git management

We operate on the principle of **atomic commits**.

We normally use GitHub Issues to coordinate.

We may have multiple agents working in parallel, and users working on different machines.

---

# Commit Rules

- **Keep commits frequent** - keep the remote up to date as much as possible.
- **Reference Issues** in commit titles if you are working on an issue (e.g., `fix: handle null IDs #123`).
- **Keep commits atomic** - commit only the files you touched and list each path explicitly.
  `git commit -m "<scoped message>" -- "path/to/file1" "path/to/file2"`
  For brand-new files, use:
  `git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- "path/to/file1" "path/to/file2"`
- **Always double-check** `git status` before any commit.
- **Delete unused or obsolete files** when your changes make them irrelevant (e.g., refactors, feature removals).
  Revert files only when the change is yours or explicitly requested.
- **Coordinate with other agents** before removing their in-progress edits. Assume any edits you encounter have a purpose.
  Do not revert or delete work you did not author unless everyone agrees.
- **Never use** `git restore` (or similar commands) to revert files you did not author.
  Coordinate with other agents so their in-progress work stays intact.
- **ABSOLUTELY NEVER** run destructive Git operations (e.g., `git reset --hard`, `rm`, `git checkout` / `git restore` to an older commit) unless the user gives explicit written instruction in this conversation.
  Treat these commands as catastrophic; if you are even slightly unsure, stop and ask before touching them.
- **Before deleting a file to resolve a local failure, stop and ask the user.**
  Other agents are often editing adjacent files; deleting their work to silence an error is never acceptable without explicit approval.
- **Never amend commits** unless you have explicit written approval in the task thread.
- **Moving, renaming, and restoring files** is allowed.
- **Quote paths containing brackets or parentheses** (e.g., `src/app/[candidate]/**`) when staging or committing so the shell does not treat them as globs or subshells.
- **When running `git rebase`**, avoid opening editors:
  export `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` (or pass `--no-edit`) so default messages are used automatically.

### 3.2 Code review and approval

* We do not use CI in these workflows.
* Use Pull Requests for review. You can ask for reviews on commits.
* Reference the driving issue in the PR description. Include a closing keyword, for example `Closes #123`.

## 4) Issue-Driven Project Management

Single source of truth: GitHub Issues drive all work. PRs link back to their issue. Discussion stays in the issue.

### 4.1 Issue hygiene and planning

* Use the documented labels and naming conventions.
* Group related work under epics. Use parent plus child issue links.
* When starting work, assign yourself and add a short plan.
* Post progress updates directly to the relevant issue so parallel agents and collaborators stay aligned.
* For out-of-scope work, suggest additional issues.
* Keep implementation details in the PR. Keep the issue high level.
* Every PR body must include `Closes #<issue-number>` when working from an issue where appropriate.

**CLI helpers**

* Sub-issues: `gh sub-issue create --parent 123 --title "Implement user authentication"`.

### 4.2 Labels and fields

Use orthogonal labels.

* Type: `type:pm`, `type:docs`, `type:workflow`, `type:analysis`, `type:infra`, `type:writing`, `type:decision`.
* Agentability: `role:agent`, `role:agent+qc` which means agent executes and human checks, `role:human`.
* Run context: `run:flexible` which means local or cloud is fine, HPC possible, `run:hpc-only`.
* Size: `size:xs`, `size:s`, `size:m`, `size:l`, `size:xl` which is an epic.
* Priority: `priority:P0`, `priority:P1`, `priority:P2` (optional).
* Status: `status:blocked`, `status:ready`, `status:in-progress`, `status:review-needed`, `status:done`.

**Size calibration**

* XS which is a one touch change: trivial tweak in a single file, no design. No new branch or worktree is needed.
* S which is a straightforward change: a few files, clear acceptance criteria, no cross domain coordination. Suitable for a single agent end to end.
* M which is a more complex and lengthy change: multiple files, long running tasks, human quality checks recommended.
* L which is a co-ordinated change: cross domain work where sequencing matters. Usually split into 2 to 5 S or M children. The parent tracks coordination only.
* XL which is an epic umbrella: never implement directly. Tracks a theme or outcome across many issues.

Keep a single issue with a checklist when items are small verifications under one assignee and one PR.

Split into sub-issues when any are true:

* Multiple assignees or handoffs which means agent to human quality checks.
* Independent scheduling where some parts can land earlier.

### 4.3 Working on issues and PRs

* When starting, mark `status:in-progress` on the issue. Update as needed.
* Regularly update the issue with comments as progress is made.
* Draft PRs are recommended.

## 5) Repository Map

* `data/` -- raw and processed experimental data
  * `raw/` -- raw data
  * `processed/` -- cleaned, analysis-ready datasets
* `scripts/` -- orchestration + CLI (no heavy compute). Includes:
  * `run_targets_*.R` launchers, `tools/`, `tests/`, and Slurm wrappers under `slurm/`.
* `reports/` -- Quarto "views" that consume outputs (`qc_group.qmd`, `qc_subject.qmd`, `input_qc.qmd`, `inference/m4_cluster_inference.qmd`).
* `archive/legacy-qmd/` -- archived numbered QMDs (`0x_*`). Kept for historical reference only.
* `outputs/` -- all rendered artefacts from pipeline and reports (figures, tables, reports markdown/html).
* `docs/` -- project documentation and reference materials.
* `manuscript/` -- publication documents. No heavy computation. Consumes prepared outputs.
  * `submission/` -- frozen outputs for journal handoff.
* `deliverables/` -- external-facing materials such as talks, conferences, media.
* `dev/` -- development guides, documentation, and environment tools.

## 6) Turn-Based Execution for Agents

* Hard limit: actions only occur during the agent's active turn. Between turns, the agent cannot poll Slurm, tail logs, read notifications, or schedule timers.
* No background promises: do not claim ongoing monitoring. Use conditional phrasing for future work, for example "On your reply, I can ...".
* Do not ask Shane to run commands or submit jobs. The agent runs commands and submits jobs.
* After any submission or long run, state where outputs or logs will appear, for example `outputs/logs/<job>-<JOBID>.{out,err}`. Suggest sensible next step options for the next turn, such as a status check, a short log tail and summary, or a targeted validation. If the next step is clear, continue with the task.

## 7) Development Workflow

Because agents are involved, prefer text-based, diffable artefacts--**and keep compute in the pipeline**.

### 7.1 WRI cycle

1. **Write**: pipeline code in `R/` + targets in `_targets.R`; report code in `reports/*.qmd`.
2. **Run**: build with `{targets}`; render QMD **to `outputs/reports/...`**.
3. **Inspect**: review rendered MD/HTML in `outputs/...`.
4. **Iterate**: refine; commit both code and updated `outputs/`.

### 7.2 Principles for documents and code

* Separate interpretation from intermediate steps. `manuscript.qmd` presents final results in a publication-ready format via apaquarto. It consumes figures and tables generated earlier.
* The data processing and analysis pipeline should be simple and reproducible and shareable on OSF.
* Readers care about the finished result. Avoid historical comments unless they aid understanding.
* Do not create ad hoc `v2` files. Use GitHub for versioning.
* Use Makefiles where helpful to automate the pipeline.
* QMDs are **views** and logs; heavy compute belongs in targets + `R/`.
* Do not mix computation and interpretation. Interpretive prose is based on QMD outputs and numbers can be inlined when needed.
* YAML side outputs generated mid pipeline may be read by `manuscript.qmd`. Prefer YAML over `.rds` for plain text diffability.
* Heavy R objects, for example Bayesian mixed models, can be saved as `.rds`.
* Exploratory reports are outside the core reproducible pipeline.
* Quarto defaults: `freeze: true`, `echo: true`. See freeze policy below.
* Prepare final tables and themed figures at the end of the pipeline and consume them in `manuscript.qmd`. No computation (except potentially minor formatting) should occur in `manuscript.qmd`.

### 7.3 Path management

* Use `here()` for all file paths. Add a `.here` file if needed.

### 7.4 Tests

* QMDs must render.
* Outputs must be free from errors and unexpected `NA`s. Always check the rendered Markdown.
* Add other tests as necessary.

### 7.5 Quarto freeze policy

Quarto writes cached renders into `_freeze/` directories adjacent to each QMD (e.g., `outputs/reports/exp1/_freeze/06_exp1_report/`); these directories are ignored by Git but must remain in place for deterministic rebuilds.

* Production/stable runs: prefer `freeze: true` for exact outputs and deterministic rebuilds.
* Local development: use the `local` profile (`configs/profiles/local.yaml`) with `reports: { freeze: auto }` to re-render only changed chunks.
* Before tagging outputs, restore `freeze: true` (or remove the local profile) and confirm the corresponding `_freeze/` directories are populated.

### 7.6 Core implementation principles

* Fail fast and surface errors early.
* Do not use defensive programming such as conditional fallbacks for missing data.
* No workarounds or fallbacks. Fix root causes.
* Assume a deterministic pipeline. If data is missing, fix upstream.
* Keep the file system organised. Use `scratch/` or `tmp/` for temporary work.
* Keep debugging work separate or avoid committing it once fixed.
* Implement the simplest solution that works. Avoid over engineering.
* Prioritise clarity and explainability over performance or terseness. Assume the code will be shared and avoid obvious comments.
* Avoid unnecessary intermediate data structures.

### 7.7 Long running tooling and stuck runs

* Long running tooling such as tests, docker compose, or migrations must always be invoked with sensible timeouts or in non interactive batch mode. Never leave a shell command waiting indefinitely. Prefer explicit timeouts, scripted runs, or log polling after the command exits.
* If a Codex run is too long or stuck on tool calling, apply the same rule. Use non interactive batch, explicit timeouts, or exit and resume with log inspection.

### 7.9 Definition of Done (checklists)

**Pipeline change (R/ + targets)**
 - [ ] New/changed targets documented in `_targets.R` comments.
 - [ ] Determinism: seeds/plans set; no silent randomness.
 - [ ] Outputs land under `outputs/{data,results,figures,tables}`.
 - [ ] `README`/docs updated where paths or user steps changed.

**Report change (reports/*.qmd)**
 - [ ] Reads from outputs only; no heavy compute.
 - [ ] `freeze` set appropriately; renders to `outputs/reports/...`.
 - [ ] Example render command added to `reports/README.md`.

## 8) Finalising

* Merge the PR to close the linked issue automatically when possible.
* After merge, confirm the repository is clean and documentation is up to date.t
