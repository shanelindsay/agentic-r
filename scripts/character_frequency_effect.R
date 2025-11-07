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
plot_rt_freq <- ggplot(model_data, aes(x = log_freq, y = median_rt_ms)) +
  geom_point(color = "#2b8cbe", alpha = 0.7) +
  geom_smooth(
    method = "loess",
    se = TRUE,
    color = "#253494",
    fill = "#a6bddb",
    span = 0.8
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
