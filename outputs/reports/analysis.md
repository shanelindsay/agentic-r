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

The pipeline kept 9 of 12 trials (dropped 3). Settings: correct-only =
TRUE, RT range = 200–2000 ms.

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

             setting value
    1   correct_only  TRUE
    2      rt_min_ms   200
    3      rt_max_ms  2000
    4   total_trials    12
    5    kept_trials     9
    6 dropped_trials     3

## Model Metrics

Model: lm(mean_log_rt ~ log_freq + strokes) (N = )

R² = 0.998.

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
    1 intercept  6.832225
    2  log_freq -0.246769
    3   strokes  0.034337

## RT Histogram (kept trials)

``` r
if (file.exists(fig_path)) {
  knitr::include_graphics(fig_path)
} else {
  cat("Figure not found: ", fig_path)
}
```

![](../outputs/figures/rt_hist.png)
