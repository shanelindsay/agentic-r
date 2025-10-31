# **Agentic AI for Reproducible Language Science: From Prompt to Pipeline**

Shane Lindsay

University of Hull

https://github.com/shanelindsay/agentic-r/

# Agenda

- Why now? (spoiler: they finally work)
- What is an agent?
- Demo: agents + reproducible research patterns
- Practical patterns you can steal

# Pre-requisites 

- Assume you have used LLM Chatbots e.g. ChatGPT, ==探索未至之境==
- Assume knowledge of R (but everything applies to other tools e.g. Python)

# Why agents now?

- LLM models are now **smart enough** for multi-step, tool-using tasks
- They are **cheap enough** to be practical for students and labs
- Agents are accessible 
- The technology is finally useful for everyday research work

By the end of 2025, no one will ever need to code or use a GUI (like SPSS) again

# What is an agent?

- General purpose LLM that lives inside a computer
- Read/write access to file system, with access to bash/powershell
- Whatever you can do, it can do with (with guardrails/approvals)
- Can work automously for typically < 20 minutes 
- Search web, write code, execute it, write it up
- Full end-to-end scientific process
  - Today focused on analyses

# Costs

- One knob: **quick and fast vs slow and smart**
- Daily heavy use: $200 per month
- Moderate use: $100 per month
- Light use: 20$ per month
- Free tiers

# Examples

- US: Codex (OpenAI), Claude Code (Anthropic), Gemini (Google), Cursor (Cursor), CoPilot (Microsoft)
- China: Kimi K2, Qwen 3, GLM 4.5
- Currently: OpenAI Codex is smartest, Claude Code 4.5 2nd, GLM/K2 best for cost

# Promise of agents

- Incresease speed
- Increase capability

# Perils of agents

- Errors
- Loss of control and responsibility
- Atrophy of skills
- Technical demands / complexity (tech debt)

# Using agents

- Think of an agent as a **new lab member** arriving cold to your research project
- Very keen, very fast, very smart, sometimes wise, sometimes also dumb
- Agents work best when projects are structured, documented, and runnable
- Structure: encourages following consistent patterns in your workflows

# Why reproducible research?

- **Verify findings** - Others can validate your results
- **Reduce bias **- Transparency in methods
- **Catch errors** - Community review improves quality
- **Preserve knowledge** - Methods survive beyond individual researchers
- *Increasingly required by funding agencies and journals*

# Reproducible research and Agentic AI are best friends

- Research codebase lifecycle: **plan → execute → review → share → re-run**
- Reproducibility means others (i.e. *agents*) can repeat the same steps and get the same artefacts
- Agents support reproducibility when outputs are scripted, logged and text based

# Coding patterns and how agents interact

- Monolithic 1000 line script : quick start, fragile for change; sprawl, hard to understand and debug
- Numbered scripts: clearer workflow, smaller functional units
- Makefile-orchestrated scripts: explicit dependencies; deterministic runs

*Goal: press a button, raw data transformed directly to numbers in a manuscript*

# Containers and predictability

- Containers are cloud based (unix) operating systems - spun up and thrown away
- Agents are stateless (no memory!); containers provide a predictable starting point
- If a stranger can run the repo from just looking at documentation, an agent can too
- Running Agents in containers makes them safe - can only operate inside the container

# Github 

- GIthub provides version tracking
- Monitor and approve any changes (Pull requests)
- Protect work from being overwritten (history always saved)

# shanelindsay/agentic-R Github Repo

- AGENTS.md > 
- dev/run-in-env.sh > get R working using micromamba
- environment.yml - R version and packages to use (numbered, reproducible)
 
- Agents file tells agent to use the wrapper to run scripts


# Workflow

- Makefile + three small R scripts (`01_prepare.R`, `02_explore.R`, `03_model.R`) + Quarto report
- `configs/cleaning.yml` holds the shared trimming parameters
- Outputs land in `outputs/{data,figures,results,reports}` (diffable YAML/CSV/MD)
- Explain changes in the PR description

# Example: Lexical Decision in Chinese

- Baseline: run the pipeline once to produce `metrics.yml`
- Demo data: a tiny, lawful slice of a lexical decision dataset + lexical predictors
- Backup: pre-baked PR and a 30–45 s recording of a successful run

# Agent demo — Builder

- Agent prompt: add one predictor (e.g. neighbourhood), update `03_model.R`, write new coefficient to `metrics.yml`, update README
- You re-run the pipeline deterministically via the wrapper/Makefile
- Show the small, scoped diff in `metrics.yml`

# Agent demo — Review

- Second agent reads the PR diff and `metrics.yml` and does a review
- Human reviews the agent review and approves or requests changes
- Loop 

# Interactive vs script-based

- 
- Execute changes via scripts/Makefile for determinism and reproducibility
- Store results as diffable tables for easy review

# GitHub review

- Branch → PR → concise description → human review → merge
- Keep commits small and well-scoped; include one-line rationales
- Use PR comments for agent checklists and reviewer notes

# End-to-end reporting

- Manuscript or Quarto report reads values from `results/*`
- This keeps numbers traceable and updates transparent

# Agent patterns to copy

- Builder: proposes and edits code
- Checker: audits diffs and outputs
- Critic (optional): proposes tests or diagnostics
- Humans remain the final approvers

# Where to start

- Pick one stage (cleaning, modelling, reporting) and start small
- Keep tasks atomic; measure time saved against review effort

# Practical tips

- Short, explicit prompts; give file paths and desired outputs
- Make outputs diffable (CSV/YAML); keep raw data read-only
- Pre-record a fallback run for live demos

# Memes and memory aids

- Single tasteful meme with one-line caption to reinforce a point
- Humour lines: “Agents don’t bring cake, but they write the README”; “Keen RA, occasional hallucinations”

# Take-home

- Agents expand what a small team can do
- Structure (container + Makefile + scripts + PRs) keeps agents honest
- Start small, review everything, iterate responsibly

# Reserve / buffer

- Space for extra demo tweaks, audience questions, or a second quick agent change
- If unused, recap the main points

# Q&A

- Show repo URL / QR and contact details
- Invite concrete “where would you start?” or “what would you like a template for?” questions
