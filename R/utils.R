write_csv_atomic <- function(df, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  tmp <- paste0(path, ".tmp")
  readr::write_csv(df, tmp)
  if (fs::file_exists(path)) {
    fs::file_delete(path)
  }
  fs::file_move(tmp, path)
}

write_yaml_atomic <- function(x, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  tmp <- paste0(path, ".tmp")
  yaml::write_yaml(x, tmp)
  if (fs::file_exists(path)) {
    fs::file_delete(path)
  }
  fs::file_move(tmp, path)
}
