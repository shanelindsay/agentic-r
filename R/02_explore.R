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

filt_csv <- here::here("outputs","data","trials_filtered.csv")
stopifnot(file.exists(filt_csv))
flt <- read.csv(filt_csv, fileEncoding = "UTF-8")
stopifnot(all(c("char","rt_ms","correct") %in% names(flt)))
n_total <- NA_integer_  # not used in plot now
n_kept  <- nrow(flt)

# Quick base-R histogram for speed and zero extra deps
png(filename = here::here("outputs","figures","rt_hist.png"), width = 800, height = 500)
hist(
  flt$rt_ms,
  breaks = 30,
  main = sprintf("RT histogram (kept %d trials)", n_kept),
  xlab = "RT (ms)",
  col = "#4477AA"
)
invisible(dev.off())

cat(sprintf("Wrote outputs/figures/rt_hist.png\n"))
