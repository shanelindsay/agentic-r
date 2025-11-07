#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(ggplot2)
  library(tibble)
  library(here)
})

# Load lexical decision trials
trials <- read_csv(
  here("data", "raw", "sclp_sample.csv"),
  show_col_types = FALSE
)

# Load character-level descriptors
chars <- read_csv(
  here("data", "raw", "cld_sample.csv"),
  show_col_types = FALSE
)

# Summarise typical response time (median) per character
char_rt <- trials %>%
  group_by(char) %>%
  summarise(
    trials = n(),
    median_rt_ms = median(rt_ms, na.rm = TRUE),
    mean_rt_ms = mean(rt_ms, na.rm = TRUE),
    .groups = "drop"
  )

# Merge with frequency and complexity; remove incomplete rows
model_data <- char_rt %>%
  left_join(chars, by = "char") %>%
  drop_na(log_freq, strokes, median_rt_ms) %>%
  mutate(
    freq = exp(log_freq),
    log_median_rt = log(median_rt_ms)
  )

# Fit simple linear model of log median RT
model <- lm(log_median_rt ~ log_freq + strokes, data = model_data)

# Prepare model diagnostics
model_summary <- summary(model)

model_tidy <- as_tibble(model_summary$coefficients, rownames = "term")

model_glance <- tibble(
  r_squared = model_summary$r.squared,
  adj_r_squared = model_summary$adj.r.squared,
  sigma = model_summary$sigma,
  df = paste(model_summary$df[1], model_summary$df[2], sep = ","),
  n = nrow(model_data)
)

model_aug <- model_data %>%
  mutate(
    .fitted = fitted(model),
    .resid = resid(model)
  )

# Ensure output directories exist
dir_create <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE)
dir_create(here("outputs", "data"))
dir_create(here("outputs", "results"))
dir_create(here("outputs", "figures"))

# Persist data and model summaries
write_csv(model_data, here("outputs", "data", "character_frequency_model_data.csv"))
write_csv(model_tidy, here("outputs", "results", "character_frequency_model_tidy.csv"))
write_csv(model_glance, here("outputs", "results", "character_frequency_model_glance.csv"))
write_csv(model_aug, here("outputs", "data", "character_frequency_model_augmented.csv"))

# Plot response time vs frequency with smooth trend and uncertainty
smooth_method <- if (nrow(model_data) >= 10) "loess" else "lm"

plot_rt_freq <- ggplot(model_data, aes(x = log_freq, y = median_rt_ms)) +
  geom_point(color = "#2b8cbe", alpha = 0.7) +
  geom_smooth(
    method = smooth_method,
    se = TRUE,
    color = "#253494",
    fill = "#a6bddb",
    span = if (smooth_method == "loess") 0.8 else 1,
    formula = y ~ x
  ) +
  labs(
    title = "Character Frequency vs. Response Time",
    x = "Log frequency",
    y = "Median lexical decision time (ms)",
    caption = "Trials aggregated to character level; loess smooth with 95% confidence band."
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = here("outputs", "figures", "character_frequency_rt_vs_freq.png"),
  plot = plot_rt_freq,
  width = 6,
  height = 4,
  dpi = 300
)

# Model the visual-complexity penalty controlling for frequency using the linear model above.
complexity_model <- model
complexity_summary <- model_summary

complexity_tidy <- model_tidy %>%
  filter(term == "strokes") %>%
  mutate(penalty_pct = (exp(Estimate) - 1) * 100)

write_csv(
  complexity_tidy,
  here("outputs", "results", "visual_complexity_model_tidy.csv")
)

complexity_glance <- tibble(
  r_squared = complexity_summary$r.squared,
  adj_r_squared = complexity_summary$adj.r.squared,
  sigma = complexity_summary$sigma,
  n = nrow(model_data),
  df_model = complexity_summary$df[1],
  df_residual = complexity_summary$df[2]
)

write_csv(
  complexity_glance,
  here("outputs", "results", "visual_complexity_model_glance.csv")
)

stroke_grid <- tibble(
  strokes = seq(
    floor(min(model_data$strokes, na.rm = TRUE)),
    ceiling(max(model_data$strokes, na.rm = TRUE)),
    by = 0.1
  )
) %>%
  mutate(log_freq = mean(model_data$log_freq, na.rm = TRUE))

stroke_predictions <- predict(
  complexity_model,
  newdata = stroke_grid,
  se.fit = TRUE
)

stroke_grid <- stroke_grid %>%
  mutate(
    fit_log_rt = stroke_predictions$fit,
    se_log_rt = stroke_predictions$se.fit,
    fit_rt_ms = exp(fit_log_rt),
    lower_rt_ms = exp(fit_log_rt - 1.96 * se_log_rt),
    upper_rt_ms = exp(fit_log_rt + 1.96 * se_log_rt)
  )

baseline_idx <- which.min(stroke_grid$strokes)
baseline_rt <- stroke_grid$fit_rt_ms[baseline_idx]

stroke_grid <- stroke_grid %>%
  mutate(
    penalty_ms = fit_rt_ms - baseline_rt,
    penalty_lower_ms = lower_rt_ms - baseline_rt,
    penalty_upper_ms = upper_rt_ms - baseline_rt
  )

penalty_diff <- diff(stroke_grid$penalty_ms) / diff(stroke_grid$strokes)
max_slope_id <- if (length(penalty_diff) > 0) which.max(penalty_diff) else NA_integer_
max_penalty_idx <- which.max(stroke_grid$penalty_ms)

penalty_summary <- list(
  model = "lm(log_median_rt ~ log_freq + strokes)",
  reference = list(
    strokes = stroke_grid$strokes[baseline_idx],
    predicted_rt_ms = baseline_rt
  ),
  max_penalty = list(
    strokes = stroke_grid$strokes[max_penalty_idx],
    penalty_ms = stroke_grid$penalty_ms[max_penalty_idx],
    predicted_rt_ms = stroke_grid$fit_rt_ms[max_penalty_idx]
  ),
  slope = list(
    rate_ms_per_stroke = if (length(penalty_diff) > 0) penalty_diff[max_slope_id] else NA_real_,
    start_strokes = if (length(penalty_diff) > 0) stroke_grid$strokes[max_slope_id] else NA_real_,
    end_strokes = if (length(penalty_diff) > 0) stroke_grid$strokes[max_slope_id + 1] else NA_real_
  )
)

yaml::write_yaml(
  penalty_summary,
  here("outputs", "results", "visual_complexity_penalty_summary.yml")
)

write_csv(
  stroke_grid,
  here("outputs", "data", "visual_complexity_partial_effect.csv")
)

plot_complexity <- ggplot(stroke_grid, aes(x = strokes, y = penalty_ms)) +
  geom_ribbon(
    aes(ymin = penalty_lower_ms, ymax = penalty_upper_ms),
    fill = "#c7e9c0",
    alpha = 0.6
  ) +
  geom_line(color = "#238b45", linewidth = 1) +
  labs(
    title = "Visual Complexity Penalty",
    x = "Strokes (visual complexity)",
    y = "Penalty vs. baseline (ms)",
    caption = "Predictions from linear model holding log frequency at its mean; shaded band shows 95% CI."
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = here("outputs", "figures", "visual_complexity_partial_effect.png"),
  plot = plot_complexity,
  width = 6,
  height = 4,
  dpi = 300
)

cat("Wrote visual complexity outputs to outputs/results, outputs/data, and outputs/figures\n")
