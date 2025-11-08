#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(ggplot2)
  library(here)
  library(yaml)
})

round6 <- function(x) as.numeric(sprintf('%.6f', x))

in_path <- here('outputs', 'data', 'processed.csv')
out_yaml <- here('outputs', 'results', 'phon_family_pron_match.yml')
fig_rel <- file.path('outputs', 'figures', 'phon_family_pron_interaction.png')
out_fig <- here(fig_rel)

stopifnot(file.exists(in_path))

dat <- read_csv(in_path, show_col_types = FALSE)

analysis_data <- dat %>%
  filter(!is.na(phon_family_size), !is.na(pron_match)) %>%
  mutate(
    pron_match = factor(pron_match, levels = c('match', 'mismatch')),
    log_freq_z = as.numeric(scale(log_freq)),
    strokes_z = as.numeric(scale(strokes)),
    phon_family_log = log1p(phon_family_size),
    phon_family_z = as.numeric(scale(phon_family_log))
  )

if (nrow(analysis_data) < 10) {
  stop('Not enough data with phonological family annotations to fit the model.')
}

mod_rt <- lm(
  mean_log_rt ~ log_freq_z + strokes_z + phon_family_z * pron_match,
  data = analysis_data
)

mod_sum <- summary(mod_rt)
coef_df <- as.data.frame(mod_sum$coefficients)
coef_df$term <- rownames(mod_sum$coefficients)

interaction_row <- coef_df %>% filter(term == 'phon_family_z:pron_matchmismatch')
family_log_mean <- mean(analysis_data$phon_family_log, na.rm = TRUE)
family_log_sd <- stats::sd(analysis_data$phon_family_log, na.rm = TRUE)

family_seq <- seq(
  from = min(analysis_data$phon_family_size, na.rm = TRUE),
  to = max(analysis_data$phon_family_size, na.rm = TRUE),
  length.out = 50
)

pred_grid <- expand_grid(
  pron_match = levels(analysis_data$pron_match),
  phon_family_size = family_seq
) %>%
  mutate(
    phon_family_log = log1p(phon_family_size),
    phon_family_z = (phon_family_log - family_log_mean) / family_log_sd,
    log_freq_z = 0,
    strokes_z = 0
  )

pred_ci <- predict(mod_rt, newdata = pred_grid, interval = 'confidence')

pred_grid <- pred_grid %>%
  bind_cols(as_tibble(pred_ci)) %>%
  rename(
    pred_log_rt = fit,
    conf_low = lwr,
    conf_high = upr
  ) %>%
  mutate(
    pred_rt_ms = exp(pred_log_rt),
    conf_low_ms = exp(conf_low),
    conf_high_ms = exp(conf_high)
  )

plot <- ggplot(pred_grid, aes(x = phon_family_size, y = pred_rt_ms, color = pron_match, fill = pron_match)) +
  geom_ribbon(aes(ymin = conf_low_ms, ymax = conf_high_ms), alpha = 0.15, linewidth = 0, show.legend = FALSE) +
  geom_line(linewidth = 1.1) +
  scale_color_manual(values = c('match' = '#1b9e77', 'mismatch' = '#d95f02'), name = 'Pronunciation match') +
  scale_fill_manual(values = c('match' = '#1b9e77', 'mismatch' = '#d95f02')) +
  labs(
    title = 'Phonological family size × pronunciation match',
    x = 'Phonological family size (characters sharing phonetic radical pronunciation)',
    y = 'Predicted lexical decision RT (ms, geometric mean)',
    caption = 'Partialled for log frequency and strokes; ribbons show 95% CIs.'
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = 'top')

ggsave(filename = out_fig, plot = plot, width = 7, height = 4.5, dpi = 300)

summary_deltas <- pred_grid %>%
  arrange(pron_match, phon_family_size) %>%
  group_by(pron_match) %>%
  summarise(
    low_family_rt = first(pred_rt_ms),
    high_family_rt = last(pred_rt_ms),
    delta_ms = high_family_rt - low_family_rt,
    .groups = 'drop'
  )

match_delta <- summary_deltas %>% filter(pron_match == 'match') %>% pull(delta_ms)
mismatch_delta <- summary_deltas %>% filter(pron_match == 'mismatch') %>% pull(delta_ms)

res <- list(
  id = 'phon_family_pron_match',
  title = 'Phonological family size × pronunciation regularity',
  model = 'lm(mean_log_rt ~ log_freq_z + strokes_z + phon_family_z * pron_match)',
  n_obs = nrow(analysis_data),
  n_match = sum(analysis_data$pron_match == 'match'),
  n_mismatch = sum(analysis_data$pron_match == 'mismatch'),
  family_size_range = list(
    min = min(analysis_data$phon_family_size, na.rm = TRUE),
    max = max(analysis_data$phon_family_size, na.rm = TRUE)
  ),
  interaction = list(
    term = 'phon_family_z:pron_matchmismatch',
    estimate = round6(interaction_row$Estimate),
    std_error = round6(interaction_row$`Std. Error`),
    t_value = round6(interaction_row$`t value`),
    p_value = round6(interaction_row$`Pr(>|t|)`)
  ),
  main_effects = list(
    phon_family_z = round6(coef_df$Estimate[coef_df$term == 'phon_family_z']),
    pron_match_mismatch = round6(coef_df$Estimate[coef_df$term == 'pron_matchmismatch'])
  ),
  fit = list(
    r2 = round6(mod_sum$r.squared),
    adj_r2 = round6(mod_sum$adj.r.squared),
    sigma = round6(mod_sum$sigma)
  ),
  predicted_effects_ms = list(
    match_delta_ms = round6(match_delta),
    mismatch_delta_ms = round6(mismatch_delta)
  ),
  figure = fig_rel,
  timestamp = format(Sys.time(), '%Y-%m-%dT%H:%M:%S%z')
)

dir.create(dirname(out_yaml), showWarnings = FALSE, recursive = TRUE)
dir.create(dirname(out_fig), showWarnings = FALSE, recursive = TRUE)

yaml::write_yaml(res, out_yaml)

cat('Wrote ', out_yaml, '\n', sep = '')
cat('Saved figure ', out_fig, '\n', sep = '')
