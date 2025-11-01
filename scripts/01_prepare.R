## scripts/01_prepare.R
## Read trial-level SCLP slice + CLD predictors; aggregate and join.
## Input:  SCLP trials (full or sample) and CLD (full or sample)
## Output: outputs/data/processed.csv (+ filtered trials, YAML, figure)

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

walk(c("outputs/data", "outputs/results", "outputs/figures"), ~fs::dir_create(here(.x)))

cfg_path <- here("configs", "cleaning.yml")
if (!file.exists(cfg_path)) stop("Missing configs/cleaning.yml at: ", cfg_path)
cfg <- yaml::read_yaml(cfg_path)

keep_correct <- isTRUE(cfg$correct_only)
rt_min <- as.numeric(cfg$rt_min_ms)
rt_max <- as.numeric(cfg$rt_max_ms)
if (!is.finite(rt_min) || !is.finite(rt_max) || !(rt_min < rt_max)) {
  stop("Bad RT bounds in configs/cleaning.yml: rt_min_ms=", rt_min, " rt_max_ms=", rt_max)
}

raw_trials_path <- here(cfg$raw_trials)
cld_path <- here(cfg$cld_file)
if (!file.exists(raw_trials_path)) stop("Missing SCLP trials at: ", raw_trials_path)
if (!file.exists(cld_path))       stop("Missing CLD file at: ", cld_path)

# --- Load SCLP trials (support 'sclp_full' and 'sample') ---
sclp_raw <- readr::read_csv(raw_trials_path, show_col_types = FALSE)
if (identical(cfg$raw_type, "sclp_full")) {
  # Expect columns: item, lexicality, accuracy, rt
  needed <- c("item", "lexicality", "accuracy", "rt")
  if (!all(needed %in% names(sclp_raw))) {
    stop("SCLP full file missing columns: ", paste(setdiff(needed, names(sclp_raw)), collapse = ", "))
  }
  sclp_raw <- dplyr::filter(sclp_raw, lexicality == "character")
  sclp <- dplyr::transmute(sclp_raw, char = item, rt_ms = rt, correct = accuracy)
} else if (identical(cfg$raw_type, "sample")) {
  if (!all(c("char", "rt_ms", "correct") %in% names(sclp_raw))) {
    stop("Sample SCLP must have columns: char, rt_ms, correct")
  }
  sclp <- dplyr::select(sclp_raw, char, rt_ms, correct)
} else {
  stop("Unknown raw_type in configs/cleaning.yml: ", cfg$raw_type)
}

# Enforce types and single-character rows
sclp <- sclp %>%
  mutate(
    char = as.character(char),
    rt_ms = suppressWarnings(as.numeric(rt_ms)),
    correct = suppressWarnings(as.numeric(correct))
  ) %>%
  filter(nchar(char) == 1L)

# --- Load CLD (support 'full' and 'sample') ---
ext <- tolower(tools::file_ext(cld_path))
if (ext %in% c("tsv", "txt")) {
  first_line <- readr::read_lines(cld_path, n_max = 1)
  use_tab <- length(first_line) && grepl("\t", first_line)
  cld_raw <- if (use_tab) {
    readr::read_delim(cld_path, delim = "\t", show_col_types = FALSE)
  } else {
    readr::read_csv(cld_path, show_col_types = FALSE)
  }
} else {
  cld_raw <- readr::read_csv(cld_path, show_col_types = FALSE)
}

if (identical(cfg$cld_type, "full")) {
  needed <- c("Word", "Length", "Strokes", "Frequency")
  if (!all(needed %in% names(cld_raw))) {
    stop("CLD full file missing columns: ", paste(setdiff(needed, names(cld_raw)), collapse = ", "))
  }
  cld <- cld_raw %>%
    filter(Length == 1) %>%
    transmute(
      char = as.character(Word),
      strokes = as.numeric(Strokes),
      log_freq = log10(pmax(as.numeric(Frequency), 0) + 1)
    )
} else if (identical(cfg$cld_type, "sample")) {
  if (!all(c("char", "log_freq", "strokes") %in% names(cld_raw))) {
    stop("Sample CLD must have columns: char, log_freq, strokes")
  }
  cld <- cld_raw %>%
    transmute(
      char = as.character(char),
      log_freq = as.numeric(log_freq),
      strokes  = as.numeric(strokes)
    )
} else {
  stop("Unknown cld_type in configs/cleaning.yml: ", cfg$cld_type)
}

# --- Trim and aggregate ---
filtered_trials <- sclp %>%
  filter(!is.na(rt_ms)) %>%
  filter(rt_ms >= rt_min, rt_ms <= rt_max) %>%
  { if (keep_correct) filter(., !is.na(correct) & correct == 1) else . }

# Atomic write helper
write_csv_atomic <- function(df, path) {
  tmp <- paste0(path, ".tmp")
  readr::write_csv(df, tmp)
  fs::file_move(tmp, path)
}

# Persist filtered trials
filtered_path <- here("outputs", "data", "trials_filtered.csv")
write_csv_atomic(filtered_trials, filtered_path)

# mean(log RT) per character
agg_rt <- filtered_trials %>%
  group_by(char) %>%
  summarise(mean_log_rt = mean(log(rt_ms)), .groups = "drop")

# accuracy per character from character trials (pre-trim RT)
agg_acc <- sclp %>%
  group_by(char) %>%
  summarise(acc_rate = mean(correct, na.rm = TRUE), .groups = "drop")

# join, requiring predictors
dat <- agg_rt %>%
  left_join(agg_acc, by = "char") %>%
  inner_join(cld, by = "char") %>%
  drop_na(log_freq, strokes)

processed_path <- here("outputs", "data", "processed.csv")
write_csv_atomic(dat, processed_path)

# Cleaning summary YAML (atomic)
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
tmp_yaml <- paste0(summary_yaml, ".tmp")
yaml::write_yaml(summary_info, tmp_yaml)
fs::file_move(tmp_yaml, summary_yaml)

# RT histogram (kept trials)
hist_plot <- filtered_trials %>%
  ggplot(aes(x = rt_ms)) +
  geom_histogram(bins = 40, fill = "#4477AA") +
  labs(
    title = glue("RT histogram (kept {nrow(filtered_trials)}/{nrow(sclp)} trials)"),
    x = "RT (ms)",
    y = "Count"
  ) +
  theme_minimal(base_size = 14)
fig_path <- here("outputs", "figures", "rt_hist.png")
ggsave(fig_path, plot = hist_plot, width = 8, height = 5, dpi = 150)

cat(glue(
  "Wrote {nrow(dat)} rows to processed data; outputs saved to:\n",
  "  - {processed_path}\n",
  "  - {summary_yaml}\n",
  "  - {fig_path}\n"
))
