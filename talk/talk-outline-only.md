# Agentic AI for Reproducible Language Science: From Prompt to Pipeline

Shane Lindsay  
University of Hull  
https://github.com/shanelindsay/agentic-r/

# Agenda

- Why now (spoiler: they finally work)
- What is an agent
- Demo: agents and reproducible research patterns
- Practical patterns you can steal

# Pre-requisites

Assume you have used LLM chatbots, for example ChatGPT, ==探索未至之境==  
Assume knowledge of R (applies to Python and other tools too)

# Why agents now

- LLM models are now smart enough for multi-step, tool-using tasks
- They are cheap enough to be practical for students and labs
- Agents are accessible
- The technology is useful for everyday research work

**Provocation**: By the end of 2025, no one will ever need to code or use a GUI (like SPSS) again

# What is an agent

- General purpose LLM that lives inside a computer
- Read and write access to the file system, with access to bash or PowerShell
- Whatever you can do, it can do, with guardrails and approvals
- Can work autonomously for typically less than 20 minutes
- Search the web, write code, execute it, write it up
- Full end to end scientific process  
  - Today focused on analyses

# Costs

- One knob: fast and rough versus slow and smart
- Daily heavy use: $200 per month
- Moderate use: $100 per month
- Light use: $20 per month
- Free tiers exist

# Examples

- US: Codex (OpenAI), Claude Code (Anthropic), Gemini (Google), Cursor, Copilot (Microsoft)
- China: Kimi K2, Qwen 3, GLM 4.5
- Currently: OpenAI Codex is smartest, Claude Code 4.5 second, GLM or K2 best for cost

# Promise of agents

- Increase speed
- Increase capability

# Perils of agents

- Errors
- Loss of control and responsibility
- Atrophy of skills
- Technical demands and complexity (tech debt)

# Using agents

- Think of an agent as a new lab member arriving cold to your research project
- Very keen, very fast, very smart, sometimes wise, sometimes also wrong
- Agents work best when projects are structured, documented and runnable
- Structure encourages consistent patterns in your workflows

# Why reproducible research

- Verify findings, others can validate your results
- Reduce bias through transparency in methods
- Catch errors, community review improves quality
- Preserve knowledge beyond individual researchers
- Increasingly required by funding agencies and journals

# Reproducible research and agentic AI are best friends

- Research codebase lifecycle: plan → execute → review → share → re-run
- Reproducibility means others, including agents, can repeat the same steps and get the same artefacts
- Agents support reproducibility when outputs are scripted, logged and text based

# Coding patterns and how agents interact

- Monolithic 1000 line script: quick start, fragile for change, sprawl, hard to understand and debug
- Numbered scripts: clearer workflow, smaller functional units
- Makefile orchestrated scripts: explicit dependencies, deterministic runs

**Goal**: press a button, raw data transformed directly to numbers in a manuscript

# Containers and predictability

- Containers are cloud based Unix environments that can be spun up and thrown away
- Agents are stateless across sessions, containers provide a predictable starting point
- If a stranger can run the repo from the documentation, an agent can too
- Running agents in containers is safer, they operate inside the container

# GitHub

- GitHub provides version tracking
- Monitor and approve any changes with pull requests
- Protect work from being overwritten, history is always saved

# shanelindsay/agentic-r GitHub repo

- `AGENTS.md`: how the agent should work in this repo
- `dev/run-in-env.sh`: get R working using micromamba
- `environment.yml`: R version and packages to use (numbered, reproducible)
- Agents are told to use the wrapper to run scripts

# Workflow

- Makefile + two small R scripts (`01_prepare.R`, `02_model.R`) + Quarto report
- `configs/cleaning.yml` holds the shared trimming parameters + data sources
- Outputs land in `outputs/{data,figures,results,reports}` (diffable YAML/CSV/MD)
- Explain changes in the PR description

# Example: Lexical Decision in Chinese

- Baseline: run the pipeline once to produce `metrics.yml`
- Data: decision dataset of RTs with lexical predictors

# Agent demo: Builder

- Agent prompt: add one predictor, for neighbourhood, update `02_model.R`, write the new coefficient to `results/metrics.yml`, update `README`
- You re-run the pipeline deterministically via the wrapper and Makefile
- See the changes in the "diff" (difference between old and new code/data)

# Agent demo: Review

- Second agent reads the PR diff and writes a review
- Human reviews the agent review and approves or requests changes
- Loop as needed

# Interactive versus script based

- Explore interactively if needed, then commit changes as scripts or Makefile targets for determinism and reproducibility
- Store results as diffable tables for easy review

# GitHub review

- Branch, PR, concise description, human review, merge
- Keep commits small and well scoped, include one line rationales
- Use PR comments for agent checklists and reviewer notes

# End to end reporting

- Manuscript or Quarto report reads values from `results/*`
- This keeps numbers traceable and updates transparent

# Agent patterns to copy

- Builder: proposes and edits code
- Checker: audits diffs and outputs
- Critic (optional): proposes tests or diagnostics
- Humans remain the final approvers

# Where to start

- Pick one stage, cleaning or modelling or reporting, and start small
- Keep tasks atomic
- Measure time saved against review effort

# Practical tips

- Short, explicit prompts, give file paths and desired outputs
- Make outputs diffable (CSV or YAML), keep raw data read only
- Pre-record a fallback run for live demos

# Take-home

- Agents expand what you can do
- Structure, container plus Makefile plus scripts plus PRs, keeps agents honest
- Start small, review everything, iterate responsibly

# Q and A

- shanelindsay/agentic-r
 
