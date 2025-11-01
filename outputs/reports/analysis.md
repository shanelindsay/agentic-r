# Agentic AI Demo Report


``` r
library(yaml)

metrics_path <- here::here("outputs","results","metrics.yml")
cleaning_path <- here::here("outputs","results","cleaning.yml")
fig_path <- here::here("outputs","figures","rt_hist.png")

stopifnot(file.exists(metrics_path))
stopifnot(file.exists(cleaning_path))
stopifnot(file.exists(fig_path))

metrics <- yaml::read_yaml(metrics_path)
cleaning <- yaml::read_yaml(cleaning_path)

stopifnot(!is.null(metrics$n_obs))
N <- as.integer(metrics$n_obs)
stopifnot(!is.na(N))

# helpers for formatting
fmt3 <- function(x) sprintf("%.3f", x)
fmt6 <- function(x) sprintf("%.6f", x)
```

## Overview

This report reads pre-computed outputs from the simple demo pipeline.

- Processed data: `outputs/data/processed.csv`
- Cleaning summary: `outputs/results/cleaning.yml`
- Model metrics: `outputs/results/metrics.yml`

## Cleaning Summary

The pipeline kept 137133 of 235016 trials (dropped 97883). Settings:
correct-only = TRUE, RT range = 200–2000 ms.

``` r
data.frame(
  setting = c("correct_only","rt_min_ms","rt_max_ms","total_trials","kept_trials","dropped_trials"),
  value = c(
    as.character(cleaning$trimming$correct_only),
    cleaning$trimming$rt_min_ms,
    cleaning$trimming$rt_max_ms,
    cleaning$counts$total_trials,
    cleaning$counts$kept_trials,
    cleaning$counts$dropped_trials
  )
)
```

             setting  value
    1   correct_only   TRUE
    2      rt_min_ms    200
    3      rt_max_ms   2000
    4   total_trials 235016
    5    kept_trials 137133
    6 dropped_trials  97883

## RT Histogram (kept trials)

``` r
knitr::include_graphics(fig_path)
```

![](../outputs/figures/rt_hist.png)

## Model Metrics

Model: lm(mean_log_rt ~ log_freq + strokes) (N = 3852)

R² = 0.434.

``` r
if (!is.null(metrics$adj_r2)) {
  cat(paste0("Adjusted R² = ", fmt3(as.numeric(metrics$adj_r2)), ".\n\n"))
}
```

    Adjusted R² = 0.433.

``` r
if (!is.null(metrics$sigma)) {
  cat(paste0("Residual sigma = ", fmt3(as.numeric(metrics$sigma)), ".\n\n"))
}
```

    Residual sigma = 0.099.

``` r
if (!is.null(metrics$aic) || !is.null(metrics$bic)) {
  cat("Information criteria:\n\n")
  aic_val <- if (!is.null(metrics$aic)) fmt3(as.numeric(metrics$aic)) else "NA"
  bic_val <- if (!is.null(metrics$bic)) fmt3(as.numeric(metrics$bic)) else "NA"
  print(data.frame(metric = c("AIC", "BIC"), value = c(aic_val, bic_val)))
}
```

    Information criteria:

      metric     value
    1    AIC -6851.160
    2    BIC -6826.134

Coefficients:

``` r
data.frame(
  term = c("intercept","log_freq","strokes"),
  estimate = c(
    fmt6(as.numeric(metrics$coefficients$intercept)),
    fmt6(as.numeric(metrics$coefficients$log_freq)),
    fmt6(as.numeric(metrics$coefficients$strokes))
  )
)
```

           term  estimate
    1 intercept  6.452355
    2  log_freq -0.070823
    3   strokes  0.013355
