suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(readr)
  library(tidyr)
  library(yaml)
  library(here)
  library(fs)
})

source(here::here("R", "utils.R"))

ideas_cfg_path <- here::here("configs", "ideas.yml")
scoring_cfg_path <- here::here("configs", "idea_scoring.yml")

stopifnot(file.exists(ideas_cfg_path), file.exists(scoring_cfg_path))

ideas_cfg <- yaml::read_yaml(ideas_cfg_path)
score_cfg <- yaml::read_yaml(scoring_cfg_path)

weights <- list(
  ease = as.numeric(score_cfg$weights$ease %||% 0.5),
  interest = as.numeric(score_cfg$weights$interest %||% 0.35),
  novelty = as.numeric(score_cfg$weights$novelty %||% 0.2),
  risk = as.numeric(score_cfg$weights$risk %||% 0.15)
)

scale_min <- as.numeric(score_cfg$scale$min %||% 1)
scale_max <- as.numeric(score_cfg$scale$max %||% 5)

`%NA%` <- function(x, val) ifelse(is.na(x), val, x)

tbl <- tibble::tibble(!!!ideas_cfg) |> tidyr::unnest_wider(ideas) |> 
  mutate(
    effort = as.numeric(effort %NA% 3),
    interest = as.numeric(interest %NA% 3),
    novelty = as.numeric(novelty %NA% 3),
    risk = as.numeric(risk %NA% 2),
    implemented = as.logical(implemented %NA% FALSE),
    status = as.character(status %NA% "proposed"),
    pr_ref = as.character(pr_ref %NA% ""),
    findings = as.character(findings %NA% "")
  )

# Derived scores
ease <- (scale_max + 1) - tbl$effort

priority <- weights$ease * ease +
  weights$interest * tbl$interest +
  weights$novelty * tbl$novelty -
  weights$risk * tbl$risk

tbl2 <- tbl |> mutate(
  ease = ease,
  priority = as.numeric(sprintf("%.3f", priority)),
  rank = dplyr::min_rank(dplyr::desc(priority))
) |> arrange(rank)

# Write CSV (diffable planning view)
csv_out <- here::here(score_cfg$output$csv_table)
dir_create(path_dir(csv_out))
write_csv_atomic(tbl2 |> select(
  rank, id, slug, title, effort, ease, interest, novelty, risk, priority,
  status, implemented, pr_ref, findings
), csv_out)

# Write YAML summary (for reports)
yaml_out <- here::here(score_cfg$output$yaml_summary)

summary <- list(
  id = "ideas_catalog",
  title = "Analysis ideas: planning board",
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  weights = weights,
  scale = list(min = scale_min, max = scale_max),
  ideas = purrr::pmap(
    tbl2,
    function(id, slug, title, question, notes, tags, effort, interest, novelty, risk,
             status, implemented, pr_ref, findings, ease, priority, rank, ...){
      list(
        id = id, slug = slug, title = title,
        question = question, notes = notes, tags = tags,
        scores = list(effort = effort, ease = ease, interest = interest, novelty = novelty, risk = risk),
        priority = priority, rank = rank,
        status = status, implemented = implemented, pr_ref = pr_ref, findings = findings
      )
    }
  )
)

write_yaml_atomic(summary, yaml_out)

cat("Wrote ", csv_out, " and ", yaml_out, "\n", sep = "")

