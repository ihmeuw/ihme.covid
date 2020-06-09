get_latest_output_dir <- function(root) {
  if (!dir.exists(root)) {
    stop(sprintf("root %s does not exist", root))
  }
  raw <- list.dirs(root, full.names = FALSE, recursive = FALSE)
  valid.idx <- grep("^\\d{4}_\\d{2}_\\d{2}[.]\\d{2}$", raw)
  if (length(valid.idx) == 0) {
    stop(sprintf("No YYYY_MM_DD.VV directories in %s", root))
  }
  return(file.path(root, max(raw[valid.idx])))
}
