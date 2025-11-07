## scripts/01_prepare.R
## Minimal pipeline: read, trim, aggregate, join, write. Fail loudly on bad inputs.

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
  library(tools)
})

source(here::here("R", "utils.R"))

dir.create(here("outputs","data"),    showWarnings = FALSE, recursive = TRUE)
dir.create(here("outputs","results"), showWarnings = FALSE, recursive = TRUE)
dir.create(here("outputs","figures"), showWarnings = FALSE, recursive = TRUE)

cfg <- yaml::read_yaml(here("configs","cleaning.yml"))
keep_correct <- isTRUE(cfg$correct_only)
rt_min <- as.numeric(cfg$rt_min_ms)
rt_max <- as.numeric(cfg$rt_max_ms)

# SCLP: full or sample
sclp_raw <- readr::read_csv(here(cfg$raw_trials), show_col_types = FALSE)
sclp <- if (identical(cfg$raw_type, "sclp_full")) {
  sclp_raw |>
    filter(lexicality == "character") |>
    transmute(char = item, rt_ms = rt, correct = accuracy)
} else if (identical(cfg$raw_type, "sample")) {
  sclp_raw |>
    select(char, rt_ms, correct)
} else stop("Unknown raw_type: ", cfg$raw_type)

sclp <- sclp |>
  mutate(char = as.character(char)) |>
  filter(nchar(char) == 1L)

# CLD: load and keep single-character predictors
cld_raw <- readr::read_csv(here(cfg$cld_file), show_col_types = FALSE)

cld <- if (identical(cfg$cld_type, "full")) {
  cld_raw |>
    filter(Length == 1) |>
    transmute(
      char     = Word,
      strokes  = as.numeric(Strokes),
      log_freq = log10(pmax(as.numeric(Frequency), 0) + 1),
      phon_family_size = suppressWarnings(as.numeric(C1PRFamilySize)),
      pron_match = dplyr::case_when(
        is.na(C1PRRegularity) ~ NA_character_,
        C1PRRegularity == 1   ~ "match",
        C1PRRegularity == 0   ~ "mismatch",
        TRUE ~ NA_character_
      )
    )
} else {
  cld_raw |>
    select(char, log_freq, strokes) |>
    mutate(
      phon_family_size = NA_real_,
      pron_match = NA_character_
    )
}

# Trim, aggregate, join
filtered_trials <- sclp |>
  filter(!is.na(rt_ms), rt_ms >= rt_min, rt_ms <= rt_max)

if (keep_correct) {
  filtered_trials <- filtered_trials |> filter(correct == 1)
}

filtered_path <- here("outputs", "data", "trials_filtered.csv")
write_csv_atomic(filtered_trials, filtered_path)

agg_rt <- filtered_trials |>
  group_by(char) |>
  summarise(
    mean_log_rt = mean(log(rt_ms)),
    mean_rt_ms = mean(rt_ms),
    sd_rt_ms = sd(rt_ms),
    kept_trials = dplyr::n(),
    .groups = "drop"
  ) |>
  mutate(geom_rt_ms = exp(mean_log_rt))

agg_acc <- sclp |>
  group_by(char) |>
  summarise(
    total_trials = dplyr::n(),
    correct_trials = sum(correct == 1, na.rm = TRUE),
    acc_rate = correct_trials / pmax(total_trials, 1),
    .groups = "drop"
  )

dat <- agg_rt |>
  left_join(agg_acc, by = "char") |>
  inner_join(cld, by = "char") |>
  drop_na(log_freq, strokes)

processed_path <- here("outputs", "data", "processed.csv")
write_csv_atomic(dat, processed_path)

summary_yaml <- here("outputs", "results", "cleaning.yml")
summary_info <- list(
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  trimming  = list(correct_only = keep_correct, rt_min_ms = rt_min, rt_max_ms = rt_max),
  counts    = list(total_trials = nrow(sclp), kept_trials = nrow(filtered_trials),
                   dropped_trials = nrow(sclp) - nrow(filtered_trials))
)
write_yaml_atomic(summary_info, summary_yaml)

hist_plot <- ggplot(filtered_trials, aes(x = rt_ms)) +
  geom_histogram(bins = 40, fill = "#4477AA") +
  labs(title = glue("RT histogram (kept {nrow(filtered_trials)}/{nrow(sclp)} trials)"),
       x = "RT (ms)", y = "Count") +
  theme_minimal(base_size = 14)
ggsave(here("outputs","figures","rt_hist.png"), plot = hist_plot, width = 8, height = 5, dpi = 150)

cat(glue("Wrote {nrow(dat)} rows to processed data\n"))
