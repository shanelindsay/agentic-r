## scripts/02_model.R
## Minimal model step: fail loudly if inputs are wrong.

suppressPackageStartupMessages({
  library(readr)
  library(here)
})

d <- readr::read_csv(here("outputs","data","processed.csv"), show_col_types = FALSE)

mod <- lm(mean_log_rt ~ log_freq + strokes, data = d)
s   <- summary(mod)

co    <- coef(mod)
r2    <- s$r.squared
adjr2 <- s$adj.r.squared
sigma <- s$sigma
aic   <- AIC(mod)
bic   <- BIC(mod)
n     <- nrow(d)

out <- here("outputs","results","metrics.yml")
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
cat(paste0(lines, collapse = "\n"), "\n", file = out)
cat(sprintf("Wrote %s\n", out))
