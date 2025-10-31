"# R/02_explore.R
# Minimal exploratory/cleaning step for the talk.
# - Computes trim stats from raw trials (200–2000 ms, correct only)
# - Saves a quick RT histogram for kept trials
# - Writes a small YAML with counts
# Outputs:
#   - outputs/figures/rt_hist.png
#   - outputs/results/cleaning.yml
" -> NULL

suppressWarnings({
  dir.create(here::here("outputs","figures"), showWarnings = FALSE, recursive = TRUE)
  dir.create(here::here("outputs","results"),  showWarnings = FALSE, recursive = TRUE)
})

raw <- read.csv(here::here("data","raw","sclp_sample.csv"), fileEncoding = "UTF-8")
stopifnot(all(c("char","rt_ms","correct") %in% names(raw)))

n_total <- nrow(raw)
keep    <- raw$correct == 1 & raw$rt_ms >= 200 & raw$rt_ms <= 2000
n_kept  <- sum(keep)

# Quick base-R histogram for speed and zero extra deps
png(filename = here::here("outputs","figures","rt_hist.png"), width = 800, height = 500)
hist(raw$rt_ms[keep], breaks = 30, main = "RT histogram (kept trials)", xlab = "RT (ms)", col = "#4477AA")
invisible(dev.off())

# Small YAML (manual to avoid extra deps)
out_yaml <- here::here("outputs","results","cleaning.yml")
lines <- c(
  sprintf('timestamp: "%s"', format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")),
  'trimming:',
  '  correct_only: true',
  '  rt_min_ms: 200',
  '  rt_max_ms: 2000',
  'counts:',
  sprintf('  total_trials: %d', n_total),
  sprintf('  kept_trials: %d',  n_kept),
  sprintf('  dropped_trials: %d', n_total - n_kept)
)
cat(paste0(lines, collapse = "\n"), "\n", file = out_yaml)
cat(sprintf("Wrote %s and outputs/figures/rt_hist.png\n", out_yaml))

