#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(glue)
  library(here)
  library(mgcv)
  library(readr)
  library(tibble)
})

source(here::here("R", "frequency_rt.R"))

character_trials <- prepare_character_trials()

frequency_model <- fit_frequency_gam(character_trials)

curve_estimates <- predict_frequency_curve(frequency_model, character_trials)
quantile_estimates <- quantile_effects(frequency_model, character_trials)

character_summary <- character_trials |>
  group_by(item) |>
  summarise(
    frequency = first(frequency),
    strokes = first(strokes),
    log10_frequency = first(log10_frequency),
    mean_rt_ms = mean(rt),
    median_rt_ms = stats::median(rt),
    trials = n(),
    .groups = "drop"
  )

outputs_dir <- list(
  figures = here::here("outputs", "figures"),
  results = here::here("outputs", "results"),
  data = here::here("outputs", "data")
)

purrr::walk(outputs_dir, fs::dir_create)

response_plot <- ggplot(character_summary, aes(x = frequency, y = mean_rt_ms)) +
  geom_point(alpha = 0.25, color = "#666666", size = 1) +
  geom_ribbon(
    data = curve_estimates,
    aes(x = frequency, ymin = lower_ms, ymax = upper_ms),
    inherit.aes = FALSE,
    fill = "#5470C6",
    alpha = 0.25
  ) +
  geom_line(
    data = curve_estimates,
    aes(x = frequency, y = fit_ms),
    inherit.aes = FALSE,
    color = "#1D3A5F",
    linewidth = 1
  ) +
  scale_x_log10() +
  labs(
    x = "Character frequency (log scale, Chinese Lexical Database units)",
    y = "Mean response time (ms)",
    title = "Higher frequency characters are recognised faster",
    subtitle = "Smooth represents the fitted effect while holding stroke count at its median"
  ) +
  theme_minimal(base_size = 12)

ggplot2::ggsave(
  filename = here::here("outputs", "figures", "frequency_vs_rt.png"),
  plot = response_plot,
  width = 7,
  height = 5,
  dpi = 300
)

readr::write_csv(
  character_summary,
  here::here("outputs", "data", "character_frequency_rt_summary.csv")
)

readr::write_csv(
  curve_estimates,
  here::here("outputs", "data", "frequency_rt_curve.csv")
)

model_summary_path <- here::here("outputs", "results", "frequency_rt_model_summary.txt")
capture.output(
  summary(frequency_model),
  file = model_summary_path
)

trial_count <- nrow(character_trials)
character_count <- n_distinct(character_trials$item)
subject_count <- n_distinct(character_trials$subject)
median_strokes <- stats::median(character_trials$strokes)

q10 <- quantile_estimates |> filter(prob == 0.1)
q50 <- quantile_estimates |> filter(prob == 0.5)
q90 <- quantile_estimates |> filter(prob == 0.9)
q99 <- quantile_estimates |> filter(prob == 0.99)

drop_10_50 <- q10$fit_ms - q50$fit_ms
drop_50_90 <- q50$fit_ms - q90$fit_ms
change_90_99 <- q99$fit_ms - q90$fit_ms

percent_drop_99 <- (q10$fit_ms - q99$fit_ms) / q10$fit_ms * 100

direction_90_99 <- ifelse(change_90_99 > 0, "increase", "reduction")

summary_lines <- glue::glue(
  "# Frequency and response time\n\n",
  "- Trials analysed: {trial_count} (subjects: {subject_count}; characters: {character_count})\n",
  "- Median stroke count held constant in effect estimates: {median_strokes}\n\n",
  "Frequency effect (holding stroke count at the median):\n\n",
  "- Moving from the 10th to 50th percentile of frequency is associated with a {round(drop_10_50, 1)} ms faster response.\n",
  "- Moving from the 50th to 90th percentile yields a further {round(drop_50_90, 1)} ms reduction.\n",
  "- Between the 90th and 99th percentile the model shows only a {round(abs(change_90_99), 1)} ms {direction_90_99}, indicating a flat or slightly reversing trend at the very high end.\n\n",
  "Overall, characters in the 99th percentile respond about {round(percent_drop_99, 1)}% faster than those in the 10th percentile."
)

readr::write_file(
  summary_lines,
  here::here("outputs", "results", "frequency_rt_summary.md")
)
