suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(scales)
  library(here)
})

source(here("R", "utils.R"))

input_path <- here("outputs", "data", "processed.csv")
yaml_path <- here("outputs", "results", "frequency_effect.yml")
figure_rel <- file.path("outputs", "figures", "response_time_vs_frequency.png")
figure_path <- here(figure_rel)

if (!file.exists(input_path)) {
  stop("Missing processed data at ", input_path)
}

dat <- readr::read_csv(input_path, show_col_types = FALSE) |>
  mutate(
    mean_rt_ms = exp(mean_log_rt),
    freq = 10^log_freq - 1
  )

if (!all(c("mean_log_rt", "log_freq", "strokes") %in% names(dat))) {
  stop("Processed data missing required columns: mean_log_rt, log_freq, strokes")
}

mod <- lm(mean_log_rt ~ log_freq + strokes, data = dat)
mod_summary <- summary(mod)
coef_mat <- mod_summary$coefficients
conf_mat <- stats::confint(mod)

strokes_ref <- stats::median(dat$strokes, na.rm = TRUE)
freq_probs <- c(0.1, 0.5, 0.9, 0.95)
freq_points <- tibble(
  prob = freq_probs,
  log_freq = as.numeric(stats::quantile(dat$log_freq, probs = freq_probs, names = FALSE)),
  strokes = strokes_ref
)

pred_ci <- predict(mod, newdata = freq_points, interval = "confidence")
freq_points <- freq_points |>
  mutate(
    fit_log = pred_ci[, "fit"],
    lwr_log = pred_ci[, "lwr"],
    upr_log = pred_ci[, "upr"],
    fit_ms = exp(fit_log),
    lwr_ms = exp(lwr_log),
    upr_ms = exp(upr_log)
  )

delta_low_mid <- freq_points$fit_ms[freq_points$prob == 0.1] -
  freq_points$fit_ms[freq_points$prob == 0.5]
delta_mid_high <- freq_points$fit_ms[freq_points$prob == 0.5] -
  freq_points$fit_ms[freq_points$prob == 0.9]
delta_high_top <- freq_points$fit_ms[freq_points$prob == 0.9] -
  freq_points$fit_ms[freq_points$prob == 0.95]

round6 <- function(x) as.numeric(sprintf("%.6f", x))
round3 <- function(x) as.numeric(sprintf("%.3f", x))

terms <- rownames(coef_mat)
coef_list <- lapply(seq_along(terms), function(i) {
  list(
    estimate = round6(coef_mat[i, "Estimate"]),
    std_error = round6(coef_mat[i, "Std. Error"]),
    conf_low = round6(conf_mat[i, 1]),
    conf_high = round6(conf_mat[i, 2])
  )
})
names(coef_list) <- terms

summary_list <- list(
  id = "frequency_effect",
  title = "Frequency effect on recognition speed (adjusting for strokes)",
  model = "lm(mean_log_rt ~ log_freq + strokes)",
  n_obs = nrow(dat),
  coefficients = coef_list,
  r2 = round6(mod_summary$r.squared),
  adj_r2 = round6(mod_summary$adj.r.squared),
  sigma = round6(mod_summary$sigma),
  aic = round6(stats::AIC(mod)),
  bic = round6(stats::BIC(mod)),
  reference = list(
    strokes_median = round3(strokes_ref),
    log_freq_quantiles = as.list(stats::setNames(
      round3(freq_points$log_freq),
      paste0("p", gsub("\\.", "", format(freq_points$prob, trim = TRUE)))
    )),
    predicted_rt_ms = as.list(stats::setNames(
      round3(freq_points$fit_ms),
      paste0("p", gsub("\\.", "", format(freq_points$prob, trim = TRUE)))
    ))
  ),
  flattening = list(
    delta_low_mid_ms = round3(delta_low_mid),
    delta_mid_high_ms = round3(delta_mid_high),
    delta_high_top_ms = round3(delta_high_top)
  ),
  figure = figure_rel,
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
)

write_yaml_atomic(summary_list, yaml_path)

plot <- ggplot(dat, aes(x = log_freq, y = mean_rt_ms)) +
  geom_point(color = "#2b8cbe", alpha = 0.7) +
  geom_smooth(
    method = "loess",
    formula = y ~ x,
    se = TRUE,
    color = "#253494",
    fill = alpha("#a6bddb", 0.6),
    span = 0.75
  ) +
  scale_y_continuous(
    labels = comma_format(accuracy = 1),
    name = "Mean response time (ms)"
  ) +
  scale_x_continuous(name = "Log10 character frequency + 1") +
  labs(
    title = "Recognition speed by usage frequency",
    subtitle = "Points: characters; line: loess smooth with 95% confidence band",
    caption = "Response times aggregated per character after trimming; model adjusts for strokes separately."
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = figure_path,
  plot = plot,
  width = 7,
  height = 4.5,
  dpi = 300
)

cat("Wrote analysis yaml to ", yaml_path, "\n", sep = "")
cat("Saved figure to ", figure_path, "\n", sep = "")
