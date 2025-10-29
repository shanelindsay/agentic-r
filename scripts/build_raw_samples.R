# scripts/build_raw_samples.R
# Usage:
#   Rscript scripts/build_raw_samples.R \
#     --sclp path/to/SCLP_trials.csv --cld path/to/CLD.csv --n 120
#
# Produces:
#   data/raw/sclp_sample.csv  (trial-level subset)
#   data/raw/cld_sample.csv   (predictor subset)
#
# Notes:
# - We expect SCLP trial-level columns to include: character, RT, accuracy
# - We expect CLD columns to include: word/character form, frequency, strokes
# - We map source columns to a minimal standard: char, rt_ms, correct, log_freq, strokes
# - Licences/terms: please consult SCLP (OSF) and CLD sites before redistribution.

args <- commandArgs(trailingOnly = TRUE)
# tiny arg parser:
get_arg <- function(flag, default=NULL) {
  i <- which(args == flag)
  if (length(i) == 1 && i < length(args)) return(args[i+1])
  return(default)
}
sclp_path <- get_arg("--sclp")
cld_path  <- get_arg("--cld")
n_keep    <- as.integer(get_arg("--n", "120"))

if (is.null(sclp_path) || is.null(cld_path)) {
  stop("Please provide --sclp <file> and --cld <file>")
}

dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)

# ---- Helpers to guess columns ----
guess_col <- function(nms, candidates) {
  hit <- intersect(tolower(nms), tolower(candidates))
  if (length(hit) == 0) return(NA_character_)
  # return the original-cased name
  nms[match(hit[1], tolower(nms))]
}

# ---- Load SCLP trials ----
sclp <- read.csv(sclp_path, fileEncoding = "UTF-8")
nms  <- names(sclp)

col_char <- guess_col(nms, c("char","character","item","zi","hanzi","stimulus"))
col_rt   <- guess_col(nms, c("rt","rt_ms","reaction_time","latency"))
col_acc  <- guess_col(nms, c("acc","accuracy","correct","is_correct","response_correct"))

if (any(is.na(c(col_char,col_rt,col_acc)))) {
  stop("Could not auto-detect SCLP columns. Please rename to: char / rt_ms / correct.")
}

sclp_small <- sclp[, c(col_char, col_rt, col_acc)]
names(sclp_small) <- c("char","rt_ms","correct")

# Coerce types
sclp_small$char    <- as.character(sclp_small$char)
sclp_small$rt_ms   <- as.numeric(sclp_small$rt_ms)
sclp_small$correct <- as.integer(sclp_small$correct)

# ---- Load CLD ----
cld <- read.csv(cld_path, fileEncoding = "UTF-8")
nms2 <- names(cld)

col_form   <- guess_col(nms2, c("char","character","word","form","item"))
col_freq   <- guess_col(nms2, c("log_freq","logfrequency","logf","zipf","frequency_log"))
col_stroke <- guess_col(nms2, c("strokes","n_strokes","numstrokes","stroke"))

if (is.na(col_form))   stop("Could not detect CLD character/word column")
if (is.na(col_freq))   stop("Could not detect CLD log frequency column")
if (is.na(col_stroke)) stop("Could not detect CLD stroke count column")

cld_small <- cld[, c(col_form, col_freq, col_stroke)]
names(cld_small) <- c("char","log_freq","strokes")
cld_small$char   <- as.character(cld_small$char)

# ---- Pick overlap & downsample ----
chars_overlap <- intersect(unique(sclp_small$char), unique(cld_small$char))
set.seed(42)
keep_chars <- head(sample(chars_overlap), n_keep)

sclp_out <- sclp_small[sclp_small$char %in% keep_chars, ]
cld_out  <- cld_small[cld_small$char  %in% keep_chars, ]

# ---- Write ----
write.csv(sclp_out, "data/raw/sclp_sample.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(cld_out,  "data/raw/cld_sample.csv",  row.names = FALSE, fileEncoding = "UTF-8")

cat(sprintf("Wrote %d SCLP trials and %d CLD rows covering %d characters\n",
            nrow(sclp_out), nrow(cld_out), length(keep_chars)))
