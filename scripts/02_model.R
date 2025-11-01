## scripts/02_model.R
## Fit a small model and write a diffable YAML with key metrics.
## Input:  outputs/data/processed.csv
## Output: outputs/results/metrics.yml

suppressPackageStartupMessages({
  library(readr)
  library(here)
})

dir.create(here::here("outputs","results"), showWarnings = FALSE, recursive = TRUE)
d <- readr::read_csv(here::here("outputs","data","processed.csv"), show_col_types = FALSE)

needed <- c("mean_log_rt","log_freq","strokes")
if (!all(needed %in% names(d))) {
  stop("Processed data missing required columns: ", paste(setdiff(needed, names(d)), collapse = ", "))
}

mod <- lm(mean_log_rt ~ log_freq + strokes, data = d)
s   <- summary(mod)

co    <- coef(mod)
r2    <- unname(s$r.squared)
adjr2 <- unname(s$adj.r.squared)
sigma <- unname(s$sigma)
aic   <- AIC(mod)
bic   <- BIC(mod)
n     <- nrow(d)

out <- here::here("outputs","results","metrics.yml")
lines <- c(
  sprintf('timestamp: "%s"', format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")),
  'model: lm(mean_log_rt ~ log_freq + strokes)',
  sprintf('n_obs: %d', n),
  'coefficients:',
  sprintf('  intercept: %.6f', unname(co[1])),
  sprintf('  log_freq: %.6f', unname(co["log_freq"])),
  sprintf('  strokes: %.6f',  unname(co["strokes"])),
  sprintf('r2: %.6f', r2),
  sprintf('adj_r2: %.6f', adjr2),
  sprintf('sigma: %.6f', sigma),
  sprintf('aic: %.6f', aic),
  sprintf('bic: %.6f', bic)
)
tmp <- paste0(out, ".tmp")
cat(paste0(lines, collapse = "\n"), "\n", file = tmp)
if (!file.rename(tmp, out)) {
  stop("Failed to move temporary metrics YAML into place.")
}
cat(sprintf("Wrote %s\n", out))
