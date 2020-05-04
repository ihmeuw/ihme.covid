#' get the latest index for given an output dir and a date
#'
#' directories are assumed to be named in YYYY_MM_DD.VV format with sane
#' year/month/date/version values.
#'
#' @param dir path to directory with versioned dirs
#' @param date character in be YYYY_MM_DD format
#'
#' @return largest version in directory tree or 0 if there are no version OR
#' the directory tree does not exist
get_latest_output_date_index <- function(dir, date) {
  currentfolders <- list.files(dir)

  # subset to date
  date_dirs <- grep(date, currentfolders, value = T)

  if (length(date_dirs) == 0) {
    return(0)
  }

  # get the index after day
  date_list <- strsplit(date_dirs, "[.]")

  inds <- unlist(lapply(date_list, function(x) x[2]))
  if (is.na(max(inds, na.rm = T))) inds <- 0

  return(max(as.numeric(inds)))
}
