# R/01_prepare.R
# Read trial-level SCLP slice + CLD predictors; aggregate and join.
# Input:  data/raw/sclp_sample.csv (columns: char, rt_ms, correct)
#         data/raw/cld_sample.csv  (columns: char, log_freq, strokes)
# Output: data/processed/merged.csv

opts <- options(stringsAsFactors = FALSE)
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

sclp <- read.csv("data/raw/sclp_sample.csv", fileEncoding = "UTF-8")
cld  <- read.csv("data/raw/cld_sample.csv",  fileEncoding = "UTF-8")

# Basic sanity
stopifnot(all(c("char","rt_ms","correct") %in% names(sclp)))
stopifnot(all(c("char","log_freq","strokes") %in% names(cld)))

# Trim and aggregate (keep correct, 200–2000 ms)
keep <- sclp$correct == 1 & sclp$rt_ms >= 200 & sclp$rt_ms <= 2000
sclp2 <- sclp[keep, c("char","rt_ms")]

# mean of log RT per character
agg_rt <- aggregate(rt_ms ~ char, data = sclp2, FUN = function(x) mean(log(x)))
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
write.csv(dat, "data/processed/merged.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("Wrote %d rows to data/processed/merged.csv\n", nrow(dat)))
