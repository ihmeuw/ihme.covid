#' Get output directory for results to save in
#'
#' Returns an appropriate path to save results in, creating it if necessary.
#'
#' @param root path to root of output results
#' @param date character date in form of "YYYY_MM_DD" or "today". "today" will be interpreted as today's date.
get_output_dir <- function(root, date) {
  if (date == "today") {
    date <- format(Sys.Date(), "%Y_%m_%d")
  }
  cur.version <- get_latest_output_date_index(root, date = date)

  dir.name <- sprintf("%s.%02i", date, cur.version + 1)
  dir.path <- file.path(root, dir.name)
  if (!dir.exists(dir.path)) {
    # handle quirk with singularity image default umask
    old.umask <- Sys.umask()
    Sys.umask("002")
    dir.create(dir.path, showWarnings = FALSE, recursive = TRUE, mode = "0777")
    Sys.umask(old.umask)
  }
  return(dir.path)
}
