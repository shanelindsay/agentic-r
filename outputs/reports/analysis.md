# Agentic AI Demo Report


``` r
library(yaml)
library(jsonlite)

metrics_path <- here::here("outputs","results","metrics.yml")
cleaning_path <- here::here("outputs","results","cleaning.yml")
fig_path <- here::here("outputs","figures","rt_hist.png")

metrics <- if (file.exists(metrics_path)) yaml::read_yaml(metrics_path) else list()
cleaning <- if (file.exists(cleaning_path)) yaml::read_yaml(cleaning_path) else list()
```

## Overview

This report reads pre-computed outputs from the simple demo pipeline.

- Processed data: `outputs/data/processed.csv`
- Cleaning summary: `outputs/results/cleaning.yml`
- Model metrics: `outputs/results/metrics.yml`

## Cleaning Summary

``` r
if (length(cleaning)) {
  as.data.frame(t(unlist(cleaning)), optional = TRUE)
} else {
  data.frame(message = "No cleaning summary found. Run `make explore`.")
}
```

                     timestamp trimming.correct_only trimming.rt_min_ms
    1 2025-10-31T11:47:42+0000                  TRUE                200
      trimming.rt_max_ms counts.total_trials counts.kept_trials
    1               2000                  12                  9
      counts.dropped_trials
    1                     3

## Model Metrics

``` r
as.data.frame(t(unlist(metrics)), optional = TRUE)
```

                     timestamp                                model FALSE
    1 2025-10-31T11:46:50+0000 lm(mean_log_rt ~ log_freq + strokes)     4
      coefficients.intercept coefficients.log_freq coefficients.strokes       r2
    1               6.832225             -0.246769             0.034337 0.997707

## RT Histogram (kept trials)

``` r
if (file.exists(fig_path)) {
  knitr::include_graphics(fig_path)
} else {
  cat("Figure not found: ", fig_path)
}
```

![](../outputs/figures/rt_hist.png)
