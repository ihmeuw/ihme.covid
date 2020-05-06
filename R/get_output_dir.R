get_output_dir <- function(root, date) {
  if (date == "today") {
    date <- format(Sys.Date(), "%Y_%m_%d")
  }
  cur.version <- get_latest_output_date_index(root, date = date)

  dir.name <- sprintf("%s.%02i", date, cur.version + 1)
  dir.path <- file.path(root, dir.name)
  if (!dir.exists(dir.path)) {
    dir.create(dir.path, showWarnings = FALSE, recursive = TRUE, mode = "0777")
  }
  return(dir.path)
}
