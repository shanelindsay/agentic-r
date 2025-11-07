# Helper functions for modelling how character frequency relates to response time.

prepare_character_trials <- function(
    trial_path = here::here("data", "raw", "SCLP_full_TrialsSCLP.csv"),
    lexicon_path = here::here("data", "raw", "chineselexicaldatabase2.1.txt"),
    rt_min = 200,
    rt_max = 2000
) {
  trials <- readr::read_csv(trial_path, show_col_types = FALSE) |>
    dplyr::filter(
      lexicality == "character",
      accuracy == 1,
      !is.na(rt),
      dplyr::between(rt, rt_min, rt_max)
    ) |>
    dplyr::mutate(
      subject = factor(subject),
      item = factor(item)
    )

  lexicon <- readr::read_csv(lexicon_path, show_col_types = FALSE) |>
    dplyr::filter(nchar(Word) == 1) |>
    dplyr::transmute(
      item = Word,
      frequency = Frequency,
      strokes = Strokes
    ) |>
    dplyr::filter(!is.na(frequency), !is.na(strokes), frequency > 0, strokes > 0)

  trials |>
    dplyr::inner_join(lexicon, by = "item") |>
    dplyr::mutate(
      log_rt = log(rt),
      log10_frequency = log10(frequency)
    )
}

fit_frequency_gam <- function(
    data,
    k_frequency = 6,
    k_strokes = 5,
    discrete = FALSE
) {
  data <- as.data.frame(data)
  s <- mgcv::s
  mgcv::bam(
    log_rt ~
      s(log10_frequency, k = k_frequency) +
      s(strokes, k = k_strokes) +
      s(subject, bs = "re"),
    data = data,
    method = "fREML",
    discrete = discrete
  )
}

predict_frequency_curve <- function(
    model,
    data,
    strokes_value = stats::median(data$strokes),
    n = 200L
) {
  freq_seq <- seq(
    from = min(data$log10_frequency),
    to = max(data$log10_frequency),
    length.out = n
  )

  baseline_subject <- levels(data$subject)[1]
  new_data <- tibble::tibble(
    log10_frequency = freq_seq,
    strokes = strokes_value,
    subject = factor(baseline_subject, levels = levels(data$subject))
  )

  preds <- stats::predict(
    model,
    newdata = new_data,
    exclude = c("s(subject)"),
    se.fit = TRUE
  )

  new_data |>
    dplyr::mutate(
      frequency = 10 ^ log10_frequency,
      fit_ms = as.numeric(exp(preds$fit)),
      lower_ms = as.numeric(exp(preds$fit - 1.96 * preds$se.fit)),
      upper_ms = as.numeric(exp(preds$fit + 1.96 * preds$se.fit))
    )
}

quantile_effects <- function(
    model,
    data,
    probs = c(0.1, 0.5, 0.9, 0.99),
    strokes_value = stats::median(data$strokes)
) {
  quantiles <- stats::quantile(data$log10_frequency, probs = probs, na.rm = TRUE)
  baseline_subject <- levels(data$subject)[1]

  new_data <- tibble::tibble(
    prob = probs,
    log10_frequency = as.numeric(quantiles),
    strokes = strokes_value,
    subject = factor(baseline_subject, levels = levels(data$subject))
  )

  preds <- stats::predict(
    model,
    newdata = new_data,
    exclude = c("s(subject)"),
    se.fit = TRUE
  )

  new_data |>
    dplyr::mutate(
      frequency = 10 ^ log10_frequency,
      fit_ms = as.numeric(exp(preds$fit)),
      lower_ms = as.numeric(exp(preds$fit - 1.96 * preds$se.fit)),
      upper_ms = as.numeric(exp(preds$fit + 1.96 * preds$se.fit))
    )
}
