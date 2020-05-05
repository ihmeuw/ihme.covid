#' Returns the directory the currently running script is in or NULL if all fails
#' @import rprojroot
get_script_dir <- function() {
  normalizePath(dirname(rprojroot::thisfile()))
}
