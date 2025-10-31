## Slide 1 — Title (00:00–00:45)

* Agentic AI for reproducible language science: from prompt to pipeline
* Speaker + affiliation
* Link/QR to repo (demo materials)

## Slide 2 — Quick poll (00:45–01:30)

* Where are you with agents today?

  * Never used · Tried a bit · Use weekly · Use daily
* What part of your workflow would you try first?

  * Cleaning · Modelling · Reporting · Something else

## Slide 3 — Why agents now (01:30–03:00)

* **Smart enough** for multi‑step, tool‑using tasks
* **Cheap enough** to be practical for students/labs
* Ecosystem maturity: IDEs, APIs, and coding agents are accessible
* Bottom line: it’s finally the **year of agents**

## Slide 4 — What is an agent (03:00–04:30)

* Planner · Tool‑caller · Executor · Reporter (logs)
* Think “new lab member arriving cold to your repo”
* Best when work is scripted, documented, and rerunnable

## Slide 5 — Costs (04:30–05:45)

* One **knob**: **speed vs spend** (smaller/faster vs larger/slower)
* Keep prompts short; avoid chatty back‑and‑forth
* Batch changes; run only what you’ll keep

## Slide 6 — Reproducible science: the brief (05:45–07:30)

* Research **codebase** with a lifecycle: **plan → execute → review → share → re‑run**
* Reproducibility = others can repeat the steps and get the same artefacts
* Agents fit this when outputs are **scripted, logged, and diffable**

## Slide 7 — Coding patterns & agents (07:30–09:30)

* **Monolithic script**: quick start; fragile; agents may “sprawl”
* **Numbered scripts**: clearer stages; agent edits are localised
* **Makefile‑orchestrated scripts**: explicit dependencies; deterministic runs
* How agents plug in: draft changes → you run → results are diffed

## Slide 8 — Repo you’ll see (09:30–10:30)

* README with quickstart
* `Makefile` + two small R scripts (`01_prepare.R`, `02_model.R`)
* `data/raw` (tiny, locked) · `data/processed` · `results/metrics.yml`

## Slide 9 — Minimal agent rules (10:30–11:30)

* Use the wrapper to run scripts; do not touch `data/raw`
* Write results to `results/` as CSV/YAML
* Explain changes in the PR description

## Slide 10 — Demo setup (11:30–12:00)

* Baseline: `make` once → show `results/metrics.yml`
* Backup: pre‑baked PR + 30–45 s clip of a successful run

## Slide 11 — Agent demo: **Builder** (12:00–16:00)

* Prompt: “Add *neighbourhood* as a predictor; write coefficient to `metrics.yml`; update README ‘How to run’”
* Re‑run: `make` deterministically
* Show: small diff in `metrics.yml` (new field + timestamp)

## Slide 12 — Agent demo: **Checker** (16:00–18:30)

* Prompt: “Given the PR diff + `metrics.yml`, produce a checklist”

  * Wrapper used? Raw data untouched? Outputs updated?
* Post checklist as PR comment; you approve or request changes

## Slide 13 — Interactive vs script‑based (18:30–20:00)

* Draft interactively; **execute** by script/Makefile
* Benefits: determinism, speed to rerun, easy review

## Slide 14 — GitHub review (20:00–21:30)

* Branch → PR → concise description → human review → merge
* Keep changes small and scoped; rationale in commit message

## Slide 15 — End‑to‑end reporting (21:30–22:45)

* Manuscript/report reads numbers from `results/`
* Transparent, traceable updates over time

## Slide 16 — Containers: why they help (22:45–24:15)

* Agents are **stateless**; containers provide a **predictable start**
* If a **stranger** can run it, an **agent** can too

## Slide 17 — Agent patterns to copy (24:15–25:45)

* **Builder** proposes edits
* **Checker** audits diffs and outputs
* Optional **Critic** suggests tests/diagnostics
* Humans approve and run

## Slide 18 — Where to start (25:45–27:00)

* Pick one stage: cleaning, modelling, or reporting
* Keep tasks small; measure time saved against review time

## Slide 19 — Audience‑aware options (27:00–28:00)

* Systems you might see locally: Qwen · Kimi · GLM · ERNIE · Hunyuan · Doubao
* Use what your institution/cloud supports

## Slide 20 — Practical tips (28:00–29:30)

* Short prompts; explicit file paths; one change at a time
* Write to **diffable** tables; keep raw data read‑only
* Pre‑record a fallback run for live talks

## Slide 21 — Memes & memory aids (29:30–30:30)

* “If a stranger can run it, an agent can too”
* “Agents don’t bring cake; they write the README”
* One tasteful meme (large image, one‑line caption)

## Slide 22 — Take‑home (30:30–31:30)

* Agents **expand capability**
* **Structure keeps them honest**
* Container + Makefile + scripts + PRs

## Slide 23 — Reserve / buffer (31:30–36:30)

* Use for demo latency, brief questions, or a second quick agent tweak
* If unused, finish with a short recap

## Slide 24 — Q&A (36:30–40:00)

* Repo URL/QR on screen
* Invite concrete “where would you start?” questions

-
