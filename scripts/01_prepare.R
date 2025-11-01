# scripts/01_prepare.R
# Read trial-level SCLP slice + CLD predictors; aggregate and join.
# Input:  data/raw/sclp_sample.csv (columns: char, rt_ms, correct)
#         data/raw/cld_sample.csv  (columns: char, log_freq, strokes)
# Output: outputs/data/processed.csv

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(purrr)
  library(tidyr)
  library(ggplot2)
  library(glue)
  library(yaml)
  library(fs)
  library(here)
})

walk(
  c("outputs/data", "outputs/results", "outputs/figures"),
  ~dir_create(here(.x))
)

cfg_path <- here("configs", "cleaning.yml")
cfg <- read_yaml(cfg_path)

keep_correct <- isTRUE(cfg$correct_only)
rt_min <- as.numeric(cfg$rt_min_ms)
rt_max <- as.numeric(cfg$rt_max_ms)

raw_trials_path <- here(cfg$raw_trials)
cld_path <- here(cfg$cld_file)

sclp <- switch(
  cfg$raw_type,
  sclp_full = read_csv(raw_trials_path, show_col_types = FALSE) %>%
    transmute(
      char = item,
      rt_ms = rt,
      correct = accuracy
    ),
  sample = read_csv(raw_trials_path, show_col_types = FALSE) %>%
    select(char, rt_ms, correct)
) %>%
  mutate(correct = as.numeric(correct))

cld <- switch(
  cfg$cld_type,
  full = read_csv(cld_path, show_col_types = FALSE) %>%
    filter(Length == 1) %>%
    transmute(
      char = Word,
      strokes = Strokes,
      log_freq = log10(Frequency + 1)
    ),
  sample = read_csv(cld_path, show_col_types = FALSE) %>%
    select(char, log_freq, strokes)
)

filtered_trials <- sclp %>%
  filter(
    (!keep_correct | correct == 1) | is.na(correct)
  ) %>%
  filter(
    is.na(rt_ms) | between(rt_ms, rt_min, rt_max)
  )

filtered_path <- here("outputs", "data", "trials_filtered.csv")
write_csv(filtered_trials, filtered_path)

agg_rt <- filtered_trials %>%
  filter(!is.na(rt_ms)) %>%
  group_by(char) %>%
  summarise(mean_log_rt = mean(log(rt_ms)), .groups = "drop")

agg_acc <- sclp %>%
  group_by(char) %>%
  summarise(acc_rate = mean(correct), .groups = "drop")

dat <- agg_rt %>%
  left_join(agg_acc, by = "char") %>%
  left_join(cld, by = "char") %>%
  drop_na(log_freq, strokes)

processed_path <- here("outputs", "data", "processed.csv")
write_csv(dat, processed_path)

summary_yaml <- here("outputs", "results", "cleaning.yml")

summary_info <- list(
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  trimming = list(
    correct_only = keep_correct,
    rt_min_ms = rt_min,
    rt_max_ms = rt_max
  ),
  counts = list(
    total_trials = nrow(sclp),
    kept_trials = nrow(filtered_trials),
    dropped_trials = nrow(sclp) - nrow(filtered_trials)
  )
)

write_yaml(summary_info, summary_yaml)

hist_plot <- filtered_trials %>%
  filter(!is.na(rt_ms)) %>%
  ggplot(aes(x = rt_ms)) +
  geom_histogram(bins = 40, fill = "#4477AA") +
  labs(
    title = glue(
      "RT histogram (kept {nrow(filtered_trials)}/{nrow(sclp)} trials)"
    ),
    x = "RT (ms)",
    y = "Count"
  ) +
  theme_minimal(base_size = 14)

fig_path <- here("outputs", "figures", "rt_hist.png")
ggsave(fig_path, plot = hist_plot, width = 8, height = 5, dpi = 150)

inform_message <- glue(
  "Wrote {nrow(dat)} rows to processed data; outputs saved to:\n",
  "  - {processed_path}\n",
  "  - {summary_yaml}\n",
  "  - {fig_path}"
)

cat(inform_message, "\n")
