# R/02_model.R
# Fit a  model and write a diffable YAML with key metrics.
# Input:  outputs/data/processed.csv
# Output: outputs/results/metrics.yml

suppressWarnings({
  dir.create(here::here("outputs","results"), showWarnings = FALSE, recursive = TRUE)
})
d <- read.csv(here::here("outputs","data","processed.csv"), fileEncoding = "UTF-8")

stopifnot(all(c("mean_log_rt","log_freq","strokes") %in% names(d)))
mod <- lm(mean_log_rt ~ log_freq + strokes, data = d)
s   <- summary(mod)

co <- coef(mod)
r2 <- s$r.squared
n  <- nrow(d)

out <- here::here("outputs","results","metrics.yml")
lines <- c(
  sprintf('timestamp: "%s"', format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")),
  'model: lm(mean_log_rt ~ log_freq + strokes)',
  sprintf('n_obs: %d', n),
  'coefficients:',
  sprintf('  intercept: %.6f', unname(co[1])),
  sprintf('  log_freq: %.6f', unname(co["log_freq"])),
  sprintf('  strokes: %.6f',  unname(co["strokes"])),
  sprintf('r2: %.6f', r2)
)
cat(paste0(lines, collapse = "\n"), "\n", file = out)
cat(sprintf("Wrote %s\n", out))
