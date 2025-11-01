suppressPackageStartupMessages({
  library(readr)
  library(yaml)
  library(here)
})

in_path <- here::here("outputs", "data", "processed.csv")
out_path <- here::here("outputs", "results", "base_lm.yml")

stopifnot(file.exists(in_path))

d <- readr::read_csv(in_path, show_col_types = FALSE)
needed <- c("mean_log_rt", "log_freq", "strokes")
missing <- setdiff(needed, names(d))
if (length(missing)) {
  stop("Processed data missing: ", paste(missing, collapse = ", "))
}

mod <- lm(mean_log_rt ~ log_freq + strokes, data = d)
s <- summary(mod)
co <- coef(mod)

round6 <- function(x) as.numeric(sprintf("%.6f", x))

res <- list(
  id = "base_lm",
  title = "Baseline linear model: log frequency + strokes",
  model = "lm(mean_log_rt ~ log_freq + strokes)",
  n_obs = nrow(d),
  coefficients = list(
    intercept = round6(unname(co[1])),
    log_freq = round6(unname(co["log_freq"])),
    strokes = round6(unname(co["strokes"]))
  ),
  r2 = round6(unname(s$r.squared)),
  adj_r2 = round6(unname(s$adj.r.squared)),
  sigma = round6(unname(s$sigma)),
  aic = round6(AIC(mod)),
  bic = round6(BIC(mod)),
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
)

dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
yaml::write_yaml(res, out_path)

cat("Wrote ", out_path, "\n", sep = "")
