# Results


``` r
library(yaml)
library(here)
```

    here() starts at /root/repo

``` r
fmt3 <- function(x) sprintf("%.3f", x)
fmt6 <- function(x) sprintf("%.6f", x)

cleaning <- yaml::read_yaml(here("outputs", "results", "cleaning.yml"))
base <- yaml::read_yaml(here("outputs", "results", "base_lm.yml"))
ideas <- tryCatch(
  yaml::read_yaml(here("outputs", "results", "ideas_catalog.yml")),
  error = function(e) NULL
)
```

## Cleaning

The pipeline kept 137133 of 235016 trials (dropped 97883). Settings:
correct-only = TRUE, RT range = 200–2000 ms.

``` r
data.frame(
  setting = c(
    "correct_only",
    "rt_min_ms",
    "rt_max_ms",
    "total_trials",
    "kept_trials",
    "dropped_trials"
  ),
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

``` r
knitr::include_graphics(here("outputs", "figures", "rt_hist.png"))
```

![](../outputs/figures/rt_hist.png)

## Baseline model: frequency and strokes

``` r
data.frame(
  term = c("intercept", "log_freq", "strokes"),
  estimate = c(
    fmt6(as.numeric(base$coefficients$intercept)),
    fmt6(as.numeric(base$coefficients$log_freq)),
    fmt6(as.numeric(base$coefficients$strokes))
  )
)
```

           term  estimate
    1 intercept  6.452355
    2  log_freq -0.070823
    3   strokes  0.013355

R² 0.434; adjusted R² 0.433; residual sigma 0.099. AIC -6851.160, BIC
-6826.134.

<!--
To add another analysis:
1) create scripts/NN_slug.R that writes outputs/results/slug.yml
2) add a Makefile rule and add it to ANALYSES
3) copy this section, rename, and read slug.yml
Keep computation out of the QMD.
-->

## Analysis ideas (planning)

``` r
if (!is.null(ideas)) {
  tbl <- do.call(rbind, lapply(ideas$ideas, function(x){
    data.frame(
      rank = as.integer(x$rank),
      id = x$id,
      title = x$title,
      ease = as.numeric(x$scores$ease),
      interest = as.numeric(x$scores$interest),
      novelty = as.numeric(x$scores$novelty),
      risk = as.numeric(x$scores$risk),
      priority = as.numeric(x$priority),
      implemented = ifelse(isTRUE(x$implemented), "[x]", "[ ]"),
      pr = ifelse(nzchar(x$pr_ref), x$pr_ref, ""),
      findings = x$findings,
      stringsAsFactors = FALSE
    )
  }))
  tbl[order(tbl$rank), ]
} else {
  data.frame(note = "ideas_catalog.yml not found; run scripts/00_ideas_catalog.R")
}
```

       rank  id                 title ease interest novelty risk priority
    1     1 I01 TBD: analysis idea 01    3        3       3    2     2.85
    2     1 I02 TBD: analysis idea 02    3        3       3    2     2.85
    3     1 I03 TBD: analysis idea 03    3        3       3    2     2.85
    4     1 I04 TBD: analysis idea 04    3        3       3    2     2.85
    5     1 I05 TBD: analysis idea 05    3        3       3    2     2.85
    6     1 I06 TBD: analysis idea 06    3        3       3    2     2.85
    7     1 I07 TBD: analysis idea 07    3        3       3    2     2.85
    8     1 I08 TBD: analysis idea 08    3        3       3    2     2.85
    9     1 I09 TBD: analysis idea 09    3        3       3    2     2.85
    10    1 I10 TBD: analysis idea 10    3        3       3    2     2.85
       implemented pr findings
    1          [ ]            
    2          [ ]            
    3          [ ]            
    4          [ ]            
    5          [ ]            
    6          [ ]            
    7          [ ]            
    8          [ ]            
    9          [ ]            
    10         [ ]            
