write_csv_atomic <- function(df, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  tmp <- paste0(path, ".tmp")
  readr::write_csv(df, tmp)
  fs::file_move(tmp, path, overwrite = TRUE)
}

write_yaml_atomic <- function(x, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  tmp <- paste0(path, ".tmp")
  yaml::write_yaml(x, tmp)
  fs::file_move(tmp, path, overwrite = TRUE)
}
