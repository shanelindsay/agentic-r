#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(ggplot2)
  library(mgcv)
  library(glue)
  library(yaml)
  library(here)
})

in_path <- here("outputs", "data", "processed.csv")
yaml_path <- here("outputs", "results", "visual_complexity_penalty.yml")
partial_path <- here("outputs", "data", "visual_complexity_partial_effect.csv")
fig_path <- here("outputs", "figures", "visual_complexity_penalty.png")

stopifnot(file.exists(in_path))

dir.create(dirname(yaml_path), showWarnings = FALSE, recursive = TRUE)
dir.create(dirname(partial_path), showWarnings = FALSE, recursive = TRUE)
dir.create(dirname(fig_path), showWarnings = FALSE, recursive = TRUE)

d <- read_csv(in_path, show_col_types = FALSE) |> tidyr::drop_na(mean_log_rt, log_freq, strokes)

if (nrow(d) < 10) {
  stop("Need at least 10 observations; found ", nrow(d))
}

gam_mod <- mgcv::gam(
  mean_log_rt ~ s(strokes, k = 5) + log_freq,
  data = d,
  method = "REML"
)

gam_summary <- summary(gam_mod)
s_row <- gam_summary$s.table["s(strokes)", , drop = FALSE]

percentile <- 0.85
grid <- tibble(
  strokes = seq(min(d$strokes), max(d$strokes), length.out = 200L),
  log_freq = median(d$log_freq)
)

pred <- predict(gam_mod, newdata = grid, se.fit = TRUE)

partial <- grid |> mutate(
  mean_log_rt = as.numeric(pred$fit),
  se = as.numeric(pred$se.fit),
  lower = mean_log_rt - 1.96 * se,
  upper = mean_log_rt + 1.96 * se,
  rt_ms = exp(mean_log_rt),
  rt_lower = exp(lower),
  rt_upper = exp(upper)
)

penalty_threshold <- quantile(partial$mean_log_rt, probs = percentile)
partial <- partial |> mutate(penalty_band = mean_log_rt >= penalty_threshold)

penalty_idx <- which.max(partial$mean_log_rt)
peak_log <- partial$mean_log_rt[penalty_idx]
min_log <- min(partial$mean_log_rt)

penalty_log <- peak_log - min_log
penalty_ms <- exp(peak_log) - exp(min_log)

highlight_range <- if (any(partial$penalty_band)) {
  range(partial$strokes[partial$penalty_band])
} else c(NA_real_, NA_real_)

fmt6 <- function(x) as.numeric(sprintf("%.6f", x))
fmt2 <- function(x) as.numeric(sprintf("%.2f", x))
fmt1 <- function(x) as.numeric(sprintf("%.1f", x))

yaml_out <- list(
  id = "visual_complexity_penalty",
  title = "Visual complexity penalty controlling for frequency",
  model = "mgcv::gam(mean_log_rt ~ s(strokes, k = 5) + log_freq, method = 'REML')",
  n_obs = nrow(d),
  edf_strokes = fmt6(s_row[1, "edf"]),
  f_strokes = fmt6(s_row[1, "F"]),
  p_strokes = fmt6(s_row[1, "p-value"]),
  penalty = list(
    log_rt = fmt6(penalty_log),
    rt_ms = fmt2(penalty_ms),
    percentile = percentile,
    range_strokes = list(
      min = ifelse(is.na(highlight_range[1]), NA, fmt1(highlight_range[1])),
      max = ifelse(is.na(highlight_range[2]), NA, fmt1(highlight_range[2]))
    )
  ),
  reference_log_freq = fmt6(median(d$log_freq)),
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
)

yaml::write_yaml(yaml_out, yaml_path)
readr::write_csv(partial, partial_path)

plot_obj <- ggplot(partial, aes(x = strokes, y = rt_ms)) +
  {if (!is.na(highlight_range[1])) annotate(
    "rect",
    xmin = highlight_range[1],
    xmax = highlight_range[2],
    ymin = -Inf,
    ymax = Inf,
    fill = "#fde0dd",
    alpha = 0.4
  )} +
  geom_ribbon(aes(ymin = rt_lower, ymax = rt_upper), fill = "#c6dbef", alpha = 0.5) +
  geom_line(color = "#08306b", linewidth = 1) +
  labs(
    title = "Partial effect of visual complexity on log RT",
    subtitle = glue("log_freq held at median ({round(median(d$log_freq), 2)})"),
    x = "Strokes (complexity)",
    y = "Predicted RT (ms)",
    caption = glue("Shaded band marks top {percentile * 100}% of predicted penalty")
  ) +
  theme_minimal(base_size = 12)

ggsave(fig_path, plot = plot_obj, width = 6.5, height = 4.5, dpi = 300)

cat("Wrote partial effect outputs to", yaml_path, "and", fig_path, "\n")
