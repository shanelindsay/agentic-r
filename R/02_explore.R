# R/02_explore.R
# Minimal exploratory/cleaning step for the talk.
# - Computes trim stats from raw trials (200–2000 ms, correct only)
# - Saves a quick RT histogram for kept trials
# - Writes a small YAML with counts
# Outputs:
#   - outputs/figures/rt_hist.png
#   - outputs/results/cleaning.yml

suppressWarnings({
  dir.create(here::here("outputs","figures"), showWarnings = FALSE, recursive = TRUE)
  dir.create(here::here("outputs","results"),  showWarnings = FALSE, recursive = TRUE)
})

raw <- read.csv(here::here("data","raw","sclp_sample.csv"), fileEncoding = "UTF-8")
stopifnot(all(c("char","rt_ms","correct") %in% names(raw)))

cfg_path <- here::here("configs","cleaning.yml")
stopifnot(file.exists(cfg_path))
cfg <- yaml::read_yaml(cfg_path)
stopifnot(all(c("correct_only","rt_min_ms","rt_max_ms") %in% names(cfg)))
correct_only <- isTRUE(cfg$correct_only)
rt_min <- as.numeric(cfg$rt_min_ms)
rt_max <- as.numeric(cfg$rt_max_ms)
stopifnot(is.finite(rt_min), is.finite(rt_max), rt_min < rt_max)

n_total <- nrow(raw)
keep    <- rep(TRUE, n_total)
if (correct_only) keep <- keep & raw$correct == 1
keep <- keep & raw$rt_ms >= rt_min & raw$rt_ms <= rt_max
n_kept  <- sum(keep)

# Quick base-R histogram for speed and zero extra deps
png(filename = here::here("outputs","figures","rt_hist.png"), width = 800, height = 500)
hist(
  raw$rt_ms[keep],
  breaks = 30,
  main = sprintf("RT histogram (kept %d/%d trials)", n_kept, n_total),
  xlab = "RT (ms)",
  col = "#4477AA"
)
invisible(dev.off())

# Small YAML (manual to avoid extra deps)
out_yaml <- here::here("outputs","results","cleaning.yml")
lines <- c(
  sprintf('timestamp: "%s"', format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")),
  'trimming:',
  sprintf('  correct_only: %s', if (correct_only) "true" else "false"),
  sprintf('  rt_min_ms: %s', rt_min),
  sprintf('  rt_max_ms: %s', rt_max),
  'counts:',
  sprintf('  total_trials: %d', n_total),
  sprintf('  kept_trials: %d',  n_kept),
  sprintf('  dropped_trials: %d', n_total - n_kept)
)
cat(paste0(lines, collapse = "\n"), "\n", file = out_yaml)
cat(sprintf("Wrote %s and outputs/figures/rt_hist.png\n", out_yaml))
