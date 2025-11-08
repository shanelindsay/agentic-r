suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tidyr)
  library(mgcv)
  library(yaml)
  library(here)
  library(scales)
})

input_path <- here("outputs", "data", "processed.csv")
yaml_path <- here("outputs", "results", "freq_rt_complexity.yml")
predictions_path <- here("outputs", "results", "freq_rt_quantiles.csv")
figure_path <- here("outputs", "figures", "freq_rt_vs_frequency.png")

if (!file.exists(input_path)) {
  stop("Missing processed data: ", input_path)
}

data <- read_csv(input_path, show_col_types = FALSE)

needed <- c("mean_log_rt", "log_freq", "strokes")
missing <- setdiff(needed, names(data))
if (length(missing)) {
  stop("Processed data missing columns: ", paste(missing, collapse = ", "))
}

analysis_data <- data %>%
  select(mean_log_rt, log_freq, strokes) %>%
  mutate(
    mean_rt_ms = exp(mean_log_rt),
    freq = exp(log_freq),
    strokes = as.numeric(strokes)
  ) %>%
  drop_na()

if (nrow(analysis_data) < 10) {
  stop("Not enough observations after cleaning: ", nrow(analysis_data))
}

gam_model <- mgcv::gam(
  mean_log_rt ~ s(log_freq, k = 5) + strokes,
  data = analysis_data,
  method = "REML"
)

quantiles <- c(`10th` = 0.10, `50th` = 0.50, `90th` = 0.90)
log_freq_quantiles <- stats::quantile(analysis_data$log_freq, probs = quantiles, names = FALSE)
median_strokes <- stats::median(analysis_data$strokes, na.rm = TRUE)

prediction_grid <- tibble(
  quantile = names(quantiles),
  prob = unname(quantiles),
  log_freq = log_freq_quantiles,
  strokes = median_strokes
)

pred <- predict(gam_model, newdata = prediction_grid, se.fit = TRUE)

prediction_grid <- prediction_grid %>%
  mutate(
    fitted_log_rt = as.numeric(pred$fit),
    se_log_rt = as.numeric(pred$se.fit),
    fitted_rt_ms = exp(fitted_log_rt),
    lower_rt_ms = exp(fitted_log_rt - 1.96 * se_log_rt),
    upper_rt_ms = exp(fitted_log_rt + 1.96 * se_log_rt),
    freq = exp(log_freq)
  )

gain_low_mid <- prediction_grid$fitted_rt_ms[prediction_grid$quantile == "10th"] -
  prediction_grid$fitted_rt_ms[prediction_grid$quantile == "50th"]
gain_mid_high <- prediction_grid$fitted_rt_ms[prediction_grid$quantile == "50th"] -
  prediction_grid$fitted_rt_ms[prediction_grid$quantile == "90th"]

round_num <- function(x, digits = 4) round(as.numeric(x), digits)

result_list <- list(
  id = "freq_rt_complexity",
  title = "Frequency effect on response time with complexity adjustment",
  model = "gam(mean_log_rt ~ s(log_freq, k = 5) + strokes)",
  n_obs = nrow(analysis_data),
  median_strokes = round_num(median_strokes, 2),
  smooth_df = round_num(sum(gam_model$edf[grepl("s\\(log_freq", names(gam_model$edf), fixed = FALSE)]), 3),
  gains_ms = list(
    low_to_mid = round_num(gain_low_mid, 2),
    mid_to_high = round_num(gain_mid_high, 2)
  ),
  quantile_estimates = prediction_grid %>%
    mutate(
      log_freq = round_num(log_freq, 4),
      freq = round_num(freq, 4),
      fitted_rt_ms = round_num(fitted_rt_ms, 2),
      lower_rt_ms = round_num(lower_rt_ms, 2),
      upper_rt_ms = round_num(upper_rt_ms, 2)
    ) %>%
    split(.$quantile) %>%
    lapply(function(df) {
      list(
        prob = df$prob[[1]],
        log_freq = df$log_freq[[1]],
        freq = df$freq[[1]],
        rt_ms = df$fitted_rt_ms[[1]],
        rt_ms_lower = df$lower_rt_ms[[1]],
        rt_ms_upper = df$upper_rt_ms[[1]]
      )
    }),
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
)

dir.create(dirname(yaml_path), showWarnings = FALSE, recursive = TRUE)
dir.create(dirname(predictions_path), showWarnings = FALSE, recursive = TRUE)
dir.create(dirname(figure_path), showWarnings = FALSE, recursive = TRUE)

write_csv(prediction_grid, predictions_path)
write_yaml(result_list, yaml_path)

plot_rt_freq <- ggplot(analysis_data, aes(x = freq, y = mean_rt_ms)) +
  geom_point(alpha = 0.6, color = "#2b8cbe") +
  geom_smooth(
    method = "gam",
    formula = y ~ s(x, k = 5),
    se = TRUE,
    color = "#00441b",
    fill = "#74c476"
  ) +
  scale_x_continuous(
    trans = "log10",
    labels = label_number(accuracy = 0.1)
  ) +
  labs(
    title = "Faster responses for higher-frequency characters",
    subtitle = "Character-level median RTs with GAM smooth adjusted for strokes",
    x = "Character frequency (log scale)",
    y = "Mean response time (ms)"
  ) +
  theme_minimal(base_size = 12)

plot_rt_freq <- plot_rt_freq +
  ggplot2::labs(
    caption = sprintf(
      "Points: characters (N = %s); smooth: GAM with 95%% CI. x-axis is log-scaled.",
      nrow(analysis_data)
    )
  )

ggsave(
  filename = figure_path,
  plot = plot_rt_freq,
  width = 6,
  height = 4,
  dpi = 300
)

cat("Wrote ", yaml_path, "\n", sep = "")
cat("Wrote ", predictions_path, "\n", sep = "")
cat("Wrote ", figure_path, "\n", sep = "")
