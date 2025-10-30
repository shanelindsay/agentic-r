```qmd
---
title: "Agentic AI for reproducible language science: from prompt to pipeline"
format:
  pptx:
    reference-doc: template.potx
execute:
  eval: false
toc: false
---

# Section Header: Why agents now
::: {.notes}
Timing: 0:00–1:30. Set the capability frame and the “Ask → Plan → Do → Record” loop.
:::

---

# From chat to agents
::: {.notes}
Timing: 1:30–3:00. Define agents as planner, tool‑caller, executor, reporter.
:::
- Agents plan multi‑step work.
- They call external tools.
- They run code and scripts.
- They record actions and results.
- Capability expands; speed increases.
![Simple agent loop schematic (non‑generative)](placeholder.png)

---

# What you will learn today
::: {.notes}
Timing: 3:00–4:00. Emphasise that it is R‑focused but portable.
:::
- Where agents add capability.
- Pragmatic pitfalls and mitigations.
- Run a containerised R workflow.
- Use GitHub for visible review.

---

# Section Header: Landscape and access
::: {.notes}
Timing: 4:00–4:20. Name systems briefly; no deep dive.
:::
---

# Systems you may encounter
::: {.notes}
Timing: 4:20–5:30. Keep brand‑agnostic; students use what is available.
:::
- Claude Code (web/IDE).
- Cursor (IDE agent mode).
- Coding agents in editors.
- Choose what your lab supports.
![Claude Code, Cursor, editor logos (insert non‑generative logos)](placeholder.png)

---

# China‑aware options (one slide)
::: {.notes}
Timing: 5:30–6:30. Mention without prices; institutions vary.
:::
- Qwen models (AliCloud).
- Kimi (Moonshot AI).
- GLM (Zhipu AI).
- ERNIE, Hunyuan, Doubao.
![Provider logos grid (insert non‑generative logos)](placeholder.png)

---

# Thinking about costs
::: {.notes}
Timing: 6:30–8:00. Teach patterns, not price lists.
:::
- Three patterns: subscription, tokens, editor.
- Iterations drive spend.
- Keep prompts short.
- Prefer small models for drafts.
![Token cost formula schematic (non‑generative)](placeholder.png)

---

# Section Header: Promise and pitfalls
::: {.notes}
Timing: 8:00–8:15. Shift from tools to practice.
:::
---

# What gets better now
::: {.notes}
Timing: 8:15–9:30. Capability and provenance, not hype.
:::
- Attempt larger tasks.
- Explore alternatives quickly.
- Faster first drafts.
- Traceable, recorded changes.

---

# Pitfalls you will meet
::: {.notes}
Timing: 9:30–11:00. Keep pragmatic and actionable.
:::
- Overreach beyond expertise.
- Skill drift if you stop reading.
- Cost creep from many runs.
- Mitigate: small tasks, tests, review.

---

# Section Header: Methods tutorial (R‑focused)
::: {.notes}
Timing: 11:00–11:15. From ideas to one runnable pipeline.
:::
---

# Why containers help agents
::: {.notes}
Timing: 11:15–12:30. Agents arrive “cold”; containers standardise starts.
:::
- Predictable start each run.
- Self‑documenting projects win.
- If a stranger can run it…
- …an agent can run it.
![Container concept icon (non‑generative)](placeholder.png)

---

# Repo skeleton (demo)
::: {.notes}
Timing: 12:30–13:30. Show structure you will actually run.
:::
- README with quickstart.
- Makefile orchestration.
- R scripts for steps.
- Raw, processed, results folders.
- Wrapper script to run R.
![Repository tree schematic (non‑generative)](placeholder.png)

---

# One pipeline, end‑to‑end
::: {.notes}
Timing: 13:30–14:45. Makefile first; upgrade later if needed.
:::
- Simple Makefile rules.
- Deterministic script runs.
- Diffable result files.
- Upgrade path exists later.

---

# Section Header: Example — lexical decision (Option A)
::: {.notes}
Timing: 14:45–15:00. Language‑science example; tiny lawful slices.
:::
---

# Task and data (tiny slices)
::: {.notes}
Timing: 15:00–16:00. Keep datasets small; ship locally.
:::
- Behaviour: lexical decision RTs.
- Predictors: frequency, strokes.
- Join SCLP with CLD rows.
- Aim: small, fast, illustrative.
![Lexical decision schematic (non‑generative)](placeholder.png)

---

# Demo: what you will run
::: {.notes}
Timing: 16:00–17:00. Prepare a fallback recording.
:::
- Clone the repo.
- Run `make` once.
- View `metrics.yml`.
- Keep a short screencast.

---

# Live steps (5–6 minutes)
::: {.notes}
Timing: 17:00–23:00. Small change + re‑run + visible diff.
:::
- Run `make` to baseline.
- Agent adds one predictor.
- Re‑run `make` deterministically.
- Show diff in `metrics.yml`.
- Commit and open a PR.

---

# Interactive vs script‑based
::: {.notes}
Timing: 23:00–24:30. Draft interactively, execute by script.
:::
- Draft with an agent.
- Execute via scripts.
- Scripts beat ad‑hoc REPL.
- Reproducibility first.

---

# Section Header: GitHub basics
::: {.notes}
Timing: 24:30–24:45. Light‑touch process; keep humans engaged.
:::
---

# Keep the human in the loop
::: {.notes}
Timing: 24:45–26:15. One screenshot of a PR with a small diff.
:::
- Branch → PR → review.
- Scoped commits with notes.
- Small, reviewable changes.
- Merge with confidence.
![PR with small YAML diff (non‑generative)](placeholder.png)

---

# End‑to‑end reporting
::: {.notes}
Timing: 26:15–27:45. Manuscript pulls numbers from results tables.
:::
- Results as CSV/YAML.
- Manuscript reads tables.
- Changes stay transparent.
![Manuscript numbers from tables schematic (non‑generative)](placeholder.png)

---

# Section Header: Wrap‑up and questions
::: {.notes}
Timing: 27:45–28:00. Leave time buffer for Q&A up to 40:00.
:::
---

# Take‑home
::: {.notes}
Timing: 28:00–29:00. Close with four rules of thumb.
:::
- Agents expand capability.
- Structure keeps them honest.
- Container + Makefile + scripts.
- GitHub review for trust.

---

# Q&A
::: {.notes}
Timing: 29:00–40:00. Keep a slide visible with repo URL and a QR code placeholder.
:::
![Repo URL / QR code placeholder (non‑generative)](placeholder.png)
```
