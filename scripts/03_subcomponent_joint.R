suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(here)
  library(yaml)
  library(ggplot2)
  library(purrr)
})

in_path <- here("outputs", "data", "processed.csv")
out_path <- here("outputs", "results", "subcomponent_joint.yml")
fig_path <- here("outputs", "figures", "component_familiarity_effects.png")

dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
dir.create(dirname(fig_path), showWarnings = FALSE, recursive = TRUE)

stopifnot(file.exists(in_path))

d <- readr::read_csv(in_path, show_col_types = FALSE)
needed <- c("mean_log_rt", "log_freq", "strokes", "sem_log_freq", "phon_log_freq")
missing <- setdiff(needed, names(d))
if (length(missing)) {
  stop("Processed data missing: ", paste(missing, collapse = ", "))
}

data <- d |> filter(!is.na(sem_log_freq), !is.na(phon_log_freq))
if (!nrow(data)) {
  stop("No observations with both semantic and phonetic familiarity")
}

median_sem <- median(data$sem_log_freq)
median_phon <- median(data$phon_log_freq)
median_strokes <- median(data$strokes)

log_freq_levels <- tibble(
  level = c("Low", "Medium", "High"),
  label = c("Low (20th pct.)", "Medium (50th pct.)", "High (80th pct.)"),
  quantile = c(0.2, 0.5, 0.8)
) |> mutate(value = as.numeric(quantile(data$log_freq, probs = quantile)))

mod <- lm(mean_log_rt ~ log_freq * sem_log_freq + log_freq * phon_log_freq + sem_log_freq * phon_log_freq + strokes, data = data)
mod_summary <- summary(mod)

make_grid <- function(component = c("semantic", "phonetic")) {
  component <- match.arg(component)
  if (component == "semantic") {
    rng <- range(data$sem_log_freq)
    seq_vals <- seq(rng[1], rng[2], length.out = 100)
    purrr::map2_dfr(log_freq_levels$value, log_freq_levels$label, ~{
      tibble(
        component = "Semantic component familiarity",
        component_value = seq_vals,
        log_freq_level = .y,
        log_freq = .x,
        sem_log_freq = seq_vals,
        phon_log_freq = median_phon,
        strokes = median_strokes
      )
    })
  } else {
    rng <- range(data$phon_log_freq)
    seq_vals <- seq(rng[1], rng[2], length.out = 100)
    purrr::map2_dfr(log_freq_levels$value, log_freq_levels$label, ~{
      tibble(
        component = "Phonetic component familiarity",
        component_value = seq_vals,
        log_freq_level = .y,
        log_freq = .x,
        sem_log_freq = median_sem,
        phon_log_freq = seq_vals,
        strokes = median_strokes
      )
    })
  }
}

pred_sem <- make_grid("semantic")
pred_phon <- make_grid("phonetic")
plot_data <- bind_rows(pred_sem, pred_phon)
plot_data$pred_log <- as.numeric(predict(mod, newdata = plot_data))
plot_data <- plot_data |> mutate(pred_rt_ms = exp(pred_log))

plot <- ggplot(plot_data, aes(x = component_value, y = pred_rt_ms, color = log_freq_level)) +
  geom_line(linewidth = 1) +
  facet_wrap(~component, scales = "free_x") +
  labs(
    title = "Component familiarity effects vary with whole-character experience",
    x = "Component familiarity (log10 frequency + 1)",
    y = "Predicted RT (ms)",
    color = "Whole-character familiarity"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")

ggsave(fig_path, plot, width = 9, height = 5.5, dpi = 150)

quantile_delta <- function(component = c("semantic", "phonetic")) {
  component <- match.arg(component)
  q_vals <- quantile(if (component == "semantic") data$sem_log_freq else data$phon_log_freq, probs = c(0.2, 0.8))
  purrr::map2(log_freq_levels$value, log_freq_levels$label, ~{
    base_new <- tibble(
      log_freq = .x,
      sem_log_freq = median_sem,
      phon_log_freq = median_phon,
      strokes = median_strokes
    )
    if (component == "semantic") {
      low_new <- base_new |> mutate(sem_log_freq = q_vals[[1]])
      high_new <- base_new |> mutate(sem_log_freq = q_vals[[2]])
    } else {
      low_new <- base_new |> mutate(phon_log_freq = q_vals[[1]])
      high_new <- base_new |> mutate(phon_log_freq = q_vals[[2]])
    }
    pred_low <- exp(predict(mod, newdata = low_new))
    pred_high <- exp(predict(mod, newdata = high_new))
    delta_ms <- as.numeric(pred_low - pred_high)
    pct <- (delta_ms / as.numeric(pred_low)) * 100
    list(
      overall_level = .y,
      low_component = as.numeric(q_vals[[1]]),
      high_component = as.numeric(q_vals[[2]]),
      rt_change_ms = round(delta_ms, 2),
      rt_change_pct = round(pct, 2)
    )
  })
}

semantic_effects <- quantile_delta("semantic")
phonetic_effects <- quantile_delta("phonetic")

round6 <- function(x) as.numeric(sprintf("%.6f", x))

freq_levels_export <- lapply(seq_len(nrow(log_freq_levels)), function(i) {
  row <- log_freq_levels[i, ]
  list(
    level = row$level,
    label = row$label,
    quantile = row$quantile,
    value = round6(row$value)
  )
})

res <- list(
  id = "subcomponent_joint",
  title = "Joint effects of whole-character and component familiarity",
  model = "lm(mean_log_rt ~ log_freq * sem_log_freq + log_freq * phon_log_freq + sem_log_freq * phon_log_freq + strokes)",
  n_obs = nrow(data),
  coefficients = as.list(setNames(round6(mod$coefficients), names(mod$coefficients))),
  fit = list(
    r2 = round6(mod_summary$r.squared),
    adj_r2 = round6(mod_summary$adj.r.squared),
    sigma = round6(mod_summary$sigma),
    aic = round6(AIC(mod)),
    bic = round6(BIC(mod))
  ),
  freq_levels = freq_levels_export,
  component_effects = list(semantic = semantic_effects, phonetic = phonetic_effects),
  figure = fs::path_rel(fig_path, start = here::here()),
  timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
)

yaml::write_yaml(res, out_path)

cat("Wrote ", out_path, " and ", fig_path, "\n", sep = "")
