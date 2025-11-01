# R/01_prepare.R
# Read trial-level SCLP slice + CLD predictors; aggregate and join.
# Input:  data/raw/sclp_sample.csv (columns: char, rt_ms, correct)
#         data/raw/cld_sample.csv  (columns: char, log_freq, strokes)
# Output: outputs/data/processed.csv

opts <- options(stringsAsFactors = FALSE)
suppressWarnings({
  dir.create(here::here("outputs","data"), recursive = TRUE, showWarnings = FALSE)
    dir.create(here::here("outputs","results"), recursive = TRUE, showWarnings = FALSE)
      dir.create(here::here("outputs","figures"), recursive = TRUE, showWarnings = FALSE)
      })

      # shared cleaning parameters and data paths
      cfg_path <- here::here("configs","cleaning.yml")
      stopifnot(file.exists(cfg_path))
      cfg <- yaml::read_yaml(cfg_path)
      stopifnot(all(c("correct_only","rt_min_ms","rt_max_ms","raw_trials","raw_type","cld_file","cld_type") %in% names(cfg)))
      correct_only <- isTRUE(cfg$correct_only)
      rt_min <- as.numeric(cfg$rt_min_ms)
      rt_max <- as.numeric(cfg$rt_max_ms)
      stopifnot(is.finite(rt_min), is.finite(rt_max), rt_min < rt_max)

      raw_trials_path <- here::here(cfg$raw_trials)
      cld_path <- here::here(cfg$cld_file)
      stopifnot(file.exists(raw_trials_path), file.exists(cld_path))

      # Load SCLP trials (support 'sclp_full' or 'sample')
      if (identical(cfg$raw_type, "sclp_full")) {
        sclp0 <- read.csv(raw_trials_path, fileEncoding = "UTF-8")
          # Expect columns: item, accuracy, rt
            stopifnot(all(c("item","accuracy","rt") %in% names(sclp0)))
              sclp <- data.frame(char = sclp0$item, rt_ms = sclp0$rt, correct = sclp0$accuracy)
              } else if (identical(cfg$raw_type, "sample")) {
                sclp <- read.csv(raw_trials_path, fileEncoding = "UTF-8")
                  stopifnot(all(c("char","rt_ms","correct") %in% names(sclp)))
                  } else {
                    stop("Unknown raw_type in configs/cleaning.yml: ", cfg$raw_type)
                    }

                    # Load CLD (support 'full' or 'sample')
                    if (identical(cfg$cld_type, "full")) {
                      cld0 <- read.csv(cld_path, fileEncoding = "UTF-8")
                        # Expect columns: Word, Length, Strokes, Frequency
                          stopifnot(all(c("Word","Length","Strokes","Frequency") %in% names(cld0)))
                            cld <- subset(cld0, Length == 1, select = c(Word, Strokes, Frequency))
                              names(cld) <- c("char","strokes","freq")
                                cld$log_freq <- log10(cld$freq + 1)
                                  cld <- cld[, c("char","log_freq","strokes")]
                                  } else if (identical(cfg$cld_type, "sample")) {
                                    cld <- read.csv(cld_path, fileEncoding = "UTF-8")
                                      stopifnot(all(c("char","log_freq","strokes") %in% names(cld)))
                                      } else {
                                        stop("Unknown cld_type in configs/cleaning.yml: ", cfg$cld_type)
                                        }

                                        ## cfg already loaded above

                                        # Basic sanity
                                        stopifnot(all(c("char","rt_ms","correct") %in% names(sclp)))
                                        stopifnot(all(c("char","log_freq","strokes") %in% names(cld)))

                                        # Trim and aggregate (shared parameters)
                                        keep <- rep(TRUE, nrow(sclp))
                                        if (correct_only) keep <- keep & sclp$correct == 1
                                        keep <- keep & sclp$rt_ms >= rt_min & sclp$rt_ms <= rt_max
                                        sclp_trim <- sclp[keep, c("char","rt_ms")]

                                        # Persist filtered trials for reuse by other steps
                                        filt_csv <- here::here("outputs","data","trials_filtered.csv")
                                        filtered_trials <- sclp[keep, c("char","rt_ms","correct")]
                                        write.csv(filtered_trials, filt_csv, row.names = FALSE, fileEncoding = "UTF-8")

                                        # mean of log RT per character
                                        agg_rt <- aggregate(rt_ms ~ char, data = sclp_trim, FUN = function(x) mean(log(x)))
                                        names(agg_rt)[2] <- "mean_log_rt"

                                        # accuracy per character from ALL trials (not just keep)
                                        agg_acc <- aggregate(correct ~ char, data = sclp[, c("char","correct")], FUN = mean)
                                        names(agg_acc)[2] <- "acc_rate"

                                        # join
                                        m1 <- merge(agg_rt, agg_acc, by = "char", all.x = TRUE)
                                        dat <- merge(m1, cld[, c("char","log_freq","strokes")], by = "char", all.x = TRUE)

                                        # drop rows missing predictors
                                        ok <- complete.cases(dat$log_freq) & complete.cases(dat$strokes)
                                        dat <- dat[ok, ]

                                        # write
                                        out_csv <- here::here("outputs","data","processed.csv")
                                        write.csv(dat, out_csv, row.names = FALSE, fileEncoding = "UTF-8")
                                        cat(sprintf("Wrote %d rows to %s\n", nrow(dat), out_csv))

                                        # Write cleaning summary YAML + histogram
                                        clean_yaml <- here::here("outputs","results","cleaning.yml")
                                        total <- nrow(sclp)
                                        kept  <- nrow(filtered_trials)
                                        dropd <- total - kept
                                        lines <- c(
                                          sprintf('timestamp: "%s"', format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")),
                                            'trimming:',
                                              sprintf('  correct_only: %s', if (correct_only) "true" else "false"),
                                                sprintf('  rt_min_ms: %s', rt_min),
                                                  sprintf('  rt_max_ms: %s', rt_max),
                                                    'counts:',
                                                      sprintf('  total_trials: %d', total),
                                                        sprintf('  kept_trials: %d',  kept),
                                                          sprintf('  dropped_trials: %d', dropd)
                                                          )
                                                          cat(paste0(lines, collapse = "\n"), "\n", file = clean_yaml)

                                                          fig_path <- here::here("outputs","figures","rt_hist.png")
                                                          png(filename = fig_path, width = 800, height = 500)
                                                          hist(
                                                            filtered_trials$rt_ms,
                                                              breaks = 40,
                                                                main = sprintf("RT histogram (kept %d/%d trials)", kept, total),
                                                                  xlab = "RT (ms)",
                                                                    col = "#4477AA"
                                                                    )
                                                                    invisible(dev.off())

                                                                    cat(sprintf("Wrote %s, %s, and %s\n", out_csv, clean_yaml, fig_path))
                                                                    